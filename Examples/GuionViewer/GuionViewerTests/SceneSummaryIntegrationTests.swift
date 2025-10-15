//
//  SceneSummaryIntegrationTests.swift
//  GuionViewerTests
//
//  Tests for scene summary generation and display
//

import XCTest
import SwiftData
@testable import GuionViewer
@testable import SwiftGuion

@MainActor
final class SceneSummaryIntegrationTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        // Create in-memory SwiftData container for testing
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self
        ])

        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext
    }

    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
    }

    // MARK: - Test Data

    let sampleFountainScript = """
    Title: Test Script

    # BIG FISH

    ## ACT ONE

    INT. COFFEE SHOP - DAY

    ALICE sits at a corner table, nervously checking her phone.

    BOB enters, spots her, and waves.

    BOB
    Hey! Sorry I'm late.

    ALICE
    (relieved)
    No worries. I just got here.

    They shake hands awkwardly.

    EXT. PARK - LATER

    Alice and Bob walk side by side, deep in conversation.

    BOB
    So what do you think about the proposal?

    ALICE
    I think we should move forward.

    Bob nods thoughtfully.
    """

    // MARK: - Tests

    func testSceneSummariesGeneratedOnDocumentParse() async throws {
        // Given: A fountain script with multiple scenes
        let script = try GuionParsedScreenplay(string: sampleFountainScript)

        // When: Parsing with generateSummaries enabled
        let document = await GuionDocumentModel.from(
            script,
            in: modelContext,
            generateSummaries: true
        )

        // Then: Scene heading elements should have summaries
        let sceneHeadings = document.elements.filter { $0.elementType == "Scene Heading" }

        XCTAssertGreaterThan(sceneHeadings.count, 0, "Should have at least one scene heading")

        for sceneHeading in sceneHeadings {
            XCTAssertNotNil(sceneHeading.summary, "Scene heading '\(sceneHeading.elementText)' should have a summary")
            XCTAssertFalse(sceneHeading.summary?.isEmpty ?? true, "Summary should not be empty")
            print("✅ Scene: \(sceneHeading.elementText)")
            print("   Summary: \(sceneHeading.summary ?? "nil")\n")
        }
    }

    func testSceneSummariesNotGeneratedWhenDisabled() async throws {
        // Given: A fountain script
        let script = try GuionParsedScreenplay(string: sampleFountainScript)

        // When: Parsing with generateSummaries disabled (default)
        let document = await GuionDocumentModel.from(
            script,
            in: modelContext,
            generateSummaries: false
        )

        // Then: Scene heading elements should NOT have summaries
        let sceneHeadings = document.elements.filter { $0.elementType == "Scene Heading" }

        for sceneHeading in sceneHeadings {
            XCTAssertNil(sceneHeading.summary, "Scene heading should not have summary when disabled")
        }
    }

    func testSummaryContentQuality() async throws {
        // Given: A scene with known content
        let sceneText = """
        INT. COFFEE SHOP - DAY

        ALICE sits at a corner table, nervously checking her phone.

        BOB enters, spots her, and waves.

        BOB
        Hey! Sorry I'm late.
        """

        // When: Summarizing the scene
        let summary = await SceneSummarizer.summarize(sceneText)

        // Then: Summary should contain relevant information
        XCTAssertNotNil(summary)

        // Should mention characters
        let lowerSummary = summary?.lowercased() ?? ""
        XCTAssertTrue(
            lowerSummary.contains("alice") || lowerSummary.contains("bob"),
            "Summary should mention characters: \(summary ?? "nil")"
        )
    }

    func testSummaryPersistedInSwiftData() async throws {
        // Given: A document with summaries
        let script = try GuionParsedScreenplay(string: sampleFountainScript)
        let document = await GuionDocumentModel.from(
            script,
            in: modelContext,
            generateSummaries: true
        )

        try modelContext.save()

        // When: Fetching from SwiftData
        let descriptor = FetchDescriptor<GuionDocumentModel>()
        let documents = try modelContext.fetch(descriptor)

        // Then: Summaries should be persisted
        XCTAssertEqual(documents.count, 1)
        let fetchedDoc = documents.first!

        let sceneHeadings = fetchedDoc.elements.filter { $0.elementType == "Scene Heading" }
        for sceneHeading in sceneHeadings {
            XCTAssertNotNil(sceneHeading.summary, "Persisted scene should have summary")
        }
    }

    func testSummaryUpdatedOnMainThread() async throws {
        // Given: A scene element
        let element = GuionElementModel(
            elementText: "INT. TEST ROOM - DAY",
            elementType: "Scene Heading"
        )
        element.document = GuionDocumentModel()
        modelContext.insert(element)

        // When: Updating summary on main thread
        await MainActor.run {
            element.summary = "Test summary"
        }

        // Then: Summary should be updated
        XCTAssertEqual(element.summary, "Test summary")
    }

    func testEmptySceneHandling() async throws {
        // Given: An empty scene
        let emptyText = ""

        // When: Attempting to summarize
        let summary = await SceneSummarizer.summarize(emptyText)

        // Then: Should return nil gracefully
        XCTAssertNil(summary, "Empty scene should return nil summary")
    }

    func testMultipleScenesConcurrent() async throws {
        // Given: A script with multiple scenes
        let script = try GuionParsedScreenplay(string: sampleFountainScript)
        let outline = script.extractOutline()
        let scenes = outline.filter { $0.type == "sceneHeader" }

        // When: Summarizing concurrently
        let summaries = await withTaskGroup(of: (String, String?).self) { group in
            for scene in scenes {
                group.addTask {
                    let summary = await SceneSummarizer.summarizeScene(scene, from: script, outline: outline)
                    return (scene.string, summary)
                }
            }

            var results: [(String, String?)] = []
            for await result in group {
                results.append(result)
            }
            return results
        }

        // Then: All scenes should have summaries
        XCTAssertEqual(summaries.count, scenes.count)
        for (sceneTitle, summary) in summaries {
            XCTAssertNotNil(summary, "Scene '\(sceneTitle)' should have summary")
            print("✅ \(sceneTitle): \(summary ?? "nil")")
        }
    }
}
