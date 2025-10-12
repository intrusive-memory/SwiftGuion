//
//  GuionDocumentAppApp.swift
//  GuionDocumentApp
//
//  Created by TOM STOVALL on 10/11/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import SwiftGuion

@main
struct GuionDocumentAppApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: GuionDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            ExportCommands()
        }
    }
}
