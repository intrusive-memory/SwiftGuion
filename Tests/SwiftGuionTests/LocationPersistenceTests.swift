import Testing
import Foundation
@testable import SwiftGuion

#if canImport(SwiftData)
import SwiftData

@Test func testLocationParsingOnInit() {
    let element = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )

    // Location should be automatically parsed
    #expect(element.locationLighting == "INT")
    #expect(element.locationScene == "COFFEE SHOP")
    #expect(element.locationTimeOfDay == "DAY")
    #expect(element.locationSetup == nil)
}

@Test func testLocationParsingWithSetup() {
    let element = GuionElementModel(
        elementText: "INT. BLOOM HOUSE MASTER BEDROOM - NIGHT",
        elementType: .sceneHeading
    )

    #expect(element.locationLighting == "INT")
    #expect(element.locationScene == "BLOOM HOUSE")
    #expect(element.locationSetup == "MASTER BEDROOM")
    #expect(element.locationTimeOfDay == "NIGHT")
}

@Test func testLocationParsingWithModifiers() {
    let element = GuionElementModel(
        elementText: "INT. WILL'S BEDROOM - NIGHT (1973)",
        elementType: .sceneHeading
    )

    #expect(element.locationLighting == "INT")
    #expect(element.locationScene == "WILL'S")
    #expect(element.locationSetup == "BEDROOM")
    #expect(element.locationTimeOfDay == "NIGHT")
    #expect(element.locationModifiers?.contains("1973") == true)
}

@Test func testLocationClearedForNonSceneHeading() {
    let element = GuionElementModel(
        elementText: "John walks in.",
        elementType: .action
    )

    // No location data should be stored
    #expect(element.locationLighting == nil)
    #expect(element.locationScene == nil)
    #expect(element.locationSetup == nil)
    #expect(element.locationTimeOfDay == nil)
}

@Test func testLocationReparsedOnTextChange() {
    let element = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )

    #expect(element.locationScene == "COFFEE SHOP")
    #expect(element.locationTimeOfDay == "DAY")

    // Change the text using the update method
    element.updateText("INT. COFFEE SHOP - NIGHT")

    // Location should be reparsed
    #expect(element.locationScene == "COFFEE SHOP")
    #expect(element.locationTimeOfDay == "NIGHT")
}

@Test func testLocationReparsedOnTypeChange() {
    let element = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .action
    )

    // Should have no location data initially
    #expect(element.locationScene == nil)

    // Change to scene heading using update method
    element.elementType = .sceneHeading

    // Location should now be parsed
    #expect(element.locationScene == "COFFEE SHOP")
    #expect(element.locationTimeOfDay == "DAY")
}

@Test func testLocationClearedWhenTypeChangesFromSceneHeading() {
    let element = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )

    #expect(element.locationScene == "COFFEE SHOP")

    // Change to non-scene heading using update method
    element.elementType = .action

    // Location should be cleared
    #expect(element.locationScene == nil)
    #expect(element.locationLighting == nil)
    #expect(element.locationTimeOfDay == nil)
}

@Test func testCachedSceneLocationProperty() {
    let element = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )

    let location = element.cachedSceneLocation
    #expect(location != nil)
    #expect(location?.lighting == .interior)
    #expect(location?.scene == "COFFEE SHOP")
    #expect(location?.timeOfDay == "DAY")
    #expect(location?.originalText == "INT. COFFEE SHOP - DAY")
}

@Test func testCachedSceneLocationReturnsNilForNonSceneHeading() {
    let element = GuionElementModel(
        elementText: "John walks in.",
        elementType: .action
    )

    #expect(element.cachedSceneLocation == nil)
}

@Test func testManualReparseLocation() {
    let element = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )

    // Manually clear location data (simulating old data)
    element.locationScene = nil
    element.locationLighting = nil

    #expect(element.locationScene == nil)

    // Force reparse
    element.reparseLocation()

    #expect(element.locationScene == "COFFEE SHOP")
    #expect(element.locationLighting == "INT")
}

@Test func testGuionDocumentModelReparseAllLocations() {
    let document = GuionDocumentModel(filename: "test.fountain")

    // Add some elements
    let scene1 = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )
    let action = GuionElementModel(
        elementText: "Alice enters.",
        elementType: .action
    )
    let scene2 = GuionElementModel(
        elementText: "EXT. PARK - NIGHT",
        elementType: .sceneHeading
    )

    document.elements = [scene1, action, scene2]

    // Manually clear location data (simulating migration)
    scene1.locationScene = nil
    scene2.locationScene = nil

    #expect(scene1.locationScene == nil)
    #expect(scene2.locationScene == nil)

    // Reparse all
    document.reparseAllLocations()

    #expect(scene1.locationScene == "COFFEE SHOP")
    #expect(scene2.locationScene == "PARK")
    #expect(action.locationScene == nil) // Action should still have no location
}

