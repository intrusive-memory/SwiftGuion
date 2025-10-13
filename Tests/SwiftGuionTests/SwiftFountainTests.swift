import Testing
import Foundation
import SwiftFijos
@testable import SwiftGuion

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test func testFDXParserExtractsGuionElements() async throws {
    let fdxURL = try Fijos.getFixture("bigfish", extension: "fdx")

    let data = try Data(contentsOf: fdxURL)
    let parser = FDXDocumentParser()
    let parsedDocument = try parser.parse(data: data, filename: fdxURL.lastPathComponent)

    #expect(!parsedDocument.elements.isEmpty, "FDX parser should produce screenplay elements")

    // The FDX file starts with an Action element
    #expect(parsedDocument.elements.first?.elementType == "Action", "First element should be Action")

    // Find scene headings in the parsed document
    let hasSceneHeading = parsedDocument.elements.contains { element in
        element.elementType == "Scene Heading" && element.elementText.uppercased().contains("EXT")
    }
    #expect(hasSceneHeading, "Parser should capture scene headings from FDX")

    // Verify we have various element types
    let elementTypes = Set(parsedDocument.elements.map { $0.elementType })
    #expect(elementTypes.contains("Scene Heading"), "Should have Scene Heading elements")
    #expect(elementTypes.contains("Action") || elementTypes.contains("Dialogue"), "Should have Action or Dialogue elements")

    let titleContainsBigFish = parsedDocument.titlePageEntries.first?.values.contains { $0.contains("Big Fish") } ?? false
    #expect(titleContainsBigFish, "Title page should capture screenplay title")

    #expect(parsedDocument.rawXML.contains("<FinalDraft"), "Raw XML should include Final Draft root element")
}

@Test func testOverBlackSceneHeading() async throws {
    // Test that scene headings are properly recognized
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    // Check that we have scene headings
    let sceneHeadings = script.elements.filter { $0.elementType == "Scene Heading" }
    #expect(!sceneHeadings.isEmpty, "Should have scene headings")
}

@Test func testGetContent() async throws {
    let script = GuionParsedScreenplay()
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")

    let content = try script.getContent(from: fountainURL)
    #expect(!content.isEmpty, "Content should not be empty")
    #expect(content.contains("FADE IN:") || content.contains("INT.") || content.contains("EXT."),
            "Content should contain screenplay elements")
}

@Test func testWriteToTextBundle() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    let tempDir = FileManager.default.temporaryDirectory
    let testFileName = "test-\(UUID().uuidString).fountain"
    let expectedBundleName = testFileName.replacingOccurrences(of: ".fountain", with: ".textbundle")
    let expectedBundleURL = tempDir.appendingPathComponent(expectedBundleName)

    // Clean up if it exists from a previous test
    try? FileManager.default.removeItem(at: expectedBundleURL)

    let outputURL = try script.writeToTextBundle(destinationURL: tempDir, fountainFilename: testFileName)

    #expect(FileManager.default.fileExists(atPath: outputURL.path))

    // Verify the .fountain file exists inside the bundle
    let fountainFileURL = outputURL.appendingPathComponent(testFileName)
    #expect(FileManager.default.fileExists(atPath: fountainFileURL.path))

    // Clean up
    try? FileManager.default.removeItem(at: outputURL)
}

@Test func testExtractCharacters() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    let characters = script.extractCharacters()

    // Verify some known characters from Big Fish exist
    #expect(characters["EDWARD"] != nil)
    #expect(characters["WILL"] != nil)

    // Verify structure is correct for all characters
    for (name, info) in characters {
        #expect(!name.isEmpty, "Character name should not be empty")
        #expect(info.counts.lineCount > 0, "\(name) should have at least one line")
        #expect(info.counts.wordCount > 0, "\(name) should have words")
        #expect(info.gender.unspecified != nil, "\(name) should have gender field")
    }
}

