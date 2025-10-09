# Scene Location Parser Example

This document demonstrates how to use the `SceneLocation` parser to extract and analyze location information from screenplay sluglines.

## Overview

The location parser breaks down scene headings (sluglines) into their constituent parts:
- **Lighting**: INT, EXT, INT/EXT, INT./EXT, I/E
- **Scene**: The primary location (e.g., "COFFEE SHOP", "WILL'S BEDROOM")
- **Setup**: Optional sub-location (e.g., "KITCHEN", "HALLWAY")
- **Time of Day**: DAY, NIGHT, DAWN, DUSK, etc.
- **Modifiers**: Additional information in parentheses or brackets (e.g., "(1973)", "[CONTINUOUS]")

## Basic Usage

### Parsing a Single Slugline

```swift
import SwiftGuion

// Parse a scene heading
let location = SceneLocation.parse("INT. COFFEE SHOP - DAY")

print(location.lighting)        // .interior
print(location.scene)           // "COFFEE SHOP"
print(location.timeOfDay)       // "DAY"
print(location.fullLocation)    // "COFFEE SHOP"
```

### Parsing with Setup

```swift
let bedroom = SceneLocation.parse("INT. WILL'S BEDROOM - NIGHT (1973)")

print(bedroom.lighting)         // .interior
print(bedroom.scene)            // "WILL'S"
print(bedroom.setup)            // "BEDROOM"
print(bedroom.timeOfDay)        // "NIGHT"
print(bedroom.modifiers)        // ["1973"]
print(bedroom.fullLocation)     // "WILL'S - BEDROOM"
```

### Parsing from GuionElement

```swift
let element = GuionElement(
    elementType: "Scene Heading",
    elementText: "EXT. PARK - DAY"
)

if let location = element.sceneLocation {
    print(location.scene)       // "PARK"
    print(location.lighting)    // .exterior
}
```

## Production Planning

### Extract All Scene Locations

```swift
let script = try FountainScript(file: "/path/to/script.fountain")

// Get all scene locations
let scenes = script.extractSceneLocations()

for scene in scenes {
    print("\(scene.location.fullLocation) - \(scene.location.timeOfDay ?? "Unknown")")
}
```

### Group Scenes by Location

```swift
// Group scenes by location for production planning
let groups = script.groupScenesByLocation()

for (locationKey, group) in groups {
    print("\n\(group.representativeLocation.fullLocation)")
    print("  Scenes: \(group.sceneCount)")
    print("  Lighting types: \(group.lightingTypes.map { $0.standardAbbreviation })")
    print("  Times of day: \(Array(group.timesOfDay))")
}
```

### Get Locations by Frequency

```swift
// Get locations sorted by most used
let topLocations = script.getLocationsByFrequency()

print("Top 5 Locations:")
for (index, group) in topLocations.prefix(5).enumerated() {
    print("\(index + 1). \(group.representativeLocation.fullLocation) - \(group.sceneCount) scenes")
}
```

### Get Locations by Appearance Order

```swift
// Get locations in order of first appearance
let locationsByAppearance = script.getLocationsByAppearance()

print("Locations in order of appearance:")
for group in locationsByAppearance {
    let firstScene = group.scenes.first!
    print("- \(group.representativeLocation.fullLocation) (first appears at scene index \(firstScene.sceneIndex))")
}
```

### Find All Scenes at a Specific Location

```swift
// Get all scenes at a specific location
let hospitalScenes = script.scenes(at: "HOSPITAL - ROOM")

print("All hospital room scenes:")
for scene in hospitalScenes {
    let time = scene.location.timeOfDay ?? "Unknown time"
    print("- Scene \(scene.sceneIndex): \(scene.sceneHeading.elementText)")
    print("  Time: \(time)")
}
```

## Advanced Analysis

### Find Locations with Multiple Lighting Types

```swift
let groups = script.groupScenesByLocation()

let mixedLightingLocations = groups.values.filter { $0.hasMultipleLightingTypes }

print("Locations requiring both INT and EXT setups:")
for group in mixedLightingLocations {
    print("- \(group.representativeLocation.fullLocation)")
    print("  Lighting: \(group.lightingTypes.map { $0.standardAbbreviation })")
}
```

### Find Locations Used at Multiple Times of Day

```swift
let multiTimeLocations = groups.values.filter { $0.timesOfDay.count > 1 }

print("Locations needing multiple times of day:")
for group in multiTimeLocations {
    print("- \(group.representativeLocation.fullLocation)")
    print("  Times: \(Array(group.timesOfDay).sorted())")
}
```

