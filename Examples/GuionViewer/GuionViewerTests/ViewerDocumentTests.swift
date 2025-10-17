//
//  ViewerDocumentTests.swift
//  GuionViewerTests
//
//  Comprehensive tests for ViewerDocument read-only viewer
//  Copyright (c) 2025
//

import XCTest
@testable import GuionViewer
import SwiftGuion

@MainActor
final class ViewerDocumentTests: XCTestCase {

    // MARK: - Test Helpers

    /// Create a temporary .fountain file for testing
    func createTempFountainFile(content: String, filename: String = "test.fountain") throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent(filename)
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    /// Create a temporary .fdx file for testing
    func createTempFDXFile(filename: String = "test.fdx") throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let url = tempDir.appendingPathComponent(filename)

        // Minimal valid FDX XML
        let fdxContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <FinalDraft>
            <Content>
                <Paragraph Type="Scene Heading"><Text>INT. TEST - DAY</Text></Paragraph>
                <Paragraph Type="Action"><Text>Test action.</Text></Paragraph>
            </Content>
        </FinalDraft>
        """
        try fdxContent.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    override func tearDown() {
        // Clean up temp files
        let tempDir = FileManager.default.temporaryDirectory
        try? FileManager.default.removeItem(at: tempDir.appendingPathComponent("test.fountain"))
        try? FileManager.default.removeItem(at: tempDir.appendingPathComponent("test.fdx"))
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testEmptyDocumentInitialization() {
        let document = ViewerDocument()

        XCTAssertNil(document.sourceURL, "Empty document should have no source URL")
        XCTAssertEqual(document.originalFilename, "Untitled")
        XCTAssertEqual(document.screenplay.elements.count, 0, "Should have no elements")
        XCTAssertEqual(document.displayModel.elements.count, 0)
        XCTAssertFalse(document.hasSummaries, "Empty document should have no summaries")
        XCTAssertEqual(document.sceneCount, 0, "Empty document should have no scenes")
    }

    func testEmptyDocumentTitle() {
        let document = ViewerDocument()
        XCTAssertEqual(document.title, "Untitled")
    }

    // MARK: - File Loading Tests

    func testLoadFountainFile() throws {
        let fountainContent = """
        INT. TEST - DAY

        Action line.

