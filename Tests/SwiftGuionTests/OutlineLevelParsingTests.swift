//
//  OutlineLevelParsingTests.swift
//  SwiftGuionTests
//
//  Comprehensive tests for outline level parsing and hierarchy
//

import XCTest
@testable import SwiftGuion

final class OutlineLevelParsingTests: XCTestCase {

    // MARK: - Basic Level Detection

    func testSingleLevel1Header() throws {
        let content = """
        # Main Title

        INT. ROOM - DAY

        Action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let level1Elements = outline.filter { $0.level == 1 }
        XCTAssertEqual(level1Elements.count, 1, "Should have exactly one level 1 element")
        XCTAssertEqual(level1Elements.first?.string, "Main Title")
    }

    func testMultipleLevel1HeadersGetDemoted() throws {
        let content = """
        # First Title

        Some action.

        # Second Title

        More action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let level1Elements = outline.filter { $0.level == 1 }
        let level2Elements = outline.filter { $0.level == 2 && $0.type == "sectionHeader" }

        XCTAssertEqual(level1Elements.count, 1, "Should have exactly one level 1 element")
        XCTAssertEqual(level1Elements.first?.string, "First Title")
        XCTAssertEqual(level2Elements.count, 1, "Second # header should be demoted to level 2")
        XCTAssertEqual(level2Elements.first?.string, "Second Title")
    }

    func testNoLevel1CreatesSymtheticTitle() throws {
        let content = """
        ## Chapter 1

        INT. ROOM - DAY

        Action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let level1Elements = outline.filter { $0.level == 1 }
        XCTAssertEqual(level1Elements.count, 1, "Should create synthetic level 1 title")
        XCTAssertTrue(level1Elements.first?.isSynthetic ?? false, "Title should be marked as synthetic")
    }

    // MARK: - Chapter Level (Level 2) Detection

    func testLevel2ChaptersDetection() throws {
        let content = """
        ## CHAPTER 1

        ### Scene Group

        INT. ROOM - DAY

        Action.

        ## CHAPTER 2

        INT. ANOTHER ROOM - DAY

        More action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let chapters = outline.filter { $0.isChapter }
        XCTAssertEqual(chapters.count, 2, "Should detect 2 chapters")
        XCTAssertEqual(chapters[0].string, "CHAPTER 1")
        XCTAssertEqual(chapters[1].string, "CHAPTER 2")
    }

    func testENDMarkersNotCountedAsChapters() throws {
        let content = """
        ## CHAPTER 1

        INT. ROOM - DAY

        Action.

        ## END CHAPTER 1

        ## CHAPTER 2

        More action.

        ## END CHAPTER 2
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let chapters = outline.filter { $0.isChapter }
        let endMarkers = outline.filter { $0.isEndMarker }

        XCTAssertEqual(chapters.count, 2, "Should detect 2 chapters (not END markers)")
        XCTAssertEqual(endMarkers.count, 2, "Should detect 2 END markers")
        XCTAssertFalse(endMarkers.allSatisfy { $0.isChapter }, "END markers should not be chapters")
    }

    func testSHOTDirectivesNotCountedAsChapters() throws {
        let content = """
        ## CHAPTER 1

        INT. ROOM - DAY

        Action.

        ## SHOT: Close-up on the door

        The door opens.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let chapters = outline.filter { $0.isChapter }

        // SHOT: should not be counted as a chapter
        // It's a technical directive, not a story chapter
        XCTAssertEqual(chapters.count, 1, "SHOT directive should not be a chapter")
        XCTAssertEqual(chapters.first?.string, "CHAPTER 1")
    }

    // MARK: - Scene Group Level (Level 3) Detection

    func testLevel3SceneGroupDetection() throws {
        let content = """
        ## CHAPTER 1

        ### PROLOGUE

        INT. ROOM - DAY

        Action.

        ### ACT ONE

        INT. ANOTHER ROOM - DAY

        More action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let sceneGroups = outline.filter { $0.level == 3 && $0.type == "sectionHeader" }
        XCTAssertEqual(sceneGroups.count, 2, "Should detect 2 scene groups")
        XCTAssertEqual(sceneGroups[0].string, "PROLOGUE")
        XCTAssertEqual(sceneGroups[1].string, "ACT ONE")
    }

    func testSceneDirectiveExtraction() throws {
        let content = """
        ## CHAPTER 1

        ### PROLOGUE S#{{SERIES: 1001}}

        INT. ROOM - DAY

        Action.

        ### THE MURDER S#{{SERIES: 1002}}

        INT. ANOTHER ROOM - DAY

        More action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let sceneGroups = outline.filter { $0.level == 3 && $0.type == "sectionHeader" }

        XCTAssertEqual(sceneGroups.count, 2, "Should detect 2 scene groups")

        // Check first scene group
        XCTAssertEqual(sceneGroups[0].sceneDirective, "PROLOGUE")
        XCTAssertTrue(sceneGroups[0].sceneDirectiveDescription?.contains("SERIES: 1001") ?? false)

        // Check second scene group
        XCTAssertEqual(sceneGroups[1].sceneDirective, "THE MURDER")
        XCTAssertTrue(sceneGroups[1].sceneDirectiveDescription?.contains("SERIES: 1002") ?? false)
    }

