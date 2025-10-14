//
//  GuionViewerApp.swift
//  GuionViewer
//
//  Phase 1: Core Document Operations
//  Copyright (c) 2025
//

import SwiftUI
import SwiftData

/// Main application entry point for GuionViewer.
///
/// GuionViewer is a sample macOS application demonstrating the SwiftGuion library's capabilities.
/// It provides a complete document-based application for viewing screenplay files in multiple formats.
@main
struct GuionViewerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: GuionDocument.init) { file in
            ContentView(document: file.document)
        }
        .commands {
            ImportCommands()
            ExportCommands()
        }
    }
}
