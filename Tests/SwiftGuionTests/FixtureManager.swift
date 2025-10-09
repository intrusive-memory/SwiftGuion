//
//  FixtureManager.swift
//  SwiftScreenplay
//
//  Copyright (c) 2025
//
//  Helper for loading fixture files in tests

import Foundation

enum FixtureManager {
    enum FixtureError: Error {
        case fixtureNotFound(String)
    }

    static func getFixturesDirectory() throws -> URL {
        let testsDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let packageRoot = testsDirectory.deletingLastPathComponent().deletingLastPathComponent()
        let fixturesDirectory = packageRoot.appendingPathComponent("Fixtures")

        guard FileManager.default.fileExists(atPath: fixturesDirectory.path) else {
            throw FixtureError.fixtureNotFound("Fixtures directory not found at \(fixturesDirectory.path)")
        }

        return fixturesDirectory
    }

    static func getFixture(_ name: String, extension ext: String) throws -> URL {
        let fixturesDirectory = try getFixturesDirectory()
        let fixtureURL = fixturesDirectory.appendingPathComponent("\(name).\(ext)")

        guard FileManager.default.fileExists(atPath: fixtureURL.path) else {
            throw FixtureError.fixtureNotFound("Fixture \(name).\(ext) not found")
        }

        return fixtureURL
    }

    // Convenience methods for common fixtures
    static func getBigFishFountain() throws -> URL {
        try getFixture("bigfish", extension: "fountain")
    }

    static func getBigFishFDX() throws -> URL {
        try getFixture("bigfish", extension: "fdx")
    }

    static func getBigFishHighland() throws -> URL {
        try getFixture("bigfish", extension: "highland")
    }

    static func getTestFountain() throws -> URL {
        try getFixture("test", extension: "fountain")
    }

    static func getTestHighland() throws -> URL {
        try getFixture("test", extension: "highland")
    }

    static func getTestTextBundle() throws -> URL {
        try getFixture("test", extension: "textbundle")
    }
}
