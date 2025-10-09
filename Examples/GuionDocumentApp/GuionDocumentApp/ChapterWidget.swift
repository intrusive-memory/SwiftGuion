//
//  ChapterWidget.swift
//  GuionDocumentApp
//
//  Copyright (c) 2025
//
//  Level 2 chapter disclosure with scene groups
//

import SwiftUI
import SwiftGuion

struct ChapterWidget: View {
    let chapter: ChapterData
    @Binding var isExpanded: Bool
    @Binding var expandedSceneGroups: Set<String>
    @Binding var expandedScenes: Set<String>
    @Binding var expandedPreScenes: Set<String>

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(chapter.sceneGroups) { sceneGroup in
                        SceneGroupWidget(
                            sceneGroup: sceneGroup,
                            isExpanded: Binding(
                                get: { expandedSceneGroups.contains(sceneGroup.id) },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedSceneGroups.insert(sceneGroup.id)
                                    } else {
                                        expandedSceneGroups.remove(sceneGroup.id)
                                    }
                                }
                            ),
                            expandedScenes: $expandedScenes,
                            expandedPreScenes: $expandedPreScenes
                        )
                    }
                }
                .padding(.top, 12)
            },
            label: {
                Text(chapter.title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)
            }
        )
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.secondary.opacity(0.05))
        )
        .overlay(
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
            }
        )
    }
}

// MARK: - Previews

#Preview("Chapter Collapsed") {
    ChapterWidget(
        chapter: ChapterData(
            element: OutlineElement(
                id: "chapter-1",
                index: 0,
                level: 2,
                range: [0, 500],
                rawString: "## CHAPTER 1",
                string: "CHAPTER 1",
                type: "sectionHeader"
            ),
            sceneGroups: [
                SceneGroupData(
                    element: OutlineElement(
                        id: "group-1",
                        index: 1,
                        level: 3,
                        range: [10, 100],
                        rawString: "### PROLOGUE",
                        string: "PROLOGUE",
                        type: "sectionHeader"
                    ),
                    scenes: []
                )
            ]
        ),
        isExpanded: .constant(false),
        expandedSceneGroups: .constant([]),
        expandedScenes: .constant([]),
        expandedPreScenes: .constant([])
    )
    .padding()
}

#Preview("Chapter Expanded") {
    ScrollView {
        ChapterWidget(
            chapter: ChapterData(
                element: OutlineElement(
                    id: "chapter-1",
                    index: 0,
                    level: 2,
                    range: [0, 500],
                    rawString: "## CHAPTER 1",
                    string: "CHAPTER 1",
                    type: "sectionHeader"
                ),
                sceneGroups: [
                    SceneGroupData(
                        element: OutlineElement(
                            id: "group-1",
                            index: 1,
                            level: 3,
                            range: [10, 100],
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
                                    index: 2,
                                    level: 0,
                                    range: [20, 60],
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
                    ),
                    SceneGroupData(
                        element: OutlineElement(
                            id: "group-2",
                            index: 3,
                            level: 3,
                            range: [110, 200],
                            rawString: "### THE MURDER",
                            string: "THE MURDER",
                            type: "sectionHeader"
                        ),
                        scenes: [
                            SceneData(
                                element: OutlineElement(
                                    id: "scene-2",
                                    index: 4,
                                    level: 0,
                                    range: [120, 180],
                                    rawString: "INT. HOME - DAY",
                                    string: "INT. HOME - DAY",
                                    type: "sceneHeader"
                                ),
                                sceneElements: [
                                    GuionElement(type: "Action", text: "Bernard examines his outfit.")
                                ],
                                sceneLocation: SceneLocation.parse("INT. HOME - DAY")
                            )
                        ]
                    )
                ]
            ),
            isExpanded: .constant(true),
            expandedSceneGroups: .constant(["group-1"]),
            expandedScenes: .constant(["scene-1"]),
            expandedPreScenes: .constant([])
        )
        .padding()
    }
}
