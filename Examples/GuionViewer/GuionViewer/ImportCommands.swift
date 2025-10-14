//
//  ImportCommands.swift
//  GuionView
//
//  Phase 1: Core Document Operations
//  Copyright (c) 2025
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftGuion

/// Import menu commands for GuionView.
///
/// Provides File → Import submenu with commands for importing .fountain, .highland, and .fdx files.
struct ImportCommands: Commands {
    var body: some Commands {
        CommandMenu("Import") {
            Button("Fountain...") {
                importFountainFile()
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])

            Button("Highland...") {
                importHighlandFile()
            }
            .keyboardShortcut("h", modifiers: [.command, .shift])

            Button("Final Draft...") {
                importFDXFile()
            }
            .keyboardShortcut("d", modifiers: [.command, .shift])
        }
    }

    // MARK: - Import Methods

    private func importFountainFile() {
        let panel = NSOpenPanel()
        panel.title = "Import Fountain File"
        panel.allowedContentTypes = [.fountain]
        panel.allowsMultipleSelection = false

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            Task { @MainActor in
                do {
                    let screenplay = try GuionParsedScreenplay(file: url.path)
                    // Phase 1: Just show success (document creation handled by app)
                    showSuccessAlert(message: "Imported \(url.lastPathComponent) with \(screenplay.elements.count) elements")
                } catch {
                    showErrorAlert(message: "Failed to import file: \(error.localizedDescription)")
                }
            }
        }
    }

    private func importHighlandFile() {
        let panel = NSOpenPanel()
        panel.title = "Import Highland File"
        panel.allowedContentTypes = [.highland]
        panel.allowsMultipleSelection = false

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            Task { @MainActor in
                do {
                    let screenplay = try GuionParsedScreenplay(highland: url)
                    // Phase 1: Just show success
                    showSuccessAlert(message: "Imported \(url.lastPathComponent) with \(screenplay.elements.count) elements")
                } catch {
                    showErrorAlert(message: "Failed to import file: \(error.localizedDescription)")
                }
            }
        }
    }

    private func importFDXFile() {
        let panel = NSOpenPanel()
        panel.title = "Import Final Draft File"
        panel.allowedContentTypes = [.fdx]
        panel.allowsMultipleSelection = false

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            Task { @MainActor in
                do {
                    let data = try Data(contentsOf: url)
                    let parser = FDXParser()
                    let parsedDoc = try parser.parse(data: data, filename: url.lastPathComponent)

                    // Convert to GuionElements
                    let elements = parsedDoc.elements.map { GuionElement(from: $0) }

                    // Convert title page
                    var titlePageDict: [String: [String]] = [:]
                    for entry in parsedDoc.titlePageEntries {
                        titlePageDict[entry.key] = entry.values
                    }
                    let titlePage = titlePageDict.isEmpty ? [] : [titlePageDict]

                    let screenplay = GuionParsedScreenplay(
                        filename: url.lastPathComponent,
                        elements: elements,
                        titlePage: titlePage,
                        suppressSceneNumbers: parsedDoc.suppressSceneNumbers
                    )

                    // Phase 1: Just show success
                    showSuccessAlert(message: "Imported \(url.lastPathComponent) with \(screenplay.elements.count) elements")
                } catch {
                    showErrorAlert(message: "Failed to import file: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Alert Helpers

    private func showSuccessAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Import Successful"
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func showErrorAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = "Import Failed"
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