        CHARACTER
        Dialogue line.
        """
        let fountainURL = try createTempFountainFile(content: fountainContent)

        let document = try ViewerDocument(contentsOf: fountainURL)

        XCTAssertEqual(document.sourceURL, fountainURL)
        XCTAssertEqual(document.originalFilename, "test.fountain")
        XCTAssertGreaterThan(document.screenplay.elements.count, 0, "Should have parsed elements")
        XCTAssertGreaterThan(document.displayModel.elements.count, 0)
        XCTAssertGreaterThan(document.sceneCount, 0, "Should have scenes")
    }

    func testLoadGuionFile() throws {
        // Create a temporary .guion file for testing
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("guion")

        // First create a screenplay
        let screenplay = GuionParsedScreenplay(
            filename: "test.guion",
            elements: [
                GuionElement(type: ElementType(string: "Scene Heading"), text: "INT. TEST - DAY"),
                GuionElement(type: ElementType(string: "Action"), text: "Test action.")
            ],
            titlePage: [["Title": ["Test Script"]]],
            suppressSceneNumbers: false
        )

        // Write it as a TextPack
        let textPack = try TextPackWriter.createTextPack(from: screenplay)
        try textPack.write(to: tempURL, originalContentsURL: nil)

        // Now load it
        let document = try ViewerDocument(contentsOf: tempURL)

        XCTAssertEqual(document.sourceURL, tempURL)
        XCTAssertEqual(document.originalFilename, tempURL.lastPathComponent)
        XCTAssertEqual(document.sceneCount, 1)
        XCTAssertEqual(document.title, "Test Script")

        // Cleanup
        try? FileManager.default.removeItem(at: tempURL)
    }

    // MARK: - File Type Detection Tests

    func testDetectFountainFileType() throws {
        let url = URL(fileURLWithPath: "/tmp/test.fountain")

        // Create a simple fountain file
        let content = "INT. TEST - DAY\n\nAction line."
        try content.write(to: url, atomically: true, encoding: .utf8)

        let document = try ViewerDocument(contentsOf: url)

        XCTAssertEqual(document.sourceType, .fountain)

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    func testDetectFDXFileType() throws {
        // Load test FDX file
        let fdxURL = try createTempFDXFile()

        let document = try ViewerDocument(contentsOf: fdxURL)

        XCTAssertEqual(document.sourceType, .fdx)
        XCTAssertGreaterThan(document.sceneCount, 0)
    }

    func testUnsupportedFileType() {
        let url = URL(fileURLWithPath: "/tmp/test.pdf")

        XCTAssertThrowsError(try ViewerDocument(contentsOf: url)) { error in
            guard let viewerError = error as? ViewerDocumentError else {
                XCTFail("Should throw ViewerDocumentError")
                return
            }

            if case .unsupportedFileType(let ext) = viewerError {
                XCTAssertEqual(ext, "pdf")
            } else {
                XCTFail("Should be unsupportedFileType error")
            }
        }
    }

    // MARK: - Error Handling Tests

    func testLoadNonexistentFile() {
        let url = URL(fileURLWithPath: "/tmp/nonexistent.fountain")

        XCTAssertThrowsError(try ViewerDocument(contentsOf: url)) { error in
            guard let viewerError = error as? ViewerDocumentError else {
                XCTFail("Should throw ViewerDocumentError")
                return
            }

            if case .loadFailed(let failedURL, _) = viewerError {
                XCTAssertEqual(failedURL, url)
            } else {
                XCTFail("Should be loadFailed error")
            }
        }
    }

    func testLoadCorruptedFountainFile() throws {
        let url = URL(fileURLWithPath: "/tmp/corrupted.fountain")

        // Create a file with invalid UTF-8
        let invalidData = Data([0xFF, 0xFE, 0xFD])
        try invalidData.write(to: url)

        XCTAssertThrowsError(try ViewerDocument(contentsOf: url)) { error in
            guard let viewerError = error as? ViewerDocumentError else {
                XCTFail("Should throw ViewerDocumentError")
                return
            }

            if case .loadFailed = viewerError {
                // Success - detected as load failure
            } else {
                XCTFail("Should be loadFailed error")
            }
        }

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Read-Only Behavior Tests

    func testOriginalFileUnchangedAfterLoad() throws {
        let fountainContent = "INT. TEST - DAY\n\nAction."
        let fountainURL = try createTempFountainFile(content: fountainContent)

        // Get original modification date
        let attributes = try FileManager.default.attributesOfItem(atPath: fountainURL.path)
        let originalModDate = attributes[.modificationDate] as? Date

        // Load document
        let document = try ViewerDocument(contentsOf: fountainURL)

        // Verify document loaded
        XCTAssertGreaterThan(document.sceneCount, 0)

        // Wait a moment to ensure time difference if file was modified
        Thread.sleep(forTimeInterval: 0.1)

        // Check modification date unchanged
        let newAttributes = try FileManager.default.attributesOfItem(atPath: fountainURL.path)
        let newModDate = newAttributes[.modificationDate] as? Date

        XCTAssertEqual(originalModDate, newModDate, "File modification date should be unchanged")
    }

    func testSourceURLIsReadOnlyReference() throws {
        let fountainContent = "INT. TEST - DAY\n\nAction."
        let fountainURL = try createTempFountainFile(content: fountainContent)

        let document = try ViewerDocument(contentsOf: fountainURL)

        XCTAssertEqual(document.sourceURL, fountainURL)

        // sourceURL is a let property, can't be modified (compile-time check)
        // This test verifies the property exists and is set correctly
    }

    // MARK: - Summary Element Tests

    func testDetectExistingSummaries() throws {
        // Create a fountain file with summary elements
        let url = URL(fileURLWithPath: "/tmp/with-summaries.fountain")
        let content = """
        # Test Script

        ## CHAPTER 1

        ### ACT ONE

        INT. ROOM - DAY

        #### SUMMARY: Test summary for this scene.

