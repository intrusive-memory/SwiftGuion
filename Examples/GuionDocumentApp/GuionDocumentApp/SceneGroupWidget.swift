//
//  SceneGroupWidget.swift
//  GuionDocumentApp
//
//  Copyright (c) 2025
//
//  Level 3 scene group disclosure with scenes
//

import SwiftUI
import SwiftGuion

struct SceneGroupWidget: View {
    let sceneGroup: SceneGroupData
    @Binding var isExpanded: Bool
    @Binding var expandedScenes: Set<String>
    @Binding var expandedPreScenes: Set<String>

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sceneGroup.scenes) { scene in
                        SceneWidget(
                            scene: scene,
                            isExpanded: Binding(
                                get: { expandedScenes.contains(scene.id) },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedScenes.insert(scene.id)
                                    } else {
                                        expandedScenes.remove(scene.id)
                                    }
                                }
                            ),
                            preSceneExpanded: Binding(
                                get: { expandedPreScenes.contains(scene.id) },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedPreScenes.insert(scene.id)
                                    } else {
                                        expandedPreScenes.remove(scene.id)
                                    }
                                }
                            )
                        )
                    }
                }
                .padding(.top, 8)
            },
            label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sceneGroup.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    if let directive = sceneGroup.directive,
                       let description = sceneGroup.directiveDescription {
                        HStack(spacing: 4) {
                            Text(directive)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(directive), \(description)")
                    }
                }
            }
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Scene group: \(sceneGroup.title)")
        .accessibilityHint("\(sceneGroup.scenes.count) scenes")
        .padding(.leading, 12) // Scene group indent
        .padding(.vertical, 6)
    }
}

// MARK: - Previews

#Preview("Scene Group Collapsed") {
    SceneGroupWidget(
        sceneGroup: SceneGroupData(
            element: OutlineElement(
                id: "group-1",
                index: 0,
                level: 3,
                range: [0, 100],
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
                        index: 1,
                        level: 0,
                        range: [10, 50],
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
        isExpanded: .constant(false),
        expandedScenes: .constant([]),
        expandedPreScenes: .constant([])
    )
    .padding()
}

#Preview("Scene Group Expanded") {
    SceneGroupWidget(
        sceneGroup: SceneGroupData(
            element: OutlineElement(
                id: "group-1",
                index: 0,
                level: 3,
                range: [0, 100],
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
                        index: 1,
                        level: 0,
                        range: [10, 50],
                        rawString: "INT. STEAM ROOM - DAY",
                        string: "INT. STEAM ROOM - DAY",
                        type: "sceneHeader"
                    ),
                    sceneElements: [
                        GuionElement(type: "Action", text: "Bernard and Killian sit in a steam room.")
                    ],
                    sceneLocation: SceneLocation.parse("INT. STEAM ROOM - DAY")
                ),
                SceneData(
                    element: OutlineElement(
                        id: "scene-2",
                        index: 2,
                        level: 0,
                        range: [60, 100],
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
        ),
        isExpanded: .constant(true),
        expandedScenes: .constant(["scene-1"]),
        expandedPreScenes: .constant([])
    )
    .padding()
}
