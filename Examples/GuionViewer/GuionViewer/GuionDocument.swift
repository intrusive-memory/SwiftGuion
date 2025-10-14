//
//  GuionDocument.swift
//  GuionView
//
//  Phase 1: Core Document Operations
//  Copyright (c) 2025
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData
import SwiftGuion
import Combine

/// Document type for GuionView application.
///
/// Implements `FileDocument` protocol to support document-based architecture.
/// Uses lazy loading with Sendable types to avoid MainActor conflicts.
///
/// ## Architecture
///
/// The document stores an immutable `GuionParsedScreenplay` (Sendable) in nonisolated context,
/// then converts to `GuionDocumentModel` (@MainActor) on demand via accessor.
///
/// ### Concurrency Pattern
/// ```
/// Read:  FileDocument init (nonisolated) → GuionParsedScreenplay → store
/// Access: @MainActor accessor → convert to GuionDocumentModel → cache
/// Write: GuionDocumentModel → GuionParsedScreenplay → TextPack
/// ```
@MainActor
final class GuionDocument: ReferenceFileDocument {

    // MARK: - FileDocument Conformance

    static var readableContentTypes: [UTType] {
        [.guionDocument, .fountain, .highland, .fdx]
    }

    static var writableContentTypes: [UTType] {
        [.guionDocument]
    }

    // MARK: - Properties

    /// Immutable, Sendable screenplay (safe to store in nonisolated context)
    private var screenplay: GuionParsedScreenplay?

    /// Cache for converted model (MainActor-isolated)
    private var cachedModel: GuionDocumentModel?

    /// Document model for UI binding
    @Published var documentModel: GuionDocumentModel

    // MARK: - Initialization

    /// Create empty document
    init() {
        self.screenplay = GuionParsedScreenplay(
            filename: "Untitled.guion",
            elements: [],
            titlePage: [],
            suppressSceneNumbers: false
        )
        self.documentModel = GuionDocumentModel()
    }

    /// Read document from file
    required init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let contentType = configuration.contentType

        // Parse based on file type
        if contentType == .guionDocument {
            // Read .guion TextPack bundle
            self.screenplay = try TextPackReader.readTextPack(from: configuration.file)
        } else if contentType == .fountain {
            // Import .fountain file
            let content = String(data: data, encoding: .utf8) ?? ""
            self.screenplay = try GuionParsedScreenplay(string: content)
        } else if contentType == .highland {
            // Import .highland file (ZIP bundle)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try data.write(to: tempURL)
            self.screenplay = try GuionParsedScreenplay(highland: tempURL)
            try? FileManager.default.removeItem(at: tempURL)
        } else if contentType == .fdx {
            // Import .fdx file (XML)
            let parser = FDXParser()
            let parsedDoc = try parser.parse(data: data, filename: configuration.file.filename ?? "document.fdx")

            // Convert FDX elements to GuionElements
            let elements = parsedDoc.elements.map { GuionElement(from: $0) }

            // Convert title page entries
            var titlePageDict: [String: [String]] = [:]
            for entry in parsedDoc.titlePageEntries {
                titlePageDict[entry.key] = entry.values
            }
            let titlePage = titlePageDict.isEmpty ? [] : [titlePageDict]

            self.screenplay = GuionParsedScreenplay(
                filename: configuration.file.filename ?? "document.fdx",
                elements: elements,
                titlePage: titlePage,
                suppressSceneNumbers: parsedDoc.suppressSceneNumbers
            )
        } else {
            throw CocoaError(.fileReadUnsupportedScheme)
        }

        // For Phase 1, create empty model and populate filename
        self.documentModel = GuionDocumentModel()
        if let screenplay = self.screenplay {
            self.documentModel.filename = screenplay.filename
            // TODO: Phase 2 will implement full conversion with ModelContext
        }
    }

    // MARK: - Snapshot

    typealias Snapshot = FileWrapper

    func snapshot(contentType: UTType) throws -> FileWrapper {
        // Convert document model to screenplay
        let screenplay = documentModel.toGuionParsedScreenplay()

        // Create TextPack bundle
        let textPack = try TextPackWriter.createTextPack(from: screenplay)

        // Return the FileWrapper directly
        return textPack
    }

    func fileWrapper(snapshot: FileWrapper, configuration: WriteConfiguration) throws -> FileWrapper {
        // Just return the snapshot as-is
        return snapshot
    }
}

// MARK: - UTType Extensions

extension UTType {
    /// .guion file type
    static var guionDocument: UTType {
        UTType(exportedAs: "com.swiftguion.guion-document")
    }

    /// .fountain file type
    static var fountain: UTType {
        UTType(importedAs: "com.quote-unquote.fountain")
    }

    /// .highland file type
    static var highland: UTType {
        UTType(importedAs: "com.highland.highland2")
    }

    /// .fdx file type
    static var fdx: UTType {
        UTType(importedAs: "com.finaldraft.fdx")
    }
}

