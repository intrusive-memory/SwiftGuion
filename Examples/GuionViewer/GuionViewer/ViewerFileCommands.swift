//
//  ViewerFileCommands.swift
//  GuionViewer
//
//  File menu commands for read-only viewer
//  Phase 1: Open (read-only), Close, Save (disabled)
//  Copyright (c) 2025
//

import SwiftUI
import UniformTypeIdentifiers

/// File menu commands for GuionViewer.
///
/// Implements a read-only viewer pattern where:
/// - "Open..." loads files in read-only mode
/// - "Save" is disabled (no editing, no auto-save)
/// - "Close" closes the current document
/// - Export and Save As will be added in Phase 2
struct ViewerFileCommands: Commands {
    @Bindable var documentManager: DocumentManager

    var body: some Commands {
        // Replace default File menu commands
        CommandGroup(replacing: .newItem) {
            // New is not applicable for a viewer
            // (or could create empty untitled document)
        }

        CommandGroup(replacing: .saveItem) {
            // Save is disabled (read-only viewer)
            Button("Save") {
                // No action
            }
            .keyboardShortcut("s")
            .disabled(true)
            .help("Save is not available in read-only mode")

            Divider()

            // Save As submenu (with all formats, .guion as default)
            Menu("Save As...") {
                Button("Guion (.guion)") {
                    saveAsGuion()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])

                Divider()

                Button("Fountain (.fountain)") {
                    saveAsFountain()
                }

                Button("Final Draft (.fdx)") {
                    saveAsFDX()
                }

                Button("Highland (.highland)") {
                    saveAsHighland()
                }
            }
            .disabled(documentManager.currentDocument == nil)
        }

        CommandGroup(after: .newItem) {
            // Open file (read-only)
            Button("Open...") {
                openFile()
            }
            .keyboardShortcut("o")

            Divider()

            // Close current document
            Button("Close") {
                documentManager.closeDocument()
            }
            .keyboardShortcut("w")
            .disabled(documentManager.currentDocument == nil)
        }
    }

    /// Show open panel and load selected file
    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [
            .guionDocument,
            .fountain,
            .fdx,
            .highland
        ]
        panel.message = "Choose a screenplay file to view"

        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }

            do {
                try documentManager.openFile(url)
            } catch let error as ViewerDocumentError {
                // Show error alert
                showError(error)
            } catch {
                // Show generic error
                showError(ViewerDocumentError.loadFailed(url, underlying: error))
            }
        }
    }

    /// Show error alert
    private func showError(_ error: ViewerDocumentError) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = error.errorDescription ?? "Error"
            alert.informativeText = error.failureReason ?? ""
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")

            if let suggestion = error.recoverySuggestion {
                alert.informativeText += "\n\n\(suggestion)"
            }

            alert.runModal()
        }
    }

    /// Show export error alert
    private func showExportError(_ error: ExportError) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = error.errorDescription ?? "Export Error"
            alert.informativeText = error.failureReason ?? ""
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")

            if let suggestion = error.recoverySuggestion {
                alert.informativeText += "\n\n\(suggestion)"
            }

            alert.runModal()
        }
    }

    // MARK: - Export Methods

    /// Export current document to Fountain format
    private func exportToFountain() {
        guard let document = documentManager.currentDocument else {
            showExportError(.noDocumentOpen)
            return
        }

        let defaultName = document.title.replacingOccurrences(of: ".", with: "_")
        ExportPanelHelper.showExportPanel(for: .fountain, defaultName: defaultName) { url in
            guard let url = url else { return }

            do {
                try ExportService.exportToFountain(document: document, to: url)
            } catch let error as ExportError {
                self.showExportError(error)
            } catch {
                self.showExportError(.writeFailed(url, underlying: error))
            }
        }
    }

    /// Export current document to FDX format
    private func exportToFDX() {
        guard let document = documentManager.currentDocument else {
            showExportError(.noDocumentOpen)
            return
        }

        let defaultName = document.title.replacingOccurrences(of: ".", with: "_")
        ExportPanelHelper.showExportPanel(for: .fdx, defaultName: defaultName) { url in
            guard let url = url else { return }

            do {
                try ExportService.exportToFDX(document: document, to: url)
            } catch let error as ExportError {
                self.showExportError(error)
            } catch {
                self.showExportError(.writeFailed(url, underlying: error))
            }
        }
    }

    /// Export current document to Highland format
    private func exportToHighland() {
        guard let document = documentManager.currentDocument else {
            showExportError(.noDocumentOpen)
            return
        }

        let defaultName = document.title.replacingOccurrences(of: ".", with: "_")
        ExportPanelHelper.showExportPanel(for: .highland, defaultName: defaultName) { url in
            guard let url = url else { return }

            do {
                try ExportService.exportToHighland(document: document, to: url)
            } catch let error as ExportError {
                self.showExportError(error)
            } catch {
                self.showExportError(.writeFailed(url, underlying: error))
            }
        }
    }

    /// Export current document to Guion format
    private func exportToGuion() {
        guard let document = documentManager.currentDocument else {
            showExportError(.noDocumentOpen)
            return
        }

        let defaultName = document.title.replacingOccurrences(of: ".", with: "_")
        ExportPanelHelper.showExportPanel(for: .guionDocument, defaultName: defaultName) { url in
            guard let url = url else { return }

            do {
                try ExportService.exportToGuion(document: document, to: url)
            } catch let error as ExportError {
                self.showExportError(error)
            } catch {
                self.showExportError(.writeFailed(url, underlying: error))
            }
        }
    }

    // MARK: - Save As Methods

    /// Save As Guion format
    private func saveAsGuion() {
        saveAs(format: .guionDocument, exportMethod: ExportService.exportToGuion)
    }

    /// Save As Fountain format
    private func saveAsFountain() {
        saveAs(format: .fountain, exportMethod: ExportService.exportToFountain)
    }

    /// Save As FDX format
    private func saveAsFDX() {
        saveAs(format: .fdx, exportMethod: ExportService.exportToFDX)
    }

    /// Save As Highland format
    private func saveAsHighland() {
        saveAs(format: .highland, exportMethod: ExportService.exportToHighland)
    }

    /// Generic Save As implementation
    private func saveAs(
        format: UTType,
        exportMethod: @escaping (ViewerDocument, URL) throws -> Void
    ) {
        guard let document = documentManager.currentDocument else {
            showExportError(.noDocumentOpen)
            return
        }

        let defaultName = document.title.replacingOccurrences(of: ".", with: "_")
        ExportPanelHelper.showSaveAsPanel(
            for: format,
            defaultName: defaultName,
            originalURL: document.sourceURL
        ) { url in
            guard let url = url else { return }

            // Check if user is replacing the original file
            let isReplacingOriginal = url == document.sourceURL

            if isReplacingOriginal {
                // Show confirmation dialog
                ExportPanelHelper.showReplaceConfirmation(for: url) { confirmed in
                    if confirmed {
                        self.performSaveAs(document: document, to: url, using: exportMethod)
                    }
                }
            } else {
                // Save to different location (no confirmation needed)
                self.performSaveAs(document: document, to: url, using: exportMethod)
            }
        }
    }

    /// Perform the actual save operation
    private func performSaveAs(
        document: ViewerDocument,
        to url: URL,
        using exportMethod: (ViewerDocument, URL) throws -> Void
    ) {
        do {
            try exportMethod(document, url)
            // Optionally show success notification
        } catch let error as ExportError {
            showExportError(error)
        } catch {
            showExportError(.writeFailed(url, underlying: error))
        }
    }
}