### Export Location Breakdown

```swift
// Export location breakdown to JSON for production planning
let outputURL = URL(fileURLWithPath: "/path/to/locations.json")
try script.writeLocationBreakdownJSON(to: outputURL)
```

The JSON output includes:
- Location name and key
- Scene count
- All lighting types used
- All times of day
- Detailed list of all scenes at that location

## Location Key Normalization

The location parser normalizes location keys for grouping:

```swift
let loc1 = SceneLocation.parse("INT. COFFEE SHOP - DAY")
let loc2 = SceneLocation.parse("INT. COFFEE SHOP - NIGHT")
let loc3 = SceneLocation.parse("EXT. COFFEE SHOP - DAY")

// Same location, different times/lighting have the same key
print(loc1.locationKey == loc2.locationKey)  // true
print(loc1.locationKey == loc3.locationKey)  // true

// Handles apostrophe variations
let curly = SceneLocation.parse("INT. WILL'S BEDROOM - NIGHT")
let straight = SceneLocation.parse("INT. WILL'S BEDROOM - NIGHT")
print(curly.locationKey == straight.locationKey)  // true
```

## Supported Lighting Types

```swift
// All supported lighting types:
SceneLighting.interior              // INT
SceneLighting.exterior              // EXT
SceneLighting.interiorExterior      // INT/EXT
SceneLighting.interiorExteriorAlt   // INT./EXT
SceneLighting.interiorExteriorShort // I/E

// Get standard abbreviation
let lighting = SceneLighting.interior
print(lighting.standardAbbreviation)  // "INT"
print(lighting.description)           // "Interior"
```

## Complex Slugline Examples

### With Parenthetical Details

```swift
let restaurant = SceneLocation.parse("INT. TINY PARIS RESTAURANT (LA RUE 14°) - NIGHT (1998)")
print(restaurant.scene)      // Contains "PARIS RESTAURANT"
print(restaurant.timeOfDay)  // "NIGHT"
print(restaurant.modifiers)  // ["1998"]
```

### With Slashes in Location

```swift
let plane = SceneLocation.parse("INT. 747 / FLYING - NIGHT")
print(plane.scene)           // "747 / FLYING"
print(plane.timeOfDay)       // "NIGHT"
```

### With Brackets for Continuity

```swift
let continuous = SceneLocation.parse("EXT. BACK YARD - NIGHT [CONTINUOUS]")
print(continuous.modifiers)  // ["CONTINUOUS"]
print(continuous.timeOfDay)  // "NIGHT"
```

### Without Time Specified

```swift
let approaching = SceneLocation.parse("EXT. APPROACHING THE HOUSE")
print(approaching.scene)     // "APPROACHING THE HOUSE"
print(approaching.timeOfDay) // nil
```

## Production Use Case Example

```swift
// Production scenario: Group scenes by location and analyze shooting requirements

let script = try FountainScript(file: "bigfish.fountain")
let locationGroups = script.getLocationsByFrequency()

print("PRODUCTION SCHEDULE ANALYSIS")
print("="*50)

for group in locationGroups {
    print("\nLOCATION: \(group.representativeLocation.fullLocation)")
    print("Total Scenes: \(group.sceneCount)")

    // Analyze lighting requirements
    let interiorScenes = group.scenes.filter { $0.location.lighting == .interior }
    let exteriorScenes = group.scenes.filter { $0.location.lighting == .exterior }

    if !interiorScenes.isEmpty {
        print("  INT scenes: \(interiorScenes.count)")
    }
    if !exteriorScenes.isEmpty {
        print("  EXT scenes: \(exteriorScenes.count)")
    }

    // Analyze time of day requirements
    print("  Times of day needed: \(Array(group.timesOfDay).sorted().joined(separator: ", "))")

    // List all scene numbers if available
    let sceneNumbers = group.scenes.compactMap { $0.sceneNumber }
    if !sceneNumbers.isEmpty {
        print("  Scene numbers: \(sceneNumbers.joined(separator: ", "))")
    }
}
```

## Testing

See `Tests/SwiftGuionTests/SceneLocationTests.swift` for comprehensive test examples covering:
- Lighting parsing
- Scene and setup extraction
- Time of day parsing
- Modifier handling
- Complex slugline patterns
- Location grouping
- Production analysis
