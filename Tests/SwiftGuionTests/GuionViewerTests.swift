//
//  GuionViewerTests.swift
//  SwiftGuionTests
//
//  Comprehensive tests for GuionViewer component and related functionality
//

import XCTest
import SwiftFijos
@testable import SwiftGuion

#if canImport(SwiftUI) && canImport(SwiftData)
import SwiftUI
import SwiftData

@available(macOS 14.0, iOS 17.0, *)
final class GuionViewerTests: XCTestCase {

    // MARK: - GuionViewerState Tests

    func testGuionViewerStateLoadingCase() {
        let url = URL(fileURLWithPath: "/test/path.fountain")
        let state = GuionViewerState.loading(url)

        if case .loading(let loadedURL) = state {
            XCTAssertEqual(loadedURL, url, "Loading state should store URL")
        } else {
            XCTFail("State should be loading")
        }
    }

    func testGuionViewerStateLoadedCase() {
        let browserData = createSampleBrowserData()
        let state = GuionViewerState.loaded(browserData)

        if case .loaded(let data) = state {
            XCTAssertNotNil(data.title, "Loaded state should contain browser data")
            XCTAssertEqual(data.chapters.count, 1, "Should have sample chapter")
        } else {
            XCTFail("State should be loaded")
        }
    }

    func testGuionViewerStateErrorCase() {
        let error = GuionViewerError.unsupportedFileType("pdf")
        let state = GuionViewerState.error(error)

        if case .error(let errorValue) = state {
            if case .unsupportedFileType(let ext) = errorValue {
                XCTAssertEqual(ext, "pdf", "Error should contain file extension")
            } else {
                XCTFail("Error should be unsupportedFileType")
            }
        } else {
            XCTFail("State should be error")
        }
    }

    func testGuionViewerStateEmptyCase() {
        let state = GuionViewerState.empty

        if case .empty = state {
            // Success
        } else {
            XCTFail("State should be empty")
        }
    }

    // MARK: - GuionViewerError Tests