@Test func testWriteCharactersJSON() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    let tempDir = FileManager.default.temporaryDirectory
    let outputPath = tempDir.appendingPathComponent("bigfish-characters.json")

    try script.writeCharactersJSON(to: outputPath)

    #expect(FileManager.default.fileExists(atPath: outputPath.path))

    // Verify the JSON can be read back
    let data = try Data(contentsOf: outputPath)
    let decoder = JSONDecoder()
    let characters = try decoder.decode(CharacterList.self, from: data)

    #expect(!characters.isEmpty, "Should have extracted characters")

    // Verify the structure is correct by checking the decoded characters
    #expect(characters.values.allSatisfy { $0.gender.unspecified != nil }, "All characters should have gender.unspecified")
    // Note: Some characters may not have scenes if they appear before the first scene heading
    #expect(characters.values.contains { !$0.scenes.isEmpty }, "At least some characters should have scenes")

    // Clean up temp file
    try? FileManager.default.removeItem(at: outputPath)
}

@Test func testExtractOutline() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    let outline = script.extractOutline()

    // Verify we have outline elements
    #expect(!outline.isEmpty, "Outline should not be empty")

    // Verify we have different types
    let types = Set(outline.map { $0.type })
    #expect(types.contains("sectionHeader"), "Should have section headers")
    #expect(types.contains("sceneHeader"), "Should have scene headers")

    // Verify structure
    let sectionHeaders = outline.filter { $0.type == "sectionHeader" }
    #expect(!sectionHeaders.isEmpty, "Should have section headers")

    // Verify first element has expected properties
    if let firstElement = outline.first {
        #expect(firstElement.type == "sectionHeader", "First element should be section header")
        #expect(firstElement.level >= 1, "First element should be level 1 or higher")
    }

    // Verify indexes are sequential
    for (i, element) in outline.enumerated() {
        #expect(element.index == i, "Index should match position in array")
    }

    // TEST API COMPATIBILITY: Verify all outline elements have elementType "outline"
    for element in outline {
        #expect(element.elementType == "outline", "All outline elements should have elementType 'outline' for API compatibility")
    }
}

@Test func testWriteOutlineJSON() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    let tempDir = FileManager.default.temporaryDirectory
    let outputPath = tempDir.appendingPathComponent("bigfish-outline.json")

    try script.writeOutlineJSON(to: outputPath)

    #expect(FileManager.default.fileExists(atPath: outputPath.path))

    // Verify the JSON can be read back
    let data = try Data(contentsOf: outputPath)
    let decoder = JSONDecoder()
    let outline = try decoder.decode(OutlineList.self, from: data)

    #expect(!outline.isEmpty, "Should have extracted outline elements")

    // Verify structure
    for element in outline {
        #expect(!element.id.isEmpty, "Each element should have an ID")
        #expect(element.range.count == 2, "Range should have 2 elements")
        #expect(!element.type.isEmpty, "Each element should have a type")
    }

    // Clean up temp file
    try? FileManager.default.removeItem(at: outputPath)
}

@Test func testWriteToTextBundleWithResources() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    let tempDir = FileManager.default.temporaryDirectory
    let outputURL = try script.writeToTextBundleWithResources(
        destinationURL: tempDir,
        name: "bigfish-output",
        includeResources: true
    )

    // Verify the TextBundle was created
    #expect(FileManager.default.fileExists(atPath: outputURL.path))

    // Verify the .fountain file exists
    let fountainFileURL = outputURL.appendingPathComponent("bigfish-output.fountain")
    #expect(FileManager.default.fileExists(atPath: fountainFileURL.path))

    // Verify resources directory exists
    let resourcesDir = outputURL.appendingPathComponent("resources")
    #expect(FileManager.default.fileExists(atPath: resourcesDir.path))

    // Verify characters.json exists and is valid
    let charactersURL = resourcesDir.appendingPathComponent("characters.json")
    #expect(FileManager.default.fileExists(atPath: charactersURL.path))

    let charactersData = try Data(contentsOf: charactersURL)
    let characters = try JSONDecoder().decode(CharacterList.self, from: charactersData)
    #expect(!characters.isEmpty, "Characters JSON should have content")

    // Verify outline.json exists and is valid
    let outlineURL = resourcesDir.appendingPathComponent("outline.json")
    #expect(FileManager.default.fileExists(atPath: outlineURL.path))

    let outlineData = try Data(contentsOf: outlineURL)
    let outline = try JSONDecoder().decode(OutlineList.self, from: outlineData)
    #expect(!outline.isEmpty, "Outline JSON should have content")

    // Clean up
    try? FileManager.default.removeItem(at: outputURL)
}

