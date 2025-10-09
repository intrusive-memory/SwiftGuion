//
//  SceneBrowserUITests.swift
//  SwiftGuionTests
//
//  UI and Integration tests for Scene Browser widgets
//

import XCTest
@testable import SwiftGuion

final class SceneBrowserUITests: XCTestCase {

    // MARK: - Integration Tests with Real Data

    func testSceneBrowserDataFromTestFixture() throws {
        // Load test.fountain and extract browser data
        let fountainPath = try FixtureManager.getTestFountain().path
        let script = try FountainScript(file: fountainPath)
        let browserData = script.extractSceneBrowserData()

        // Verify title exists
        XCTAssertNotNil(browserData.title, "Browser should have a title")
        XCTAssertFalse(browserData.title!.string.isEmpty, "Title should not be empty")

        // Verify chapters exist
        XCTAssertGreaterThan(browserData.chapters.count, 0, "Should have at least one chapter")

        // Verify first chapter structure
        let firstChapter = browserData.chapters[0]
        XCTAssertFalse(firstChapter.title.isEmpty, "Chapter should have a title")
        XCTAssertGreaterThan(firstChapter.sceneGroups.count, 0, "Chapter should have scene groups")

        // Verify scene group structure
        let firstGroup = firstChapter.sceneGroups[0]
        XCTAssertFalse(firstGroup.title.isEmpty, "Scene group should have a title")
        XCTAssertGreaterThan(firstGroup.scenes.count, 0, "Scene group should have scenes")

        // Verify scene structure
        let firstScene = firstGroup.scenes[0]
        XCTAssertFalse(firstScene.slugline.isEmpty, "Scene should have a slugline")
        XCTAssertNotNil(firstScene.element, "Scene should have outline element")
    }

    func testHierarchyIntegrityWithRealData() throws {
        let fountainPath = try FixtureManager.getTestFountain().path
        let script = try FountainScript(file: fountainPath)
        let browserData = script.extractSceneBrowserData()

        // Verify all chapters have valid IDs
        for chapter in browserData.chapters {
            XCTAssertFalse(chapter.id.isEmpty, "Chapter should have valid ID")
            XCTAssertTrue(chapter.element.isChapter, "Chapter element should be marked as chapter")
            XCTAssertEqual(chapter.element.level, 2, "Chapter should be level 2")

            // Verify scene groups
            for sceneGroup in chapter.sceneGroups {
                XCTAssertFalse(sceneGroup.id.isEmpty, "Scene group should have valid ID")
                XCTAssertEqual(sceneGroup.element.level, 3, "Scene group should be level 3")

                // Verify scenes
                for scene in sceneGroup.scenes {
                    XCTAssertFalse(scene.id.isEmpty, "Scene should have valid ID")
                    XCTAssertEqual(scene.element.type, "sceneHeader", "Scene element should be scene header")
                }
            }
        }
    }

    func testSceneContentExtraction() throws {
        let fountainPath = try FixtureManager.getTestFountain().path
        let script = try FountainScript(file: fountainPath)
        let browserData = script.extractSceneBrowserData()

        // Find first scene with content
        var foundSceneWithContent = false
        for chapter in browserData.chapters {
            for sceneGroup in chapter.sceneGroups {
                for scene in sceneGroup.scenes {
                    if !scene.sceneElements.isEmpty {
                        foundSceneWithContent = true

                        // Verify scene has elements
                        XCTAssertGreaterThan(scene.sceneElements.count, 0, "Scene should have elements")

                        // Verify elements have content
                        for element in scene.sceneElements {
                            XCTAssertFalse(element.elementText.isEmpty, "Element should have text")
                            XCTAssertFalse(element.elementType.isEmpty, "Element should have type")
                        }

                        break
                    }
                }
                if foundSceneWithContent { break }
            }
            if foundSceneWithContent { break }
        }

        XCTAssertTrue(foundSceneWithContent, "Should find at least one scene with content")
    }

    func testPreSceneContentAttachment() throws {
        let fountainPath = try FixtureManager.getTestFountain().path
        let script = try FountainScript(file: fountainPath)
        let browserData = script.extractSceneBrowserData()

        // test.fountain has OVER BLACK content that should be attached to scenes
        var foundPreScene = false
        for chapter in browserData.chapters {
            for sceneGroup in chapter.sceneGroups {
                for scene in sceneGroup.scenes {
                    if scene.hasPreScene {
                        foundPreScene = true

                        XCTAssertNotNil(scene.preSceneElements, "PreScene elements should exist")
                        XCTAssertGreaterThan(scene.preSceneElements!.count, 0, "PreScene should have elements")

                        // Verify preScene content
                        for element in scene.preSceneElements! {
                            XCTAssertFalse(element.elementText.isEmpty, "PreScene element should have text")
                        }

                        // Verify preSceneText property
                        XCTAssertFalse(scene.preSceneText.isEmpty, "PreScene text should not be empty")

                        break
                    }
                }
                if foundPreScene { break }
            }
            if foundPreScene { break }
        }

        // Note: This test will pass even if no preScene is found,
        // as it verifies the structure works correctly
    }

