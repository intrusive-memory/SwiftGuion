import Testing
import Foundation
import SwiftFijos
@testable import SwiftGuion

@Test func testSpeakableContentProtocol() async throws {
    // Test Scene Heading
    let sceneHeading = GuionElement(elementType: "Scene Heading", elementText: "INT. COFFEE SHOP - DAY")
    #expect(sceneHeading.speakableText() == "INT. COFFEE SHOP - DAY", "Scene heading should return full slug line")

    // Test Character
    let character = GuionElement(elementType: "Character", elementText: "EDWARD")
    #expect(character.speakableText() == "EDWARD", "Character should return character name")

    // Test Dialogue
    let dialogue = GuionElement(elementType: "Dialogue", elementText: "I've been thinking about something you said.")
    #expect(dialogue.speakableText() == "I've been thinking about something you said.", "Dialogue should return the character's line")

    // Test Parenthetical
    let parenthetical = GuionElement(elementType: "Parenthetical", elementText: "(under his breath)")
    #expect(parenthetical.speakableText() == "(under his breath)", "Parenthetical should return the direction")

    // Test Action
    let action = GuionElement(elementType: "Action", elementText: "Edward walks slowly across the room, deep in thought.")
    #expect(action.speakableText() == "Edward walks slowly across the room, deep in thought.", "Action should return the description")

    // Test Transition
    let transition = GuionElement(elementType: "Transition", elementText: "CUT TO:")
    #expect(transition.speakableText() == "CUT TO:", "Transition should return the transition text")

    // Test Lyrics
    let lyrics = GuionElement(elementType: "Lyrics", elementText: "~Here comes the sun~")
    #expect(lyrics.speakableText() == "~Here comes the sun~", "Lyrics should return the lyrics text")

    // Test Comment (should return empty string)
    let comment = GuionElement(elementType: "Comment", elementText: "This is a note to self")
    #expect(comment.speakableText() == "", "Comments should not be speakable")

    // Test Boneyard (should return empty string)
    let boneyard = GuionElement(elementType: "Boneyard", elementText: "This scene was cut")
    #expect(boneyard.speakableText() == "", "Boneyard content should not be speakable")

    // Test Page Break (should return empty string)
    let pageBreak = GuionElement(elementType: "Page Break", elementText: "")
    #expect(pageBreak.speakableText() == "", "Page breaks should not be speakable")

    // Test Synopsis
    let synopsis = GuionElement(elementType: "Synopsis", elementText: "Edward meets his future wife")
    #expect(synopsis.speakableText() == "Edward meets his future wife", "Synopsis should return the synopsis text")

    // Test Section Heading
    let sectionHeading = GuionElement(elementType: "Section Heading", elementText: "ACT II")
    #expect(sectionHeading.speakableText() == "ACT II", "Section heading should return the heading text")
}

@Test func testSpeakableContentWithRealScript() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    // Find a scene heading and verify it's speakable
    let sceneHeadings = script.elements.filter { $0.elementType == "Scene Heading" }
    #expect(!sceneHeadings.isEmpty, "Should have scene headings")

    if let firstScene = sceneHeadings.first {
        let speakable = firstScene.speakableText()
        #expect(!speakable.isEmpty, "Scene heading should have speakable text")
        #expect(speakable == firstScene.elementText, "Speakable text should match element text for scene headings")
    }

    // Find dialogue and verify it's speakable
    let dialogues = script.elements.filter { $0.elementType == "Dialogue" }
    #expect(!dialogues.isEmpty, "Should have dialogue")

    if let firstDialogue = dialogues.first {
        let speakable = firstDialogue.speakableText()
        #expect(!speakable.isEmpty, "Dialogue should have speakable text")
        #expect(speakable == firstDialogue.elementText, "Speakable text should match element text for dialogue")
    }

    // Find action and verify it's speakable
    let actions = script.elements.filter { $0.elementType == "Action" }
    #expect(!actions.isEmpty, "Should have actions")

    if let firstAction = actions.first {
        let speakable = firstAction.speakableText()
        #expect(!speakable.isEmpty, "Action should have speakable text")
        #expect(speakable == firstAction.elementText, "Speakable text should match element text for actions")
    }
}

@Test func testSpeakableContentForAllElementTypes() async throws {
    let fountainURL = try Fijos.getFixture("bigfish", extension: "fountain")
    let script = try GuionParsedScreenplay(file: fountainURL.path)

    // Iterate through all elements and verify speakableText doesn't crash
    for element in script.elements {
        let speakable = element.speakableText()

        // Verify non-speakable types return empty strings
        if element.elementType == "Comment" || element.elementType == "Boneyard" || element.elementType == "Page Break" {
            #expect(speakable.isEmpty, "\(element.elementType) should return empty string")
        } else if !element.elementText.isEmpty {
            // For other types, if there's text, speakable should match
            #expect(speakable == element.elementText, "\(element.elementType) speakable text should match element text")
        }
    }
}

@Test func testSpeakableContentGenerateNarration() async throws {
    // Create a simple script to test narration generation
    let script = GuionParsedScreenplay(
        elements: [
            GuionElement(elementType: "Scene Heading", elementText: "INT. COFFEE SHOP - DAY"),
            GuionElement(elementType: "Action", elementText: "Edward sits at a table, reading a newspaper."),
            GuionElement(elementType: "Character", elementText: "WILL"),
            GuionElement(elementType: "Dialogue", elementText: "Dad, we need to talk."),
            GuionElement(elementType: "Character", elementText: "EDWARD"),
            GuionElement(elementType: "Parenthetical", elementText: "(without looking up)"),
            GuionElement(elementType: "Dialogue", elementText: "What about?"),
            GuionElement(elementType: "Transition", elementText: "CUT TO:")
        ]
    )

    // Generate narration by combining speakable content
    let narration = script.elements
        .map { $0.speakableText() }
        .filter { !$0.isEmpty }
        .joined(separator: " ")

    #expect(narration.contains("INT. COFFEE SHOP - DAY"), "Narration should include scene heading")
    #expect(narration.contains("Edward sits at a table"), "Narration should include action")
    #expect(narration.contains("WILL"), "Narration should include character name")
    #expect(narration.contains("Dad, we need to talk."), "Narration should include dialogue")
    #expect(narration.contains("EDWARD"), "Narration should include second character")
    #expect(narration.contains("without looking up"), "Narration should include parenthetical")
    #expect(narration.contains("What about?"), "Narration should include second dialogue")
    #expect(narration.contains("CUT TO:"), "Narration should include transition")
}
