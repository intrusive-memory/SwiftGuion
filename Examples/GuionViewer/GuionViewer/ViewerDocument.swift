//
//  ViewerDocument.swift
//  GuionViewer
//
//  Read-only document viewer for screenplay files
//  Phase 1: Core read-only viewing
//  Copyright (c) 2025
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import SwiftGuion

/// Document model for read-only screenplay viewing.
///
/// ViewerDocument implements a read-only viewer pattern similar to Preview.app:
/// - Files are loaded into memory and never modified
/// - Original files remain untouched unless explicitly saved via "Save As → Replace"
/// - All modifications (like generated summaries) are transient until exported
/// - No auto-save, no file monitoring
///
/// ## Architecture
///
/// ```
/// File (read-only) → GuionParsedScreenplay → ViewerDocument
///                                            ├─ sourceURL (original)
///                                            ├─ screenplay (immutable)
///                                            └─ displayModel (in-memory SwiftData)
///                                                   ↓
///                                            GuionViewer UI
/// ```
@Observable
@MainActor
final class ViewerDocument {

    // MARK: - Properties

    /// Original file URL (read-only reference, never modified)
    let sourceURL: URL?

    /// Original file type
    let sourceType: UTType

    /// Original filename (for display)
    let originalFilename: String

    /// Parsed screenplay (immutable, Sendable)
    private(set) var screenplay: GuionParsedScreenplay

    /// Display model for UI binding (in-memory SwiftData)
    private(set) var displayModel: GuionDocumentModel

    /// SwiftData model context (in-memory only, not persisted)
    private let modelContext: ModelContext

    // MARK: - Initialization

    /// Create an empty untitled document
    init() {
        self.sourceURL = nil
        self.sourceType = .guionDocument
        self.originalFilename = "Untitled"

        self.screenplay = GuionParsedScreenplay(
            filename: "Untitled.guion",
            elements: [],
            titlePage: [],
            suppressSceneNumbers: false
        )

        // Create in-memory SwiftData context
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        self.modelContext = ModelContext(container)

        self.displayModel = GuionDocumentModel(filename: "Untitled.guion")
        modelContext.insert(displayModel)
    }

    /// Load a document from a file URL (read-only)
    ///
    /// The file is read once and never modified. All changes happen in-memory only.
    ///
    /// - Parameter url: File URL to load
    /// - Throws: ViewerDocumentError if the file cannot be read or parsed
    init(contentsOf url: URL) throws {
        self.sourceURL = url
        self.originalFilename = url.lastPathComponent

        // Detect file type from extension
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "guion":
            self.sourceType = .guionDocument
        case "fountain":
            self.sourceType = .fountain
        case "fdx":
            self.sourceType = .fdx
        case "highland":
            self.sourceType = .highland
        default:
            throw ViewerDocumentError.unsupportedFileType(pathExtension)
        }

        // Parse file based on type (read-only)
        let parsedScreenplay: GuionParsedScreenplay
        do {
            switch sourceType {
            case .guionDocument:
                // Read .guion TextPack bundle
                let fileWrapper = try FileWrapper(url: url)
                parsedScreenplay = try TextPackReader.readTextPack(from: fileWrapper)

            case .fountain:
                // Import .fountain file (plain text)
                let content = try String(contentsOf: url, encoding: .utf8)
                parsedScreenplay = try GuionParsedScreenplay(string: content)

            case .fdx:
                // Import .fdx file (XML)
                let data = try Data(contentsOf: url)
                let parser = FDXParser()
                let parsedDoc = try parser.parse(data: data, filename: url.lastPathComponent)

                // Convert FDX elements to GuionElements
                let elements = parsedDoc.elements.map { GuionElement(from: $0) }

                // Convert title page entries
                var titlePageDict: [String: [String]] = [:]
                for entry in parsedDoc.titlePageEntries {
                    titlePageDict[entry.key] = entry.values
                }
                let titlePage = titlePageDict.isEmpty ? [] : [titlePageDict]

                parsedScreenplay = GuionParsedScreenplay(
                    filename: url.lastPathComponent,
                    elements: elements,
                    titlePage: titlePage,
                    suppressSceneNumbers: parsedDoc.suppressSceneNumbers
                )

            case .highland:
                // Import .highland file (bundle)
                parsedScreenplay = try GuionParsedScreenplay(highland: url)

            default:
                throw ViewerDocumentError.unsupportedFileType(pathExtension)
            }
        } catch {
            throw ViewerDocumentError.loadFailed(url, underlying: error)
        }

