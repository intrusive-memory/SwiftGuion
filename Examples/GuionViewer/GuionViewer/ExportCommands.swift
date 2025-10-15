//
//  ExportCommands.swift
//  GuionViewer
//
//  Phase 2: Export commands for read-only viewer
//  Copyright (c) 2025
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftGuion

/// Export functionality for ViewerDocument
///
/// Provides methods to export the current document to different formats:
/// - Fountain (.fountain)
/// - Final Draft (.fdx)
/// - Highland (.highland)
@MainActor
struct ExportService {

    /// Export document to Fountain format
    ///
    /// - Parameters:
    ///   - document: The document to export
    ///   - url: The destination URL
    /// - Throws: ExportError if export fails
    static func exportToFountain(document: ViewerDocument, to url: URL) throws {
        // Convert model to screenplay
        let screenplay = document.displayModel.toGuionParsedScreenplay()

        // Generate Fountain text
        let fountainText = FountainWriter.document(from: screenplay)

        // Write to file
        do {
            try fountainText.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw ExportError.writeFailed(url, underlying: error)
        }
    }

    /// Export document to Final Draft XML format
    ///
    /// - Parameters:
    ///   - document: The document to export
    ///   - url: The destination URL
    /// - Throws: ExportError if export fails
    static func exportToFDX(document: ViewerDocument, to url: URL) throws {
        // Convert model to FDX XML using the document writer
        let fdxData = FDXDocumentWriter.makeFDX(from: document.displayModel)

        // Write to file
        do {
            try fdxData.write(to: url, options: .atomic)
        } catch {
            throw ExportError.writeFailed(url, underlying: error)
        }
    }

    /// Export document to Highland format
    ///
    /// - Parameters:
    ///   - document: The document to export
    ///   - url: The destination URL
    /// - Throws: ExportError if export fails
    static func exportToHighland(document: ViewerDocument, to url: URL) throws {
        // Convert model to screenplay
        let screenplay = document.displayModel.toGuionParsedScreenplay()

        // Get the base name for the Highland bundle
        let name = url.deletingPathExtension().lastPathComponent

        // Write as Highland bundle
        do {
            try screenplay.writeToHighland(destinationURL: url, name: name)
        } catch {
            throw ExportError.writeFailed(url, underlying: error)
        }
    }

    /// Export document to native .guion format
    ///
    /// - Parameters:
    ///   - document: The document to export
    ///   - url: The destination URL
    /// - Throws: ExportError if export fails
    static func exportToGuion(document: ViewerDocument, to url: URL) throws {
        // Convert model to screenplay
        let screenplay = document.displayModel.toGuionParsedScreenplay()

        // Create TextPack
        do {
            let textPack = try TextPackWriter.createTextPack(from: screenplay)
            try textPack.write(to: url, originalContentsURL: nil)
        } catch {
            throw ExportError.writeFailed(url, underlying: error)
        }
    }

    /// Save document to its original format
    ///
    /// - Parameters:
    ///   - document: The document to save
    ///   - url: The destination URL
    /// - Throws: ExportError if save fails
    static func saveAs(document: ViewerDocument, to url: URL) throws {
        // Determine format based on document's source type
        switch document.sourceType {
        case .fountain:
            try exportToFountain(document: document, to: url)
        case .fdx:
            try exportToFDX(document: document, to: url)
        case .highland:
            try exportToHighland(document: document, to: url)
        case .guionDocument:
            try exportToGuion(document: document, to: url)
        default:
            throw ExportError.unsupportedFormat(document.sourceType)
        }
    }
}

// MARK: - Export Error Types

/// Errors that can occur during export operations
enum ExportError: LocalizedError {
    case noDocumentOpen
    case writeFailed(URL, underlying: Error)
    case unsupportedFormat(UTType)

    var errorDescription: String? {
        switch self {
        case .noDocumentOpen:
            return "No document is currently open"
        case .writeFailed(let url, _):
            return "Failed to write file: \(url.lastPathComponent)"
        case .unsupportedFormat(let type):
            return "Unsupported export format: \(type.identifier)"
        }
    }

    var failureReason: String? {
        switch self {
        case .noDocumentOpen:
            return "You must open a document before exporting."
        case .writeFailed(_, let error):
            return "The file could not be written: \(error.localizedDescription)"
        case .unsupportedFormat:
            return "This format is not supported for export."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .noDocumentOpen:
            return "Open a screenplay file and try again."
        case .writeFailed:
            return "Check that you have write permissions for the destination folder."
        case .unsupportedFormat:
            return "Try exporting to .fountain, .fdx, .highland, or .guion format."
        }
    }
}

// MARK: - Export Panel Helper

/// Helper to show save panel for export
struct ExportPanelHelper {

    /// Show save panel for exporting to a specific format
    ///
    /// - Parameters:
    ///   - contentType: The UTType for the export format
    ///   - defaultName: Default filename (without extension)
    ///   - completion: Called with the selected URL or nil if cancelled
    static func showExportPanel(
        for contentType: UTType,
        defaultName: String,
        completion: @escaping (URL?) -> Void
    ) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [contentType]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = defaultName
        panel.message = "Export screenplay as \(contentType.preferredFilenameExtension ?? "file")"

        panel.begin { response in
            if response == .OK {
                completion(panel.url)
            } else {
                completion(nil)
            }
        }
    }

    /// Show save panel for Save As operation
    ///
    /// - Parameters:
    ///   - contentType: The UTType for the save format
    ///   - defaultName: Default filename (with extension)
    ///   - originalURL: The original file URL (if any)
    ///   - completion: Called with the selected URL or nil if cancelled
    static func showSaveAsPanel(
        for contentType: UTType,
        defaultName: String,
        originalURL: URL?,
        completion: @escaping (URL?) -> Void
    ) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [contentType]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = defaultName
        panel.message = "Save screenplay as \(contentType.preferredFilenameExtension ?? "file")"

        // If there's an original file, pre-select its directory
        if let originalURL = originalURL {
            panel.directoryURL = originalURL.deletingLastPathComponent()
        }

        panel.begin { response in
            if response == .OK {
                completion(panel.url)
            } else {
                completion(nil)
            }
        }
    }

    /// Show confirmation dialog for replacing original file
    ///
    /// - Parameters:
    ///   - url: The URL being replaced
    ///   - completion: Called with true if user confirmed, false if cancelled
    static func showReplaceConfirmation(for url: URL, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Replace Original File?"
            alert.informativeText = """
            You are about to replace the original file:

            \(url.lastPathComponent)

            This action cannot be undone. The original file will be permanently replaced with the current version.
            """
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Replace")
            alert.addButton(withTitle: "Cancel")

            let response = alert.runModal()
            completion(response == .alertFirstButtonReturn)
        }
    }
}
