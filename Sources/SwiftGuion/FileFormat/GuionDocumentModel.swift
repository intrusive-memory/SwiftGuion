//
//  GuionDocumentModel.swift
//  FountainDocumentApp
//
//  Copyright (c) 2025
//

import Foundation
import SwiftData

/// SwiftData model representing a complete screenplay document.
///
/// This is the root model for screenplay storage, containing all elements,
/// title page entries, and document metadata.
///
/// ## Overview
///
/// `GuionDocumentModel` is the persistent storage representation of a screenplay,
/// designed to work seamlessly with SwiftData for automatic persistence and iCloud sync.
///
/// ## Example
///
/// ```swift
/// let document = GuionDocumentModel(filename: "MyScript.guion")
///
/// let sceneHeading = GuionElementModel(
///     elementText: "INT. COFFEE SHOP - DAY",
///     elementType: "Scene Heading"
/// )
/// document.elements.append(sceneHeading)
///
/// modelContext.insert(document)
/// ```
///
/// ## Topics
///
/// ### Creating Documents
/// - ``init(filename:rawContent:suppressSceneNumbers:)``
///
/// ### Document Properties
/// - ``filename``
/// - ``rawContent``
/// - ``suppressSceneNumbers``
///
/// ### Content
/// - ``elements``
/// - ``titlePage``
///
/// ### Location Management
/// - ``reparseAllLocations()``
/// - ``sceneLocations``
///
/// ### Serialization
/// - ``save(to:)``
/// - ``load(from:in:)``
/// - ``validate()``
@Model
public final class GuionDocumentModel {
    public var filename: String?
    public var rawContent: String?
    public var suppressSceneNumbers: Bool

    @Relationship(deleteRule: .cascade, inverse: \GuionElementModel.document)
    public var elements: [GuionElementModel]

    @Relationship(deleteRule: .cascade, inverse: \TitlePageEntryModel.document)
    public var titlePage: [TitlePageEntryModel]

    public init(filename: String? = nil, rawContent: String? = nil, suppressSceneNumbers: Bool = false) {
        self.filename = filename
        self.rawContent = rawContent
        self.suppressSceneNumbers = suppressSceneNumbers
        self.elements = []
        self.titlePage = []
    }

    /// Reparse all scene heading locations (useful for migration or updates)
    public func reparseAllLocations() {
        for element in elements where element.elementType == .sceneHeading {
            element.reparseLocation()
        }
    }

    /// Get all scene elements with their cached locations
    public var sceneLocations: [(element: GuionElementModel, location: SceneLocation)] {
        return elements.compactMap { element in
            guard let location = element.cachedSceneLocation else { return nil }
            return (element, location)
        }
    }

    // MARK: - Conversion Methods

    /// Create a GuionDocumentModel from a GuionParsedScreenplay
    /// - Parameters:
    ///   - screenplay: The screenplay to convert
    ///   - context: The ModelContext to use
    ///   - generateSummaries: Whether to generate AI summaries for scene headings (default: false)
    /// - Returns: The created GuionDocumentModel
    @MainActor
    public static func from(
        _ screenplay: GuionParsedScreenplay,
        in context: ModelContext,
        generateSummaries: Bool = false
    ) async -> GuionDocumentModel {
        let document = GuionDocumentModel(
            filename: screenplay.filename,
            rawContent: screenplay.stringFromDocument(),
            suppressSceneNumbers: screenplay.suppressSceneNumbers
        )

        // Convert title page entries
        for dictionary in screenplay.titlePage {
            for (key, values) in dictionary {
                let entry = TitlePageEntryModel(key: key, values: values)
                entry.document = document
                document.titlePage.append(entry)
            }
        }

        // Generate summaries for scene headings if requested
        if generateSummaries {
            let outline = screenplay.extractOutline()
            var elementsWithSummaries: [GuionElement] = []
            var skipIndices = Set<Int>()

            for (index, element) in screenplay.elements.enumerated() {
                // Skip if already processed (e.g., OVER BLACK that was handled with scene)
                if skipIndices.contains(index) {
                    continue
                }

                // Add the original element
                elementsWithSummaries.append(element)

                // Check if this is a scene heading that needs a summary
                if element.elementType == .sceneHeading,
                   let sceneId = element.sceneId,
                   let scene = outline.first(where: { $0.sceneId == sceneId }) {

                    // Generate summary
                    if let summaryText = await SceneSummarizer.summarizeScene(scene, from: screenplay, outline: outline) {
                        // Check if next element is OVER BLACK
                        if index + 1 < screenplay.elements.count {
                            let nextElement = screenplay.elements[index + 1]
                            if nextElement.elementType == .action &&
                               nextElement.elementText.uppercased().contains("OVER BLACK") {
                                // Add OVER BLACK element before summary
                                elementsWithSummaries.append(nextElement)
                                skipIndices.insert(index + 1)
                            }
                        }

                        // Create summary element as #### SUMMARY: text
                        // Note: Leading space is required because Fountain parser preserves the space after hashtags
                        let summaryElement = GuionElement(
                            elementType: .sectionHeading(level: 4),
                            elementText: " SUMMARY: \(summaryText)"
                        )
                        elementsWithSummaries.append(summaryElement)
                    }
                }
            }

            // Convert all elements including inserted summaries to models
            for element in elementsWithSummaries {
                let elementModel = GuionElementModel(from: element)
                elementModel.document = document
                document.elements.append(elementModel)
            }
        } else {
            // Convert elements without summaries
            for element in screenplay.elements {
                let elementModel = GuionElementModel(from: element)
                elementModel.document = document
                document.elements.append(elementModel)
            }
        }

        context.insert(document)
        return document
    }

