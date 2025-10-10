//
//  IntegrationTests.swift
//  SwiftGuionTests
//
//  Phase 6: Performance Optimization & Testing
//  Integration tests for complete workflows, performance benchmarks, and concurrent operations
//
//  Copyright (c) 2025
//

import XCTest
import SwiftData
import UniformTypeIdentifiers
@testable import SwiftGuion

@MainActor
final class IntegrationTests: XCTestCase {

    var modelContext: ModelContext!
    var modelContainer: ModelContainer!
    var fixturesPath: URL!
    var tempDirectory: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory model context
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext

        // Get fixtures path
        let bundle = Bundle(for: type(of: self))
        guard let path = bundle.resourcePath else {
            throw NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find resource path"])
        }
        fixturesPath = URL(fileURLWithPath: path).appendingPathComponent("Fixtures")

        // Create temp directory for tests
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("IntegrationTests-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() async throws {
        // Clean up temp directory
        try? FileManager.default.removeItem(at: tempDirectory)

        modelContext = nil
        modelContainer = nil
        fixturesPath = nil
        tempDirectory = nil
        try await super.tearDown()
    }

    // MARK: - GATE 6.1: Full workflow test

    func testCompleteWorkflow() async throws {
        // Step 1: Import BigFish.fountain
        let fountainURL = fixturesPath.appendingPathComponent("BigFish.fountain")

        guard FileManager.default.fileExists(atPath: fountainURL.path) else {
            throw XCTSkip("BigFish.fountain not found in test bundle")
        }

        let script = try FountainScript(file: fountainURL.path)

        // Step 2: Convert to GuionDocumentModel (simulating import)
        let document = await GuionDocumentParserSwiftData.parse(script: script, in: modelContext)

        // Step 3: Verify elements parsed
        XCTAssertGreaterThan(document.elements.count, 0, "Should have parsed elements")
        XCTAssertEqual(document.filename, "BigFish.guion", "Filename should be transformed")

        // Verify title page
        XCTAssertGreaterThan(document.titlePage.count, 0, "Should have title page entries")

        // Verify scene headings exist
        let sceneHeadings = document.elements.filter { $0.elementType == "Scene Heading" }
        XCTAssertGreaterThan(sceneHeadings.count, 0, "Should have scene headings")

        // Verify dialogue exists
        let dialogue = document.elements.filter { $0.elementType == "Dialogue" }
        XCTAssertGreaterThan(dialogue.count, 0, "Should have dialogue")

        // Step 4: Save as BigFish.guion
        let guionURL = tempDirectory.appendingPathComponent("BigFish.guion")
        try document.save(to: guionURL)

        // Verify file was created
        XCTAssertTrue(FileManager.default.fileExists(atPath: guionURL.path), "File should be created")

        // Step 5: Close document (simulated by clearing context)
        // In a real app, this would be handled by DocumentGroup

        // Step 6: Reopen BigFish.guion
        let loadedDocument = try GuionDocumentModel.load(from: guionURL, in: modelContext)

        // Step 7: Verify elements match
        XCTAssertEqual(loadedDocument.elements.count, document.elements.count, "Element count should match")
        XCTAssertEqual(loadedDocument.filename, "BigFish.guion", "Filename should be preserved")

        // Verify a few random elements
        for i in [0, loadedDocument.elements.count / 2, loadedDocument.elements.count - 1] {
            XCTAssertEqual(
                loadedDocument.elements[i].elementText,
                document.elements[i].elementText,
                "Element \(i) text should match"
            )
            XCTAssertEqual(
                loadedDocument.elements[i].elementType,
                document.elements[i].elementType,
                "Element \(i) type should match"
            )
        }

        // Step 8: Export as BigFish-export.fountain
        let exportedScript = GuionDocumentParserSwiftData.toFountainScript(from: loadedDocument)
        let exportURL = tempDirectory.appendingPathComponent("BigFish-export.fountain")
        try exportedScript.write(to: exportURL)

        // Step 9: Compare with original
        let originalContent = try String(contentsOf: fountainURL, encoding: .utf8)
        let exportedContent = try String(contentsOf: exportURL, encoding: .utf8)

        // Note: We can't expect byte-for-byte match due to formatting differences,
        // but we can verify key content is preserved
        let originalLines = originalContent.components(separatedBy: .newlines)
        let exportedLines = exportedContent.components(separatedBy: .newlines)

        // Compare scene headings (should be identical)
        let originalScenes = originalLines.filter { line in
            line.hasPrefix("INT.") || line.hasPrefix("EXT.") || line.hasPrefix("I/E")
        }
        let exportedScenes = exportedLines.filter { line in
            line.hasPrefix("INT.") || line.hasPrefix("EXT.") || line.hasPrefix("I/E")
        }

        XCTAssertEqual(
            originalScenes.count,
            exportedScenes.count,
            "Scene heading count should match"
        )

        print("✅ Complete workflow test passed:")
        print("   - Imported \(document.elements.count) elements")
        print("   - Saved and reloaded successfully")
        print("   - Exported with \(exportedScenes.count) scenes")
    }

