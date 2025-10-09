//
//  GuionDocumentModel.swift
//  FountainDocumentApp
//
//  Copyright (c) 2025
//

import Foundation
#if canImport(SwiftData)
import SwiftData

@Model
public final class GuionDocumentModel {
    public var filename: String?
    public var rawContent: String?
    public var suppressSceneNumbers: Bool

    @Relationship(deleteRule: .cascade, inverse: \GuionElementModel.document)
    public var elements: [GuionElementModel]

    @Relationship(deleteRule: .cascade, inverse: \TitlePageEntryModel.document)
    public var titlePage: [TitlePageEntryModel]

    public init(filename: String? = nil, rawContent: String? = nil, suppressSceneNumbers: Bool = false) {
        self.filename = filename
        self.rawContent = rawContent
        self.suppressSceneNumbers = suppressSceneNumbers
        self.elements = []
        self.titlePage = []
    }

    /// Reparse all scene heading locations (useful for migration or updates)
    public func reparseAllLocations() {
        for element in elements where element.elementType == "Scene Heading" {
            element.reparseLocation()
        }
    }

    /// Get all scene elements with their cached locations
    public var sceneLocations: [(element: GuionElementModel, location: SceneLocation)] {
        return elements.compactMap { element in
            guard let location = element.cachedSceneLocation else { return nil }
            return (element, location)
        }
    }
}

@Model
public final class GuionElementModel: GuionElementProtocol {
    public var elementText: String
    public var elementType: String
    public var isCentered: Bool
    public var isDualDialogue: Bool
    public var sceneNumber: String?
    public var sectionDepth: Int
    public var sceneId: String?

    // SwiftData-specific properties
    public var summary: String?
    public var document: GuionDocumentModel?

    // Cached parsed location data
    public var locationLighting: String?      // Raw value of SceneLighting enum
    public var locationScene: String?         // Primary location name
    public var locationSetup: String?         // Optional sub-location
    public var locationTimeOfDay: String?     // Time of day
    public var locationModifiers: [String]?   // Additional modifiers

    public init(elementText: String, elementType: String, isCentered: Bool = false, isDualDialogue: Bool = false, sceneNumber: String? = nil, sectionDepth: Int = 0, summary: String? = nil, sceneId: String? = nil) {
        self.elementText = elementText
        self.elementType = elementType
        self.isCentered = isCentered
        self.isDualDialogue = isDualDialogue
        self.sceneNumber = sceneNumber
        self.sectionDepth = sectionDepth
        self.summary = summary
        self.sceneId = sceneId

        // Parse location if this is a scene heading
        if elementType == "Scene Heading" {
            self.parseAndStoreLocation()
        }
    }

    /// Initialize from any GuionElementProtocol conforming type
    public convenience init<T: GuionElementProtocol>(from element: T, summary: String? = nil) {
        self.init(
            elementText: element.elementText,
            elementType: element.elementType,
            isCentered: element.isCentered,
            isDualDialogue: element.isDualDialogue,
            sceneNumber: element.sceneNumber,
            sectionDepth: element.sectionDepth,
            summary: summary,
            sceneId: element.sceneId
        )
    }

    /// Parse and store location data from elementText
    private func parseAndStoreLocation() {
        guard elementType == "Scene Heading" else {
            // Clear location data if not a scene heading
            locationLighting = nil
            locationScene = nil
            locationSetup = nil
            locationTimeOfDay = nil
            locationModifiers = nil
            return
        }

        let location = SceneLocation.parse(elementText)

        // Store parsed components
        locationLighting = location.lighting.rawValue
        locationScene = location.scene
        locationSetup = location.setup
        locationTimeOfDay = location.timeOfDay
        locationModifiers = location.modifiers.isEmpty ? nil : location.modifiers
    }

    /// Get the cached scene location (reconstructed from stored properties)
    /// Returns nil if this is not a scene heading or location hasn't been parsed
    public var cachedSceneLocation: SceneLocation? {
        guard elementType == "Scene Heading",
              let lightingRaw = locationLighting,
              let scene = locationScene else {
            return nil
        }

        let lighting = SceneLighting(rawValue: lightingRaw) ?? .unknown

        return SceneLocation(
            lighting: lighting,
            scene: scene,
            setup: locationSetup,
            timeOfDay: locationTimeOfDay,
            modifiers: locationModifiers ?? [],
            originalText: elementText
        )
    }

    /// Force reparse the location (useful for migration or manual updates)
    public func reparseLocation() {
        parseAndStoreLocation()
    }

    /// Update element text and automatically reparse location if needed
    public func updateText(_ newText: String) {
        guard newText != elementText else { return }
        elementText = newText
        if elementType == "Scene Heading" {
            parseAndStoreLocation()
        }
    }

    /// Update element type and automatically reparse location if needed
    public func updateType(_ newType: String) {
        guard newType != elementType else { return }
        let wasSceneHeading = elementType == "Scene Heading"
        let isSceneHeading = newType == "Scene Heading"

        elementType = newType

        if isSceneHeading && !wasSceneHeading {
            // Became a scene heading - parse location
            parseAndStoreLocation()
        } else if !isSceneHeading && wasSceneHeading {
            // Was a scene heading, no longer is - clear location
            parseAndStoreLocation()
        }
    }
}

@Model
public final class TitlePageEntryModel {
    public var key: String
    public var values: [String]

    public var document: GuionDocumentModel?

    public init(key: String, values: [String]) {
        self.key = key
        self.values = values
    }
}
#endif
