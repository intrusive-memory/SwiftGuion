//
//  GuionDocumentParserSwiftData.swift
//  SwiftFountain
//

import Foundation
#if canImport(SwiftData)
import SwiftData

public struct GuionElementSnapshot {
    public let elementText: String
    public let elementType: String
    public let isCentered: Bool
    public let isDualDialogue: Bool
    public let sceneNumber: String?
    public let sectionDepth: Int
    public let summary: String?
    public let sceneId: String?

    public init(elementText: String, elementType: String, isCentered: Bool, isDualDialogue: Bool, sceneNumber: String?, sectionDepth: Int, summary: String? = nil, sceneId: String? = nil) {
        self.elementText = elementText
        self.elementType = elementType
        self.isCentered = isCentered
        self.isDualDialogue = isDualDialogue
        self.sceneNumber = sceneNumber
        self.sectionDepth = sectionDepth
        self.summary = summary
        self.sceneId = sceneId
    }
}

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

    /// Parse a FountainScript into SwiftData models
    /// - Parameters:
    ///   - script: The FountainScript to parse
    ///   - modelContext: The ModelContext to use
    ///   - generateSummaries: Whether to generate AI summaries for scene headings (default: false)
    /// - Returns: The created GuionDocumentModel
    public static func parse(script: FountainScript, in modelContext: ModelContext, generateSummaries: Bool = false) async -> GuionDocumentModel {
        let titlePageEntries = script.titlePage.flatMap { dictionary in
            dictionary.map { GuionTitleEntrySnapshot(key: $0.key, values: $0.value) }
        }

        // Generate summaries for scene headings if requested
        var elementSnapshots: [GuionElementSnapshot] = []

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

                elementSnapshots.append(GuionElementSnapshot(
                    elementText: element.elementText,
                    elementType: element.elementType,
                    isCentered: element.isCentered,
                    isDualDialogue: element.isDualDialogue,
                    sceneNumber: element.sceneNumber,
                    sectionDepth: Int(element.sectionDepth),
                    summary: summary,
                    sceneId: element.sceneId
                ))
            }
        } else {
            elementSnapshots = script.elements.map { element in
                GuionElementSnapshot(
                    elementText: element.elementText,
                    elementType: element.elementType,
                    isCentered: element.isCentered,
                    isDualDialogue: element.isDualDialogue,
                    sceneNumber: element.sceneNumber,
                    sectionDepth: Int(element.sectionDepth),
                    sceneId: element.sceneId
                )
            }
        }

        return buildModel(
            filename: script.filename,
            rawContent: script.stringFromDocument(),
            suppressSceneNumbers: script.suppressSceneNumbers,
            titlePageEntries: titlePageEntries,
            elementSnapshots: elementSnapshots,
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
    public static func loadAndParse(from url: URL, in modelContext: ModelContext, generateSummaries: Bool = false) async throws -> GuionDocumentModel {
        let pathExtension = url.pathExtension.lowercased()

        switch pathExtension {
        case "highland":
            let script = FountainScript()
            try script.loadHighland(url)
            return await parse(script: script, in: modelContext, generateSummaries: generateSummaries)
        case "textbundle":
            let script = FountainScript()
            try script.loadTextBundle(url)
            return await parse(script: script, in: modelContext, generateSummaries: generateSummaries)
        case "fountain":
            let script = FountainScript()
            try script.loadFile(url.path)
            return await parse(script: script, in: modelContext, generateSummaries: generateSummaries)
        case "fdx":
            let data = try Data(contentsOf: url)
            let parser = FDXDocumentParser()
            do {
                let parsed = try parser.parse(data: data, filename: url.lastPathComponent)
                return buildModel(
                    filename: parsed.filename,
                    rawContent: parsed.rawXML,
                    suppressSceneNumbers: parsed.suppressSceneNumbers,
                    titlePageEntries: parsed.titlePageEntries.map { entry in
                        GuionTitleEntrySnapshot(key: entry.key, values: entry.values)
                    },
                    elementSnapshots: parsed.elements.map { element in
                        GuionElementSnapshot(
                            elementText: element.elementText,
                            elementType: element.elementType,
                            isCentered: element.isCentered,
                            isDualDialogue: element.isDualDialogue,
                            sceneNumber: element.sceneNumber,
                            sectionDepth: element.sectionDepth,
                            sceneId: element.sceneId
                        )
                    },
                    in: modelContext
                )
            } catch {
                throw GuionDocumentParserError.invalidFDX
            }
        default:
            throw GuionDocumentParserError.unsupportedFileType(pathExtension)
        }
    }

    /// Convert a SwiftData model back to a FountainScript
    /// - Parameter model: The GuionDocumentModel to convert
    /// - Returns: A FountainScript instance
    public static func toFountainScript(from model: GuionDocumentModel) -> FountainScript {
        let script = FountainScript()

        // Set basic properties
        script.filename = model.filename
        script.suppressSceneNumbers = model.suppressSceneNumbers

        // Convert title page
        let titlePageArray: [[String: [String]]] = model.titlePage.map { entry in
            [entry.key: entry.values]
        }
        script.titlePage = titlePageArray

        // Convert elements
        for elementModel in model.elements {
            let element = GuionElement(
                elementType: elementModel.elementType,
                elementText: elementModel.elementText
            )
            element.isCentered = elementModel.isCentered
            element.isDualDialogue = elementModel.isDualDialogue
            element.sceneNumber = elementModel.sceneNumber
            element.sectionDepth = UInt(elementModel.sectionDepth)
            element.sceneId = elementModel.sceneId
            script.elements.append(element)
        }

        return script
    }

    /// Convert a SwiftData model into FDX data
    /// - Parameter model: The GuionDocumentModel to convert
    /// - Returns: XML data representing the guion in FDX format
    public static func toFDXData(from model: GuionDocumentModel) -> Data {
        return FDXDocumentWriter.makeFDX(from: model)
    }

    private static func buildModel(
        filename: String?,
        rawContent: String?,
        suppressSceneNumbers: Bool,
        titlePageEntries: [GuionTitleEntrySnapshot],
        elementSnapshots: [GuionElementSnapshot],
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

        for snapshot in elementSnapshots {
            let elementModel = GuionElementModel(
                elementText: snapshot.elementText,
                elementType: snapshot.elementType,
                isCentered: snapshot.isCentered,
                isDualDialogue: snapshot.isDualDialogue,
                sceneNumber: snapshot.sceneNumber,
                sectionDepth: snapshot.sectionDepth,
                summary: snapshot.summary,
                sceneId: snapshot.sceneId
            )
            elementModel.document = documentModel
            documentModel.elements.append(elementModel)
        }

        modelContext.insert(documentModel)
        return documentModel
    }
}
#endif
