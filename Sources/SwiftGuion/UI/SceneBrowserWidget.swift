//
//  SceneBrowserWidget.swift
//  SwiftGuion
//
//  Copyright (c) 2025
//
//  Main scene browser container displaying hierarchical outline structure
//

import SwiftUI

/// Main scene browser widget displaying the hierarchical outline structure of a screenplay
public struct SceneBrowserWidget: View {
    let browserData: SceneBrowserData

    @State private var expandedChapters: Set<String> = []
    @State private var expandedSceneGroups: Set<String> = []
    @State private var expandedScenes: Set<String> = []
    @State private var expandedPreScenes: Set<String> = []

    /// Creates a SceneBrowserWidget from SceneBrowserData
    /// - Parameter browserData: The scene browser data containing the screenplay structure
    public init(browserData: SceneBrowserData) {
        self.browserData = browserData
    }

    /// Creates a SceneBrowserWidget directly from a GuionParsedScreenplay
    /// - Parameter script: The GuionParsedScreenplay to extract browser data from
    public init(script: GuionParsedScreenplay) {
        self.browserData = script.extractSceneBrowserData()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title header (Level 1 - always visible)
            if let title = browserData.title {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title.string)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(title.isSynthetic ? .secondary : .primary)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Script title: \(title.string)")

                    Divider()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)
            }

            // Scrollable chapter list or empty state
            if browserData.chapters.isEmpty {
                EmptyBrowserView()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(browserData.chapters) { chapter in
                            ChapterWidget(
                                chapter: chapter,
                                isExpanded: Binding(
                                    get: { expandedChapters.contains(chapter.id) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedChapters.insert(chapter.id)
                                        } else {
                                            expandedChapters.remove(chapter.id)
                                        }
                                    }
                                ),
                                expandedSceneGroups: $expandedSceneGroups,
                                expandedScenes: $expandedScenes,
                                expandedPreScenes: $expandedPreScenes
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .accessibilityLabel("Scene browser")
                .accessibilityHint("\(browserData.chapters.count) chapters")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Empty State View

/// View displayed when no chapters are found in the screenplay
public struct EmptyBrowserView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No Chapters Found")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("This screenplay doesn't have chapter markers (##).")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No chapters found. This screenplay doesn't have chapter markers.")
    }
}

// MARK: - Previews

#Preview("Scene Browser - Simple") {
    SceneBrowserWidget(
        browserData: SceneBrowserData(
            title: OutlineElement(
                id: "title",
                index: 0,
                level: 1,
                range: [0, 10],
                rawString: "# Test Script",
                string: "Test Script",
                type: "sectionHeader"
            ),
            chapters: [
                ChapterData(
                    element: OutlineElement(
                        id: "chapter-1",
                        index: 1,
                        level: 2,
                        range: [10, 100],
                        rawString: "## CHAPTER 1",
                        string: "CHAPTER 1",
                        type: "sectionHeader"
                    ),
                    sceneGroups: [
                        SceneGroupData(
                            element: OutlineElement(
                                id: "group-1",
                                index: 2,
                                level: 3,
                                range: [20, 80],
                                rawString: "### PROLOGUE",
                                string: "PROLOGUE",
                                type: "sectionHeader"
                            ),
                            scenes: [
                                SceneData(
                                    element: OutlineElement(
                                        id: "scene-1",
                                        index: 3,
                                        level: 0,
                                        range: [30, 70],
                                        rawString: "INT. STEAM ROOM - DAY",
                                        string: "INT. STEAM ROOM - DAY",
                                        type: "sceneHeader"
                                    ),
                                    sceneElements: [
                                        GuionElement(type: "Action", text: "Bernard and Killian sit in a steam room.")
                                    ],
                                    sceneLocation: SceneLocation.parse("INT. STEAM ROOM - DAY")
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    )
    .frame(width: 400, height: 600)
}

#Preview("Scene Browser - Empty") {
    SceneBrowserWidget(
        browserData: SceneBrowserData(
            title: OutlineElement(
                id: "title",
                index: 0,
                level: 1,
                range: [0, 10],
                rawString: "# Untitled Script",
                string: "Untitled Script",
                type: "sectionHeader"
            ),
            chapters: []
        )
    )
    .frame(width: 400, height: 600)
}
