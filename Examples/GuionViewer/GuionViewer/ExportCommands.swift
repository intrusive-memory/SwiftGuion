//
//  ExportCommands.swift
//  GuionView
//
//  Phase 1: Core Document Operations
//  Copyright (c) 2025
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftGuion

/// Export menu commands for GuionView.
///
/// Provides File → Export submenu with commands for exporting to .fountain, .highland, and .fdx formats.
struct ExportCommands: Commands {
    @FocusedBinding(\.document) var document: GuionDocument?

    var body: some Commands {
        CommandMenu("Export") {
            Button("Fountain...") {
                exportToFountain()
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(document == nil)

            Button("Highland...") {
                exportToHighland()
            }
            .keyboardShortcut("h", modifiers: [.command, .option])
            .disabled(document == nil)

            Button("Final Draft...") {
                exportToFDX()
            }
            .keyboardShortcut("d", modifiers: [.command, .option])
            .disabled(document == nil)
        }
    }

    // MARK: - Export Methods

    private func exportToFountain() {
        guard let document = document else { return }

        let panel = NSSavePanel()
        panel.title = "Export to Fountain"
        panel.allowedContentTypes = [.fountain]
        panel.nameFieldStringValue = document.documentModel.filename.replacingOccurrences(of: ".guion", with: ".fountain")

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            Task { @MainActor in
                do {
                    let screenplay = document.documentModel.toGuionParsedScreenplay()
                    let fountainText = screenplay.stringFromDocument()
                    try fountainText.write(to: url, atomically: true, encoding: .utf8)

                    showSuccessAlert(message: "Exported to \(url.lastPathComponent)")
                } catch {
                    showErrorAlert(message: "Failed to export: \(error.localizedDescription)")
                }
            }
        }
    }

    private func exportToHighland() {
        guard let document = document else { return }

        let panel = NSSavePanel()
        panel.title = "Export to Highland"
        panel.allowedContentTypes = [.highland]
        panel.nameFieldStringValue = document.documentModel.filename.replacingOccurrences(of: ".guion", with: ".highland")

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            Task { @MainActor in
                do {
                    let screenplay = document.documentModel.toGuionParsedScreenplay()
                    // Highland is TextBundle ZIP format with .fountain content
                    // For now, use TextPackWriter pattern but create Highland structure
                    // TODO: Implement proper Highland export
                    throw NSError(domain: "GuionView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Highland export not yet implemented in Phase 1"])
                } catch {
                    showErrorAlert(message: "Failed to export: \(error.localizedDescription)")
                }
            }
        }
    }

    private func exportToFDX() {
        guard let document = document else { return }

        let panel = NSSavePanel()
        panel.title = "Export to Final Draft"
        panel.allowedContentTypes = [.fdx]
        panel.nameFieldStringValue = document.documentModel.filename.replacingOccurrences(of: ".guion", with: ".fdx")

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            Task { @MainActor in
                do {
                    let screenplay = document.documentModel.toGuionParsedScreenplay()
                    let fdxData = FDXDocumentWriter.write(screenplay)
                    try fdxData.write(to: url, atomically: true)

                    showSuccessAlert(message: "Exported to \(url.lastPathComponent)")
                } catch {
                    showErrorAlert(message: "Failed to export: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Alert Helpers

    private func showSuccessAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Export Successful"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Export Failed"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Copy Error")
        let response = alert.runModal()

        if response == .alertSecondButtonReturn {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(message, forType: .string)
        }
    }
}

// MARK: - FocusedValues Extension

extension FocusedValues {
    var document: FocusedBinding<GuionDocument> {
        get { self[DocumentKey.self] }
        set { self[DocumentKey.self] = newValue }
    }

    private struct DocumentKey: FocusedValueKey {
        typealias Value = Binding<GuionDocument>
    }
}
