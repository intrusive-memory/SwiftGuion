# SpeakableContent Protocol Example

This document demonstrates how to use the `SpeakableContent` protocol in SwiftGuion to extract speakable text from screenplay elements.

## Overview

The `SpeakableContent` protocol provides a single method `speakableText()` that returns the appropriate text content for each element type:

- **Scene Heading**: Returns the entire slug line (e.g., "INT. COFFEE SHOP - DAY")
- **Dialogue**: Returns the text of the character's line
- **Action**: Returns the action description
- **Character**: Returns the character name
- **Parenthetical**: Returns the direction
- **Transition**: Returns the transition text
- **Lyrics**: Returns the lyrics text
- **Synopsis**: Returns the synopsis
- **Section Heading**: Returns the heading text
- **Comment/Boneyard/Page Break**: Returns empty string (not speakable)

## Basic Usage

```swift
import SwiftGuion

// Create screenplay elements
let sceneHeading = GuionElement(
    elementType: "Scene Heading",
    elementText: "INT. COFFEE SHOP - DAY"
)
print(sceneHeading.speakableText())
// Output: "INT. COFFEE SHOP - DAY"

let dialogue = GuionElement(
    elementType: "Dialogue",
    elementText: "I've been thinking about what you said."
)
print(dialogue.speakableText())
// Output: "I've been thinking about what you said."

let action = GuionElement(
    elementType: "Action",
    elementText: "Edward walks across the room."
)
print(action.speakableText())
// Output: "Edward walks across the room."
```

## Generate Narration from a Script

```swift
let script = FountainScript()
script.elements = [
    GuionElement(elementType: "Scene Heading", elementText: "INT. HOSPITAL ROOM - NIGHT"),
    GuionElement(elementType: "Action", elementText: "The room is dimly lit."),
    GuionElement(elementType: "Character", elementText: "WILL"),
    GuionElement(elementType: "Dialogue", elementText: "I'm here, Dad."),
    GuionElement(elementType: "Comment", elementText: "This won't be included")
]

// Generate complete narration (excluding comments)
let narration = script.elements
    .map { $0.speakableText() }
    .filter { !$0.isEmpty }
    .joined(separator: "\n")

print(narration)
/* Output:
INT. HOSPITAL ROOM - NIGHT
The room is dimly lit.
WILL
I'm here, Dad.
*/
```

## Filter by Element Type

```swift
// Extract only dialogue
let dialogueOnly = script.elements
    .filter { $0.elementType == "Dialogue" }
    .map { $0.speakableText() }
    .joined(separator: "\n")

// Extract only scene descriptions (headings + actions)
let sceneDescription = script.elements
    .filter { ["Scene Heading", "Action"].contains($0.elementType) }
    .map { $0.speakableText() }
    .joined(separator: "\n")
```

## Reading from a Fountain File

```swift
// Load a Fountain file
let script = try FountainScript(file: "/path/to/script.fountain")

// Generate narration for the entire script
let fullNarration = script.elements
    .map { $0.speakableText() }
    .filter { !$0.isEmpty }
    .joined(separator: " ")

// Or process scene by scene
let sceneHeadings = script.elements.enumerated().filter {
    $0.element.elementType == "Scene Heading"
}

for (index, sceneStart) in sceneHeadings {
    let nextSceneIndex = sceneHeadings.first(where: { $0.offset > index })?.offset
        ?? script.elements.count

    let scene = script.elements[index..<nextSceneIndex]
    let sceneNarration = scene
        .map { $0.speakableText() }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")

    print("Scene: \(scene.first?.elementText ?? "")")
    print(sceneNarration)
    print("---")
}
```

## Use Cases

1. **Audio Narration**: Generate text-to-speech scripts from screenplays
2. **Accessibility**: Create audio descriptions for visually impaired readers
3. **Table Reads**: Extract dialogue-only versions for actors
4. **Story Summaries**: Generate condensed versions using actions and scene headings
5. **Script Analysis**: Extract specific element types for analysis

## Implementation Details

The `SpeakableContent` protocol is implemented as an extension on `GuionElementProtocol`, which means all `GuionElement` instances automatically conform to the protocol. The implementation uses a switch statement on `elementType` to determine what text should be returned.

Non-speakable elements (Comments, Boneyard, Page Breaks) return empty strings to make filtering easy.

## Running the Full Example

See `SpeakableContentExample.swift` for a complete working example. To run it:

```bash
# Build the package first
swift build

# Run tests to verify functionality
swift test --filter SpeakableContentTests
```

The test file `Tests/SwiftGuionTests/SpeakableContentTests.swift` contains comprehensive tests demonstrating all use cases.
