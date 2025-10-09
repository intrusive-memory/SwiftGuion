//
//  SceneBrowserWidget.swift
//  GuionDocumentApp
//
//  Copyright (c) 2025
//
//  Main scene browser container displaying hierarchical outline structure
//

import SwiftUI
import SwiftGuion

struct SceneBrowserWidget: View {
    let browserData: SceneBrowserData

    @State private var expandedChapters: Set<String> = []
    @State private var expandedSceneGroups: Set<String> = []
    @State private var expandedScenes: Set<String> = []
    @State private var expandedPreScenes: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title header (Level 1 - always visible)
            if let title = browserData.title {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title.string)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.primary)

                    Divider()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)
            }

            // Scrollable chapter list
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - Convenience Initializer

extension SceneBrowserWidget {
    /// Create a scene browser from a FountainScript
    init(script: FountainScript) {
        self.browserData = script.extractSceneBrowserData()
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

#Preview("Scene Browser - Multiple Chapters") {
    SceneBrowserWidget(
        browserData: SceneBrowserData(
            title: OutlineElement(
                id: "title",
                index: 0,
                level: 1,
                range: [0, 10],
                rawString: "# You're Nobody til Somebody Wants You Dead",
                string: "You're Nobody til Somebody Wants You Dead",
                type: "sectionHeader"
            ),
            chapters: [
                ChapterData(
                    element: OutlineElement(
                        id: "chapter-1",
                        index: 1,
                        level: 2,
                        range: [10, 500],
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
                                range: [20, 200],
                                rawString: "### PROLOGUE S#{{SERIES: 1001}}",
                                string: "PROLOGUE",
                                type: "sectionHeader",
                                sceneDirective: "PROLOGUE",
                                sceneDirectiveDescription: "S#{{SERIES: 1001}}"
                            ),
                            scenes: [
                                SceneData(
                                    element: OutlineElement(
                                        id: "scene-1",
                                        index: 3,
                                        level: 0,
                                        range: [30, 150],
                                        rawString: "INT. STEAM ROOM - DAY",
                                        string: "INT. STEAM ROOM - DAY",
                                        type: "sceneHeader"
                                    ),
                                    sceneElements: [
                                        GuionElement(type: "Action", text: "Bernard and Killian sit in a steam room, towels wrapped around their waist."),
                                        GuionElement(type: "Character", text: "BERNARD"),
                                        GuionElement(type: "Dialogue", text: "Have you thought about how I'm going to do it?")
                                    ],
                                    preSceneElements: [
                                        GuionElement(type: "Action", text: "CHAPTER 1"),
                                        GuionElement(type: "Action", text: "BERNARD")
                                    ],
                                    sceneLocation: SceneLocation.parse("INT. STEAM ROOM - DAY")
                                )
                            ]
                        ),
                        SceneGroupData(
                            element: OutlineElement(
                                id: "group-2",
                                index: 4,
                                level: 3,
                                range: [210, 450],
                                rawString: "### THE MURDER S#{{SERIES: 1002}}",
                                string: "THE MURDER",
                                type: "sectionHeader",
                                sceneDirective: "THE MURDER",
                                sceneDirectiveDescription: "S#{{SERIES: 1002}}"
                            ),
                            scenes: [
                                SceneData(
                                    element: OutlineElement(
                                        id: "scene-2",
                                        index: 5,
                                        level: 0,
                                        range: [220, 300],
                                        rawString: "INT. HOME - BERNARD'S CASITA - DAY",
                                        string: "INT. HOME - BERNARD'S CASITA - DAY",
                                        type: "sceneHeader"
                                    ),
                                    sceneElements: [
                                        GuionElement(type: "Action", text: "Bernard examines a pair of lightweight jogging shorts that are more-or-less see-thru.")
                                    ],
                                    sceneLocation: SceneLocation.parse("INT. HOME - BERNARD'S CASITA - DAY")
                                )
                            ]
                        )
                    ]
                ),
                ChapterData(
                    element: OutlineElement(
                        id: "chapter-2",
                        index: 6,
                        level: 2,
                        range: [510, 1000],
                        rawString: "## CHAPTER 2",
                        string: "CHAPTER 2",
                        type: "sectionHeader"
                    ),
                    sceneGroups: [
                        SceneGroupData(
                            element: OutlineElement(
                                id: "group-3",
                                index: 7,
                                level: 3,
                                range: [520, 700],
                                rawString: "### Steam Room S#{{SERIES: 2001}}",
                                string: "Steam Room",
                                type: "sectionHeader",
                                sceneDirective: "Steam Room",
                                sceneDirectiveDescription: "S#{{SERIES: 2001}}"
                            ),
                            scenes: [
                                SceneData(
                                    element: OutlineElement(
                                        id: "scene-3",
                                        index: 8,
                                        level: 0,
                                        range: [530, 650],
                                        rawString: "INT. STEAM ROOM - DAY",
                                        string: "INT. STEAM ROOM - DAY",
                                        type: "sceneHeader"
                                    ),
                                    sceneElements: [
                                        GuionElement(type: "Action", text: "Killian and Bernard recline on the white tile.")
                                    ],
                                    preSceneElements: [
                                        GuionElement(type: "Action", text: "CHAPTER 2"),
                                        GuionElement(type: "Action", text: "KILLIAN")
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
    .frame(width: 500, height: 800)
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
