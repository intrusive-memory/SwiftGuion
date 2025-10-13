//
//  GuionDocumentParserSwiftData.swift
//  SwiftFountain
//

import Foundation
#if canImport(SwiftData)
import SwiftData

// GuionElementSnapshot is now obsolete - use GuionElement directly with protocol-based conversion

public struct GuionTitleEntrySnapshot {
    public let key: String
    public let values: [String]

    public init(key: String, values: [String]) {
        self.key = key
        self.values = values
    }
}

public enum GuionDocumentParserError: Error {
    case unsupportedFileType(String)
    case invalidFDX
}

public class GuionDocumentParserSwiftData {

    /// Parse a GuionParsedScreenplay into SwiftData models
    /// - Parameters:
    ///   - script: The GuionParsedScreenplay to parse
    ///   - modelContext: The ModelContext to use
    ///   - generateSummaries: Whether to generate AI summaries for scene headings (default: false)
    /// - Returns: The created GuionDocumentModel
    @MainActor
    public static func parse(script: GuionParsedScreenplay, in modelContext: ModelContext, generateSummaries: Bool = false) async -> GuionDocumentModel {
        let titlePageEntries = script.titlePage.flatMap { dictionary in
            dictionary.map { GuionTitleEntrySnapshot(key: $0.key, values: $0.value) }
        }

        // Generate summaries for scene headings if requested
        var elementsWithSummaries: [(element: GuionElement, summary: String?)] = []

        if generateSummaries {
            let outline = script.extractOutline()

            for element in script.elements {
                var summary: String? = nil

                // Generate summary only for Scene Heading elements
                if element.elementType == "Scene Heading" {
                    // Find the corresponding outline element by UUID (handles duplicate headings)
                    if let sceneId = element.sceneId,
                       let scene = outline.first(where: { $0.sceneId == sceneId }) {
                        summary = await SceneSummarizer.summarizeScene(scene, from: script, outline: outline)
                    }
                }

                elementsWithSummaries.append((element, summary))
            }
        } else {
            elementsWithSummaries = script.elements.map { ($0, nil) }
        }

        return buildModel(
            filename: script.filename,
            rawContent: script.stringFromDocument(),
            suppressSceneNumbers: script.suppressSceneNumbers,
            titlePageEntries: titlePageEntries,
            elementsWithSummaries: elementsWithSummaries,
            in: modelContext
        )
    }

    /// Load a guion document from URL and parse into SwiftData
    /// - Parameters:
    ///   - url: The URL of the document
    ///   - modelContext: The ModelContext to use
    ///   - generateSummaries: Whether to generate AI summaries for scene headings (default: false)
    /// - Returns: The created GuionDocumentModel
    /// - Throws: Parsing errors
    @MainActor
    public static func loadAndParse(from url: URL, in modelContext: ModelContext, generateSummaries: Bool = false) async throws -> GuionDocumentModel {
        let pathExtension = url.pathExtension.lowercased()

        switch pathExtension {
        case "highland":
            let script = try GuionParsedScreenplay(highland: url)
            return await parse(script: script, in: modelContext, generateSummaries: generateSummaries)
        case "textbundle":
            let script = try GuionParsedScreenplay(textBundle: url)
            return await parse(script: script, in: modelContext, generateSummaries: generateSummaries)
        case "fountain":
            let script = try GuionParsedScreenplay(file: url.path)
            return await parse(script: script, in: modelContext, generateSummaries: generateSummaries)
        case "fdx":
            let data = try Data(contentsOf: url)
            let parser = FDXDocumentParser()
            do {
                let parsed = try parser.parse(data: data, filename: url.lastPathComponent)
                let elements = parsed.elements.map { GuionElement(from: $0) }
                return buildModel(
                    filename: parsed.filename,
                    rawContent: parsed.rawXML,
                    suppressSceneNumbers: parsed.suppressSceneNumbers,
                    titlePageEntries: parsed.titlePageEntries.map { entry in
                        GuionTitleEntrySnapshot(key: entry.key, values: entry.values)
                    },
                    elementsWithSummaries: elements.map { ($0, nil) },
                    in: modelContext
                )
            } catch {
                throw GuionDocumentParserError.invalidFDX
            }
        default:
            throw GuionDocumentParserError.unsupportedFileType(pathExtension)
        }
    }

    /// Convert a SwiftData model back to a GuionParsedScreenplay
    /// - Parameter model: The GuionDocumentModel to convert
    /// - Returns: A GuionParsedScreenplay instance
    public static func toFountainScript(from model: GuionDocumentModel) -> GuionParsedScreenplay {
        // Convert title page
        let titlePageArray: [[String: [String]]] = model.titlePage.map { entry in
            [entry.key: entry.values]
        }

        // Convert elements using protocol-based conversion
        let elements = model.elements.map { GuionElement(from: $0) }

        // Create screenplay with all properties
        return GuionParsedScreenplay(
            filename: model.filename,
            elements: elements,
            titlePage: titlePageArray,
            suppressSceneNumbers: model.suppressSceneNumbers
        )
    }

    /// Convert a SwiftData model into FDX data
    /// - Parameter model: The GuionDocumentModel to convert
    /// - Returns: XML data representing the guion in FDX format
    public static func toFDXData(from model: GuionDocumentModel) -> Data {
        return FDXDocumentWriter.makeFDX(from: model)
    }

    @MainActor
    private static func buildModel(
        filename: String?,
        rawContent: String?,
        suppressSceneNumbers: Bool,
        titlePageEntries: [GuionTitleEntrySnapshot],
        elementsWithSummaries: [(element: GuionElement, summary: String?)],
        in modelContext: ModelContext
    ) -> GuionDocumentModel {
        let documentModel = GuionDocumentModel(
            filename: filename,
            rawContent: rawContent,
            suppressSceneNumbers: suppressSceneNumbers
        )

        for entry in titlePageEntries {
            let titlePageEntry = TitlePageEntryModel(key: entry.key, values: entry.values)
            titlePageEntry.document = documentModel
            documentModel.titlePage.append(titlePageEntry)
        }

        for (element, summary) in elementsWithSummaries {
            // Use protocol-based conversion with summary
            let elementModel = GuionElementModel(from: element, summary: summary)
            elementModel.document = documentModel
            documentModel.elements.append(elementModel)
        }

        modelContext.insert(documentModel)
        return documentModel
    }
}
#endif