@Test func testLoadFromHighland() async throws {
    let highlandURL = try Fijos.getFixture("bigfish", extension: "highland")

    let script = try GuionParsedScreenplay(highland: highlandURL)

    #expect(!script.elements.isEmpty, "Highland file should contain elements")
    // Highland files may use text.md instead of .fountain extension
    #expect(script.filename != nil, "Should extract filename")
}

@Test func testWriteToHighland() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    let tempDir = FileManager.default.temporaryDirectory
    let highlandURL = try script.writeToHighland(
        destinationURL: tempDir,
        name: "bigfish-output",
        includeResources: true
    )

    // Verify the Highland file was created
    #expect(FileManager.default.fileExists(atPath: highlandURL.path))
    #expect(highlandURL.pathExtension == "highland")

    // Verify we can load it back
    let loadedScript = try GuionParsedScreenplay(highland: highlandURL)
    #expect(!loadedScript.elements.isEmpty, "Loaded script should have elements")

    // Clean up
    try? FileManager.default.removeItem(at: highlandURL)
}

@Test func testHighlandRoundTrip() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let originalScript = try GuionParsedScreenplay(file: fountainURL.path)

    let tempDir = FileManager.default.temporaryDirectory

    // Write to Highland with resources
    let highlandURL = try originalScript.writeToHighland(
        destinationURL: tempDir,
        name: "roundtrip-bigfish",
        includeResources: true
    )

    // Load it back
    let loadedScript = try GuionParsedScreenplay(highland: highlandURL)

    // Verify the content is reasonable (element count may differ slightly due to formatting)
    #expect(loadedScript.elements.count > 0, "Loaded script should have elements")
    #expect(loadedScript.titlePage.count == originalScript.titlePage.count, "Title page should match")

    // Verify resources can be extracted
    let characters = loadedScript.extractCharacters()
    #expect(!characters.isEmpty, "Should be able to extract characters from loaded script")

    let outline = loadedScript.extractOutline()
    #expect(!outline.isEmpty, "Should be able to extract outline from loaded script")

    // Clean up
    try? FileManager.default.removeItem(at: highlandURL)
}

// MARK: - Functional Tests

@Test func testUnifiedGetContentUrl() async throws {
    let script = GuionParsedScreenplay()

    // Test 1: .fountain file - should return the URL as-is
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let fountainContentUrl = try script.getContentUrl(from: fountainURL)
    #expect(fountainContentUrl.path == fountainURL.path, ".fountain file should return same URL")

    // Test 2: .highland file - should return URL to content file
    // Note: Some .highland files are plain text Fountain files, not ZIP archives
    let highlandURL = try Fijos.getFixture("bigfish", extension: "highland")
    let highlandContentUrl = try script.getContentUrl(from: highlandURL)
    #expect(highlandContentUrl.pathExtension.lowercased() == "fountain" ||
            highlandContentUrl.pathExtension.lowercased() == "md" ||
            highlandContentUrl.pathExtension.lowercased() == "highland",
            "Highland should return .fountain, .md, or .highland file URL")
}

