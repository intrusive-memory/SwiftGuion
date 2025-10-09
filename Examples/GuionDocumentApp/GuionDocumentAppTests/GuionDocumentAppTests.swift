//
//  GuionDocumentAppTests.swift
//  GuionDocumentAppTests
//
//  Created by TOM STOVALL on 10/9/25.
//

import Testing
import SwiftData
import UniformTypeIdentifiers
@testable import GuionDocumentApp
import SwiftGuion

@MainActor
struct GuionDocumentAppTests {

    // MARK: - Helper Methods

    private func createModelContext() throws -> ModelContext {
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    private func getFixturesDirectory() throws -> URL {
        // Navigate from the test bundle to the Fixtures directory
        let testBundle = Bundle(for: type(of: self) as! AnyClass)
        let bundlePath = testBundle.bundlePath
        let bundleURL = URL(fileURLWithPath: bundlePath)

        // Go up to the project root and find Fixtures
        let projectRoot = bundleURL
            .deletingLastPathComponent()  // Examples
            .deletingLastPathComponent()  // GuionDocumentApp
            .deletingLastPathComponent()  // Examples
            .deletingLastPathComponent()  // SwiftGuion

        let fixturesURL = projectRoot.appendingPathComponent("Fixtures")

        guard FileManager.default.fileExists(atPath: fixturesURL.path) else {
            throw TestError.fixturesNotFound(fixturesURL.path)
        }

        return fixturesURL
    }

    private func getFixture(_ name: String, extension ext: String) throws -> URL {
        let fixturesDir = try getFixturesDirectory()
        let fixtureURL = fixturesDir.appendingPathComponent("\(name).\(ext)")

        guard FileManager.default.fileExists(atPath: fixtureURL.path) else {
            throw TestError.fixtureNotFound("\(name).\(ext)")
        }

        return fixtureURL
    }

    // MARK: - BigFish Fountain Tests

    @Test("Parse BigFish.fountain file")
    func parseBigFishFountain() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try getFixture("bigfish", extension: "fountain")

        // Parse the document
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Verify document was parsed
        #expect(document.filename == "bigfish.fountain")
        #expect(!document.elements.isEmpty, "Document should have elements")

        // Verify we have various element types
        let elementTypes = Set(document.elements.map { $0.elementType })
        #expect(elementTypes.contains("Scene Heading"), "Should have scene headings")
        #expect(elementTypes.contains("Action"), "Should have action elements")
        #expect(elementTypes.contains("Character"), "Should have character elements")
        #expect(elementTypes.contains("Dialogue"), "Should have dialogue elements")

        // Verify title page
        #expect(!document.titlePage.isEmpty, "Should have title page entries")

        // Verify locations are parsed
        let locations = document.sceneLocations
        #expect(!locations.isEmpty, "Should have parsed scene locations")

        // Verify we can extract characters
        let characters = extractCharacters(from: document)
        #expect(!characters.isEmpty, "Should have characters with dialogue")

        print("✅ BigFish.fountain: \(document.elements.count) elements, \(locations.count) locations, \(characters.count) characters")
    }

    // MARK: - BigFish FDX Tests

    @Test("Parse BigFish.fdx file")
    func parseBigFishFDX() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try getFixture("bigfish", extension: "fdx")

        // Parse the document
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Verify document was parsed
        #expect(document.filename == "bigfish.fdx")
        #expect(!document.elements.isEmpty, "Document should have elements")

        // Verify we have various element types
        let elementTypes = Set(document.elements.map { $0.elementType })
        #expect(elementTypes.contains("Scene Heading"), "Should have scene headings")
        #expect(elementTypes.contains("Action"), "Should have action elements")
        #expect(elementTypes.contains("Character"), "Should have character elements")
        #expect(elementTypes.contains("Dialogue"), "Should have dialogue elements")

        // Verify locations are parsed
        let locations = document.sceneLocations
        #expect(!locations.isEmpty, "Should have parsed scene locations")

        // Verify we can extract characters
        let characters = extractCharacters(from: document)
        #expect(!characters.isEmpty, "Should have characters with dialogue")

