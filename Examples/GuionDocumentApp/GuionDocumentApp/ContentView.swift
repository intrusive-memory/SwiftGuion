//
//  ContentView.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/11/25.
//

import SwiftUI
import SwiftData
import SwiftGuion

struct ContentView: View {
    @Binding var document: GuionDocument

    var body: some View {
        VStack(spacing: 0) {
            if document.documentModel.elements.isEmpty {
                EmptyDocumentView()
            } else {
                SceneBrowserWidget(script: fountainScript)
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .focusedValue(\.document, document)
    }

    private var fountainScript: FountainScript {
        GuionDocumentParserSwiftData.toFountainScript(from: document.documentModel)
    }
}

struct EmptyDocumentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Empty Screenplay")
                .font(.title)
                .foregroundStyle(.secondary)

            Text("Import a screenplay file or start writing")
                .font(.body)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
