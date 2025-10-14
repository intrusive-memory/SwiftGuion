//
//  GuionViewerApp.swift
//  GuionViewer
//
//  Created by TOM STOVALL on 10/13/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct GuionViewerApp: App {
    var body: some Scene {
        DocumentGroup(editing: .itemDocument, migrationPlan: GuionViewerMigrationPlan.self) {
            ContentView()
        }
    }
}

extension UTType {
    static var itemDocument: UTType {
        UTType(importedAs: "com.example.item-document")
    }
}

struct GuionViewerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        GuionViewerVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct GuionViewerVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
