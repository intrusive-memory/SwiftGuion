//
//  PreSceneBox.swift
//  SwiftGuion
//
//  Copyright (c) 2025
//
//  Expandable/collapsable box for OVER BLACK content attached to scenes
//

import SwiftUI
#if canImport(SwiftData)
import SwiftData
#endif

/// A collapsible box displaying pre-scene content (OVER BLACK) with an expandable disclosure
public struct PreSceneBox: View {
    let content: [GuionElement]
    @Binding var isExpanded: Bool

    /// Creates a PreSceneBox with the given content and expansion state
    /// - Parameters:
    ///   - content: Array of GuionElements representing the pre-scene content
    ///   - isExpanded: Binding to control the expanded/collapsed state
    public init(content: [GuionElement], isExpanded: Binding<Bool>) {
        self.content = content
        self._isExpanded = isExpanded
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with chevron
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)

                    Text("OVER BLACK")
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    Color.secondary.opacity(0.1)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("OVER BLACK content")
            .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand")
            .accessibilityAddTraits(.isButton)

            // Content (conditionally shown)
            if isExpanded {
                VStack(alignment: .center, spacing: 4) {
                    ForEach(content.indices, id: \.self) { index in
                        Text(content[index].elementText)
                            .font(.system(.body, design: .monospaced))
                            .italic()
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    Color.secondary.opacity(0.05)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview("PreScene Collapsed") {
    PreSceneBox(
        content: [
            GuionElement(type: "Action", text: "CHAPTER 1"),
            GuionElement(type: "Action", text: "BERNARD")
        ],
        isExpanded: .constant(false)
    )
    .padding()
}

#Preview("PreScene Expanded") {
    PreSceneBox(
        content: [
            GuionElement(type: "Action", text: "CHAPTER 1"),
            GuionElement(type: "Action", text: "BERNARD")
        ],
        isExpanded: .constant(true)
    )
    .padding()
}

#Preview("PreScene Long Content") {
    PreSceneBox(
        content: [
            GuionElement(type: "Action", text: "CHAPTER 2"),
            GuionElement(type: "Action", text: "KILLIAN"),
            GuionElement(type: "Action", text: "Over the sounds of a steam room, we hear...")
        ],
        isExpanded: .constant(true)
    )
    .padding()
}

// MARK: - SwiftData Model Version

#if canImport(SwiftData)
/// A collapsible box displaying pre-scene content from SwiftData models
public struct PreSceneBoxFromModels: View {
    let content: [GuionElementModel]
    @Binding var isExpanded: Bool

    /// Creates a PreSceneBoxFromModels with the given content and expansion state
    /// - Parameters:
    ///   - content: Array of GuionElementModels representing the pre-scene content
    ///   - isExpanded: Binding to control the expanded/collapsed state
    public init(content: [GuionElementModel], isExpanded: Binding<Bool>) {
        self.content = content
        self._isExpanded = isExpanded
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with chevron
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)

                    Text("OVER BLACK")
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    Color.secondary.opacity(0.1)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("OVER BLACK content")
            .accessibilityHint(isExpanded ? "Double tap to collapse" : "Double tap to expand")
            .accessibilityAddTraits(.isButton)

            // Content (conditionally shown)
            if isExpanded {
                VStack(alignment: .center, spacing: 4) {
                    ForEach(content.indices, id: \.self) { index in
                        Text(content[index].elementText)
                            .font(.system(.body, design: .monospaced))
                            .italic()
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    Color.secondary.opacity(0.05)
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}
#endif
