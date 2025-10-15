//
//  GuionViewerApp.swift
//  GuionViewer
//
//  Phase 1: Read-Only Viewer (no auto-save, no editing)
//  Copyright (c) 2025
//

import SwiftUI
import UniformTypeIdentifiers

/// Main application entry point for GuionViewer.
///
/// GuionViewer is a read-only screenplay viewer similar to Preview.app:
/// - Opens files in read-only mode
/// - No auto-save or file monitoring
/// - Original files never modified (except via explicit "Save As → Replace")
/// - Export creates new files
///
/// ## Architecture
///
/// Unlike a DocumentGroup app, GuionViewer uses WindowGroup to maintain full control
/// over file operations. This allows implementing the read-only viewer pattern where
/// files are never modified unless the user explicitly chooses to replace them.
@main
struct GuionViewerApp: App {
    /// Shared state for managing open documents
    @State private var documentManager = DocumentManager()

    var body: some Scene {
        // Main viewer window
        WindowGroup(id: "viewer") {
            if let document = documentManager.currentDocument {
                ContentView(document: document)
                    .frame(minWidth: 600, minHeight: 400)
            } else {
                WelcomeView()
                    .frame(width: 500, height: 400)
            }
        }
        .commands {
            ViewerFileCommands(documentManager: documentManager)
        }
    }
}

/// Manager for open documents
@Observable
class DocumentManager {
    /// Currently displayed document
    var currentDocument: ViewerDocument?

    /// Open a file in read-only mode
    @MainActor
    func openFile(_ url: URL) throws {
        let document = try ViewerDocument(contentsOf: url)
        self.currentDocument = document
    }

    /// Create a new empty document
    @MainActor
    func createNew() {
        self.currentDocument = ViewerDocument()
    }

    /// Close the current document
    func closeDocument() {
        self.currentDocument = nil
    }
}

/// Welcome screen shown when no document is open
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "doc.text")
                .font(.system(size: 72))
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                Text("GuionViewer")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Read-Only Screenplay Viewer")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Text("Open a screenplay file to begin")
                    .foregroundStyle(.secondary)

                Text("File → Open... or drag a file here")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Divider()
                .frame(width: 200)

            VStack(alignment: .leading, spacing: 4) {
                Text("Supported Formats:")
                    .font(.caption)
                    .fontWeight(.semibold)

                Text("• .guion (SwiftGuion native)")
                    .font(.caption)
                Text("• .fountain (Fountain format)")
                    .font(.caption)
                Text("• .fdx (Final Draft)")
                    .font(.caption)
                Text("• .highland (Highland 2)")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(40)
    }
}

#Preview("Welcome Screen") {
    WelcomeView()
}
