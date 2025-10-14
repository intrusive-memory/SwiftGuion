//
//  ContentView.swift
//  GuionView
//
//  Phase 1: Core Document Operations (Minimal View)
//  Copyright (c) 2025
//

import SwiftUI

/// Main content view for GuionView.
///
/// **Phase 1**: Displays simple document info to verify import/export functionality.
/// **Phase 2**: Will be replaced with GuionViewer component.
struct ContentView: View {
    @Binding var document: GuionDocument

    var body: some View {
        VStack(spacing: 20) {
            Text("GuionView")
                .font(.largeTitle)
                .fontWeight(.bold)

            Divider()

            Text("Document Loaded")
                .font(.headline)

            Text(document.documentModel.filename.isEmpty ? "Untitled" : document.documentModel.filename)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("\(document.documentModel.elements.count) elements")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()

            Text("Phase 1: Core Document Operations")
                .font(.caption)
                .foregroundStyle(.quaternary)
                .padding(.bottom)
        }
        .padding()
        .frame(minWidth: 600, minHeight: 800)
    }
}

#Preview {
    ContentView(document: .constant(GuionDocument()))
}