        Action line.
        """
        try content.write(to: url, atomically: true, encoding: .utf8)

        let document = try ViewerDocument(contentsOf: url)

        XCTAssertTrue(document.hasSummaries, "Should detect summary elements")

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    func testNoSummariesInPlainFountain() throws {
        let url = URL(fileURLWithPath: "/tmp/no-summaries.fountain")
        let content = """
        INT. ROOM - DAY

        Action line.
        """
        try content.write(to: url, atomically: true, encoding: .utf8)

        let document = try ViewerDocument(contentsOf: url)

        XCTAssertFalse(document.hasSummaries, "Should not detect summaries when none exist")

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Scene Count Tests

    func testSceneCountAccurate() throws {
        let url = URL(fileURLWithPath: "/tmp/scenes.fountain")
        let content = """
        INT. ROOM - DAY

        Action 1.

        EXT. STREET - NIGHT

        Action 2.

        INT. CAR - DAY

        Action 3.
        """
        try content.write(to: url, atomically: true, encoding: .utf8)

        let document = try ViewerDocument(contentsOf: url)

        XCTAssertEqual(document.sceneCount, 3, "Should count 3 scenes")

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    func testSceneCountZeroForEmptyDocument() {
        let document = ViewerDocument()
        XCTAssertEqual(document.sceneCount, 0)
    }

    // MARK: - Title Extraction Tests

    func testTitleFromTitlePage() throws {
        let url = URL(fileURLWithPath: "/tmp/titled.fountain")
        let content = """
        Title: My Great Script
        Author: John Doe

        INT. ROOM - DAY

        Action.
        """
        try content.write(to: url, atomically: true, encoding: .utf8)

        let document = try ViewerDocument(contentsOf: url)

        XCTAssertEqual(document.title, "My Great Script")

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    func testTitleFallsBackToFilename() throws {
        let url = URL(fileURLWithPath: "/tmp/untitled-script.fountain")
        let content = """
        INT. ROOM - DAY

        Action.
        """
        try content.write(to: url, atomically: true, encoding: .utf8)

        let document = try ViewerDocument(contentsOf: url)

        XCTAssertEqual(document.title, "untitled-script.fountain")

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - In-Memory SwiftData Tests

    func testSwiftDataModelContextInMemoryOnly() throws {
        let url = URL(fileURLWithPath: "/tmp/memory-test.fountain")
        let content = "INT. ROOM - DAY\n\nAction."
        try content.write(to: url, atomically: true, encoding: .utf8)

        let document = try ViewerDocument(contentsOf: url)

        // Verify displayModel is populated
        XCTAssertGreaterThan(document.displayModel.elements.count, 0)

        // Verify it's in-memory (no persistence)
        // We can't directly check ModelConfiguration from outside,
        // but we can verify the model works
        XCTAssertNotNil(document.displayModel.elements.first)

        // Cleanup
        try? FileManager.default.removeItem(at: url)
    }

    func testGuionDocumentModelConversion() throws {
        let screenplay = GuionParsedScreenplay(
            filename: "test.fountain",
            elements: [
                GuionElement(type: ElementType(string: "Scene Heading"), text: "INT. ROOM - DAY"),
                GuionElement(type: ElementType(string: "Action"), text: "Action line."),
                GuionElement(type: ElementType(string: "Character"), text: "JOHN"),
                GuionElement(type: ElementType(string: "Dialogue"), text: "Hello!")
            ],
            titlePage: [["Title": ["Test"], "Author": ["John Doe"]]],
            suppressSceneNumbers: false
        )

        let model = GuionDocumentModel(from: screenplay)

        XCTAssertEqual(model.filename, "test.fountain")
        XCTAssertEqual(model.elements.count, 4)
        XCTAssertEqual(model.titlePage.count, 2) // Title and Author
        XCTAssertFalse(model.suppressSceneNumbers)

        // Verify elements converted correctly
        XCTAssertEqual(model.elements[0].elementType, "Scene Heading")
        XCTAssertEqual(model.elements[1].elementType, "Action")
        XCTAssertEqual(model.elements[2].elementType, "Character")
        XCTAssertEqual(model.elements[3].elementType, "Dialogue")
    }

    func testGuionDocumentModelRoundTrip() throws {
        let originalScreenplay = GuionParsedScreenplay(
            filename: "test.fountain",
            elements: [
                GuionElement(type: ElementType(string: "Scene Heading"), text: "INT. ROOM - DAY"),
                GuionElement(type: ElementType(string: "Action"), text: "Action line.")
            ],
            titlePage: [["Title": ["Test"]]],
            suppressSceneNumbers: true
        )

        // Convert to model
        let model = GuionDocumentModel(from: originalScreenplay)

        // Convert back to screenplay
        let convertedScreenplay = model.toGuionParsedScreenplay()

        // Verify round-trip fidelity
        XCTAssertEqual(convertedScreenplay.filename, originalScreenplay.filename)
        XCTAssertEqual(convertedScreenplay.elements.count, originalScreenplay.elements.count)
        XCTAssertEqual(convertedScreenplay.suppressSceneNumbers, originalScreenplay.suppressSceneNumbers)

        for (index, element) in convertedScreenplay.elements.enumerated() {
            XCTAssertEqual(element.elementType, originalScreenplay.elements[index].elementType)
            XCTAssertEqual(element.elementText, originalScreenplay.elements[index].elementText)
        }
    }

    // MARK: - Error Description Tests

    func testUnsupportedFileTypeErrorDescription() {
        let error = ViewerDocumentError.unsupportedFileType("pdf")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("pdf"))
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion!.contains(".guion"))
    }

    func testLoadFailedErrorDescription() {
        let url = URL(fileURLWithPath: "/tmp/test.fountain")
        struct TestError: Error {}
        let error = ViewerDocumentError.loadFailed(url, underlying: TestError())

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("test.fountain"))
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }

    // MARK: - Integration Tests

    func testLoadRealFountainFileEndToEnd() throws {
        let fountainContent = """
        INT. TEST - DAY