@Test func testUnifiedGetContent() async throws {
    let script = GuionParsedScreenplay()

    // Test 1: .fountain file - should return complete content
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let fountainContent = try script.getContent(from: fountainURL)
    #expect(!fountainContent.isEmpty, "Fountain content should not be empty")
    #expect(fountainContent.contains("INT.") || fountainContent.contains("EXT."), "Should contain scene headings")

    // Test 2: .highland file - should return complete content
    let highlandURL = try Fijos.getFixture("bigfish", extension: "highland")
    let highlandContent = try script.getContent(from: highlandURL)
    #expect(!highlandContent.isEmpty, "Highland content should not be empty")
}

@Test func testGetGuionElements() async throws {
    // Test 1: Script loaded from file should have elements
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    let elements = script.getGuionElements()
    #expect(!elements.isEmpty, "Should have screenplay elements")
    #expect(elements.contains { $0.elementType == "Scene Heading" }, "Should have scene headings")

    // Test 2: Empty script should return empty array
    let emptyScript = GuionParsedScreenplay()
    let emptyElements = emptyScript.getGuionElements()
    #expect(emptyElements.isEmpty, "Empty script should return empty array")
}

@Test func testFirstDialogue() async throws {
    // Test with Big Fish fixture files
    let testFiles: [(String, String)] = [
        ("bigfish", "fountain"),
        ("bigfish", "highland")
    ]

    for (_, ext) in testFiles {
        let fileURL: URL
        switch ext {
        case "fountain":
            fileURL = try Fijos.getFixture("bigfish", extension: "fountain")
        case "highland":
            fileURL = try Fijos.getFixture("bigfish", extension: "highland")
        default:
            continue
        }

        let script: GuionParsedScreenplay
        switch ext {
        case "fountain":
            script = try GuionParsedScreenplay(file: fileURL.path)
        case "highland":
            script = try GuionParsedScreenplay(highland: fileURL)
        default:
            continue
        }

        // Test EDWARD's first line (from the bigfish.fountain fixture)
        let edwardFirstLine = script.firstDialogue(for: "EDWARD")
        #expect(edwardFirstLine != nil, "\(ext): EDWARD should have dialogue")

        // Test WILL's first line
        let willFirstLine = script.firstDialogue(for: "WILL")
        #expect(willFirstLine != nil, "\(ext): WILL should have dialogue")

        // Test case insensitivity
        let edwardLowerCase = script.firstDialogue(for: "edward")
        #expect(edwardLowerCase == edwardFirstLine,
                "\(ext): Should be case insensitive")

        // Test non-existent character
        let nonExistentCharacter = script.firstDialogue(for: "NONEXISTENT")
        #expect(nonExistentCharacter == nil,
                "\(ext): Should return nil for non-existent character")
    }
}

@Suite("Outline Hierarchy Functional Tests")
struct OutlineHierarchyFunctionalTests {

