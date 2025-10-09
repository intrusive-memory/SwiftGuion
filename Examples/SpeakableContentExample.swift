#!/usr/bin/env swift

import Foundation
import SwiftGuion

// Example: Using the SpeakableContent protocol to generate narration from a screenplay

// Example 1: Simple element creation and speaking
func example1_basicUsage() {
    print("=== Example 1: Basic Usage ===\n")

    let sceneHeading = GuionElement(elementType: "Scene Heading", elementText: "INT. COFFEE SHOP - DAY")
    print("Scene: \(sceneHeading.speakableText())")

    let action = GuionElement(elementType: "Action", elementText: "Edward sits at a corner table, lost in thought.")
    print("Action: \(action.speakableText())")

    let character = GuionElement(elementType: "Character", elementText: "WILL")
    print("Character: \(character.speakableText())")

    let dialogue = GuionElement(elementType: "Dialogue", elementText: "Dad, we need to talk.")
    print("Dialogue: \(dialogue.speakableText())")

    print()
}

// Example 2: Generate a complete narration from a mini-script
func example2_generateNarration() {
    print("=== Example 2: Generate Narration ===\n")

    let script = FountainScript()
    script.elements = [
        GuionElement(elementType: "Scene Heading", elementText: "INT. HOSPITAL ROOM - NIGHT"),
        GuionElement(elementType: "Action", elementText: "The room is dimly lit. Edward lies in bed, his eyes closed."),
        GuionElement(elementType: "Character", elementText: "WILL"),
        GuionElement(elementType: "Parenthetical", elementText: "(softly)"),
        GuionElement(elementType: "Dialogue", elementText: "I'm here, Dad."),
        GuionElement(elementType: "Action", elementText: "Edward's eyes flutter open."),
        GuionElement(elementType: "Character", elementText: "EDWARD"),
        GuionElement(elementType: "Dialogue", elementText: "Tell me a story."),
        GuionElement(elementType: "Comment", elementText: "This is a touching moment"),
        GuionElement(elementType: "Transition", elementText: "FADE OUT.")
    ]

    // Generate narration by filtering out non-speakable elements
    let narration = script.elements
        .map { $0.speakableText() }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")

    print("Generated Narration:\n")
    print(narration)
    print()
}

// Example 3: Filter by element type for targeted narration
func example3_filteredNarration() {
    print("=== Example 3: Filtered Narration ===\n")

    let script = FountainScript()
    script.elements = [
        GuionElement(elementType: "Scene Heading", elementText: "EXT. RIVER - DAY"),
        GuionElement(elementType: "Action", elementText: "The sun sparkles on the water."),
        GuionElement(elementType: "Character", elementText: "YOUNG EDWARD"),
        GuionElement(elementType: "Dialogue", elementText: "I caught the biggest fish you've ever seen!"),
        GuionElement(elementType: "Action", elementText: "He spreads his arms wide."),
        GuionElement(elementType: "Character", elementText: "YOUNG WILL"),
        GuionElement(elementType: "Dialogue", elementText: "Sure you did, Dad.")
    ]

    // Only narrate dialogue
    print("Dialogue Only:\n")
    let dialogueOnly = script.elements
        .filter { $0.elementType == "Dialogue" }
        .map { $0.speakableText() }
        .joined(separator: "\n")
    print(dialogueOnly)
    print()

    // Only narrate actions and scene headings (scene description)
    print("Scene Description Only:\n")
    let sceneDescription = script.elements
        .filter { $0.elementType == "Scene Heading" || $0.elementType == "Action" }
        .map { $0.speakableText() }
        .joined(separator: "\n")
    print(sceneDescription)
    print()
}

// Example 4: Read a Fountain file and generate speakable content
func example4_fromFile() {
    print("=== Example 4: From Fountain File ===\n")

    // This example would work with an actual Fountain file
    // let script = try? FountainScript(file: "/path/to/your/script.fountain")
    //
    // if let script = script {
    //     // Generate narration for the first scene
    //     let firstSceneIndex = script.elements.firstIndex { $0.elementType == "Scene Heading" } ?? 0
    //     let secondSceneIndex = script.elements[firstSceneIndex...].dropFirst().firstIndex { $0.elementType == "Scene Heading" } ?? script.elements.count
    //
    //     let firstScene = script.elements[firstSceneIndex..<secondSceneIndex]
    //     let sceneNarration = firstScene
    //         .map { $0.speakableText() }
    //         .filter { !$0.isEmpty }
    //         .joined(separator: " ")
    //
    //     print("First Scene Narration:")
    //     print(sceneNarration)
    // }

    print("(To use this example, uncomment the code and provide a path to a Fountain file)")
    print()
}

// Example 5: Practical use case - Audio narration script
func example5_audioNarration() {
    print("=== Example 5: Audio Narration Script ===\n")

    let script = FountainScript()
    script.elements = [
        GuionElement(elementType: "Scene Heading", elementText: "INT. CHILDHOOD HOME - DAY"),
        GuionElement(elementType: "Action", elementText: "An old photograph sits on the mantle."),
        GuionElement(elementType: "Character", elementText: "NARRATOR"),
        GuionElement(elementType: "Dialogue", elementText: "Every story has a beginning."),
        GuionElement(elementType: "Action", elementText: "The camera slowly zooms in on young Edward's smiling face.")
    ]

    // Format for audio narration with markers
    print("Audio Script:\n")
    for element in script.elements {
        let speakable = element.speakableText()
        if !speakable.isEmpty {
            switch element.elementType {
            case "Scene Heading":
                print("🎬 SCENE: \(speakable)")
            case "Character":
                print("🎭 CHARACTER: \(speakable)")
            case "Dialogue":
                print("💬 SPEAK: \(speakable)")
            case "Action":
                print("📝 DESCRIBE: \(speakable)")
            default:
                print("📄 \(speakable)")
            }
        }
    }
    print()
}

// Run all examples
print("\n" + String(repeating: "=", count: 50))
print("SwiftGuion SpeakableContent Examples")
print(String(repeating: "=", count: 50) + "\n")

example1_basicUsage()
example2_generateNarration()
example3_filteredNarration()
example4_fromFile()
example5_audioNarration()

print(String(repeating: "=", count: 50))
print("Examples Complete")
print(String(repeating: "=", count: 50) + "\n")