        Action line.

        CHARACTER
        Dialogue.
        """
        let fountainURL = try createTempFountainFile(content: fountainContent)

        // Load document
        let document = try ViewerDocument(contentsOf: fountainURL)

        // Verify all properties
        XCTAssertEqual(document.sourceURL, fountainURL)
        XCTAssertEqual(document.sourceType, .fountain)
        XCTAssertEqual(document.originalFilename, "test.fountain")
        XCTAssertGreaterThan(document.sceneCount, 0)
        XCTAssertGreaterThan(document.screenplay.elements.count, 0)
        XCTAssertGreaterThan(document.displayModel.elements.count, 0)

        // Verify SwiftData model
        XCTAssertNotNil(document.displayModel)
        XCTAssertEqual(
            document.screenplay.elements.count,
            document.displayModel.elements.count,
            "Element counts should match"
        )
    }

    func testLoadMultipleDocuments() throws {
        let fountainContent = "INT. TEST - DAY\n\nAction."
        let fountainURL = try createTempFountainFile(content: fountainContent)

        // Load same file twice (simulating multiple windows)
        let doc1 = try ViewerDocument(contentsOf: fountainURL)
        let doc2 = try ViewerDocument(contentsOf: fountainURL)

        // Verify both loaded correctly
        XCTAssertEqual(doc1.sceneCount, doc2.sceneCount)
        XCTAssertEqual(doc1.screenplay.elements.count, doc2.screenplay.elements.count)

        // Verify they're independent (different model contexts)
        XCTAssertNotIdentical(doc1.displayModel, doc2.displayModel)
    }

    // MARK: - Performance Tests

    func testLoadLargeFilePerformance() throws {
        // Create a moderately large test file with multiple scenes
        var scenes: [String] = []
        for i in 1...50 {
            scenes.append("""
            INT. SCENE \(i) - DAY

            Action for scene \(i).

            CHARACTER
            Dialogue for scene \(i).
            """)
        }
        let largeContent = scenes.joined(separator: "\n\n")
        let largeURL = try createTempFountainFile(content: largeContent, filename: "large-test.fountain")

        measure {
            do {
                let document = try ViewerDocument(contentsOf: largeURL)
                XCTAssertGreaterThan(document.sceneCount, 40, "Large file should have many scenes")
            } catch {
                XCTFail("Failed to load large file: \(error)")
            }
        }

        // Clean up
        try? FileManager.default.removeItem(at: largeURL)
    }
}