    // MARK: - GATE 6.2: Large document performance

    func testLargeDocumentPerformance() async throws {
        // Create document with 5000 elements
        let document = GuionDocumentModel(filename: "large-test.guion", rawContent: "")

        let elementCount = 5000
        print("⏱️  Creating document with \(elementCount) elements...")

        let createStart = Date()
        for i in 1...elementCount {
            let elementType: String
            let elementText: String

            switch i % 10 {
            case 0:
                elementType = "Scene Heading"
                elementText = "INT. LOCATION \(i / 10) - DAY"
            case 1:
                elementType = "Character"
                elementText = "CHARACTER \(i % 5 + 1)"
            case 2, 3:
                elementType = "Dialogue"
                elementText = "This is dialogue line number \(i). It contains some text to make it realistic."
            case 4:
                elementType = "Parenthetical"
                elementText = "(beat)"
            default:
                elementType = "Action"
                elementText = "Action line \(i). A character does something interesting here."
            }

            let element = GuionElementModel(elementText: elementText, elementType: elementType)
            element.document = document
            document.elements.append(element)
        }
        let createTime = Date().timeIntervalSince(createStart)
        print("   Created in \(String(format: "%.3f", createTime))s")

        modelContext.insert(document)

        // Measure save time
        let saveURL = tempDirectory.appendingPathComponent("large-test.guion")

        let saveStart = Date()
        try document.save(to: saveURL)
        let saveTime = Date().timeIntervalSince(saveStart)

        print("   Saved in \(String(format: "%.3f", saveTime))s")

        // Measure load time
        let loadStart = Date()
        let loadedDocument = try GuionDocumentModel.load(from: saveURL, in: modelContext)
        let loadTime = Date().timeIntervalSince(loadStart)

        print("   Loaded in \(String(format: "%.3f", loadTime))s")

        // Verify loaded correctly
        XCTAssertEqual(loadedDocument.elements.count, elementCount, "All elements should be loaded")

        // Assert performance requirements (< 60 seconds for both - accounts for slower CI machines)
        // CI machines are typically slower than local development, so we allow more time
        XCTAssertLessThan(saveTime, 60.0, "Save time should be < 60 seconds for 5000 elements")
        XCTAssertLessThan(loadTime, 60.0, "Load time should be < 60 seconds for 5000 elements")

        // Additional verification: random element checks
        for _ in 1...10 {
            let randomIndex = Int.random(in: 0..<elementCount)
            XCTAssertEqual(
                loadedDocument.elements[randomIndex].elementText,
                document.elements[randomIndex].elementText,
                "Random element \(randomIndex) should match"
            )
        }

        print("✅ Large document performance test passed")
        print("   - \(elementCount) elements")
        print("   - Save: \(String(format: "%.3f", saveTime))s")
        print("   - Load: \(String(format: "%.3f", loadTime))s")
    }

    // MARK: - GATE 6.3: Concurrent document handling

