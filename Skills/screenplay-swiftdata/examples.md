# SwiftGuion Screenplay Import/Export Examples

This document provides practical, copy-paste examples for common SwiftGuion tasks.

## Table of Contents

1. [Basic Import](#basic-import)
2. [Import with Progress](#import-with-progress)
3. [Export to Fountain](#export-to-fountain)
4. [Export to Final Draft](#export-to-final-draft)
5. [Character Analysis](#character-analysis)
6. [Location Extraction](#location-extraction)
7. [Outline Generation](#outline-generation)
8. [SwiftUI Document List](#swiftui-document-list)
9. [File Drag & Drop](#file-drag--drop)
10. [Batch Import](#batch-import)

---

## Basic Import

Simple screenplay import with proper thread safety (parsing on background, SwiftData on main):

```swift
import SwiftData
import SwiftGuion

@MainActor
func importScreenplay(url: URL, modelContext: ModelContext) async throws {
    // Step 1: Parse the screenplay on BACKGROUND thread
    // GuionParsedScreenplay is Sendable and thread-safe
    let parsedCollection = try await GuionParsedScreenplay(
        file: url.path,
        parser: .fast
    )
    // Parsing happens automatically on background thread
    // parsedCollection is now available on main thread (Sendable)

    // Step 2: ALL SwiftData operations on MainActor (we're already here)
    // Create document model
    let document = GuionDocumentModel(
        filename: parsedCollection.filename ?? url.lastPathComponent,
        rawContent: nil,
        suppressSceneNumbers: parsedCollection.suppressSceneNumbers
    )

    modelContext.insert(document)

    // Convert elements with chapter tracking
    var currentChapter = 0
    var positionInChapter = 0

    for element in parsedCollection.elements {
        // Chapter detection: section heading level 2
        if case .sectionHeading(let level) = element.elementType, level == 2 {
            currentChapter += 1
            positionInChapter = 1
        } else {
            positionInChapter += 1
        }

        let elementModel = GuionElementModel(
            from: element,
            chapterIndex: currentChapter,
            orderIndex: positionInChapter
        )

        document.elements.append(elementModel)
        modelContext.insert(elementModel)
    }

    // Import title page
    for titlePageSection in parsedCollection.titlePage {
        for (key, values) in titlePageSection {
            for value in values {
                let entry = TitlePageEntryModel(key: key, values: [value])
                document.titlePage.append(entry)
                modelContext.insert(entry)
            }
        }
    }

    try modelContext.save()
}

// Usage:
Task { @MainActor in
    try await importScreenplay(url: fileURL, modelContext: modelContext)
}
```

---

## Import with Progress

Import with detailed progress reporting:

```swift
import SwiftUI
import SwiftData
import SwiftGuion

struct ProgressInfo {
    var fractionCompleted: Double
    var description: String
}

@MainActor
class ScreenplayImportViewModel: ObservableObject {
    @Published var progress: ProgressInfo?
    @Published var isImporting = false
    @Published var error: Error?

    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func importScreenplay(from url: URL) async {
        isImporting = true
        defer { isImporting = false }

        do {
            let progressHandler = OperationProgress(totalUnits: nil) { [weak self] update in
                Task { @MainActor in
                    self?.progress = ProgressInfo(
                        fractionCompleted: update.fractionCompleted ?? 0,
                        description: update.description
                    )
                }
            }

            let parsedCollection = try await GuionParsedScreenplay(
                file: url.path,
                parser: .fast,
                progress: progressHandler
            )

            let document = GuionDocumentModel(
                filename: parsedCollection.filename ?? url.lastPathComponent,
                rawContent: nil,
                suppressSceneNumbers: parsedCollection.suppressSceneNumbers
            )

            modelContext.insert(document)

            var currentChapter = 0
            var positionInChapter = 0

            for element in parsedCollection.elements {
                if case .sectionHeading(let level) = element.elementType, level == 2 {
                    currentChapter += 1
                    positionInChapter = 1
                } else {
                    positionInChapter += 1
                }

                let elementModel = GuionElementModel(
                    from: element,
                    chapterIndex: currentChapter,
                    orderIndex: positionInChapter
                )

                document.elements.append(elementModel)
                modelContext.insert(elementModel)
            }

            for titlePageSection in parsedCollection.titlePage {
                for (key, values) in titlePageSection {
                    for value in values {
                        let entry = TitlePageEntryModel(key: key, values: [value])
                        document.titlePage.append(entry)
                        modelContext.insert(entry)
                    }
                }
            }

            try modelContext.save()
            progress = nil

        } catch {
            self.error = error
        }
    }
}

// Usage in SwiftUI
struct ImportView: View {
    @StateObject private var viewModel: ScreenplayImportViewModel

    var body: some View {
        VStack {
            if viewModel.isImporting, let progress = viewModel.progress {
                VStack {
                    ProgressView(value: progress.fractionCompleted)
                    Text(progress.description)
                        .font(.caption)
                }
                .padding()
            }
        }
    }
}
```

---

## Export to Fountain

Export a SwiftData document to Fountain format:

```swift
import SwiftData
import SwiftGuion

func exportToFountain(document: GuionDocumentModel, to url: URL) throws {
    // Convert SwiftData to immutable screenplay
    let screenplay = document.toGuionParsedScreenplay()

    // Create Fountain writer
    let writer = FountainWriter(screenplay: screenplay)

    // Generate Fountain content
    let fountainContent = writer.write()

    // Write to file
    try fountainContent.write(to: url, atomically: true, encoding: .utf8)
}

// Example usage with file save panel
func exportWithFilePicker(document: GuionDocumentModel) {
    let savePanel = NSSavePanel()
    savePanel.allowedContentTypes = [
        UTType(filenameExtension: "fountain") ?? .plainText
    ]
    savePanel.nameFieldStringValue = document.filename ?? "screenplay.fountain"

    savePanel.begin { response in
        guard response == .OK, let url = savePanel.url else { return }

        do {
            try exportToFountain(document: document, to: url)
            print("Exported to: \(url.path)")
        } catch {
            print("Export error: \(error)")
        }
    }
}
```

---

## Export to Final Draft

Export to FDX (Final Draft XML) format:

```swift
import SwiftData
import SwiftGuion

func exportToFinalDraft(document: GuionDocumentModel, to url: URL) throws {
    // Convert SwiftData to immutable screenplay
    let screenplay = document.toGuionParsedScreenplay()

    // Create FDX writer
    let writer = FDXWriter(screenplay: screenplay)

    // Generate FDX content
    let fdxContent = writer.write()

    // Write to file
    try fdxContent.write(to: url, atomically: true, encoding: .utf8)
}

// Export with validation
func exportToFinalDraftWithValidation(
    document: GuionDocumentModel,
    to url: URL
) throws {
    guard !document.elements.isEmpty else {
        throw ExportError.emptyDocument
    }

    let screenplay = document.toGuionParsedScreenplay()
    let writer = FDXWriter(screenplay: screenplay)
    let fdxContent = writer.write()

    try fdxContent.write(to: url, atomically: true, encoding: .utf8)
}

enum ExportError: LocalizedError {
    case emptyDocument
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .emptyDocument:
            return "Cannot export empty document"
        case .invalidFormat:
            return "Invalid screenplay format"
        }
    }
}
```

---

## Character Analysis

Extract and analyze characters from a screenplay:

```swift
import SwiftData
import SwiftGuion

struct CharacterInfo {
    let name: String
    let lineCount: Int
    let category: CharacterCategory

    enum CharacterCategory {
        case major      // 20+ lines
        case minor      // 5-19 lines
        case bitPart    // 1-4 lines
    }

    var category: CharacterCategory {
        switch lineCount {
        case 20...:
            return .major
        case 5..<20:
            return .minor
        default:
            return .bitPart
        }
    }
}

func extractCharacters(from document: GuionDocumentModel) -> [CharacterInfo] {
    var characterLines: [String: Int] = [:]
    var currentCharacter: String?

    // Sort elements by screenplay order
    let sortedElements = document.elements.sorted {
        if $0.chapterIndex != $1.chapterIndex {
            return $0.chapterIndex < $1.chapterIndex
        }
        return $0.orderIndex < $1.orderIndex
    }

    for element in sortedElements {
        if element.elementType == .character {
            currentCharacter = element.elementText
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "^", with: "") // Remove dual dialogue marker
        } else if element.elementType == .dialogue, let character = currentCharacter {
            characterLines[character, default: 0] += 1
        } else if element.elementType == .sceneHeading {
            currentCharacter = nil
        }
    }

    return characterLines.map { name, count in
        CharacterInfo(name: name, lineCount: count)
    }
    .sorted { $0.lineCount > $1.lineCount }
}

// Alternative: Extract from immutable screenplay
func extractCharacters(from screenplay: GuionParsedScreenplay) -> [CharacterInfo] {
    let characters = screenplay.extractCharacters()

    return characters.map { character in
        CharacterInfo(
            name: character.name,
            lineCount: character.dialogueCount
        )
    }
    .sorted { $0.lineCount > $1.lineCount }
}

// Usage example
func analyzeCharacters(document: GuionDocumentModel) {
    let characters = extractCharacters(from: document)

    let major = characters.filter { $0.category == .major }
    let minor = characters.filter { $0.category == .minor }
    let bitParts = characters.filter { $0.category == .bitPart }

    print("Major Characters (\(major.count)):")
    major.forEach { print("  \($0.name): \($0.lineCount) lines") }

    print("\nMinor Characters (\(minor.count)):")
    minor.forEach { print("  \($0.name): \($0.lineCount) lines") }

    print("\nBit Parts (\(bitParts.count)):")
    bitParts.forEach { print("  \($0.name): \($0.lineCount) lines") }
}
```

---

## Location Extraction

Extract and organize scene locations:

```swift
import SwiftData
import SwiftGuion

struct LocationInfo {
    let lighting: SceneLocation.Lighting
    let scene: String
    let setup: String?
    let timeOfDay: String?
    let occurrenceCount: Int
}

func extractLocations(from document: GuionDocumentModel) -> [LocationInfo] {
    var locationCounts: [String: (location: SceneLocation, count: Int)] = [:]

    let sceneHeadings = document.elements.filter { $0.elementType == .sceneHeading }

    for heading in sceneHeadings {
        guard let location = heading.cachedSceneLocation else { continue }

        let key = "\(location.lighting.rawValue)|\(location.scene)|\(location.setup ?? "")|\(location.timeOfDay ?? "")"

        if var existing = locationCounts[key] {
            existing.count += 1
            locationCounts[key] = existing
        } else {
            locationCounts[key] = (location, 1)
        }
    }

    return locationCounts.values.map { location, count in
        LocationInfo(
            lighting: location.lighting,
            scene: location.scene,
            setup: location.setup,
            timeOfDay: location.timeOfDay,
            occurrenceCount: count
        )
    }
    .sorted {
        // Sort by lighting, then scene name
        if $0.lighting != $1.lighting {
            return $0.lighting.rawValue < $1.lighting.rawValue
        }
        return $0.scene < $1.scene
    }
}

// Group locations by INT/EXT
func groupLocationsByLighting(
    _ locations: [LocationInfo]
) -> [SceneLocation.Lighting: [LocationInfo]] {
    Dictionary(grouping: locations) { $0.lighting }
}

// Usage example
func analyzeLocations(document: GuionDocumentModel) {
    let locations = extractLocations(from: document)
    let grouped = groupLocationsByLighting(locations)

    for (lighting, locationList) in grouped.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
        print("\n\(lighting.rawValue) Locations:")
        for location in locationList {
            let setup = location.setup.map { " - \($0)" } ?? ""
            let time = location.timeOfDay.map { " - \($0)" } ?? ""
            print("  \(location.scene)\(setup)\(time) (\(location.occurrenceCount)x)")
        }
    }
}
```

---

## Outline Generation

Generate hierarchical outline from section headings:

```swift
import SwiftData
import SwiftGuion

struct OutlineNode {
    let text: String
    let level: Int
    let elementIndex: Int
    var children: [OutlineNode] = []
}

func extractOutline(from document: GuionDocumentModel) -> [OutlineNode] {
    let outlineElements = document.elements
        .filter { element in
            element.elementType == .synopsis || element.elementType.isSectionHeading
        }
        .sorted {
            if $0.chapterIndex != $1.chapterIndex {
                return $0.chapterIndex < $1.chapterIndex
            }
            return $0.orderIndex < $1.orderIndex
        }

    var rootNodes: [OutlineNode] = []
    var nodeStack: [OutlineNode] = []

    for (index, element) in outlineElements.enumerated() {
        let level: Int
        if element.elementType == .synopsis {
            level = 99 // Synopsis always at deepest level
        } else if case .sectionHeading(let headingLevel) = element.elementType {
            level = headingLevel
        } else {
            continue
        }

        let node = OutlineNode(
            text: element.elementText,
            level: level,
            elementIndex: index
        )

        // Pop nodes until we find parent level
        while let last = nodeStack.last, last.level >= level {
            nodeStack.removeLast()
        }

        if let parent = nodeStack.last {
            var mutableParent = parent
            mutableParent.children.append(node)
            nodeStack[nodeStack.count - 1] = mutableParent
        } else {
            rootNodes.append(node)
        }

        nodeStack.append(node)
    }

    return rootNodes
}

// Print outline with indentation
func printOutline(_ nodes: [OutlineNode], indent: Int = 0) {
    for node in nodes {
        let prefix = String(repeating: "  ", count: indent)
        print("\(prefix)- \(node.text)")
        printOutline(node.children, indent: indent + 1)
    }
}

// Alternative: Using built-in outline extraction
func extractOutlineSimple(from screenplay: GuionParsedScreenplay) -> [GuionElement] {
    return screenplay.extractOutline()
}

// Get hierarchical tree
func extractOutlineTree(from screenplay: GuionParsedScreenplay) -> [OutlineElement] {
    return screenplay.extractOutlineTree()
}
```

---

## SwiftUI Document List

Complete SwiftUI view for managing screenplay documents:

```swift
import SwiftUI
import SwiftData
import SwiftGuion
import UniformTypeIdentifiers

struct ScreenplayListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GuionDocumentModel.filename) private var documents: [GuionDocumentModel]

    @State private var selectedDocument: GuionDocumentModel?
    @State private var showingImporter = false
    @State private var importError: Error?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedDocument) {
                ForEach(documents) { document in
                    NavigationLink(value: document) {
                        VStack(alignment: .leading) {
                            Text(document.filename ?? "Untitled")
                                .font(.headline)

                            Text("\(document.elements.count) elements")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteDocuments)
            }
            .navigationTitle("Screenplays")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import", systemImage: "plus")
                    }
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [
                    UTType(filenameExtension: "fountain") ?? .plainText,
                    UTType(filenameExtension: "fdx") ?? .xml,
                    UTType(filenameExtension: "highland") ?? .zip
                ],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
        } detail: {
            if let document = selectedDocument {
                GuionViewer(document: document)
            } else {
                ContentUnavailableView(
                    "Select a Screenplay",
                    systemImage: "doc.text",
                    description: Text("Choose a screenplay from the list")
                )
            }
        }
    }

    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            Task {
                await importScreenplay(from: url)
            }
        case .failure(let error):
            importError = error
        }
    }

    private func importScreenplay(from url: URL) async {
        do {
            let parsedCollection = try await GuionParsedScreenplay(
                file: url.path,
                parser: .fast
            )

            await MainActor.run {
                let document = GuionDocumentModel(
                    filename: parsedCollection.filename ?? url.lastPathComponent,
                    rawContent: nil,
                    suppressSceneNumbers: parsedCollection.suppressSceneNumbers
                )

                modelContext.insert(document)

                var currentChapter = 0
                var positionInChapter = 0

                for element in parsedCollection.elements {
                    if case .sectionHeading(let level) = element.elementType, level == 2 {
                        currentChapter += 1
                        positionInChapter = 1
                    } else {
                        positionInChapter += 1
                    }

                    let elementModel = GuionElementModel(
                        from: element,
                        chapterIndex: currentChapter,
                        orderIndex: positionInChapter
                    )

                    document.elements.append(elementModel)
                    modelContext.insert(elementModel)
                }

                try? modelContext.save()
                selectedDocument = document
            }
        } catch {
            await MainActor.run {
                importError = error
            }
        }
    }

    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(documents[index])
        }
    }
}
```

---

## File Drag & Drop

Implement drag and drop for screenplay files:

```swift
import SwiftUI
import SwiftData
import SwiftGuion
import UniformTypeIdentifiers

struct ScreenplayDropZone: View {
    @Environment(\.modelContext) private var modelContext

    @State private var isTargeted = false
    @State private var importError: Error?

    let supportedTypes: [UTType] = [
        UTType(filenameExtension: "fountain") ?? .plainText,
        UTType(filenameExtension: "fdx") ?? .xml,
        UTType(filenameExtension: "highland") ?? .zip
    ]

    var body: some View {
        VStack {
            ContentUnavailableView {
                Label("Drop Screenplay Here", systemImage: "doc.badge.plus")
            } description: {
                Text("Supports .fountain, .fdx, and .highland files")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(isTargeted ? Color.accentColor.opacity(0.1) : Color.clear)
        }
        .onDrop(of: supportedTypes, isTargeted: $isTargeted) { providers in
            handleDrop(providers: providers)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, error in
            guard error == nil,
                  let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }

            Task {
                await importScreenplay(from: url)
            }
        }

        return true
    }

    private func importScreenplay(from url: URL) async {
        do {
            let parsedCollection = try await GuionParsedScreenplay(
                file: url.path,
                parser: .fast
            )

            await MainActor.run {
                let document = GuionDocumentModel(
                    filename: parsedCollection.filename ?? url.lastPathComponent,
                    rawContent: nil,
                    suppressSceneNumbers: parsedCollection.suppressSceneNumbers
                )

                modelContext.insert(document)

                var currentChapter = 0
                var positionInChapter = 0

                for element in parsedCollection.elements {
                    if case .sectionHeading(let level) = element.elementType, level == 2 {
                        currentChapter += 1
                        positionInChapter = 1
                    } else {
                        positionInChapter += 1
                    }

                    let elementModel = GuionElementModel(
                        from: element,
                        chapterIndex: currentChapter,
                        orderIndex: positionInChapter
                    )

                    document.elements.append(elementModel)
                    modelContext.insert(elementModel)
                }

                try? modelContext.save()
            }
        } catch {
            await MainActor.run {
                importError = error
            }
        }
    }
}
```

---

## Batch Import

Import multiple screenplay files:

```swift
import SwiftData
import SwiftGuion

/// Parser actor - handles parsing on background threads
actor ScreenplayBatchParser {
    /// Parse multiple screenplays, returning Sendable parsed data
    func parseScreenplays(
        from urls: [URL],
        onProgress: @escaping @Sendable (Int, Int, String) -> Void
    ) async throws -> [(URL, GuionParsedScreenplay)] {
        var results: [(URL, GuionParsedScreenplay)] = []

        for (index, url) in urls.enumerated() {
            await onProgress(index + 1, urls.count, url.lastPathComponent)

            let parsedCollection = try await GuionParsedScreenplay(
                file: url.path,
                parser: .fast
            )

            results.append((url, parsedCollection))
        }

        return results
    }
}

/// Persister - handles SwiftData operations on MainActor only
@MainActor
class ScreenplayBatchPersister {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Persist multiple parsed screenplays (must be on MainActor)
    func persistScreenplays(
        _ parsedData: [(URL, GuionParsedScreenplay)]
    ) throws -> [GuionDocumentModel] {
        var documents: [GuionDocumentModel] = []

        for (url, parsedCollection) in parsedData {
            let document = try persistScreenplay(parsedCollection, sourceURL: url)
            documents.append(document)
        }

        try modelContext.save()
        return documents
    }

    private func persistScreenplay(
        _ parsedCollection: GuionParsedScreenplay,
        sourceURL: URL
    ) throws -> GuionDocumentModel {
        let document = GuionDocumentModel(
            filename: parsedCollection.filename ?? sourceURL.lastPathComponent,
            rawContent: nil,
            suppressSceneNumbers: parsedCollection.suppressSceneNumbers
        )

        modelContext.insert(document)

        var currentChapter = 0
        var positionInChapter = 0

        for element in parsedCollection.elements {
            if case .sectionHeading(let level) = element.elementType, level == 2 {
                currentChapter += 1
                positionInChapter = 1
            } else {
                positionInChapter += 1
            }

            let elementModel = GuionElementModel(
                from: element,
                chapterIndex: currentChapter,
                orderIndex: positionInChapter
            )

            document.elements.append(elementModel)
            modelContext.insert(elementModel)
        }

        for titlePageSection in parsedCollection.titlePage {
            for (key, values) in titlePageSection {
                for value in values {
                    let entry = TitlePageEntryModel(key: key, values: [value])
                    document.titlePage.append(entry)
                    modelContext.insert(entry)
                }
            }
        }

        return document
    }
}

// Usage
@MainActor
class BatchImportViewModel: ObservableObject {
    @Published var currentFile: String = ""
    @Published var progress: (current: Int, total: Int) = (0, 0)
    @Published var isImporting = false

    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func importFiles(_ urls: [URL]) async throws {
        isImporting = true
        defer { isImporting = false }

        // Parse on background thread
        let parser = ScreenplayBatchParser()
        let parsedData = try await parser.parseScreenplays(from: urls) { current, total, filename in
            Task { @MainActor in
                self.currentFile = filename
                self.progress = (current, total)
            }
        }

        // Persist on main thread (we're already on MainActor)
        let persister = ScreenplayBatchPersister(modelContext: modelContext)
        _ = try persister.persistScreenplays(parsedData)
    }
}
```

---

## Testing Examples

Unit tests for SwiftGuion functionality:

```swift
import XCTest
import SwiftData
@testable import SwiftGuion

final class ScreenplayImportTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: GuionDocumentModel.self,
            configurations: config
        )
        modelContext = modelContainer.mainContext
    }

    func testBasicImport() async throws {
        let fountainContent = """
        INT. TEST SCENE - DAY

        Action line.

        CHARACTER
        Dialogue line.
        """

        let parsedCollection = try await GuionParsedScreenplay(
            string: fountainContent
        )

        let document = GuionDocumentModel(
            filename: "test.fountain",
            rawContent: nil,
            suppressSceneNumbers: false
        )

        modelContext.insert(document)

        for element in parsedCollection.elements {
            let model = GuionElementModel(
                from: element,
                chapterIndex: 0,
                orderIndex: 0
            )
            document.elements.append(model)
            modelContext.insert(model)
        }

        try modelContext.save()

        XCTAssertEqual(document.elements.count, 3)
        XCTAssertEqual(document.elements[0].elementType, .sceneHeading)
        XCTAssertEqual(document.elements[1].elementType, .action)
        XCTAssertEqual(document.elements[2].elementType, .character)
    }

    func testChapterIndexing() async throws {
        let fountainContent = """
        ## Chapter One

        INT. SCENE ONE - DAY

        Action.

        ## Chapter Two

        INT. SCENE TWO - DAY

        More action.
        """

        let parsedCollection = try await GuionParsedScreenplay(
            string: fountainContent
        )

        var currentChapter = 0
        var positionInChapter = 0

        for element in parsedCollection.elements {
            if case .sectionHeading(let level) = element.elementType, level == 2 {
                currentChapter += 1
                positionInChapter = 1
            } else {
                positionInChapter += 1
            }

            let model = GuionElementModel(
                from: element,
                chapterIndex: currentChapter,
                orderIndex: positionInChapter
            )

            // Verify chapter indices
            if element.elementType == .sceneHeading {
                if element.elementText.contains("SCENE ONE") {
                    XCTAssertEqual(model.chapterIndex, 1)
                } else if element.elementText.contains("SCENE TWO") {
                    XCTAssertEqual(model.chapterIndex, 2)
                }
            }
        }
    }
}
```

---

## Additional Resources

- **SwiftGuion Documentation**: [README.md](../../README.md)
- **API Guide**: [Docs/GUION_VIEWER_API.md](../../Docs/GUION_VIEWER_API.md)
- **Produciesta Example**: [../Produciesta](../../../Produciesta)
- **Fountain Specification**: https://fountain.io

For more complex examples, see the Produciesta app source code or the SwiftGuion test suite.
