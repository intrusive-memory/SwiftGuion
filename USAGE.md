# USAGE

SwiftGuion is a Swift package for parsing and exporting Fountain-formatted screenplays without mutating the source files. This document provides quick, copy-ready snippets for bots and automations that need to work with the library.

## Installation

Add the package as a dependency in your `Package.swift` (macOS 15 or newer is required):

```swift
.package(url: "https://github.com/stovak/SwiftGuion.git", from: "1.0.0")
```

Then depend on the `SwiftGuion` product from your target.

## Loading Fountain Content

### Parse from disk or memory

```swift
import SwiftGuion

// Parse a Fountain file using the fast parser
let script = try FountainScript(file: "/path/to/script.fountain")

// Parse from an in-memory string (regex parser available via the `parser:` argument)
let scriptFromString = try FountainScript(string: fountainText, parser: .regex)
```

`FountainScript` keeps the parsed elements and title page in memory and never modifies the original file. You can reload from cached content or switch parser strategies on demand. 【F:Sources/SwiftGuion/FountainScript.swift†L30-L143】

### Parse Highland and TextBundle packages

```swift
let highland = try FountainScript(highlandURL: URL(filePath: "/path/to/project.highland"))
let textBundle = try FountainScript(textBundleURL: URL(filePath: "/path/to/notes.textbundle"))
```

Both helpers extract the bundle, locate the Fountain/Markdown payload, and feed it through the standard parsing pipeline. 【F:Sources/SwiftGuion/FountainScript+Highland.swift†L31-L123】【F:Sources/SwiftGuion/FountainScript+TextBundle.swift†L32-L118】

## Accessing Parsed Data

```swift
// Title page entries preserve the raw key/value layout
for section in script.titlePage {
    for (key, values) in section {
        print("\(key): \(values.joined(separator: ", "))")
    }
}

// Iterate structured guión elements
typealias Element = GuionElement
for element in script.elements {
    print("\(element.elementType): \(element.elementText)")
}
```

Elements capture type metadata (scene numbers, centered flags, section depth, dual-dialogue marker) and expose `CustomStringConvertible` output for debugging. 【F:Sources/SwiftGuion/FountainScript.swift†L35-L140】【F:Sources/SwiftGuion/GuionElement.swift†L18-L45】

## Derived Insights

### Characters

```swift
let characters = script.extractCharacters()
print(characters["PROTAGONIST"]?.counts.wordCount ?? 0)

try script.writeCharactersJSON(to: URL(fileURLWithPath: "characters.json"))
```

`extractCharacters()` scans scene headings and dialogue to track appearances, line counts, and word counts; writers can persist the summary as JSON. 【F:Sources/SwiftGuion/FountainScript+Characters.swift†L30-L94】【F:Sources/SwiftGuion/CharacterInfo.swift†L28-L74】

### Outline

```swift
let outline = script.extractOutline()
let tree = outline.tree()

try script.writeOutlineJSON(to: "outline.json")
```

The outline builder normalizes section headings, scene headings, and NOTE: comments into a hierarchical `OutlineTree`. Export helpers drop cosmetic root markers before encoding pretty-printed JSON. 【F:Sources/SwiftGuion/FountainScript+Outline.swift†L30-L273】【F:Sources/SwiftGuion/OutlineElement.swift†L168-L268】

## Exporting

```swift
// Fountain text
try script.write(toFile: "Script.fountain")

// TextBundle (.textbundle directory)
let bundleURL = try script.writeToTextBundle(destinationURL: outputDir)

// Highland package (.highland archive)
let highlandURL = try script.writeToHighland(destinationURL: outputDir, name: "Draft")
```

The writer regenerates full Fountain documents (title page + body) and can package them as TextBundle directories or Highland archives—including optional character and outline JSON resources. 【F:Sources/SwiftGuion/FountainScript.swift†L88-L108】【F:Sources/SwiftGuion/FountainScript+TextBundle.swift†L84-L179】【F:Sources/SwiftGuion/FountainScript+Highland.swift†L81-L123】

## Working with Multiple File Types

To load content lazily, use the resolver helpers:

```swift
let contentURL = try script.getContentUrl(from: url)  // Handles .fountain, .textbundle, .highland
let bodyOnly = try script.getContent(from: url)       // Strips title page for .fountain files
```

These utilities share the same content discovery logic that powers the Highland and TextBundle constructors, allowing bots to funnel any supported container into `loadString`. 【F:Sources/SwiftGuion/FountainScript.swift†L146-L195】
