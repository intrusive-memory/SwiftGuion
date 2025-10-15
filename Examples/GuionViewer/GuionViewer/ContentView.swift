//
//  ContentView.swift
//  GuionViewer
//
//  Main content view using GuionViewer component
//  Phase 1: Read-only viewing with model-based data binding
//  Copyright (c) 2025
//

import SwiftUI
import SwiftGuion

/// Main content view for GuionViewer.
///
/// Uses the GuionViewer component from SwiftGuion to display screenplay content
/// with hierarchical scene browsing, chapters, and scene groups.
///
/// ## Architecture
///
/// ContentView binds to ViewerDocument's displayModel and extracts scene browser data
/// directly from the SwiftData model, maintaining reactivity for any future modifications
/// (like generated summaries).
struct ContentView: View {
    /// The document being viewed (read-only)
    var document: ViewerDocument

    var body: some View {
        if #available(macOS 14.0, *) {
            // Extract scene browser data from the SwiftData model
            // This maintains model references for reactive UI updates
            let browserData = document.displayModel.extractSceneBrowserData()

            GuionViewer(browserData: browserData)
                .frame(minWidth: 600, minHeight: 400)
                .navigationTitle(document.title)
                .navigationSubtitle(document.sourceURL?.path ?? "")
        } else {
            // Fallback for older macOS versions
            FallbackView(document: document)
        }
    }
}

/// Fallback view for macOS versions before 14.0
struct FallbackView: View {
    let document: ViewerDocument

    var body: some View {
        VStack(spacing: 20) {
            Text("GuionViewer")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Requires macOS 14.0 or later")
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Filename:")
                        .fontWeight(.semibold)
                    Text(document.originalFilename)
                }

                HStack {
                    Text("Title:")
                        .fontWeight(.semibold)
                    Text(document.title)
                }

                HStack {
                    Text("Scenes:")
                        .fontWeight(.semibold)
                    Text("\(document.sceneCount)")
                }

                HStack {
                    Text("Elements:")
                        .fontWeight(.semibold)
                    Text("\(document.displayModel.elements.count)")
                }

                HStack {
                    Text("Has Summaries:")
                        .fontWeight(.semibold)
                    Text(document.hasSummaries ? "Yes" : "No")
                }
            }
            .padding()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview("Empty Document") {
    ContentView(document: ViewerDocument())
}

#Preview("Fallback View") {
    FallbackView(document: ViewerDocument())
}