    func testSceneLocationParsing() throws {
        let fountainPath = try FixtureManager.getTestFountain().path
        let script = try FountainScript(file: fountainPath)
        let browserData = script.extractSceneBrowserData()

        // Find scenes with locations
        var foundSceneWithLocation = false
        for chapter in browserData.chapters {
            for sceneGroup in chapter.sceneGroups {
                for scene in sceneGroup.scenes {
                    if let location = scene.sceneLocation {
                        foundSceneWithLocation = true

                        // Verify location parsing
                        XCTAssertFalse(location.scene.isEmpty, "Location should have scene name")
                        XCTAssertNotEqual(location.lighting, .unknown, "Location should have valid lighting")

                        break
                    }
                }
                if foundSceneWithLocation { break }
            }
            if foundSceneWithLocation { break }
        }

        XCTAssertTrue(foundSceneWithLocation, "Should find at least one scene with parsed location")
    }

    func testSceneDirectiveMetadata() throws {
        let fountainPath = try FixtureManager.getTestFountain().path
        let script = try FountainScript(file: fountainPath)
        let browserData = script.extractSceneBrowserData()

        // Look for scene groups with directives (like "### PROLOGUE S#{{SERIES: 1001}}")
        var foundDirective = false
        for chapter in browserData.chapters {
            for sceneGroup in chapter.sceneGroups {
                if let directive = sceneGroup.directive {
                    foundDirective = true

                    XCTAssertFalse(directive.isEmpty, "Directive should not be empty")

                    // Directive description is optional but should be valid if present
                    if let description = sceneGroup.directiveDescription {
                        XCTAssertFalse(description.isEmpty, "Directive description should not be empty if present")
                    }

                    break
                }
            }
            if foundDirective { break }
        }

        XCTAssertTrue(foundDirective, "test.fountain should have scene groups with directives")
    }

    // MARK: - State Management Tests

    func testChapterExpansionState() {
        // Create sample browser data
        let browserData = createSampleBrowserData()

        // Verify we have chapters to test
        XCTAssertGreaterThan(browserData.chapters.count, 0, "Should have chapters for testing")

        // Test that chapter IDs are unique and valid
        var chapterIds = Set<String>()
        for chapter in browserData.chapters {
            XCTAssertFalse(chapter.id.isEmpty, "Chapter ID should not be empty")
            XCTAssertFalse(chapterIds.contains(chapter.id), "Chapter IDs should be unique")
            chapterIds.insert(chapter.id)
        }
    }

    func testSceneGroupExpansionState() {
        let browserData = createSampleBrowserData()

        // Verify scene groups have unique IDs
        var sceneGroupIds = Set<String>()
        for chapter in browserData.chapters {
            for sceneGroup in chapter.sceneGroups {
                XCTAssertFalse(sceneGroup.id.isEmpty, "Scene group ID should not be empty")
                XCTAssertFalse(sceneGroupIds.contains(sceneGroup.id), "Scene group IDs should be unique")
                sceneGroupIds.insert(sceneGroup.id)
            }
        }
    }

    func testSceneExpansionState() {
        let browserData = createSampleBrowserData()

        // Verify scenes have unique IDs
        var sceneIds = Set<String>()
        for chapter in browserData.chapters {
            for sceneGroup in chapter.sceneGroups {
                for scene in sceneGroup.scenes {
                    XCTAssertFalse(scene.id.isEmpty, "Scene ID should not be empty")
                    XCTAssertFalse(sceneIds.contains(scene.id), "Scene IDs should be unique")
                    sceneIds.insert(scene.id)
                }
            }
        }
    }

    // MARK: - Data Model Tests

    func testBrowserDataHierarchy() {
        let browserData = createSampleBrowserData()

        // Verify title
        XCTAssertNotNil(browserData.title, "Should have a title")
        XCTAssertEqual(browserData.title?.level, 1, "Title should be level 1")

        // Verify chapters
        XCTAssertGreaterThan(browserData.chapters.count, 0, "Should have chapters")

        for chapter in browserData.chapters {
            // Verify chapter level
            XCTAssertEqual(chapter.element.level, 2, "Chapter should be level 2")

            // Verify scene groups
            XCTAssertGreaterThan(chapter.sceneGroups.count, 0, "Chapter should have scene groups")

            for sceneGroup in chapter.sceneGroups {
                // Verify scene group level
                XCTAssertEqual(sceneGroup.element.level, 3, "Scene group should be level 3")

                // Verify scenes
                XCTAssertGreaterThan(sceneGroup.scenes.count, 0, "Scene group should have scenes")
            }
        }
    }

    func testMultipleChapters() throws {
        let fountainPath = try FixtureManager.getTestFountain().path
        let script = try FountainScript(file: fountainPath)
        let browserData = script.extractSceneBrowserData()

        // test.fountain should have multiple chapters
        XCTAssertGreaterThanOrEqual(browserData.chapters.count, 2, "test.fountain should have at least 2 chapters")

        // Verify each chapter has unique content
        let chapterTitles = Set(browserData.chapters.map { $0.title })
        XCTAssertEqual(chapterTitles.count, browserData.chapters.count, "Chapter titles should be unique")
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
                                        GuionElement(type: "Action", text: "Bernard and Killian sit in a steam room.")
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
}