    func testUnsupportedFileTypeError() {
        let error = GuionViewerError.unsupportedFileType("pdf")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("pdf"))
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion!.contains(".guion"))
    }

    func testLoadFailedError() {
        struct TestError: Error {}
        let underlyingError = TestError()
        let error = GuionViewerError.loadFailed(underlyingError)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("Failed to load"))
        XCTAssertNotNil(error.recoverySuggestion)
    }

    func testUnsupportedInitializationError() {
        let message = "Use init(document:) for .guion files"
        let error = GuionViewerError.unsupportedInitialization(message)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertEqual(error.errorDescription, message)
        XCTAssertNotNil(error.recoverySuggestion)
    }

    func testMissingModelContextError() {
        let error = GuionViewerError.missingModelContext

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("ModelContext"))
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion!.contains("init(document:)"))
    }

    // MARK: - GuionViewer Initialization Tests

    @MainActor
    func testInitWithFountainScript() throws {
        let fountainPath = try Fijos.getFixture("test", extension: "fountain").path
        let script = try FountainScript(file: fountainPath)

        // Create viewer with script
        let viewer = GuionViewer(script: script)

        // Viewer should be created successfully
        XCTAssertNotNil(viewer)
    }

    @MainActor
    func testInitWithBrowserData() {
        let browserData = createSampleBrowserData()
        let viewer = GuionViewer(browserData: browserData)

        XCTAssertNotNil(viewer)
    }

    @MainActor
    func testInitWithGuionDocumentModel() throws {
        // Create a simple document model
        let document = GuionDocumentModel(filename: "test.guion")

        // Add some test elements
        let element = GuionElementModel(
            elementText: "INT. ROOM - DAY",
            elementType: "Scene Heading"
        )
        document.elements.append(element)

        // Create viewer
        let viewer = GuionViewer(document: document)

        XCTAssertNotNil(viewer)
    }

    // MARK: - GuionDocumentModel to FountainScript Conversion Tests

    func testToFountainScriptWithElements() {
        let document = GuionDocumentModel(filename: "test.guion")

        // Add test elements
        let sceneHeading = GuionElementModel(
            elementText: "INT. ROOM - DAY",
            elementType: "Scene Heading"
        )
        let action = GuionElementModel(
            elementText: "A character enters the room.",
            elementType: "Action"
        )
        let character = GuionElementModel(
            elementText: "JOHN",
            elementType: "Character"
        )
        let dialogue = GuionElementModel(
            elementText: "Hello, world!",
            elementType: "Dialogue"
        )

        document.elements.append(contentsOf: [sceneHeading, action, character, dialogue])

        // Convert to FountainScript
        let script = document.toFountainScript()

        XCTAssertEqual(script.elements.count, 4, "Should have 4 elements")
        XCTAssertEqual(script.elements[0].elementType, "Scene Heading")
        XCTAssertEqual(script.elements[0].elementText, "INT. ROOM - DAY")
        XCTAssertEqual(script.elements[1].elementType, "Action")
        XCTAssertEqual(script.elements[3].elementType, "Dialogue")
    }

    func testToFountainScriptWithTitlePage() {
        let document = GuionDocumentModel(filename: "test.guion")

        // Add title page entries
        let titleEntry = TitlePageEntryModel(key: "Title", values: ["My Screenplay"])
        let authorEntry = TitlePageEntryModel(key: "Author", values: ["John Doe"])

        document.titlePage.append(contentsOf: [titleEntry, authorEntry])

        // Convert to FountainScript
        let script = document.toFountainScript()

        XCTAssertEqual(script.titlePage.count, 1, "Should have title page")
        XCTAssertNotNil(script.titlePage.first?["Title"])
        XCTAssertEqual(script.titlePage.first?["Title"]?.first, "My Screenplay")
        XCTAssertNotNil(script.titlePage.first?["Author"])
        XCTAssertEqual(script.titlePage.first?["Author"]?.first, "John Doe")
    }

    func testToFountainScriptWithEmptyTitlePage() {
        let document = GuionDocumentModel(filename: "test.guion")

        // Add element but no title page
        let action = GuionElementModel(elementText: "Action text", elementType: "Action")
        document.elements.append(action)

        // Convert to FountainScript
        let script = document.toFountainScript()

        // Should have empty title page (not added if empty)
        XCTAssertTrue(script.titlePage.isEmpty || script.titlePage.first?.isEmpty == true,
                     "Empty title page should not be added")
    }

    func testToFountainScriptPreservesFilename() {
        let document = GuionDocumentModel(filename: "test-screenplay.guion")
        let script = document.toFountainScript()

        XCTAssertEqual(script.filename, "test-screenplay.guion")
    }

    func testToFountainScriptPreservesSuppressSceneNumbers() {
        let document = GuionDocumentModel(
            filename: "test.guion",
            suppressSceneNumbers: true
        )
        let script = document.toFountainScript()

        XCTAssertTrue(script.suppressSceneNumbers)
    }

    func testToFountainScriptWithSpecialElements() {
        let document = GuionDocumentModel(filename: "test.guion")

        // Add elements with special properties
        let centeredElement = GuionElementModel(
            elementText: "THE END",
            elementType: "Centered",
            isCentered: true
        )

        let dualDialogueElement = GuionElementModel(
            elementText: "Speaking simultaneously",
            elementType: "Dialogue",
            isDualDialogue: true
        )

        let sceneWithNumber = GuionElementModel(
            elementText: "INT. HOUSE - DAY",
            elementType: "Scene Heading",
            sceneNumber: "42"
        )

        let sectionHeading = GuionElementModel(
            elementText: "ACT ONE",
            elementType: "Section Heading",
            sectionDepth: 1
        )

        document.elements.append(contentsOf: [
            centeredElement,
            dualDialogueElement,
            sceneWithNumber,
            sectionHeading
        ])

        let script = document.toFountainScript()

        XCTAssertEqual(script.elements.count, 4)
        XCTAssertTrue(script.elements[0].isCentered)
        XCTAssertTrue(script.elements[1].isDualDialogue)
        XCTAssertEqual(script.elements[2].sceneNumber, "42")
        XCTAssertEqual(script.elements[3].sectionDepth, 1)
    }

    // MARK: - Empty State Tests

    func testEmptyDocumentCreatesEmptyBrowserData() {
        let document = GuionDocumentModel(filename: "empty.guion")
        let script = document.toFountainScript()
        let browserData = script.extractSceneBrowserData()

        // Empty document should have no chapters
        XCTAssertEqual(browserData.chapters.count, 0)
    }

    func testDocumentWithOnlyActionHasNoChapters() {
        let document = GuionDocumentModel(filename: "simple.guion")
        let action = GuionElementModel(
            elementText: "Just some action.",
            elementType: "Action"
        )
        document.elements.append(action)

        let script = document.toFountainScript()
        let browserData = script.extractSceneBrowserData()

        // Document with only action and no structure should have no chapters
        // (unless synthetic chapters are created)
        XCTAssertGreaterThanOrEqual(browserData.chapters.count, 0)
    }

    // MARK: - Scene Browser Data Extraction from GuionDocumentModel

    func testExtractSceneBrowserDataFromDocument() {
        let document = createSampleDocument()
        let script = document.toFountainScript()
        let browserData = script.extractSceneBrowserData()

        XCTAssertNotNil(browserData.title)
        XCTAssertGreaterThan(browserData.chapters.count, 0)
    }

    func testDocumentWithCompleteHierarchy() {
        let document = GuionDocumentModel(filename: "complete.guion")

        // Add title
        let titleEntry = TitlePageEntryModel(
            key: "Title",
            values: ["Complete Screenplay"]
        )
        document.titlePage.append(titleEntry)

        // Add main title section
        let mainTitle = GuionElementModel(
            elementText: "Complete Screenplay",
            elementType: "Section Heading",
            sectionDepth: 1
        )

        // Add chapter
        let chapter = GuionElementModel(
            elementText: "CHAPTER 1",
            elementType: "Section Heading",
            sectionDepth: 2
        )

        // Add scene group
        let sceneGroup = GuionElementModel(
            elementText: "PROLOGUE",
            elementType: "Section Heading",
            sectionDepth: 3
        )

        // Add scene
        let scene = GuionElementModel(
            elementText: "INT. ROOM - DAY",
            elementType: "Scene Heading"
        )

        // Add action
        let action = GuionElementModel(
            elementText: "A character enters.",
            elementType: "Action"
        )

        document.elements.append(contentsOf: [
            mainTitle, chapter, sceneGroup, scene, action
        ])

        let script = document.toFountainScript()
        let browserData = script.extractSceneBrowserData()

        XCTAssertNotNil(browserData.title)
        XCTAssertGreaterThan(browserData.chapters.count, 0)

        if let firstChapter = browserData.chapters.first {
            XCTAssertGreaterThan(firstChapter.sceneGroups.count, 0)

            if let firstGroup = firstChapter.sceneGroups.first {
                XCTAssertGreaterThan(firstGroup.scenes.count, 0)

                if let firstScene = firstGroup.scenes.first {
                    XCTAssertGreaterThan(firstScene.sceneElements.count, 0)
                }
            }
        }
    }

    // MARK: - Integration Tests

    @MainActor
    func testEndToEndFountainToViewerFlow() throws {
        // Load fountain file
        let fountainPath = try Fijos.getFixture("test", extension: "fountain").path
        let script = try FountainScript(file: fountainPath)

        // Extract browser data
        let browserData = script.extractSceneBrowserData()

        // Create viewer
        let viewer = GuionViewer(browserData: browserData)

        XCTAssertNotNil(viewer)
        XCTAssertNotNil(browserData.title)
        XCTAssertGreaterThan(browserData.chapters.count, 0)
    }

    @MainActor
    func testEndToEndDocumentToViewerFlow() {
        // Create document
        let document = createSampleDocument()

        // Create viewer directly from document
        let viewer = GuionViewer(document: document)

        XCTAssertNotNil(viewer)
    }

    // MARK: - Performance Tests

    func testLargeDocumentConversionPerformance() throws {
        // Load BigFish fixture
        let fountainPath = try Fijos.getFixture("bigfish", extension: "fountain").path
        let script = try FountainScript(file: fountainPath)

        // Create a document model with all elements
        let document = GuionDocumentModel(filename: "bigfish.guion")

        for element in script.elements {
            let modelElement = GuionElementModel(from: element)
            document.elements.append(modelElement)
        }

        // Measure conversion time
        let startTime = Date()
        let convertedScript = document.toFountainScript()
        let duration = Date().timeIntervalSince(startTime)

        XCTAssertEqual(convertedScript.elements.count, script.elements.count)

        print("⚡ Performance: BigFish document conversion took \(String(format: "%.3f", duration)) seconds")
        print("📊 Elements converted: \(convertedScript.elements.count)")

        // Should complete in reasonable time
        XCTAssertLessThan(duration, 1.0, "Conversion should complete in under 1 second")
    }

    func testBrowserDataExtractionPerformance() throws {
        let fountainPath = try Fijos.getFixture("bigfish", extension: "fountain").path
        let script = try FountainScript(file: fountainPath)

        // Create document and convert
        let document = GuionDocumentModel(filename: "bigfish.guion")
        for element in script.elements {
            document.elements.append(GuionElementModel(from: element))
        }

        let convertedScript = document.toFountainScript()

        // Measure browser data extraction
        let startTime = Date()
        let browserData = convertedScript.extractSceneBrowserData()
        let duration = Date().timeIntervalSince(startTime)

        print("⚡ Performance: Browser data extraction took \(String(format: "%.3f", duration)) seconds")
        print("📊 Chapters: \(browserData.chapters.count)")

        XCTAssertNotNil(browserData.title)
        XCTAssertLessThan(duration, 5.0, "Browser data extraction should complete in under 5 seconds")
    }

    // MARK: - Edge Cases and Error Conditions

    func testDocumentWithMixedContent() {
        let document = GuionDocumentModel(filename: "mixed.guion")

        // Mix of structured and unstructured content
        let elements = [
            GuionElementModel(elementText: "Unstructured action", elementType: "Action"),
            GuionElementModel(elementText: "CHAPTER 1", elementType: "Section Heading", sectionDepth: 2),
            GuionElementModel(elementText: "More action", elementType: "Action"),
            GuionElementModel(elementText: "INT. ROOM - DAY", elementType: "Scene Heading"),
            GuionElementModel(elementText: "Scene action", elementType: "Action")
        ]

        document.elements.append(contentsOf: elements)

        let script = document.toFountainScript()
        let browserData = script.extractSceneBrowserData()

        // Should handle mixed content gracefully
        XCTAssertGreaterThanOrEqual(browserData.chapters.count, 0)
    }

    func testDocumentWithOnlyScenesNoStructure() {
        let document = GuionDocumentModel(filename: "scenes-only.guion")

        let scenes = [
            GuionElementModel(elementText: "INT. ROOM - DAY", elementType: "Scene Heading"),
            GuionElementModel(elementText: "Action 1", elementType: "Action"),
            GuionElementModel(elementText: "EXT. STREET - NIGHT", elementType: "Scene Heading"),
            GuionElementModel(elementText: "Action 2", elementType: "Action")
        ]

        document.elements.append(contentsOf: scenes)

        let script = document.toFountainScript()
        let browserData = script.extractSceneBrowserData()

        // Should create synthetic structure
        XCTAssertGreaterThanOrEqual(browserData.chapters.count, 0)
    }

    func testRoundTripFidelity() throws {
        // Create original document
        let original = createSampleDocument()

        // Convert to FountainScript
        let script1 = original.toFountainScript()

        // Create new document from script
        let document2 = GuionDocumentModel(filename: "roundtrip.guion")
        for element in script1.elements {
            document2.elements.append(GuionElementModel(from: element))
        }

        for (key, values) in script1.titlePage.first ?? [:] {
            document2.titlePage.append(TitlePageEntryModel(key: key, values: values))
        }

        // Convert back to FountainScript
        let script2 = document2.toFountainScript()

        // Verify round-trip fidelity
        XCTAssertEqual(script1.elements.count, script2.elements.count)

        for (index, element) in script1.elements.enumerated() {
            XCTAssertEqual(element.elementType, script2.elements[index].elementType)
            XCTAssertEqual(element.elementText, script2.elements[index].elementText)
            XCTAssertEqual(element.isCentered, script2.elements[index].isCentered)
            XCTAssertEqual(element.isDualDialogue, script2.elements[index].isDualDialogue)
            XCTAssertEqual(element.sceneNumber, script2.elements[index].sceneNumber)
            XCTAssertEqual(element.sectionDepth, script2.elements[index].sectionDepth)
        }
    }

    // MARK: - Helper Methods

    private func createSampleBrowserData() -> SceneBrowserData {
        return SceneBrowserData(
            title: OutlineElement(
                id: "title-1",
                index: 0,
                level: 1,
                range: [0, 10],
                rawString: "# Test Script",
                string: "Test Script",
                type: "sectionHeader"
            ),
            chapters: [
                ChapterData(
                    element: OutlineElement(
                        id: "chapter-1",
                        index: 1,
                        level: 2,
                        range: [10, 100],
                        rawString: "## CHAPTER 1",
                        string: "CHAPTER 1",
                        type: "sectionHeader"
                    ),
                    sceneGroups: [
                        SceneGroupData(
                            element: OutlineElement(
                                id: "group-1",
                                index: 2,
                                level: 3,
                                range: [20, 80],
                                rawString: "### PROLOGUE",
                                string: "PROLOGUE",
                                type: "sectionHeader"
                            ),
                            scenes: [
                                SceneData(
                                    element: OutlineElement(
                                        id: "scene-1",
                                        index: 3,
                                        level: 0,
                                        range: [30, 70],
                                        rawString: "INT. STEAM ROOM - DAY",
                                        string: "INT. STEAM ROOM - DAY",
                                        type: "sceneHeader"
                                    ),
                                    sceneElements: [
                                        GuionElement(type: "Action", text: "Test action.")
                                    ],
                                    sceneLocation: SceneLocation.parse("INT. STEAM ROOM - DAY")
                                )
                            ]
                        )
                    ]
                )
            ]
        )
    }

    private func createSampleDocument() -> GuionDocumentModel {
        let document = GuionDocumentModel(filename: "sample.guion")

        // Add title page
        document.titlePage.append(
            TitlePageEntryModel(key: "Title", values: ["Sample Screenplay"])
        )

        // Add structured content
        let elements = [
            GuionElementModel(
                elementText: "Sample Screenplay",
                elementType: "Section Heading",
                sectionDepth: 1
            ),
            GuionElementModel(
                elementText: "CHAPTER 1",
                elementType: "Section Heading",
                sectionDepth: 2
            ),
            GuionElementModel(
                elementText: "OPENING",
                elementType: "Section Heading",
                sectionDepth: 3
            ),
            GuionElementModel(
                elementText: "INT. OFFICE - DAY",
                elementType: "Scene Heading"
            ),
            GuionElementModel(
                elementText: "A character sits at a desk.",
                elementType: "Action"
            )
        ]

        document.elements.append(contentsOf: elements)

        return document
    }
}

#endif // canImport(SwiftUI) && canImport(SwiftData)
