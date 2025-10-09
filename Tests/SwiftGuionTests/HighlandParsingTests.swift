//
//  HighlandParsingTests.swift
//  SwiftGuionTests
//
//  Created by TOM STOVALL on 10/9/25.
//

import XCTest
import SwiftData
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
        // Get the package root directory
        let packageRootPath = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let fixturesURL = packageRootPath.appendingPathComponent("Fixtures")

        // Ensure Fixtures directory exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: fixturesURL.path), "Fixtures directory not found at \(fixturesURL.path)")

        // Get all Highland files
        let contents = try FileManager.default.contentsOfDirectory(at: fixturesURL, includingPropertiesForKeys: nil)
        let highlandFiles = contents.filter { $0.pathExtension == "highland" }

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

        // Assert that all files parsed with non-zero elements
        XCTAssertTrue(failedFiles.isEmpty, "Some Highland files failed to parse or had zero elements")
    }

    /// Test that Highland file structure is correctly identified
    func testHighlandFileStructure() throws {
        let packageRootPath = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let fixturesURL = packageRootPath.appendingPathComponent("Fixtures")
        let testHighlandURL = fixturesURL.appendingPathComponent("test.highland")

        guard FileManager.default.fileExists(atPath: testHighlandURL.path) else {
            XCTFail("test.highland not found")
            return
        }

        // Highland files are ZIP archives
        let data = try Data(contentsOf: testHighlandURL)
        XCTAssertGreaterThan(data.count, 0, "Highland file should contain data")

        // Check if it's a ZIP file (starts with PK)
        let signature = data.prefix(2)
        XCTAssertEqual(signature, Data([0x50, 0x4B]), "Highland file should be a ZIP archive")
    }
}
