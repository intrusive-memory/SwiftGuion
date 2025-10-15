//
//  SceneBrowserData.swift
//  SwiftGuion
//
//  Copyright (c) 2025
//
//  Data models for the Scene Browser widget.
//  Provides hierarchical structure: Title → Chapter → Scene Group → Scene
//
//  **Architecture**: These structures hold references to SwiftData models, not value copies.
//  UI components query the models directly for reactive updates.
//

import Foundation
#if canImport(SwiftData)
import SwiftData
#endif

/// Main data structure for the scene browser
public struct SceneBrowserData {
    /// The title/root element (Level 1)
    public let title: OutlineElement?

    /// All chapters in the document (Level 2)
    public let chapters: [ChapterData]

    public init(title: OutlineElement?, chapters: [ChapterData]) {
        self.title = title
        self.chapters = chapters
    }
}

/// Chapter data (Level 2 outline element)
public struct ChapterData: Identifiable {
    public let id: String
    public let element: OutlineElement
    public let sceneGroups: [SceneGroupData]

    public init(element: OutlineElement, sceneGroups: [SceneGroupData]) {
        self.id = element.id
        self.element = element
        self.sceneGroups = sceneGroups
    }

    /// Chapter title
    public var title: String {
        element.string
    }
}

/// Scene group data (Level 3 outline element)
public struct SceneGroupData: Identifiable {
    public let id: String
    public let element: OutlineElement
    public let scenes: [SceneData]

    public init(element: OutlineElement, scenes: [SceneData]) {
        self.id = element.id
        self.element = element
        self.scenes = scenes
    }

    /// Scene group title
    public var title: String {
        element.string
    }

    /// Scene directive metadata (e.g., "PROLOGUE" from "### PROLOGUE S#{{SERIES: 1001}}")
    public var directive: String? {
        element.sceneDirective
    }

    /// Full directive description (e.g., "S#{{SERIES: 1001}}")
    public var directiveDescription: String? {
        element.sceneDirectiveDescription
    }
}

/// Scene data with optional preScene content
///
/// **SwiftData Architecture**: This structure holds references to GuionElementModel instances.
/// UI components read properties directly from the models for reactive updates.
public struct SceneData: Identifiable {
    public let id: String

    #if canImport(SwiftData)
    /// Reference to the scene heading element model (SwiftData)
    public let sceneHeadingModel: GuionElementModel?

    /// References to scene content element models (SwiftData)
    public let sceneElementModels: [GuionElementModel]

    /// References to pre-scene content element models (SwiftData)
    public let preSceneElementModels: [GuionElementModel]?
    #endif

    /// Value-type storage (always available for compatibility)
    public let element: OutlineElement?
    public let sceneElements: [GuionElement]?
    public let preSceneElements: [GuionElement]?

    /// Cached scene location
    public let sceneLocation: SceneLocation?

    #if canImport(SwiftData)
    /// SwiftData initializer: accepts model references
    public init(
        sceneHeadingModel: GuionElementModel?,
        sceneElementModels: [GuionElementModel],
        preSceneElementModels: [GuionElementModel]? = nil,
        sceneLocation: SceneLocation? = nil
    ) {
        self.id = sceneHeadingModel?.sceneId ?? UUID().uuidString
        self.sceneHeadingModel = sceneHeadingModel
        self.sceneElementModels = sceneElementModels
        self.preSceneElementModels = preSceneElementModels

        // Set value-based properties to nil when using model-based init
        self.element = nil
        self.sceneElements = nil
        self.preSceneElements = nil
        self.sceneLocation = sceneLocation
    }
    #endif

    /// Value-based initializer: accepts value types (always available)
    public init(
        element: OutlineElement,
        sceneElements: [GuionElement],
        preSceneElements: [GuionElement]? = nil,
        sceneLocation: SceneLocation? = nil
    ) {
        self.id = element.id
        self.element = element
        self.sceneElements = sceneElements
        self.preSceneElements = preSceneElements
        self.sceneLocation = sceneLocation

        #if canImport(SwiftData)
        // Set model-based properties to nil/empty when using value-based init
        self.sceneHeadingModel = nil
        self.sceneElementModels = []
        self.preSceneElementModels = nil
        #endif
    }

    /// Scene slugline/heading
    public var slugline: String {
        #if canImport(SwiftData)
        if let model = sceneHeadingModel {
            return model.elementText
        }
        #endif
        return element?.string ?? "Untitled Scene"
    }

    /// Scene number if present
    public var sceneNumber: String? {
        #if canImport(SwiftData)
        if let model = sceneHeadingModel {
            return model.sceneNumber
        }
        #endif
        return nil
    }

    /// UUID linking to GuionElement
    public var sceneId: String? {
        #if canImport(SwiftData)
        if let model = sceneHeadingModel {
            return model.sceneId
        }
        #endif
        return element?.sceneId
    }

    /// AI-generated summary (extracted from Section Heading elements)
    public var summary: String? {
        #if canImport(SwiftData)
        // Look for Section Heading with depth 4 that contains "SUMMARY:"
        // Note: elementText may have leading space from Fountain parsing
        for element in sceneElementModels {
            if element.elementType == "Section Heading" &&
               element.sectionDepth == 4 {
                let trimmedText = element.elementText.trimmingCharacters(in: .whitespaces)
                if trimmedText.hasPrefix("SUMMARY:") {
                    // Extract text after "SUMMARY: " prefix
                    if let range = trimmedText.range(of: "SUMMARY:") {
                        let summary = String(trimmedText[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                        return summary.isEmpty ? nil : summary
                    }
                }
            }
        }
        #else
        // Look for Section Heading with depth 4 that contains "SUMMARY:"
        // Note: elementText may have leading space from Fountain parsing
        if let elements = sceneElements {
            for element in elements {
                if element.elementType == "Section Heading" &&
                   element.sectionDepth == 4 {
                    let trimmedText = element.elementText.trimmingCharacters(in: .whitespaces)
                    if trimmedText.hasPrefix("SUMMARY:") {
                        // Extract text after "SUMMARY: " prefix
                        if let range = trimmedText.range(of: "SUMMARY:") {
                            let summary = String(trimmedText[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                            return summary.isEmpty ? nil : summary
                        }
                    }
                }
            }
        }
        #endif
        return nil
    }

    /// Whether this scene has preScene content (OVER BLACK)
    public var hasPreScene: Bool {
        #if canImport(SwiftData)
        if let preScene = preSceneElementModels {
            return !preScene.isEmpty
        }
        #endif
        guard let preScene = preSceneElements else { return false }
        return !preScene.isEmpty
    }

    /// PreScene text joined
    public var preSceneText: String {
        #if canImport(SwiftData)
        if let preScene = preSceneElementModels {
            return preScene.map { $0.elementText }.joined(separator: "\n")
        }
        #endif
        guard let preScene = preSceneElements else { return "" }
        return preScene.map { $0.elementText }.joined(separator: "\n")
    }

    /// Check if this is an OVER BLACK scene
    public var isOverBlack: Bool {
        #if canImport(SwiftData)
        if let model = sceneHeadingModel {
            return model.elementText.uppercased().contains("OVER BLACK")
        }
        #endif
        return element?.string.uppercased().contains("OVER BLACK") ?? false
    }
}

// MARK: - Extensions

#if !canImport(SwiftData)
// Sendable conformance only for non-SwiftData (value-type) mode
// SwiftData models are MainActor-bound and not Sendable
extension SceneBrowserData: Sendable {}
extension ChapterData: Sendable {}
extension SceneGroupData: Sendable {}
extension SceneData: Sendable {}
#endif
