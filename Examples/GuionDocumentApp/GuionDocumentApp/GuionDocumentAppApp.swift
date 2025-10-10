//
//  GuionDocumentAppApp.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/9/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import SwiftGuion

@main
struct GuionDocumentAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        DocumentGroup(newDocument: GuionDocumentConfiguration()) { file in
            ContentView(configuration: file.$document)
                .modelContainer(sharedModelContainer)
        }
        .commands {
            ExportCommands()
        }

        #if os(macOS)
        // Auxiliary windows can be opened via menu commands
        WindowGroup(id: "locations", for: String.self) { $documentID in
            LocationsWindowView(documentID: documentID)
                .modelContainer(sharedModelContainer)
        }

        WindowGroup(id: "characters", for: String.self) { $documentID in
            CharactersWindowView(documentID: documentID)
                .modelContainer(sharedModelContainer)
        }
        #endif
    }
}

/// Custom menu commands for export functionality
struct ExportCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .saveItem) {
            Divider()

            Button("Export as Fountain...") {
                NotificationCenter.default.post(name: .exportAsFountain, object: nil)
            }
            .keyboardShortcut("E", modifiers: [.command, .shift])

            Button("Export as Final Draft...") {
                NotificationCenter.default.post(name: .exportAsFDX, object: nil)
            }
            .keyboardShortcut("D", modifiers: [.command, .shift])
        }
    }
}

// Notification names for export commands
extension Notification.Name {
    static let exportAsFountain = Notification.Name("exportAsFountain")
    static let exportAsFDX = Notification.Name("exportAsFDX")
}

extension UTType {
    static var guionDocument: UTType {
        UTType(importedAs: "com.swiftguion.screenplay")
    }

    static var fdxDocument: UTType {
        UTType(importedAs: "com.finaldraft.fdx")
    }

    static var fountainDocument: UTType {
        UTType(importedAs: "com.fountain")
    }

    static var highlandDocument: UTType {
        UTType(importedAs: "com.highland")
    }
}
