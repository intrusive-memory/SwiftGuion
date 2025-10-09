//
//  GuionDocumentAppApp.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/9/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct GuionDocumentAppApp: App {
    var body: some Scene {
        DocumentGroup(editing: .itemDocument, migrationPlan: GuionDocumentAppMigrationPlan.self) {
            ContentView()
        }
    }
}

extension UTType {
    static var itemDocument: UTType {
        UTType(importedAs: "com.example.item-document")
    }
}

struct GuionDocumentAppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        GuionDocumentAppVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct GuionDocumentAppVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