        // Create in-memory SwiftData context
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            self.modelContext = ModelContext(container)
        } catch {
            throw ViewerDocumentError.modelContextFailed(underlying: error)
        }

        // Now initialize remaining stored properties
        self.screenplay = parsedScreenplay
        self.displayModel = GuionDocumentModel(from: parsedScreenplay)
        modelContext.insert(displayModel)
    }

    // MARK: - Computed Properties

    /// Check if the document has summary elements
    var hasSummaries: Bool {
        displayModel.elements.contains { element in
            element.elementType == "Section Heading" &&
            element.sectionDepth == 4 &&
            element.elementText.trimmingCharacters(in: .whitespaces).hasPrefix("SUMMARY:")
        }
    }

    /// Count of scenes in the document
    var sceneCount: Int {
        displayModel.elements.filter { $0.elementType == "Scene Heading" }.count
    }

    /// Document title (from title page or filename)
    var title: String {
        if let titleEntry = displayModel.titlePage.first(where: { $0.key.lowercased() == "title" }),
           let titleValue = titleEntry.values.first, !titleValue.isEmpty {
            return titleValue
        }
        return originalFilename
    }
}

// MARK: - Error Types

/// Errors that can occur when loading or working with ViewerDocument
enum ViewerDocumentError: LocalizedError {
    case unsupportedFileType(String)
    case loadFailed(URL, underlying: Error)
    case modelContextFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .unsupportedFileType(let ext):
            return "Unsupported file type: .\(ext)"
        case .loadFailed(let url, _):
            return "Failed to load file: \(url.lastPathComponent)"
        case .modelContextFailed:
            return "Failed to create in-memory model context"
        }
    }

    var failureReason: String? {
        switch self {
        case .unsupportedFileType(let ext):
            return "The file extension '.\(ext)' is not supported by GuionViewer."
        case .loadFailed(_, let error):
            return "The file could not be read or parsed: \(error.localizedDescription)"
        case .modelContextFailed(let error):
            return "Could not initialize SwiftData model context: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .unsupportedFileType:
            return "GuionViewer supports .guion, .fountain, .fdx, and .highland files."
        case .loadFailed:
            return "Check that the file is valid and not corrupted."
        case .modelContextFailed:
            return "Try restarting the application."
        }
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

// MARK: - GuionDocumentModel Extension

extension GuionDocumentModel {
    /// Create a GuionDocumentModel from a GuionParsedScreenplay (sample app version)
    ///
    /// This is a simplified conversion for the sample app that doesn't use SwiftData's
    /// full `from(_:in:generateSummaries:)` method since we don't need async summarization
    /// during document loading.
    ///
    /// - Parameter screenplay: The screenplay to convert
    /// - Returns: A GuionDocumentModel with all elements converted
    convenience init(from screenplay: GuionParsedScreenplay) {
        self.init(
            filename: screenplay.filename,
            rawContent: screenplay.stringFromDocument(),
            suppressSceneNumbers: screenplay.suppressSceneNumbers
        )

        // Convert title page entries
        for dictionary in screenplay.titlePage {
            for (key, values) in dictionary {
                let entry = TitlePageEntryModel(key: key, values: values)
                entry.document = self
                self.titlePage.append(entry)
            }
        }

        // Convert elements
        for element in screenplay.elements {
            let elementModel = GuionElementModel(from: element)
            elementModel.document = self
            self.elements.append(elementModel)
        }
    }
}