@Test func testGuionDocumentModelSceneLocations() {
    let document = GuionDocumentModel(filename: "test.fountain")

    let scene1 = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )
    let action = GuionElementModel(
        elementText: "Alice enters.",
        elementType: .action
    )
    let scene2 = GuionElementModel(
        elementText: "EXT. PARK - NIGHT",
        elementType: .sceneHeading
    )

    document.elements = [scene1, action, scene2]

    let sceneLocations = document.sceneLocations

    // Should only have 2 scenes (action excluded)
    #expect(sceneLocations.count == 2)

    // Verify locations
    #expect(sceneLocations[0].location.scene == "COFFEE SHOP")
    #expect(sceneLocations[1].location.scene == "PARK")
}

@Test func testLocationDataPersistsThroughChanges() {
    let element = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )

    let originalLocation = element.cachedSceneLocation
    #expect(originalLocation?.scene == "COFFEE SHOP")

    // Change time of day using update method
    element.updateText("INT. COFFEE SHOP - NIGHT")

    let updatedLocation = element.cachedSceneLocation
    #expect(updatedLocation?.scene == "COFFEE SHOP")
    #expect(updatedLocation?.timeOfDay == "NIGHT")

    // Verify it's a different instance but same scene
    #expect(originalLocation?.scene == updatedLocation?.scene)
    #expect(originalLocation?.timeOfDay != updatedLocation?.timeOfDay)
}

@Test func testComplexLocationPersistence() {
    let element = GuionElementModel(
        elementText: "INT. TINY PARIS RESTAURANT (LA RUE 14°) - NIGHT (1998)",
        elementType: .sceneHeading
    )

    #expect(element.locationLighting == "INT")
    #expect(element.locationScene?.contains("RESTAURANT") == true)
    #expect(element.locationTimeOfDay == "NIGHT")
    #expect(element.locationModifiers?.contains("1998") == true)

    let location = element.cachedSceneLocation
    #expect(location != nil)
    #expect(location?.modifiers.contains("1998") == true)
}

@Test func testInitFromGuionElement() {
    let plainElement = GuionElement(
        elementType: .sceneHeading,
        elementText: "INT. HOSPITAL ROOM - DAY"
    )

    let model = GuionElementModel(from: plainElement)

    // Location should be automatically parsed during init
    #expect(model.locationLighting == "INT")
    #expect(model.locationScene == "HOSPITAL")
    #expect(model.locationSetup == "ROOM")
    #expect(model.locationTimeOfDay == "DAY")

    // Verify cached location works
    let location = model.cachedSceneLocation
    #expect(location?.scene == "HOSPITAL")
    #expect(location?.setup == "ROOM")
}

@Test func testMultipleLocationChanges() {
    let element = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )

    #expect(element.locationScene == "COFFEE SHOP")
    #expect(element.locationTimeOfDay == "DAY")

    // First change using update method
    element.updateText("INT. COFFEE SHOP - NIGHT")
    #expect(element.locationTimeOfDay == "NIGHT")

    // Second change using update method
    element.updateText("EXT. COFFEE SHOP - NIGHT")
    #expect(element.locationLighting == "EXT")

    // Third change - completely different location
    element.updateText("INT. HOSPITAL ROOM - DAY")
    #expect(element.locationScene == "HOSPITAL")
    #expect(element.locationSetup == "ROOM")
    #expect(element.locationLighting == "INT")
    #expect(element.locationTimeOfDay == "DAY")
}

@Test func testLocationKeyConsistency() {
    let element1 = GuionElementModel(
        elementText: "INT. COFFEE SHOP - DAY",
        elementType: .sceneHeading
    )

    let element2 = GuionElementModel(
        elementText: "INT. COFFEE SHOP - NIGHT",
        elementType: .sceneHeading
    )

    // Both should have same location key (different time)
    let loc1 = element1.cachedSceneLocation
    let loc2 = element2.cachedSceneLocation

    #expect(loc1?.locationKey == loc2?.locationKey)
    #expect(loc1?.scene == loc2?.scene)
    #expect(loc1?.timeOfDay != loc2?.timeOfDay)
}

#endif
