//
//  GuionViewApp.swift
//  GuionView
//
//  Phase 1: Core Document Operations
//  Copyright (c) 2025
//

import SwiftUI
import SwiftData

/// Main application entry point for GuionView.
///
/// GuionView is a sample macOS application demonstrating the SwiftGuion library's capabilities.
/// It provides a complete document-based application for viewing screenplay files in multiple formats.
@main
struct GuionViewApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { GuionDocument() }) { file in
            ContentView(document: file.$document)
        }
        .commands {
            ImportCommands()
            ExportCommands()
        }
    }
}
