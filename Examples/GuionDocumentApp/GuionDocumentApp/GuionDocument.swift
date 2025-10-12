//
//  GuionDocument.swift
//  GuionDocumentApp
//
//  Copyright (c) 2025
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import SwiftGuion

extension UTType {
    static var guionDocument: UTType {
        UTType(exportedAs: "com.intrusive-memory.guion")
    }
}

struct GuionDocument: FileDocument {
    static var readableContentTypes: [UTType] {
        [.guionDocument, .fountain, .highland, .fdx]
    }

    static var writableContentTypes: [UTType] {
        [.guionDocument]
    }

    // Store data representation instead of live SwiftData models
    private var documentData: Data?
    private var script: FountainScript?

    // Computed property to get/create the model on demand
    @MainActor
    var documentModel: GuionDocumentModel {
        get {
            if let data = documentData {
                // Decode from stored data
                let schema = Schema([
                    GuionDocumentModel.self,
                    GuionElementModel.self,
                    TitlePageEntryModel.self,
                ])
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

                do {
                    let container = try ModelContainer(for: schema, configurations: [config])
                    let context = container.mainContext
                    return try GuionDocumentModel.decodeFromBinaryData(data, in: context)
                } catch {
                    // Fallback to empty document
                    return createEmptyModel()
                }
            } else if let script = script {
                // Create from script
                return createModelFromScript(script)
            } else {
                // Create empty
                return createEmptyModel()
            }
        }
    }

    @MainActor
    private func createEmptyModel() -> GuionDocumentModel {
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = container.mainContext
            let model = GuionDocumentModel(filename: "Untitled.guion")
            context.insert(model)
            return model
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    @MainActor
    private func createModelFromScript(_ script: FountainScript) -> GuionDocumentModel {
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = container.mainContext

            let model = GuionDocumentModel(
                filename: script.filename,
                rawContent: script.stringFromDocument(),
                suppressSceneNumbers: script.suppressSceneNumbers
            )

            // Convert title page
            for dictionary in script.titlePage {
                for (key, values) in dictionary {
                    let entry = TitlePageEntryModel(key: key, values: values)
                    entry.document = model
                    model.titlePage.append(entry)
                }
            }

            // Convert elements
            for element in script.elements {
                let elementModel = GuionElementModel(from: element)
                elementModel.document = model
                model.elements.append(elementModel)
            }

            context.insert(model)
            return model
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    nonisolated init() {
        self.documentData = nil
        self.script = nil
    }

    nonisolated init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let fileExtension = configuration.file.filename?.split(separator: ".").last?.lowercased() ?? ""

        switch fileExtension {
        case "guion":
            // Store the binary data for lazy decoding
            self.documentData = data
            self.script = nil

        case "fountain", "highland", "fdx":
            // Parse screenplay formats into FountainScript
            let parsedScript = FountainScript()

            // Create temp file for parsing
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(configuration.file.filename ?? "import.\(fileExtension)")
            try data.write(to: tempURL)

            switch fileExtension {
            case "fountain":
                try parsedScript.loadFile(tempURL.path)
            case "highland":
                try parsedScript.loadHighland(tempURL)
            case "fdx":
                let parser = FDXDocumentParser()
                let parsed = try parser.parse(data: data, filename: configuration.file.filename ?? "Untitled.fdx")

                // Convert FDX to FountainScript
                parsedScript.filename = parsed.filename
                parsedScript.suppressSceneNumbers = parsed.suppressSceneNumbers

                // Convert title page
                var titlePageArray: [[String: [String]]] = []
                for entry in parsed.titlePageEntries {
                    titlePageArray.append([entry.key: entry.values])
                }
                parsedScript.titlePage = titlePageArray

                // Convert elements
                parsedScript.elements = parsed.elements.map { GuionElement(from: $0) }

            default:
                throw CocoaError(.fileReadUnknown)
            }

            // Clean up temp file
            try? FileManager.default.removeItem(at: tempURL)

            // Update filename
            if let filename = configuration.file.filename {
                parsedScript.filename = transformFilename(filename)
            }

            // Store the script for lazy model creation
            self.documentData = nil
            self.script = parsedScript

        default:
            throw CocoaError(.fileReadUnknown)
        }
    }

    nonisolated func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // We need to encode the current state
        // Use documentData if available, otherwise we need to encode from script
        if let data = documentData {
            return FileWrapper(regularFileWithContents: data)
        } else {
            // This requires MainActor access, so we throw an error
            // The actual save will happen through a different mechanism
            throw CocoaError(.fileWriteUnknown)
        }
    }

    // MARK: - Export Methods

    /// Export to Fountain format
    @MainActor
    func exportToFountain() -> String {
        let script = GuionDocumentParserSwiftData.toFountainScript(from: documentModel)
        return script.stringFromDocument()
    }

    /// Export to FDX format
    @MainActor
    func exportToFDX() -> Data {
        return GuionDocumentParserSwiftData.toFDXData(from: documentModel)
    }

    /// Export to Highland format (uses Fountain format)
    @MainActor
    func exportToHighland() -> String {
        return exportToFountain()
    }

    // MARK: - Save Support

    /// Update the internal data representation for saving
    @MainActor
    mutating func updateForSave() throws {
        let data = try documentModel.encodeToBinaryData()
        self.documentData = data
        self.script = nil
    }

    // MARK: - Helper Methods

    /// Transform imported filenames to .guion extension
    private func transformFilename(_ filename: String?) -> String? {
        guard let original = filename else { return nil }
        let baseName = (original as NSString).deletingPathExtension
        return "\(baseName).guion"
    }
}

// UTType extensions for screenplay formats
extension UTType {
    static var fountain: UTType {
        UTType(importedAs: "com.quotes.fountain")
    }

    static var highland: UTType {
        UTType(importedAs: "com.johnaugust.highland")
    }

    static var fdx: UTType {
        UTType(importedAs: "com.finaldraft.fdx")
    }
}
