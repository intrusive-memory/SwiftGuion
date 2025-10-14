//
//  ContentView.swift
//  GuionViewer
//
//  Phase 1: Core Document Operations
//  Copyright (c) 2025
//

import SwiftUI
import SwiftGuion

/// Main content view for GuionViewer.
///
/// Phase 1: Displays basic document information (filename and element count).
struct ContentView: View {
    @ObservedObject var document: GuionDocument

    var body: some View {
        VStack(spacing: 20) {
            Text("GuionViewer")
                .font(.largeTitle)
                .fontWeight(.bold)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Filename:")
                        .fontWeight(.semibold)
                    Text(document.documentModel.filename ?? "Untitled")
                }

                HStack {
                    Text("Elements:")
                        .fontWeight(.semibold)
                    Text("\(document.documentModel.elements.count)")
                }

                HStack {
                    Text("Title Page Entries:")
                        .fontWeight(.semibold)
                    Text("\(document.documentModel.titlePage.count)")
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)

            Spacer()

            Text("Phase 1: Core Document Operations")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    ContentView(document: GuionDocument())
}