    // MARK: - Hierarchy and Parent-Child Relationships

    func testChapterSceneGroupHierarchy() throws {
        let content = """
        ## CHAPTER 1

        ### Scene Group A

        INT. ROOM - DAY

        Action.

        ### Scene Group B

        INT. ANOTHER ROOM - DAY

        More action.

        ## CHAPTER 2

        ### Scene Group C

        INT. THIRD ROOM - DAY

        Even more action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let chapters = outline.filter { $0.isChapter }
        XCTAssertEqual(chapters.count, 2)

        let chapter1 = chapters[0]
        let chapter2 = chapters[1]

        // Check that scene groups belong to correct chapters
        let groupsInChapter1 = outline.filter { $0.level == 3 && $0.parentId == chapter1.id }
        let groupsInChapter2 = outline.filter { $0.level == 3 && $0.parentId == chapter2.id }

        XCTAssertEqual(groupsInChapter1.count, 2, "Chapter 1 should have 2 scene groups")
        XCTAssertEqual(groupsInChapter2.count, 1, "Chapter 2 should have 1 scene group")
    }

    func testSceneHeadersUnderSceneGroups() throws {
        let content = """
        ## CHAPTER 1

        ### Scene Group

        INT. ROOM A - DAY

        Action one.

        INT. ROOM B - NIGHT

        Action two.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let sceneGroup = outline.first { $0.level == 3 && $0.type == "sectionHeader" }
        XCTAssertNotNil(sceneGroup)

        let scenes = outline.filter { $0.type == "sceneHeader" && $0.parentId == sceneGroup?.id }
        XCTAssertEqual(scenes.count, 2, "Should have 2 scenes under scene group")
        XCTAssertEqual(scenes[0].string, "INT. ROOM A - DAY")
        XCTAssertEqual(scenes[1].string, "INT. ROOM B - NIGHT")
    }

    // MARK: - Edge Cases

    func testEmptyScript() {
        let script = GuionParsedScreenplay()
        let outline = script.extractOutline()

        // Empty script creates a synthetic title + blank element
        let structural = outline.filter { $0.type != "blank" }
        XCTAssertEqual(structural.count, 1, "Empty script creates a synthetic title")
        XCTAssertTrue(structural.first?.isSynthetic ?? false, "Title should be synthetic")
    }

    func testScriptWithOnlyScenes() throws {
        let content = """
        INT. ROOM - DAY

        Action.

        EXT. STREET - NIGHT

        More action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        // Should create synthetic title
        let level1Elements = outline.filter { $0.level == 1 }
        XCTAssertEqual(level1Elements.count, 1, "Should create synthetic title")

        let scenes = outline.filter { $0.type == "sceneHeader" }
        XCTAssertEqual(scenes.count, 2, "Should detect 2 scene headers")
    }

    func testMixedHierarchyLevels() throws {
        let content = """
        # Main Title

        ## Chapter 1

        ### Scene Group

        INT. ROOM - DAY

        Action.

        ## Chapter 2

        INT. ANOTHER ROOM - DAY

        Direct scene without scene group.
        """

        let script = try GuionParsedScreenplay(string: content)
        let outline = script.extractOutline()

        let level1 = outline.filter { $0.level == 1 }
        let chapters = outline.filter { $0.isChapter }
        let sceneGroups = outline.filter { $0.level == 3 && $0.type == "sectionHeader" }
        let scenes = outline.filter { $0.type == "sceneHeader" }

        XCTAssertEqual(level1.count, 1, "Should have 1 level 1 title")
        XCTAssertEqual(chapters.count, 2, "Should have 2 chapters")
        XCTAssertEqual(sceneGroups.count, 1, "Should have 1 scene group")
        XCTAssertEqual(scenes.count, 2, "Should have 2 scenes")
    }

    // MARK: - Scene Browser Integration

    func testSceneBrowserWithMultipleChapters() throws {
        let content = """
        ## CHAPTER 1

        ### PROLOGUE S#{{SERIES: 1001}}

        INT. ROOM - DAY

        Action.

        ## CHAPTER 2

        ### Scene Group S#{{SERIES: 2001}}

        INT. ANOTHER ROOM - DAY

        More action.
        """

        let script = try GuionParsedScreenplay(string: content)
        let browserData = script.extractSceneBrowserData()

        XCTAssertEqual(browserData.chapters.count, 2, "Should extract 2 chapters")
        XCTAssertEqual(browserData.chapters[0].title, "CHAPTER 1")
        XCTAssertEqual(browserData.chapters[1].title, "CHAPTER 2")

        // Check scene groups
        XCTAssertEqual(browserData.chapters[0].sceneGroups.count, 1)
        XCTAssertEqual(browserData.chapters[0].sceneGroups[0].directive, "PROLOGUE")

        XCTAssertEqual(browserData.chapters[1].sceneGroups.count, 1)
        XCTAssertEqual(browserData.chapters[1].sceneGroups[0].directive, "Scene Group")
    }
}