    @Test("Functional test: Outline hierarchy across all fixture files")
    func testOutlineHierarchyAcrossFixtureFiles() async throws {
        let testFiles: [(name: String, ext: String)] = [
            ("bigfish", "fountain"),
            ("bigfish", "highland")
        ]
        
        for (name, ext) in testFiles {
            let fileURL: URL
            switch ext {
            case "fountain":
                fileURL = try Fijos.getFixture("bigfish", extension: "fountain")
            case "highland":
                fileURL = try Fijos.getFixture("bigfish", extension: "highland")
            default:
                continue
            }

            // Load script using appropriate method
            let script: GuionParsedScreenplay
            switch ext {
            case "fountain":
                script = try GuionParsedScreenplay(file: fileURL.path)
            case "highland":
                script = try GuionParsedScreenplay(highland: fileURL)
            default:
                continue
            }

            // Extract outline and tree for hierarchical analysis
            let outline = script.extractOutline()
            let tree = script.extractOutlineTree()
            
            print("Testing \(name).\(ext) - Outline has \(outline.count) elements")
            
            // VERIFY OVERALL STRUCTURE
            #expect(!outline.isEmpty, "\(ext): Should have outline elements")
            #expect(tree.root != nil, "\(ext): Tree should have a root")
            
            // VERIFY LEVEL 1 (MAIN TITLE)
            let level1Elements = outline.filter { $0.level == 1 }
            #expect(level1Elements.count >= 1, "\(ext): Should have at least 1 level 1 element")

            if let mainTitle = level1Elements.first {
                #expect(mainTitle.parentId == nil, "\(ext): Main title should have no parent")
            }

            // VERIFY SECTIONS
            let sectionHeaders = outline.filter { $0.type == "sectionHeader" }
            let endMarkers = outline.filter { $0.isEndMarker }

            #expect(!sectionHeaders.isEmpty, "\(ext): Should have section headers")
            
            // Verify sections have proper parent relationships
            if let mainTitle = level1Elements.first {
                for section in sectionHeaders where section.level >= 2 {
                    if section.parentId != nil {
                        #expect(section.parentId == mainTitle.id || outline.contains { $0.id == section.parentId },
                                "\(ext): Section should have valid parent")
                    }
                }
            }
            
            // Verify END markers if they exist
            for endMarker in endMarkers {
                #expect(endMarker.isEndMarker, "\(ext): END marker should be identified as end marker")
                #expect(endMarker.childIds.isEmpty, "\(ext): END markers should not have children")
            }

            // VERIFY SCENE HEADERS
            let sceneHeaders = outline.filter { $0.type == "sceneHeader" }

            #expect(sceneHeaders.count >= 10, "\(ext): Should have at least 10 scene headers")

            // Verify some expected scene headers from bigfish
            let foundScenes = sceneHeaders.map { $0.string }

            var hasIntScene = false
            var hasExtScene = false
            for scene in foundScenes {
                if scene.contains("INT.") { hasIntScene = true }
                if scene.contains("EXT.") { hasExtScene = true }
            }
            #expect(hasIntScene, "\(ext): Should contain INT. scenes")
            #expect(hasExtScene, "\(ext): Should contain EXT. scenes")
            
            // VERIFY TREE STRUCTURE
            if let rootNode = tree.root {
                if let mainTitle = level1Elements.first {
                    #expect(rootNode.element.id == mainTitle.id, "\(ext): Tree root should be main title")
                }
                #expect(rootNode.parent == nil, "\(ext): Root should have no parent")
                #expect(rootNode.depth == 0, "\(ext): Root depth should be 0")
                #expect(rootNode.hasChildren, "\(ext): Root should have children")

                // Verify tree structure matches outline relationships
                let treeNodeCount = tree.allNodes.count
                let nonEndMarkerElements = outline.filter { !$0.isEndMarker && $0.level != -1 } // Exclude END markers and blank
                #expect(treeNodeCount == nonEndMarkerElements.count,
                        "\(ext): Tree should contain all non-end-marker elements (expected: \(nonEndMarkerElements.count), got: \(treeNodeCount))")
            }
            
            // VERIFY PARENT/CHILD METHODS WORK CORRECTLY
            for element in outline {
                // Test parent() method
                if let parentId = element.parentId {
                    let parent = element.parent(from: outline)
                    #expect(parent?.id == parentId, "\(ext): parent() method should return correct parent")
                } else {
                    let parent = element.parent(from: outline)
                    #expect(parent == nil, "\(ext): parent() should return nil for elements without parent")
                }
                
                // Test children() method
                let children = element.children(from: outline)
                #expect(children.count == element.childIds.count, "\(ext): children() count should match childIds count")
                
                for child in children {
                    #expect(element.childIds.contains(child.id), "\(ext): children() should return elements in childIds")
                    #expect(child.parentId == element.id, "\(ext): Child's parentId should match element id")
                }
                
                // Test descendants() method
                let descendants = element.descendants(from: outline)
                let directChildren = element.children(from: outline)
                #expect(descendants.count >= directChildren.count, "\(ext): descendants should include at least direct children")
            }
            
            // VERIFY API COMPATIBILITY
            for element in outline {
                #expect(element.elementType == "outline", "\(ext): All elements should have elementType 'outline'")
            }
            
            print("✅ \(name).\(ext) hierarchy validation complete")
        }
    }
}
