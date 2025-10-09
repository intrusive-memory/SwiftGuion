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
