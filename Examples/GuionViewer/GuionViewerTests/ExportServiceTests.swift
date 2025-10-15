//
//  ExportServiceTests.swift
//  GuionViewerTests
//
//  Comprehensive tests for export functionality
//  Copyright (c) 2025
//

import XCTest
import UniformTypeIdentifiers
@testable import GuionViewer
import SwiftGuion

final class ExportServiceTests: XCTestCase {

    // MARK: - Test Helpers

    var tempDirectory: URL!

    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }


    // MARK: - ExportError Tests

    func testExportErrorNoDocumentOpen() {
        let error = ExportError.noDocumentOpen

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("No document"))
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }

    func testExportErrorWriteFailed() {
        let url = URL(fileURLWithPath: "/tmp/test.fountain")
        struct TestError: Error {}
        let error = ExportError.writeFailed(url, underlying: TestError())

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("test.fountain"))
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }

    func testExportErrorUnsupportedFormat() {
        let error = ExportError.unsupportedFormat(.pdf)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
        XCTAssertTrue(error.recoverySuggestion!.contains(".fountain") ||
                     error.recoverySuggestion!.contains(".fdx"))
    }

    // MARK: - Save As Helper Tests

    func testSaveAsPanelShowsCorrectDirectory() throws {
        // This test would require UI testing framework
        // Documenting the expected behavior:
        // - When originalURL is provided, panel should open in that directory
        // - Panel should show correct file extension
        // - Default filename should be set
    }

    func testReplaceConfirmationDialog() throws {
        // This test would require UI testing framework
        // Documenting the expected behavior:
        // - Dialog should show filename being replaced
        // - Should have Replace and Cancel buttons
        // - Replace button should be first (default)
        // - Dialog should be warning style
    }
}
