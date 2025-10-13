//
//  SceneBrowserData.swift
//  SwiftGuion
//
//  Copyright (c) 2025
//
//  Data models for the Scene Browser widget.
//  Provides hierarchical structure: Title → Chapter → Scene Group → Scene
//

import Foundation

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
public struct SceneData: Identifiable {
    public let id: String
    public let element: OutlineElement
    public let sceneElements: [GuionElement]
    public let preSceneElements: [GuionElement]?
    public let sceneLocation: SceneLocation?

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
    }

    /// Scene slugline/heading
    public var slugline: String {
        element.string
    }

    /// Scene number if present
    public var sceneNumber: String? {
        // Try to get from GuionElement via sceneId
        return nil // Will be populated during extraction
    }

    /// UUID linking to GuionElement
    public var sceneId: String? {
        element.sceneId
    }

    /// Whether this scene has preScene content (OVER BLACK)
    public var hasPreScene: Bool {
        guard let preScene = preSceneElements else { return false }
        return !preScene.isEmpty
    }

    /// PreScene text joined
    public var preSceneText: String {
        guard let preScene = preSceneElements else { return "" }
        return preScene.map { $0.elementText }.joined(separator: "\n")
    }

    /// Check if this is an OVER BLACK scene
    public var isOverBlack: Bool {
        return element.string.uppercased().contains("OVER BLACK")
    }
}

// MARK: - Extensions

extension SceneBrowserData: Sendable {}
extension ChapterData: Sendable {}
extension SceneGroupData: Sendable {}
extension SceneData: Sendable {}
