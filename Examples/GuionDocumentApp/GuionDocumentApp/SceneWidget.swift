//
//  SceneWidget.swift
//  GuionDocumentApp
//
//  Copyright (c) 2025
//
//  Individual scene disclosure group with optional preScene content
//

import SwiftUI
import SwiftGuion

struct SceneWidget: View {
    let scene: SceneData
    @Binding var isExpanded: Bool
    @Binding var preSceneExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // PreScene box (if exists)
            if scene.hasPreScene, let preSceneElements = scene.preSceneElements {
                PreSceneBox(
                    content: preSceneElements,
                    isExpanded: $preSceneExpanded
                )
                .padding(.bottom, 4)
            }

            // Scene disclosure group
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(scene.sceneElements.indices, id: \.self) { index in
                            SceneElementView(element: scene.sceneElements[index])
                        }
                    }
                    .padding(.top, 8)
                },
                label: {
                    HStack(spacing: 8) {
                        Text(scene.slugline)
                            .font(.system(.body, design: .monospaced))
                            .bold()
                            .foregroundStyle(.primary)

                        Spacer()

                        if let location = scene.sceneLocation {
                            Text(location.lighting.standardAbbreviation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.secondary.opacity(0.1))
                                )
                                .accessibilityLabel("\(location.lighting.standardAbbreviation) scene")
                        }
                    }
                }
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Scene: \(scene.slugline)")
            .accessibilityHint("\(scene.sceneElements.count) elements")
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .padding(.leading, 24) // Scene indent
    }
}

// MARK: - Scene Element View

struct SceneElementView: View {
    let element: GuionElement

    var body: some View {
        HStack(alignment: .top) {
            leadingSpacer

            Text(element.elementText)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(colorForElement)
                .textSelection(.enabled)
                .multilineTextAlignment(element.isCentered ? .center : .leading)

            if element.isCentered {
                Spacer()
            } else {
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, verticalPadding)
    }

    @ViewBuilder
    private var leadingSpacer: some View {
        switch element.elementType {
        case "Character":
            Spacer().frame(width: 100)
        case "Parenthetical":
            Spacer().frame(width: 90)
        case "Dialogue":
            Spacer().frame(width: 60)
        case "Transition":
            EmptyView()
        default:
            EmptyView()
        }
    }

    private var colorForElement: Color {
        switch element.elementType {
        case "Character":
            return .primary
        case "Parenthetical":
            return .secondary
        case "Transition":
            return .secondary
        default:
            return .primary
        }
    }

    private var verticalPadding: CGFloat {
        switch element.elementType {
        case "Character":
            return 4
        case "Action":
            return 2
        default:
            return 1
        }
    }
}

// MARK: - Previews

#Preview("Scene Collapsed") {
    SceneWidget(
        scene: SceneData(
            element: OutlineElement(
                id: "scene-1",
                index: 0,
                level: 0,
                range: [0, 50],
                rawString: "INT. STEAM ROOM - DAY",
                string: "INT. STEAM ROOM - DAY",
                type: "sceneHeader",
                sceneId: "uuid-1"
            ),
            sceneElements: [
                GuionElement(type: "Action", text: "Bernard and Killian sit in a steam room, towels wrapped around their waist."),
                GuionElement(type: "Character", text: "BERNARD"),
                GuionElement(type: "Dialogue", text: "Have you thought about how I'm going to do it?")
            ],
            sceneLocation: SceneLocation.parse("INT. STEAM ROOM - DAY")
        ),
        isExpanded: .constant(false),
        preSceneExpanded: .constant(false)
    )
    .padding()
}

#Preview("Scene Expanded") {
    SceneWidget(
        scene: SceneData(
            element: OutlineElement(
                id: "scene-1",
                index: 0,
                level: 0,
                range: [0, 50],
                rawString: "INT. STEAM ROOM - DAY",
                string: "INT. STEAM ROOM - DAY",
                type: "sceneHeader",
                sceneId: "uuid-1"
            ),
            sceneElements: [
                GuionElement(type: "Action", text: "Bernard and Killian sit in a steam room, towels wrapped around their waist."),
                GuionElement(type: "Character", text: "BERNARD"),
                GuionElement(type: "Dialogue", text: "Have you thought about how I'm going to do it?")
            ],
            sceneLocation: SceneLocation.parse("INT. STEAM ROOM - DAY")
        ),
        isExpanded: .constant(true),
        preSceneExpanded: .constant(false)
    )
    .padding()
}

#Preview("Scene with PreScene") {
    SceneWidget(
        scene: SceneData(
            element: OutlineElement(
                id: "scene-1",
                index: 0,
                level: 0,
                range: [0, 50],
                rawString: "INT. STEAM ROOM - DAY",
                string: "INT. STEAM ROOM - DAY",
                type: "sceneHeader",
                sceneId: "uuid-1"
            ),
            sceneElements: [
                GuionElement(type: "Action", text: "Bernard and Killian sit in a steam room."),
                GuionElement(type: "Character", text: "BERNARD"),
                GuionElement(type: "Dialogue", text: "Have you thought about it?")
            ],
            preSceneElements: [
                GuionElement(type: "Action", text: "CHAPTER 1"),
                GuionElement(type: "Action", text: "BERNARD")
            ],
            sceneLocation: SceneLocation.parse("INT. STEAM ROOM - DAY")
        ),
        isExpanded: .constant(true),
        preSceneExpanded: .constant(true)
    )
    .padding()
}