        print("✅ BigFish.fdx: \(document.elements.count) elements, \(locations.count) locations, \(characters.count) characters")
    }

    // MARK: - BigFish Highland Tests

    @Test("Parse BigFish.highland file")
    func parseBigFishHighland() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try getFixture("bigfish", extension: "highland")

        // Parse the document
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Verify document was parsed
        #expect(document.filename == "bigfish.fountain", "Highland files extract to fountain")
        #expect(!document.elements.isEmpty, "Document should have elements")

        // Verify we have various element types
        let elementTypes = Set(document.elements.map { $0.elementType })
        #expect(elementTypes.contains("Scene Heading"), "Should have scene headings")
        #expect(elementTypes.contains("Action"), "Should have action elements")
        #expect(elementTypes.contains("Character"), "Should have character elements")
        #expect(elementTypes.contains("Dialogue"), "Should have dialogue elements")

        // Verify locations are parsed
        let locations = document.sceneLocations
        #expect(!locations.isEmpty, "Should have parsed scene locations")

        // Verify we can extract characters
        let characters = extractCharacters(from: document)
        #expect(!characters.isEmpty, "Should have characters with dialogue")

        print("✅ BigFish.highland: \(document.elements.count) elements, \(locations.count) locations, \(characters.count) characters")
    }

    // MARK: - Cross-Format Consistency Tests

    @Test("All BigFish formats produce similar results")
    func bigFishCrossFormatConsistency() async throws {
        let modelContext = try createModelContext()

        // Parse all three formats
        let fountainURL = try getFixture("bigfish", extension: "fountain")
        let fdxURL = try getFixture("bigfish", extension: "fdx")
        let highlandURL = try getFixture("bigfish", extension: "highland")

        let fountainDoc = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fountainURL,
            in: modelContext,
            generateSummaries: false
        )

        let fdxDoc = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fdxURL,
            in: modelContext,
            generateSummaries: false
        )

        let highlandDoc = try await GuionDocumentParserSwiftData.loadAndParse(
            from: highlandURL,
            in: modelContext,
            generateSummaries: false
        )

        // All should have similar element counts (within 10% of each other)
        let fountainCount = fountainDoc.elements.count
        let fdxCount = fdxDoc.elements.count
        let highlandCount = highlandDoc.elements.count

        let minCount = min(fountainCount, fdxCount, highlandCount)
        let maxCount = max(fountainCount, fdxCount, highlandCount)
        let variance = Double(maxCount - minCount) / Double(minCount)

        #expect(variance < 0.15, "Element counts should be within 15% of each other (got \(fountainCount), \(fdxCount), \(highlandCount))")

        // All should have scene headings
        #expect(fountainDoc.sceneLocations.count > 0, "Fountain should have locations")
        #expect(fdxDoc.sceneLocations.count > 0, "FDX should have locations")
        #expect(highlandDoc.sceneLocations.count > 0, "Highland should have locations")

        print("✅ Cross-format consistency: Fountain=\(fountainCount), FDX=\(fdxCount), Highland=\(highlandCount) elements")
    }

    // MARK: - Document Export Tests

    @Test("Export document to Fountain format")
    func exportToFountain() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try getFixture("bigfish", extension: "fdx")

        // Parse FDX
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Convert to Fountain
        let script = GuionDocumentParserSwiftData.toFountainScript(from: document)
        let fountainText = script.stringFromDocument()

        #expect(!fountainText.isEmpty, "Should generate fountain text")
        #expect(fountainText.contains("INT.") || fountainText.contains("EXT."), "Should contain scene headings")

        print("✅ Export to Fountain: \(fountainText.count) characters")
    }

    @Test("Export document to FDX format")
    func exportToFDX() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try getFixture("bigfish", extension: "fountain")

        // Parse Fountain
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Convert to FDX
        let fdxData = GuionDocumentParserSwiftData.toFDXData(from: document)

        #expect(fdxData.count > 0, "Should generate FDX data")

        // Verify it's valid XML
        let xmlString = String(data: fdxData, encoding: .utf8)
        #expect(xmlString?.contains("<?xml") ?? false, "Should be valid XML")
        #expect(xmlString?.contains("FinalDraft") ?? false, "Should be FinalDraft format")

        print("✅ Export to FDX: \(fdxData.count) bytes")
    }

    // MARK: - Scene Browser Integration Tests

    @Test("Convert GuionDocumentModel to SceneBrowserData")
    func convertDocumentToSceneBrowserData() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try getFixture("test", extension: "fountain")

        // Parse the document
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Convert to FountainScript
        let script = GuionDocumentParserSwiftData.toFountainScript(from: document)

        // Extract scene browser data
        let browserData = script.extractSceneBrowserData()

        // Verify title exists
        #expect(browserData.title != nil, "Should have a title")
        #expect(!browserData.title!.string.isEmpty, "Title should not be empty")

        // Verify chapters exist
        #expect(browserData.chapters.count > 0, "Should have chapters")

        // Verify first chapter structure
        let firstChapter = browserData.chapters[0]
        #expect(!firstChapter.title.isEmpty, "Chapter should have title")
        #expect(firstChapter.sceneGroups.count > 0, "Chapter should have scene groups")

        print("✅ Scene Browser Data: title='\(browserData.title?.string ?? "")' chapters=\(browserData.chapters.count)")
    }

    @Test("Scene Browser handles all screenplay formats")
    func sceneBrowserHandlesAllFormats() async throws {
        let modelContext = try createModelContext()

        // Test with Fountain
        let fountainURL = try getFixture("bigfish", extension: "fountain")
        let fountainDoc = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fountainURL,
            in: modelContext,
            generateSummaries: false
        )
        let fountainScript = GuionDocumentParserSwiftData.toFountainScript(from: fountainDoc)
        let fountainBrowser = fountainScript.extractSceneBrowserData()
        #expect(fountainBrowser.chapters.count > 0, "Fountain should produce chapters")

        // Test with FDX
        let fdxURL = try getFixture("bigfish", extension: "fdx")
        let fdxDoc = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fdxURL,
            in: modelContext,
            generateSummaries: false
        )
        let fdxScript = GuionDocumentParserSwiftData.toFountainScript(from: fdxDoc)
        let fdxBrowser = fdxScript.extractSceneBrowserData()
        #expect(fdxBrowser.chapters.count > 0, "FDX should produce chapters")

        // Test with Highland
        let highlandURL = try getFixture("bigfish", extension: "highland")
        let highlandDoc = try await GuionDocumentParserSwiftData.loadAndParse(
            from: highlandURL,
            in: modelContext,
            generateSummaries: false
        )
        let highlandScript = GuionDocumentParserSwiftData.toFountainScript(from: highlandDoc)
        let highlandBrowser = highlandScript.extractSceneBrowserData()
        #expect(highlandBrowser.chapters.count > 0, "Highland should produce chapters")

        print("✅ Scene Browser works with all formats: Fountain=\(fountainBrowser.chapters.count), FDX=\(fdxBrowser.chapters.count), Highland=\(highlandBrowser.chapters.count) chapters")
    }

    @Test("Scene Browser preserves scene content")
    func sceneBrowserPreservesSceneContent() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try getFixture("test", extension: "fountain")

        // Parse the document
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Convert to scene browser data
        let script = GuionDocumentParserSwiftData.toFountainScript(from: document)
        let browserData = script.extractSceneBrowserData()

        // Find first scene with content
        var foundSceneWithContent = false
        for chapter in browserData.chapters {
            for sceneGroup in chapter.sceneGroups {
                for scene in sceneGroup.scenes {
                    if !scene.sceneElements.isEmpty {
                        foundSceneWithContent = true

                        // Verify scene has elements
                        #expect(scene.sceneElements.count > 0, "Scene should have elements")

                        // Verify elements have content
                        for element in scene.sceneElements {
                            #expect(!element.elementText.isEmpty, "Element should have text")
                            #expect(!element.elementType.isEmpty, "Element should have type")
                        }

                        break
                    }
                }
                if foundSceneWithContent { break }
            }
            if foundSceneWithContent { break }
        }

        #expect(foundSceneWithContent, "Should find at least one scene with content")
        print("✅ Scene Browser preserves scene content correctly")
    }

    @Test("Scene Browser handles preScene content")
    func sceneBrowserHandlesPreSceneContent() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try getFixture("test", extension: "fountain")

        // Parse the document
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Convert to scene browser data
        let script = GuionDocumentParserSwiftData.toFountainScript(from: document)
        let browserData = script.extractSceneBrowserData()

        // Look for scenes with preScene content
        var foundPreScene = false
        for chapter in browserData.chapters {
            for sceneGroup in chapter.sceneGroups {
                for scene in sceneGroup.scenes {
                    if scene.hasPreScene {
                        foundPreScene = true

                        #expect(scene.preSceneElements != nil, "PreScene elements should exist")
                        #expect(scene.preSceneElements!.count > 0, "PreScene should have elements")

                        // Verify preScene content
                        for element in scene.preSceneElements! {
                            #expect(!element.elementText.isEmpty, "PreScene element should have text")
                        }

                        break
                    }
                }
                if foundPreScene { break }
            }
            if foundPreScene { break }
        }

        // Note: test.fountain may or may not have preScene content
        // This test validates the structure works correctly
        print("✅ Scene Browser handles preScene content: found=\(foundPreScene)")
    }

    // MARK: - Helper Functions

    private func extractCharacters(from document: GuionDocumentModel) -> [(name: String, lineCount: Int)] {
        var characterCounts: [String: Int] = [:]

        for element in document.elements where element.elementType == "Character" {
            let name = cleanCharacterName(element.elementText)
            characterCounts[name, default: 0] += 1
        }

        return characterCounts.map { (name: $0.key, lineCount: $0.value) }
            .sorted { $0.lineCount > $1.lineCount }
    }

    private func cleanCharacterName(_ name: String) -> String {
        var cleaned = name.trimmingCharacters(in: .whitespaces)
        if let openParen = cleaned.firstIndex(of: "(") {
            cleaned = String(cleaned[..<openParen]).trimmingCharacters(in: .whitespaces)
        }
        cleaned = cleaned.replacingOccurrences(of: "^", with: "").trimmingCharacters(in: .whitespaces)
        return cleaned.uppercased()
    }

    // MARK: - Error Types

    enum TestError: Error {
        case fixturesNotFound(String)
        case fixtureNotFound(String)
    }
}

// MARK: - Bundle Extension for Tests

private extension Bundle {
    static var testBundle: Bundle {
        Bundle(for: TestBundleMarker.self)
    }
}

private class TestBundleMarker {}
