//
//  SceneWidget.swift
//  SwiftGuion
//
//  Copyright (c) 2025
//
//  Individual scene disclosure group with optional preScene content
//

import SwiftUI

/// A widget displaying an individual scene with optional pre-scene content
public struct SceneWidget: View {
    let scene: SceneData
    @Binding var isExpanded: Bool
    @Binding var preSceneExpanded: Bool

    /// Creates a SceneWidget
    /// - Parameters:
    ///   - scene: The scene data to display
    ///   - isExpanded: Binding to control the scene's expanded/collapsed state
    ///   - preSceneExpanded: Binding to control the pre-scene content's expanded/collapsed state
    public init(scene: SceneData, isExpanded: Binding<Bool>, preSceneExpanded: Binding<Bool>) {
        self.scene = scene
        self._isExpanded = isExpanded
        self._preSceneExpanded = preSceneExpanded
    }

    private var sceneElementsAccessibilityHint: String {
        let count = scene.sceneElementModels.count
        return "\(count) elements"
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // PreScene box (if exists)
            if scene.hasPreScene, let preSceneModels = scene.preSceneElementModels {
                PreSceneBox(
                    content: preSceneModels,
                    isExpanded: $preSceneExpanded
                )
                .padding(.bottom, 4)
            }

            // Scene disclosure group
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    VStack(alignment: .leading, spacing: 8) {
                        // Filter out Scene Heading since it's already shown in the label
                        ForEach(scene.sceneElementModels.filter { $0.elementType != "Scene Heading" }.indices, id: \.self) { index in
                            let filteredElements = scene.sceneElementModels.filter { $0.elementType != "Scene Heading" }
                            SceneElementView(element: filteredElements[index])
                        }
                    }
                    .padding(.top, 8)
                },
                label: {
                    VStack(alignment: .leading, spacing: 4) {
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

                        // Display summary in collapsed state
                        if let summary = scene.summary, !isExpanded {
                            Text(summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Scene: \(scene.slugline)")
            .accessibilityHint(sceneElementsAccessibilityHint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .padding(.leading, 24) // Scene indent
    }
}

// MARK: - Scene Element Views

/// Internal view for rendering individual scene elements
struct SceneElementView: View {
    let element: GuionElementModel

    var body: some View {
        HStack(alignment: .top) {
            leadingSpacer

            Text(element.elementText)
                .font(fontForElement)
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

    private var fontForElement: Font {
        // Summary elements (Section Heading depth 4) get italic caption font
        if element.elementType == "Section Heading" && element.sectionDepth == 4 {
            return .system(.caption, design: .monospaced).italic()
        }
        return .system(.body, design: .monospaced)
    }

    private var colorForElement: Color {
        // Summary elements use secondary color
        if element.elementType == "Section Heading" && element.sectionDepth == 4 {
            return .secondary
        }

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
