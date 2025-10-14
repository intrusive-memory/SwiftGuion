//
//  Guio_nViewerApp.swift
//  GuiónViewer
//
//  Created by TOM STOVALL on 10/13/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct Guio_nViewerApp: App {
    var body: some Scene {
        DocumentGroup(editing: .itemDocument, migrationPlan: Guio_nViewerMigrationPlan.self) {
            ContentView()
        }
    }
}

extension UTType {
    static var itemDocument: UTType {
        UTType(importedAs: "com.example.item-document")
    }
}

struct Guio_nViewerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        Guio_nViewerVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct Guio_nViewerVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
