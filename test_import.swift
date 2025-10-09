import SwiftGuion
import Foundation

// Test that the main classes are accessible
let script = FountainScript()
let element = GuionElement(type: "Action", text: "Test")

print("✓ FountainScript is accessible")
print("✓ GuionElement is accessible")

// Test ParserType enum
let parserType: ParserType = .fast
print("✓ ParserType is accessible")

// Test CharacterInfo
let charInfo = CharacterInfo()
print("✓ CharacterInfo is accessible")

// Test OutlineElement
let outlineElement = OutlineElement(index: 0, level: 1, range: [0, 10], rawString: "Test", string: "Test", type: "section")
print("✓ OutlineElement is accessible")

// Test FDX types
let fdxElement = FDXParsedElement(
    elementText: "Test",
    elementType: "Action",
    isCentered: false,
    isDualDialogue: false,
    sceneNumber: nil,
    sectionDepth: 0
)
print("✓ FDXParsedElement is accessible")

print("\nAll core types are publicly accessible! ✅")
