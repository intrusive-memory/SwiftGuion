//
//  FountainScript+SceneBrowser.swift
//  SwiftGuion
//
//  Copyright (c) 2025
//
//  Extension to extract hierarchical scene browser data from FountainScript
//

import Foundation

extension FountainScript {
    /// Extract hierarchical scene browser data
    ///
    /// This method builds a hierarchical structure from the outline:
    /// - Title (Level 1) → Chapters (Level 2) → Scene Groups (Level 3) → Scenes
    /// - Detects and attaches OVER BLACK content as preScene elements
    /// - Uses existing outline infrastructure for hierarchy
    ///
    /// - Returns: SceneBrowserData containing the complete hierarchy
    public func extractSceneBrowserData() -> SceneBrowserData {
        let outline = extractOutline()

        // Find the root/title element (Level 1)
        let title = outline.first { $0.isMainTitle }

        // Find all chapters (Level 2 elements)
        let chapterElements = outline.filter { $0.isChapter }

        // Build chapter data with scene groups and scenes
        let chapters = chapterElements.map { chapterElement in
            buildChapterData(chapter: chapterElement, outline: outline)
        }

        return SceneBrowserData(title: title, chapters: chapters)
    }

    /// Build chapter data with its scene groups
    private func buildChapterData(chapter: OutlineElement, outline: OutlineList) -> ChapterData {
        // Find scene groups (Level 3) that are children of this chapter
        let sceneGroupElements = outline.filter { element in
            element.level == 3 && element.parentId == chapter.id
        }

        // Build scene group data
        let sceneGroups = sceneGroupElements.map { sceneGroupElement in
            buildSceneGroupData(sceneGroup: sceneGroupElement, outline: outline)
        }

        return ChapterData(element: chapter, sceneGroups: sceneGroups)
    }

    /// Build scene group data with its scenes
    private func buildSceneGroupData(sceneGroup: OutlineElement, outline: OutlineList) -> SceneGroupData {
        // Find scenes that are children of this scene group
        let sceneElements = outline.filter { element in
            element.type == "sceneHeader" && element.parentId == sceneGroup.id
        }

        // Build scene data with OVER BLACK detection
        let scenes = buildScenesWithOverBlack(sceneElements: sceneElements, outline: outline)

        return SceneGroupData(element: sceneGroup, scenes: scenes)
    }

    /// Build scene data with OVER BLACK detection and attachment
    private func buildScenesWithOverBlack(sceneElements: [OutlineElement], outline: OutlineList) -> [SceneData] {
        var result: [SceneData] = []
        var pendingOverBlack: [GuionElement]?

        for sceneElement in sceneElements {
            // Get scene content
            let sceneText = sceneElement.sceneText(from: self, outline: outline)
            let sceneGuionElements = parseSceneContent(sceneText: sceneText)

            // Check if this is an OVER BLACK scene
            if isOverBlackScene(sceneElement) {
                // Store OVER BLACK content to attach to next scene
                pendingOverBlack = sceneGuionElements
                continue
            }

            // Parse scene location
            let location = SceneLocation.parse(sceneElement.string)

            // Create scene data
            let sceneData = SceneData(
                element: sceneElement,
                sceneElements: sceneGuionElements,
                preSceneElements: pendingOverBlack,
                sceneLocation: location
            )

            result.append(sceneData)

            // Clear pending OVER BLACK after attaching
            pendingOverBlack = nil
        }

        // If there's remaining OVER BLACK at the end, create a standalone scene for it
        if let overBlack = pendingOverBlack, !overBlack.isEmpty {
            // This is an edge case: OVER BLACK at the end with no following scene
            // We'll ignore it or could create a special end marker
        }

        return result
    }

    /// Check if a scene element is an OVER BLACK scene
    private func isOverBlackScene(_ element: OutlineElement) -> Bool {
        return element.string.uppercased().contains("OVER BLACK")
    }

    /// Parse scene content text into GuionElements
    private func parseSceneContent(sceneText: String) -> [GuionElement] {
        // The sceneText already includes all elements from the scene
        // We need to parse it back into GuionElements
        // For now, we'll create a simple action element
        // This could be enhanced to properly parse the content

        guard !sceneText.isEmpty else { return [] }

        // Split by double newlines to get separate elements
        let parts = sceneText.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Skip the first part if it's the scene heading
        let contentParts = parts.dropFirst()

        if contentParts.isEmpty {
            return []
        }

        // Convert parts to GuionElements
        // This is a simplified approach - ideally we'd re-parse properly
        return contentParts.map { part in
            GuionElement(type: "Action", text: part)
        }
    }
}

// MARK: - Helper Extensions

extension OutlineElement {
    /// Check if this element represents a scene directive (Level 3 with metadata)
    var hasDirective: Bool {
        return level == 3 && sceneDirective != nil
    }
}
