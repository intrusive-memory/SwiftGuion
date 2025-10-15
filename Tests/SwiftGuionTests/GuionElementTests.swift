//
//  GuionElementTests.swift
//  SwiftGuionTests
//
//  Tests for GuionElement struct and protocol
//

import Testing
import Foundation
@testable import SwiftGuion

@Suite("GuionElement Tests")
struct GuionElementTests {

    @Test("Initialize GuionElement with default values")
    func testDefaultInitialization() {
        let element = GuionElement()

        #expect(element.elementType == "")
        #expect(element.elementText == "")
        #expect(element.isCentered == false)
        #expect(element.isDualDialogue == false)
        #expect(element.sceneNumber == nil)
        #expect(element.sectionDepth == 0)
        #expect(element.sceneId == nil)
    }

    @Test("Initialize GuionElement with elementType and elementText")
    func testParameterizedInitialization() {
        let element = GuionElement(elementType: "Action", elementText: "The hero runs.")

        #expect(element.elementType == "Action")
        #expect(element.elementText == "The hero runs.")
        #expect(element.isCentered == false)
        #expect(element.isDualDialogue == false)
        #expect(element.sceneNumber == nil)
        #expect(element.sectionDepth == 0)
        #expect(element.sceneId == nil)
    }

    @Test("Initialize GuionElement with type and text convenience initializer")
    func testConvenienceInitialization() {
        let element = GuionElement(type: "Character", text: "JOHN")

        #expect(element.elementType == "Character")
        #expect(element.elementText == "JOHN")
    }

    @Test("Initialize GuionElement from protocol conforming type")
    func testProtocolInitialization() {
        var sourceElement = GuionElement(elementType: "Scene Heading", elementText: "INT. OFFICE - DAY")
        sourceElement.isCentered = true
        sourceElement.isDualDialogue = false
        sourceElement.sceneNumber = "1"
        sourceElement.sectionDepth = 2
        sourceElement.sceneId = "test-scene-id"

        let newElement = GuionElement(from: sourceElement)

        #expect(newElement.elementType == "Scene Heading")
        #expect(newElement.elementText == "INT. OFFICE - DAY")
        #expect(newElement.isCentered == true)
        #expect(newElement.isDualDialogue == false)
        #expect(newElement.sceneNumber == "1")
        #expect(newElement.sectionDepth == 2)
        #expect(newElement.sceneId == "test-scene-id")
    }

    @Test("Test description for basic element")
    func testBasicDescription() {
        let element = GuionElement(elementType: "Action", elementText: "The hero runs.")

        let description = element.description
        #expect(description.contains("Action"))
        #expect(description.contains("The hero runs."))
    }

    @Test("Test description for centered element")
    func testCenteredDescription() {
        var element = GuionElement(elementType: "Action", elementText: "THE END")
        element.isCentered = true

        let description = element.description
        #expect(description.contains("Action"))
        #expect(description.contains("centered"))
        #expect(description.contains("THE END"))
    }

    @Test("Test description for dual dialogue element")
    func testDualDialogueDescription() {
        var element = GuionElement(elementType: "Character", elementText: "JOHN")
        element.isDualDialogue = true

        let description = element.description
        #expect(description.contains("Character"))
        #expect(description.contains("dual dialogue"))
        #expect(description.contains("JOHN"))
    }

    @Test("Test description for section heading with depth")
    func testSectionDepthDescription() {
        var element = GuionElement(elementType: "Section Heading", elementText: "ACT II")
        element.sectionDepth = 3

        let description = element.description
        #expect(description.contains("Section Heading"))
        #expect(description.contains("3"))
        #expect(description.contains("ACT II"))
    }

    @Test("Test GuionElement is Sendable")
    func testGuionElementIsSendable() {
        let element = GuionElement(elementType: "Action", elementText: "Test")

        // If this compiles, it confirms Sendable conformance
        let _: any Sendable = element
    }

    @Test("Test modifying element properties")
    func testPropertyMutation() {
        var element = GuionElement()

        element.elementType = "Dialogue"
        element.elementText = "Hello, world!"
        element.isCentered = true
        element.isDualDialogue = true
        element.sceneNumber = "42"
        element.sectionDepth = 5
        element.sceneId = "unique-id"

        #expect(element.elementType == "Dialogue")
        #expect(element.elementText == "Hello, world!")
        #expect(element.isCentered == true)
        #expect(element.isDualDialogue == true)
        #expect(element.sceneNumber == "42")
        #expect(element.sectionDepth == 5)
        #expect(element.sceneId == "unique-id")
    }

    @Test("Test multiple elements with different types")
    func testMultipleElementTypes() {
        let sceneHeading = GuionElement(elementType: "Scene Heading", elementText: "EXT. PARK - DAY")
        let action = GuionElement(elementType: "Action", elementText: "Birds chirp.")
        let character = GuionElement(elementType: "Character", elementText: "SARAH")
        let dialogue = GuionElement(elementType: "Dialogue", elementText: "What a beautiful day!")
        let transition = GuionElement(elementType: "Transition", elementText: "CUT TO:")

        #expect(sceneHeading.elementType == "Scene Heading")
        #expect(action.elementType == "Action")
        #expect(character.elementType == "Character")
        #expect(dialogue.elementType == "Dialogue")
        #expect(transition.elementType == "Transition")
    }

    @Test("Test GuionElementProtocol description extension with custom type")
    func testProtocolDescriptionExtension() {
        // Create a custom type that conforms to GuionElementProtocol
        struct CustomElement: GuionElementProtocol {
            var elementType: String
            var elementText: String
            var isCentered: Bool
            var isDualDialogue: Bool
            var sceneNumber: String?
            var sectionDepth: Int
            var sceneId: String?
            var summary: String?
        }

        // Test basic description
        let basicElement = CustomElement(
            elementType: "Custom Action",
            elementText: "This is custom text",
            isCentered: false,
            isDualDialogue: false,
            sceneNumber: nil,
            sectionDepth: 0,
            sceneId: nil,
            summary: nil
        )
        #expect(basicElement.description.contains("Custom Action"))
        #expect(basicElement.description.contains("This is custom text"))

        // Test centered element
        let centeredElement = CustomElement(
            elementType: "Custom",
            elementText: "Centered text",
            isCentered: true,
            isDualDialogue: false,
            sceneNumber: nil,
            sectionDepth: 0,
            sceneId: nil,
            summary: nil
        )
        #expect(centeredElement.description.contains("centered"))

        // Test dual dialogue element
        let dualElement = CustomElement(
            elementType: "Custom Dialogue",
            elementText: "Dual text",
            isCentered: false,
            isDualDialogue: true,
            sceneNumber: nil,
            sectionDepth: 0,
            sceneId: nil,
            summary: nil
        )
        #expect(dualElement.description.contains("dual dialogue"))

        // Test section depth element
        let sectionElement = CustomElement(
            elementType: "Custom Section",
            elementText: "Section text",
            isCentered: false,
            isDualDialogue: false,
            sceneNumber: nil,
            sectionDepth: 3,
            sceneId: nil,
            summary: nil
        )
        #expect(sectionElement.description.contains("3"))
    }
}