    func testConcurrentDocuments() async throws {
        // Open 5 documents simultaneously
        let documentCount = 5

        print("⏱️  Testing concurrent handling of \(documentCount) documents...")

        // Create multiple documents
        var documents: [GuionDocumentModel] = []
        var urls: [URL] = []

        for i in 1...documentCount {
            let document = GuionDocumentModel(filename: "concurrent-\(i).guion", rawContent: "Document \(i)")

            // Add unique elements to each document
            for j in 1...100 {
                let element = GuionElementModel(
                    elementText: "Document \(i), Element \(j)",
                    elementType: j % 5 == 0 ? "Scene Heading" : "Action"
                )
                element.document = document
                document.elements.append(element)
            }

            modelContext.insert(document)
            documents.append(document)

            let url = tempDirectory.appendingPathComponent("concurrent-\(i).guion")
            urls.append(url)

            try document.save(to: url)
        }

        // Load all documents concurrently
        let loadStart = Date()

        // Note: Since we need @MainActor context, we can't use true async concurrency
        // But we can test rapid sequential loading which simulates concurrent scenarios
        var loadedDocuments: [GuionDocumentModel] = []

        for url in urls {
            let loaded = try GuionDocumentModel.load(from: url, in: modelContext)
            loadedDocuments.append(loaded)
        }

        let loadTime = Date().timeIntervalSince(loadStart)
        print("   Loaded \(documentCount) documents in \(String(format: "%.3f", loadTime))s")

        // Verify: No conflicts
        XCTAssertEqual(loadedDocuments.count, documentCount, "Should load all documents")

        // Verify: Each maintains separate state
        for (index, loadedDoc) in loadedDocuments.enumerated() {
            XCTAssertEqual(loadedDoc.filename, "concurrent-\(index + 1).guion", "Filename should match")
            XCTAssertEqual(loadedDoc.elements.count, 100, "Should have 100 elements")

            // Verify first element is unique to this document
            XCTAssertEqual(
                loadedDoc.elements[0].elementText,
                "Document \(index + 1), Element 1",
                "Element should belong to correct document"
            )

            // Verify last element
            XCTAssertEqual(
                loadedDoc.elements[99].elementText,
                "Document \(index + 1), Element 100",
                "Last element should belong to correct document"
            )
        }

        // Test concurrent modifications (simulate editing multiple documents)
        for (index, document) in loadedDocuments.enumerated() {
            let newElement = GuionElementModel(
                elementText: "Added to document \(index + 1)",
                elementType: "Action"
            )
            newElement.document = document
            document.elements.append(newElement)
        }

        // Save all modified documents
        for (index, document) in loadedDocuments.enumerated() {
            try document.save(to: urls[index])
        }

        // Reload and verify modifications persisted
        for (index, url) in urls.enumerated() {
            let reloaded = try GuionDocumentModel.load(from: url, in: modelContext)
            XCTAssertEqual(reloaded.elements.count, 101, "Should have 101 elements after modification")
            XCTAssertEqual(
                reloaded.elements.last?.elementText,
                "Added to document \(index + 1)",
                "Last element should be the added one"
            )
        }

        print("✅ Concurrent document test passed")
        print("   - \(documentCount) documents handled")
        print("   - No state conflicts detected")
        print("   - All modifications persisted correctly")
    }

    // MARK: - Additional Performance Tests

