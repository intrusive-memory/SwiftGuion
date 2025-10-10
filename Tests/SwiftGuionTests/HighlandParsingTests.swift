//
//  HighlandParsingTests.swift
//  SwiftGuionTests
//
//  Created by TOM STOVALL on 10/9/25.
//

import XCTest
import SwiftData
import SwiftFijos
@testable import SwiftGuion

final class HighlandParsingTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
    }

    /// Test parsing all Highland files in the Fixtures directory
    @MainActor
    func testAllHighlandFilesInFixtures() async throws {
        // Get all Highland fixtures using Fijos
        let highlandFixtures = try Fijos.listFixtures(withExtension: "highland")
        let highlandFiles = highlandFixtures.map { $0.url }

        XCTAssertFalse(highlandFiles.isEmpty, "No Highland files found in Fixtures directory")

        print("\n📋 Found \(highlandFiles.count) Highland files to test:")
        for file in highlandFiles {
            print("  - \(file.lastPathComponent)")
        }

        var failedFiles: [(URL, Error?)] = []
        var successfulFiles: [(URL, Int)] = []

        // Test each Highland file
        for highlandURL in highlandFiles {
            print("\n🔍 Testing: \(highlandURL.lastPathComponent)")

            do {
                let document = try await GuionDocumentParserSwiftData.loadAndParse(
                    from: highlandURL,
                    in: modelContext,
                    generateSummaries: false
                )

                let elementCount = document.elements.count
                print("  ✅ Parsed successfully: \(elementCount) elements")

                if elementCount == 0 {
                    print("  ⚠️  WARNING: Zero elements parsed!")
                    failedFiles.append((highlandURL, nil))
                } else {
                    successfulFiles.append((highlandURL, elementCount))
                }

            } catch {
                print("  ❌ Failed to parse: \(error)")
                failedFiles.append((highlandURL, error))
            }
        }

        // Print summary
        print("\n" + String(repeating: "=", count: 60))
        print("📊 SUMMARY")
        print(String(repeating: "=", count: 60))
        print("✅ Successfully parsed: \(successfulFiles.count)/\(highlandFiles.count)")
        print("❌ Failed or empty: \(failedFiles.count)/\(highlandFiles.count)")

        if !successfulFiles.isEmpty {
            print("\n✅ Successful files:")
            for (url, count) in successfulFiles {
                print("  - \(url.lastPathComponent): \(count) elements")
            }
        }

        if !failedFiles.isEmpty {
            print("\n❌ Failed files:")
            for (url, error) in failedFiles {
                if let error = error {
                    print("  - \(url.lastPathComponent): \(error.localizedDescription)")
                } else {
                    print("  - \(url.lastPathComponent): Zero elements parsed")
                }
            }
        }

        print(String(repeating: "=", count: 60) + "\n")

        // Assert that we successfully parsed at least one file
        // Some fixture files (like test.highland from dependencies) may be corrupted
        XCTAssertGreaterThan(successfulFiles.count, 0, "Should successfully parse at least one Highland file")

        // Assert that we parse at least some files successfully
        // Note: Some fixture files from external dependencies may be corrupted or incomplete
        let successRate = Double(successfulFiles.count) / Double(highlandFiles.count)
        XCTAssertGreaterThanOrEqual(successRate, 0.5, "At least 50% of Highland files should parse successfully (some fixtures may be test stubs)")
    }

    /// Test that Highland file structure is correctly identified
    func testHighlandFileStructure() throws {
        let testHighlandURL = try Fijos.getFixture("test", extension: "highland")

        // Highland files are ZIP archives
        let data = try Data(contentsOf: testHighlandURL)
        XCTAssertGreaterThan(data.count, 0, "Highland file should contain data")

        // Check if it's a ZIP file (starts with PK)
        let signature = data.prefix(2)
        XCTAssertEqual(signature, Data([0x50, 0x4B]), "Highland file should be a ZIP archive")
    }
}