    /// Convert this GuionDocumentModel to a GuionParsedScreenplay
    /// - Returns: GuionParsedScreenplay instance containing the document data
    public func toGuionParsedScreenplay() -> GuionParsedScreenplay {
        // Convert title page
        var titlePageDict: [String: [String]] = [:]
        for entry in titlePage {
            titlePageDict[entry.key] = entry.values
        }
        let titlePageArray = titlePageDict.isEmpty ? [] : [titlePageDict]

        // Convert elements using protocol-based conversion
        let convertedElements = elements.map { GuionElement(from: $0) }

        return GuionParsedScreenplay(
            filename: filename,
            elements: convertedElements,
            titlePage: titlePageArray,
            suppressSceneNumbers: suppressSceneNumbers
        )
    }

    /// Extract hierarchical scene browser data from SwiftData models
    ///
    /// This method builds the chapter → scene group → scene hierarchy directly
    /// from the `elements` relationship, without converting to GuionParsedScreenplay.
    ///
    /// **Architecture**: Returns structure with references to GuionElementModel instances,
    /// not value copies. UI components read properties directly from models for reactive updates.
    ///
    /// - Returns: SceneBrowserData with model references
    public func extractSceneBrowserData() -> SceneBrowserData {
        // For Phase 1: Convert to screenplay and use existing extraction logic
        // TODO: Phase 2 will implement direct SwiftData traversal for better performance
        let screenplay = toGuionParsedScreenplay()
        let valueBasedData = screenplay.extractSceneBrowserData()

        // Map value-based structure to model-based structure
        return mapToModelBased(valueData: valueBasedData)
    }

    /// Map value-based SceneBrowserData to model-based SceneBrowserData
    private func mapToModelBased(valueData: SceneBrowserData) -> SceneBrowserData {
        // Build lookup dictionary: sceneId -> GuionElementModel (for scene headings)
        var sceneHeadingLookup: [String: GuionElementModel] = [:]
        for element in elements {
            if let sceneId = element.sceneId, element.elementType == .sceneHeading {
                sceneHeadingLookup[sceneId] = element
            }
        }

        // Build lookup for all elements by text+type (for scene content matching)
        // This allows us to find model equivalents of value-based elements
        var elementLookup: [[String: String]: [GuionElementModel]] = [:]
        for element in elements {
            let key = ["text": element.elementText, "type": element.elementType.description]
            if elementLookup[key] == nil {
                elementLookup[key] = []
            }
            elementLookup[key]?.append(element)
        }

        // Map chapters
        let mappedChapters = valueData.chapters.map { chapter in
            // Map scene groups
            let mappedSceneGroups = chapter.sceneGroups.map { sceneGroup in
                // Map scenes
                let mappedScenes = sceneGroup.scenes.map { scene in
                    // Find the scene heading model by sceneId
                    let sceneHeadingModel = scene.sceneId.flatMap { sceneHeadingLookup[$0] }

                    // Find scene content element models
                    var sceneElementModels: [GuionElementModel] = []

                    // Add the scene heading first
                    if let heading = sceneHeadingModel {
                        sceneElementModels.append(heading)
                    }

                    // Add all scene content elements
                    if let valueElements = scene.sceneElements {
                        // Track which models we've already used to avoid duplicates
                        var usedModels = Set<ObjectIdentifier>()
                        if let heading = sceneHeadingModel {
                            usedModels.insert(ObjectIdentifier(heading))
                        }

                        for valueElement in valueElements {
                            let key = ["text": valueElement.elementText, "type": valueElement.elementType.description]
                            if let candidates = elementLookup[key] {
                                // Find first unused match
                                if let match = candidates.first(where: { !usedModels.contains(ObjectIdentifier($0)) }) {
                                    sceneElementModels.append(match)
                                    usedModels.insert(ObjectIdentifier(match))
                                }
                            }
                        }
                    }

                    // Find preScene element models
                    var preSceneElementModels: [GuionElementModel]? = nil
                    if let preSceneValues = scene.preSceneElements {
                        var preSceneModels: [GuionElementModel] = []
                        var usedModels = Set<ObjectIdentifier>()

                        for valueElement in preSceneValues {
                            let key = ["text": valueElement.elementText, "type": valueElement.elementType.description]
                            if let candidates = elementLookup[key] {
                                if let match = candidates.first(where: { !usedModels.contains(ObjectIdentifier($0)) }) {
                                    preSceneModels.append(match)
                                    usedModels.insert(ObjectIdentifier(match))
                                }
                            }
                        }

                        if !preSceneModels.isEmpty {
                            preSceneElementModels = preSceneModels
                        }
                    }

                    return SceneData(
                        sceneHeadingModel: sceneHeadingModel,
                        sceneElementModels: sceneElementModels,
                        preSceneElementModels: preSceneElementModels,
                        sceneLocation: scene.sceneLocation
                    )
                }

                return SceneGroupData(
                    element: sceneGroup.element,
                    scenes: mappedScenes
                )
            }

            return ChapterData(
                element: chapter.element,
                sceneGroups: mappedSceneGroups
            )
        }

        return SceneBrowserData(
            title: valueData.title,
            chapters: mappedChapters
        )
    }
}