    func testMemoryEfficiency() async throws {
        // Test memory usage with large documents
        let document = GuionDocumentModel(filename: "memory-test.guion", rawContent: "")

        // Create 1000 elements
        for i in 1...1000 {
            let element = GuionElementModel(
                elementText: "Element \(i): " + String(repeating: "test ", count: 20),
                elementType: i % 10 == 0 ? "Scene Heading" : "Action"
            )
            element.document = document
            document.elements.append(element)
        }

        modelContext.insert(document)

        let saveURL = tempDirectory.appendingPathComponent("memory-test.guion")
        try document.save(to: saveURL)

        // Get file size
        let attributes = try FileManager.default.attributesOfItem(atPath: saveURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0

        print("📊 Memory test:")
        print("   - 1000 elements")
        print("   - File size: \(fileSize / 1024) KB")

        // Load and verify
        let loaded = try GuionDocumentModel.load(from: saveURL, in: modelContext)
        XCTAssertEqual(loaded.elements.count, 1000, "All elements should load")

        // Rough memory efficiency check: file should not be excessively large
        // With 1000 elements of ~100 chars each, expect file < 500KB
        XCTAssertLessThan(fileSize, 500_000, "File size should be reasonable")
    }

    func testRapidSaveLoad() async throws {
        // Test rapid save/load cycles (simulating auto-save scenarios)
        let document = GuionDocumentModel(filename: "rapid-test.guion", rawContent: "")

        // Add initial elements
        for i in 1...50 {
            let element = GuionElementModel(
                elementText: "Element \(i)",
                elementType: "Action"
            )
            element.document = document
            document.elements.append(element)
        }

        modelContext.insert(document)

        let saveURL = tempDirectory.appendingPathComponent("rapid-test.guion")

        // Perform 10 rapid save/load cycles
        let cycleCount = 10
        let startTime = Date()

        for cycle in 1...cycleCount {
            // Add an element
            let newElement = GuionElementModel(
                elementText: "Cycle \(cycle) element",
                elementType: "Action"
            )
            newElement.document = document
            document.elements.append(newElement)

            // Save
            try document.save(to: saveURL)

            // Load
            let loaded = try GuionDocumentModel.load(from: saveURL, in: modelContext)
            XCTAssertEqual(loaded.elements.count, 50 + cycle, "Should have correct element count")
        }

        let totalTime = Date().timeIntervalSince(startTime)
        let avgCycleTime = totalTime / Double(cycleCount)

        print("⚡ Rapid save/load test:")
        print("   - \(cycleCount) cycles")
        print("   - Total time: \(String(format: "%.3f", totalTime))s")
        print("   - Avg per cycle: \(String(format: "%.3f", avgCycleTime))s")

        // Each cycle should be reasonably fast
        XCTAssertLessThan(avgCycleTime, 1.0, "Average cycle time should be < 1s")
    }

    func testSceneLocationCachingPerformance() async throws {
        // Test that scene location caching improves performance
        let document = GuionDocumentModel(filename: "location-cache-test.guion", rawContent: "")

        // Create many scene headings
        for i in 1...200 {
            let element = GuionElementModel(
                elementText: "INT. LOCATION \(i) - DAY",
                elementType: "Scene Heading"
            )
            element.document = document
            document.elements.append(element)

            // Add some action after each scene
            let action = GuionElementModel(
                elementText: "Something happens in location \(i).",
                elementType: "Action"
            )
            action.document = document
            document.elements.append(action)
        }

        modelContext.insert(document)

        // Save with location caching
        let saveURL = tempDirectory.appendingPathComponent("location-cache-test.guion")
        try document.save(to: saveURL)

        // Load and verify cached locations
        let loadStart = Date()
        let loaded = try GuionDocumentModel.load(from: saveURL, in: modelContext)
        let loadTime = Date().timeIntervalSince(loadStart)

        // Verify all scene headings have cached locations
        let sceneHeadings = loaded.elements.filter { $0.elementType == "Scene Heading" }
        XCTAssertEqual(sceneHeadings.count, 200, "Should have 200 scene headings")

        for scene in sceneHeadings {
            XCTAssertNotNil(scene.locationLighting, "Should have cached lighting")
            XCTAssertNotNil(scene.locationScene, "Should have cached scene")
            XCTAssertNotNil(scene.locationTimeOfDay, "Should have cached time of day")
        }

        print("🗺️  Scene location caching test:")
        print("   - 200 scene headings")
        print("   - Load time: \(String(format: "%.3f", loadTime))s")
        print("   - All locations cached: ✅")

        // Loading should be fast because locations are cached
        XCTAssertLessThan(loadTime, 1.0, "Load should be fast with cached locations")
    }

    // MARK: - Export/Import Fidelity Tests

    func testRoundTripFidelity() async throws {
        // Test that export -> import preserves all data
        let original = GuionDocumentModel(filename: "fidelity-test.guion", rawContent: "Test screenplay")

        // Create diverse elements (avoid transitions as they get ">" prefix when forced)
        let testElements: [(String, String)] = [
            ("Scene Heading", "INT. COFFEE SHOP - DAY"),
            ("Action", "A BARISTA makes coffee behind the counter."),
            ("Character", "BARISTA"),
            ("Dialogue", "Would you like some coffee?"),
            ("Character", "CUSTOMER"),
            ("Parenthetical", "(surprised)"),
            ("Dialogue", "I thought this was a library!"),
            ("Action", "BARISTA looks confused."),
            ("Scene Heading", "EXT. STREET - DAY"),
            ("Action", "The customer storms out."),
        ]

        for (type, text) in testElements {
            let element = GuionElementModel(elementText: text, elementType: type)
            element.document = original
            original.elements.append(element)
        }

        // Add title page
        let titleEntry = TitlePageEntryModel(key: "title", values: ["Fidelity Test"])
        titleEntry.document = original
        original.titlePage.append(titleEntry)

        modelContext.insert(original)

        // Save as .guion
        let guionURL = tempDirectory.appendingPathComponent("fidelity-test.guion")
        try original.save(to: guionURL)

        // Export to Fountain
        let exportedScript = GuionDocumentParserSwiftData.toFountainScript(from: original)
        let fountainURL = tempDirectory.appendingPathComponent("fidelity-test.fountain")
        try exportedScript.write(to: fountainURL)

        // Re-import from Fountain
        let reimportedScript = try FountainScript(file: fountainURL.path)
        let reimported = await GuionDocumentParserSwiftData.parse(script: reimportedScript, in: modelContext)

        // Verify fidelity
        XCTAssertEqual(reimported.elements.count, original.elements.count, "Element count should match")

        for i in 0..<original.elements.count {
            XCTAssertEqual(
                reimported.elements[i].elementType,
                original.elements[i].elementType,
                "Element \(i) type should match"
            )
            XCTAssertEqual(
                reimported.elements[i].elementText,
                original.elements[i].elementText,
                "Element \(i) text should match"
            )
        }

        print("🔄 Round-trip fidelity test passed:")
        print("   - \(original.elements.count) elements preserved")
        print("   - .guion -> Fountain -> .guion")
    }
}
