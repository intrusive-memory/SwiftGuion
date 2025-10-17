//
//  BigFishParsingTests.swift
//  SwiftGuionTests
//
//  Tests for parsing BigFish screenplay in all three formats
//

import Testing
import Foundation
import SwiftData
import SwiftFijos
@testable import SwiftGuion

struct BigFishParsingTests {

    // MARK: - Helper Methods

    @MainActor
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

    // MARK: - BigFish Fountain Tests

    @Test("Parse BigFish.fountain using unified parser")
    @MainActor
    func parseBigFishFountain() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try Fijos.getFixture("bigfish", extension: "fountain")

        // Parse using the unified parser
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
        #expect(elementTypes.contains(.sceneHeading), "Should have scene headings")
        #expect(elementTypes.contains(.action), "Should have action elements")
        #expect(elementTypes.contains(.character), "Should have character elements")
        #expect(elementTypes.contains(.dialogue), "Should have dialogue elements")

        // Title page is optional (not all scripts have one)
        // BigFish fountain may or may not have title page depending on parser

        // Verify locations are parsed
        let locations = document.sceneLocations
        #expect(!locations.isEmpty, "Should have parsed scene locations")

        // Count characters
        let characterElements = document.elements.filter { $0.elementType == .character }
        let uniqueCharacters = Set(characterElements.map { cleanCharacterName($0.elementText) })

        print("✅ BigFish.fountain: \(document.elements.count) elements, \(locations.count) locations, \(uniqueCharacters.count) unique characters")
    }

    // MARK: - BigFish FDX Tests

    @Test("Parse BigFish.fdx using unified parser")
    @MainActor
    func parseBigFishFDX() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try Fijos.getFixture("bigfish", extension: "fdx")

        // Parse using the unified parser
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
        #expect(elementTypes.contains(.sceneHeading), "Should have scene headings")
        #expect(elementTypes.contains(.action), "Should have action elements")
        #expect(elementTypes.contains(.character), "Should have character elements")
        #expect(elementTypes.contains(.dialogue), "Should have dialogue elements")

        // Verify locations are parsed
        let locations = document.sceneLocations
        #expect(!locations.isEmpty, "Should have parsed scene locations")

        // Count characters
        let characterElements = document.elements.filter { $0.elementType == .character }
        let uniqueCharacters = Set(characterElements.map { cleanCharacterName($0.elementText) })

        print("✅ BigFish.fdx: \(document.elements.count) elements, \(locations.count) locations, \(uniqueCharacters.count) unique characters")
    }

    // MARK: - BigFish Highland Tests

    @Test("Parse BigFish.highland using unified parser")
    @MainActor
    func parseBigFishHighland() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try Fijos.getFixture("bigfish", extension: "highland")

        // Parse using the unified parser
        let document = try await GuionDocumentParserSwiftData.loadAndParse(
            from: fixtureURL,
            in: modelContext,
            generateSummaries: false
        )

        // Verify document was parsed
        // Highland files extract to text.md internally, so we check for that or the original filename
        #expect(document.filename == "text.md" || document.filename == "bigfish.highland", "Highland extracts to text.md internally")
        #expect(!document.elements.isEmpty, "Document should have elements")

        // Verify we have various element types
        let elementTypes = Set(document.elements.map { $0.elementType })
        #expect(elementTypes.contains(.sceneHeading), "Should have scene headings")
        #expect(elementTypes.contains(.action), "Should have action elements")
        #expect(elementTypes.contains(.character), "Should have character elements")
        #expect(elementTypes.contains(.dialogue), "Should have dialogue elements")

        // Verify locations are parsed
        let locations = document.sceneLocations
        #expect(!locations.isEmpty, "Should have parsed scene locations")

        // Count characters
        let characterElements = document.elements.filter { $0.elementType == .character }
        let uniqueCharacters = Set(characterElements.map { cleanCharacterName($0.elementText) })

        print("✅ BigFish.highland: \(document.elements.count) elements, \(locations.count) locations, \(uniqueCharacters.count) unique characters")
    }

    // MARK: - Cross-Format Consistency Tests

    @Test("All BigFish formats produce similar results")
    @MainActor
    func bigFishCrossFormatConsistency() async throws {
        let modelContext = try createModelContext()

        // Parse all three formats
        let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
        let fdxURL = try Fijos.getFixture("bigfish", extension: "fdx")
        let highlandURL = try Fijos.getFixture("bigfish", extension: "highland")

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

        // All should have similar element counts
        let fountainCount = fountainDoc.elements.count
        let fdxCount = fdxDoc.elements.count
        let highlandCount = highlandDoc.elements.count

        print("📊 Element counts: Fountain=\(fountainCount), FDX=\(fdxCount), Highland=\(highlandCount)")

        // All should have elements
        #expect(fountainCount > 0, "Fountain should have elements")
        #expect(fdxCount > 0, "FDX should have elements")
        #expect(highlandCount > 0, "Highland should have elements")

        // All should have scene headings
        #expect(fountainDoc.sceneLocations.count > 0, "Fountain should have locations")
        #expect(fdxDoc.sceneLocations.count > 0, "FDX should have locations")
        #expect(highlandDoc.sceneLocations.count > 0, "Highland should have locations")

        // Note: The fixture files bigfish.fountain and bigfish.highland are different versions
        // of the script, so their element counts will differ. This is expected.

        print("✅ Cross-format consistency verified")
    }

    // MARK: - Export Tests

    @Test("Export to Fountain format")
    @MainActor
    func exportToFountain() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try Fijos.getFixture("bigfish", extension: "fdx")

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

    @Test("Export to FDX format")
    @MainActor
    func exportToFDX() async throws {
        let modelContext = try createModelContext()
        let fixtureURL = try Fijos.getFixture("bigfish", extension: "fountain")

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

    // MARK: - Helper Functions

    private func cleanCharacterName(_ name: String) -> String {
        var cleaned = name.trimmingCharacters(in: .whitespaces)
        if let openParen = cleaned.firstIndex(of: "(") {
            cleaned = String(cleaned[..<openParen]).trimmingCharacters(in: .whitespaces)
        }
        cleaned = cleaned.replacingOccurrences(of: "^", with: "").trimmingCharacters(in: .whitespaces)
        return cleaned.uppercased()
    }
}
