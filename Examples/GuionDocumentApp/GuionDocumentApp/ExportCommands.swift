//
//  ExportCommands.swift
//  GuionDocumentApp
//
//  Copyright (c) 2025
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftGuion
#if canImport(AppKit)
import AppKit
#endif

struct ExportCommands: Commands {
    @FocusedValue(\.document) var document: GuionDocument?

    var body: some Commands {
        #if os(macOS)
        CommandMenu("Export") {
            Button("Export as Fountain...") {
                exportAsFountain()
            }
            .keyboardShortcut("E", modifiers: [.command, .shift])
            .disabled(document == nil)

            Button("Export as Highland...") {
                exportAsHighland()
            }
            .disabled(document == nil)

            Button("Export as Final Draft (FDX)...") {
                exportAsFDX()
            }
            .disabled(document == nil)

            Divider()

            Button("Export All Formats...") {
                exportAllFormats()
            }
            .disabled(document == nil)
        }
        #endif
    }

    #if os(macOS)
    private func exportAsFountain() {
        guard let document = document else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.fountain]
        savePanel.nameFieldStringValue = (document.documentModel.filename as? NSString)?
            .deletingPathExtension ?? "Untitled"
        savePanel.nameFieldStringValue += ".fountain"

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }

            do {
                let fountainText = document.exportToFountain()
                try fountainText.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                showError(error, format: "Fountain")
            }
        }
    }

    private func exportAsHighland() {
        guard let document = document else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.highland]
        savePanel.nameFieldStringValue = (document.documentModel.filename as? NSString)?
            .deletingPathExtension ?? "Untitled"
        savePanel.nameFieldStringValue += ".highland"

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }

            do {
                let highlandText = document.exportToHighland()
                try highlandText.write(to: url, atomically: true, encoding: .utf8)
            } catch {
                showError(error, format: "Highland")
            }
        }
    }

    private func exportAsFDX() {
        guard let document = document else { return }

        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.fdx]
        savePanel.nameFieldStringValue = (document.documentModel.filename as? NSString)?
            .deletingPathExtension ?? "Untitled"
        savePanel.nameFieldStringValue += ".fdx"

        savePanel.begin { response in
            guard response == .OK, let url = savePanel.url else { return }

            do {
                let fdxData = document.exportToFDX()
                try fdxData.write(to: url, options: .atomic)
            } catch {
                showError(error, format: "Final Draft")
            }
        }
    }

    private func exportAllFormats() {
        guard let document = document else { return }

        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.prompt = "Export to Folder"
        openPanel.message = "Choose a folder to export all formats"

        openPanel.begin { response in
            guard response == .OK, let directoryURL = openPanel.url else { return }

            let baseName = (document.documentModel.filename as? NSString)?
                .deletingPathExtension ?? "Untitled"

            do {
                // Export Fountain
                let fountainURL = directoryURL.appendingPathComponent("\(baseName).fountain")
                let fountainText = document.exportToFountain()
                try fountainText.write(to: fountainURL, atomically: true, encoding: .utf8)

                // Export Highland
                let highlandURL = directoryURL.appendingPathComponent("\(baseName).highland")
                let highlandText = document.exportToHighland()
                try highlandText.write(to: highlandURL, atomically: true, encoding: .utf8)

                // Export FDX
                let fdxURL = directoryURL.appendingPathComponent("\(baseName).fdx")
                let fdxData = document.exportToFDX()
                try fdxData.write(to: fdxURL, options: .atomic)

                // Show success notification
                let alert = NSAlert()
                alert.messageText = "Export Successful"
                alert.informativeText = "All formats exported to:\n\(directoryURL.path)"
                alert.alertStyle = .informational
                alert.runModal()

            } catch {
                showError(error, format: "all formats")
            }
        }
    }

    private func showError(_ error: Error, format: String) {
        let alert = NSAlert()
        alert.messageText = "Export Failed"
        alert.informativeText = "Could not export as \(format):\n\(error.localizedDescription)"
        alert.alertStyle = .critical
        alert.runModal()
    }
    #endif
}

// FocusedValues extension to access the current document
extension FocusedValues {
    struct DocumentKey: FocusedValueKey {
        typealias Value = GuionDocument
    }

    var document: DocumentKey.Value? {
        get { self[DocumentKey.self] }
        set { self[DocumentKey.self] = newValue }
    }
}
