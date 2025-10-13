# BOT GUIDE

A comprehensive orientation for automated agents (LLMs, AI assistants, code generators) consuming SwiftGuion.

## Quick Reference

**SwiftGuion** is a Swift package for parsing, analyzing, and exporting screenplay formats (Fountain, FDX, Highland, TextPack).

**Core Architecture:**
- **GuionParsedScreenplay**: Immutable, thread-safe parsed screenplay (primary entry point)
- **GuionDocumentModel**: SwiftData-backed mutable model for persistence
- **TextPack Format**: Native .guion bundle with structured JSON exports

**Supported Formats:** `.fountain`, `.fdx` (Final Draft), `.highland` (Highland 2), `.guion` (TextPack bundles)

**Platform:** macOS 14.0+, iOS 17.0+ (SwiftUI components)

**Test Coverage:** 128 tests, 100% pass rate

---

## Architecture Overview

### Immutable Core (Thread-Safe)

```swift
// GuionParsedScreenplay is Sendable and immutable
let screenplay = try GuionParsedScreenplay(file: "screenplay.fountain")
// Safe to pass between threads, no data races possible
```

**Key Types:**
- `GuionParsedScreenplay`: Immutable screenplay with `let` properties
- `GuionElement`: Individual screenplay elements (Scene Heading, Action, Dialogue, etc.)
- All properties immutable, safe for concurrent access

### Mutable Persistence (SwiftData)

```swift
// Convert to SwiftData model for persistence
let document = await GuionDocumentModel.from(screenplay, in: context)

// Convert back to immutable form
let screenplay2 = document.toGuionParsedScreenplay()
```

**Key Types:**
- `GuionDocumentModel`: SwiftData @Model for persistence
- `GuionElementModel`: SwiftData element model
- `TitlePageEntryModel`: SwiftData title page entries

### Explicit Conversion Pattern

```swift
// Immutable → Mutable (for persistence)
let document = await GuionDocumentModel.from(screenplay, in: context, generateSummaries: false)

// Mutable → Immutable (for processing)
let screenplay = document.toGuionParsedScreenplay()
```

---

## File Format Support

### 1. Fountain (.fountain)

```swift
// Parse Fountain file
let screenplay = try GuionParsedScreenplay(file: "screenplay.fountain")

// Parse Fountain string
let screenplay = try GuionParsedScreenplay(string: fountainText)

// Using explicit parser
let parser = FountainParser(file: "screenplay.fountain")
let screenplay = GuionParsedScreenplay(
    filename: "screenplay.fountain",
    elements: parser.elements,
    titlePage: parser.titlePage
)
```

**Parser:** `FountainParser` (state machine, high performance)

### 2. Final Draft XML (.fdx)

```swift
// Parse FDX file
let fdxData = try Data(contentsOf: fdxURL)
let parser = FDXParser()
let fdxDoc = try parser.parse(data: fdxData, filename: "screenplay.fdx")

let screenplay = GuionParsedScreenplay(
    filename: "screenplay.fdx",
    elements: fdxDoc.elements,
    titlePage: fdxDoc.titlePage
)
```

**Parser:** `FDXParser` (XML-based)

### 3. Highland (.highland)

```swift
// Parse Highland archive
let screenplay = try GuionParsedScreenplay(highland: highlandURL)
```

**Format:** ZIP archive containing TextBundle with screenplay data

**Internal Filename:** Extracts to `text.md` internally (not `screenplay.fountain`)

### 4. TextPack (.guion) - Native Format

```swift
// Read TextPack bundle
let screenplay = try TextPackReader.readTextPack(from: fileWrapper)

// Create TextPack bundle
let textPack = try TextPackWriter.createTextPack(from: screenplay)

// Access structured resources
let characters = TextPackReader.readCharacters(from: textPack)
let locations = TextPackReader.readLocations(from: textPack)
```

**Structure:**
```
MyScript.guion/
├── info.json              # Metadata (version, dates, filename)
├── screenplay.fountain    # Complete screenplay
└── Resources/
    ├── characters.json    # Character dialogue counts, scene appearances
    ├── locations.json     # Location data with INT/EXT, time-of-day
    ├── elements.json      # All screenplay elements with IDs
    └── titlepage.json     # Title page entries
```

---

## Common Workflows

### Workflow 1: Parse and Analyze

```swift
// 1. Parse screenplay
let screenplay = try GuionParsedScreenplay(file: "screenplay.fountain")

// 2. Access elements
for element in screenplay.elements {
    print("\(element.elementType): \(element.elementText)")
}

// 3. Extract characters
let characters: CharacterList = screenplay.extractCharacters()
for (name, info) in characters {
    print("\(name): \(info.counts.lineCount) lines, \(info.counts.wordCount) words")
}

// 4. Extract locations
let locations = screenplay.extractSceneLocations()
for location in locations {
    print("\(location.lighting.rawValue). \(location.scene) - \(location.timeOfDay ?? "")")
}

// 5. Extract outline
let outline = screenplay.extractOutline()
for element in outline {
    print("[\(element.level)] \(element.type): \(element.string)")
}
```

### Workflow 2: Convert Between Formats

```swift
// Fountain → TextPack
let screenplay = try GuionParsedScreenplay(file: "screenplay.fountain")
let textPack = try TextPackWriter.createTextPack(from: screenplay)

// TextPack → Fountain
let screenplay = try TextPackReader.readTextPack(from: textPack)
try screenplay.write(toFile: "output.fountain")

// FDX → Fountain
let fdxData = try Data(contentsOf: fdxURL)
let parser = FDXParser()
let fdxDoc = try parser.parse(data: fdxData, filename: "screenplay.fdx")
let screenplay = GuionParsedScreenplay(
    filename: "screenplay.fdx",
    elements: fdxDoc.elements,
    titlePage: fdxDoc.titlePage
)
try screenplay.write(toFile: "output.fountain")
```

### Workflow 3: SwiftData Integration

```swift
// Parse → Persist
let screenplay = try GuionParsedScreenplay(file: "screenplay.fountain")
let document = await GuionDocumentModel.from(screenplay, in: context)
// Document now tracked by SwiftData

// Retrieve → Process
let screenplay = document.toGuionParsedScreenplay()
// Immutable copy safe for concurrent processing
```

### Workflow 4: UI Integration

```swift
import SwiftUI
import SwiftGuion

struct ContentView: View {
    let document: GuionDocumentModel

    var body: some View {
        GuionViewer(document: document)
            .frame(minWidth: 600, minHeight: 800)
    }
}
```

---

## API Quick Reference

### GuionParsedScreenplay

**Initializers:**
```swift
init(filename:elements:titlePage:suppressSceneNumbers:)
init(file:parser:)
init(string:parser:)
init(highland:)
init(textBundle:)
```

**Properties (all immutable):**
```swift
let filename: String?
let elements: [GuionElement]
let titlePage: [[String: [String]]]
let suppressSceneNumbers: Bool
```

**Methods:**
```swift
func stringFromDocument() -> String
func write(toFile:) throws
func write(to:) throws
func extractCharacters() -> CharacterList
func extractSceneLocations() -> [SceneLocation]
func extractOutline() -> [OutlineElement]
func extractOutlineTree() -> OutlineTree
```

### GuionDocumentModel

**Conversion:**
```swift
static func from(_:in:generateSummaries:) async -> GuionDocumentModel
func toGuionParsedScreenplay() -> GuionParsedScreenplay
```

**Properties:**
```swift
var filename: String?
var rawContent: String?
var elements: [GuionElementModel]
var titlePage: [TitlePageEntryModel]
var suppressSceneNumbers: Bool
```

### FountainParser

```swift
init(file:) throws
init(string:)

var elements: [GuionElement]
var titlePage: [[String: [String]]]
```

### FDXParser

```swift
func parse(data:filename:) throws -> FDXParsedDocument
```

### TextPackWriter

```swift
static func createTextPack(from: GuionParsedScreenplay) throws -> FileWrapper
static func createTextPack(from: GuionDocumentModel) throws -> FileWrapper
```

### TextPackReader

```swift
static func readTextPack(from:) throws -> GuionParsedScreenplay
static func readTextPack(from:in:generateSummaries:) async throws -> GuionDocumentModel
static func readCharacters(from:) -> TextPackCharacterList?
static func readLocations(from:) -> LocationList?
static func readElements(from:) -> ElementList?
static func readTitlePage(from:) -> TitlePageData?
```

---

## Element Types

GuionElement.elementType values:

- **Scene Heading**: INT/EXT scene headings
- **Action**: Action/description lines
- **Character**: Character name before dialogue
- **Dialogue**: Spoken lines
- **Parenthetical**: (stage direction) within dialogue
- **Transition**: CUT TO:, FADE OUT, etc.
- **Section Heading**: # Markdown-style headers
- **Synopsis**: = Synopsis lines
- **Comment**: /* Boneyard comments */
- **Centered**: > Centered text <
- **Page Break**: ===
- **Lyrics**: ~ Song lyrics ~

---

## Testing

```bash
# Run all tests
swift test

# Run specific test
swift test --filter BigFishParsingTests

# Run with verbose output
swift test --verbose
```

**Test Files:**
- `Tests/SwiftGuionTests/FountainParserTests.swift` - Parser tests
- `Tests/SwiftGuionTests/BigFishParsingTests.swift` - Cross-format tests
- `Tests/SwiftGuionTests/TextPackTests.swift` - TextPack format tests
- `Fixtures/` - Test screenplay files (bigfish.fountain, bigfish.fdx, bigfish.highland)

**Current Status:** 128/128 tests passing (100%)

---

## Package Structure

```
Sources/SwiftGuion/
├── Core/
│   ├── GuionParsedScreenplay.swift    # Immutable screenplay (Sendable)
│   └── GuionElement.swift             # Element structure
├── FileFormat/
│   ├── GuionDocumentModel.swift       # SwiftData model
│   ├── GuionDocument.swift            # FileDocument implementation
│   ├── TextPackMetadata.swift         # JSON schemas
│   ├── TextPackWriter.swift           # Bundle creation
│   └── TextPackReader.swift           # Bundle reading
├── ImportExport/
│   ├── FountainParser.swift           # State machine parser
│   ├── FountainWriter.swift           # Fountain serializer
│   ├── FDXParser.swift                # FDX XML parser
│   └── FDXDocumentWriter.swift        # FDX XML writer
├── Analysis/
│   ├── CharacterInfo.swift            # Character extraction
│   ├── SceneLocation.swift            # Location parsing
│   ├── OutlineElement.swift           # Outline structure
│   └── SceneSummarizer.swift          # AI summaries
└── UI/
    ├── GuionViewer.swift              # Main viewer component
    ├── SceneBrowserWidget.swift       # Scene browser
    └── [other SwiftUI widgets]
```

---

## Common Pitfalls for Bots

### ❌ Don't: Mutate GuionParsedScreenplay

```swift
// ERROR: All properties are 'let' constants
screenplay.elements.append(newElement)  // Won't compile
```

### ✅ Do: Create New Instance

```swift
var newElements = screenplay.elements
newElements.append(newElement)
let newScreenplay = GuionParsedScreenplay(
    filename: screenplay.filename,
    elements: newElements,
    titlePage: screenplay.titlePage
)
```

### ❌ Don't: Mix Old Type Names

```swift
// ERROR: These types were renamed
let script = FountainScript()        // Now: GuionParsedScreenplay
let parser = FastFountainParser()    // Now: FountainParser
let parser = FDXDocumentParser()     // Now: FDXParser
```

### ✅ Do: Use Current Type Names

```swift
let screenplay = GuionParsedScreenplay()
let parser = FountainParser()
let fdxParser = FDXParser()
```

### ❌ Don't: Expect Highland Filename

```swift
// ERROR: Highland files extract to "text.md" internally
#expect(document.filename == "screenplay.fountain")  // Fails
```

### ✅ Do: Accept Actual Filename

```swift
// Highland extracts to "text.md"
#expect(document.filename == "text.md" || document.filename == "screenplay.highland")
```

### ❌ Don't: Skip Conversion Methods

```swift
// ERROR: Manually copying properties is error-prone
let document = GuionDocumentModel(...)
for element in screenplay.elements {
    let model = GuionElementModel(...)
    // ... manual property copying ...
}
```

### ✅ Do: Use Conversion Methods

```swift
// Single source of truth for conversions
let document = await GuionDocumentModel.from(screenplay, in: context)
let screenplay = document.toGuionParsedScreenplay()
```

---

## Type Signature Reference (for Code Generation)

### GuionParsedScreenplay

```swift
public final class GuionParsedScreenplay: Sendable {
    public let filename: String?
    public let elements: [GuionElement]
    public let titlePage: [[String: [String]]]
    public let suppressSceneNumbers: Bool

    public init(
        filename: String?,
        elements: [GuionElement],
        titlePage: [[String: [String]]] = [],
        suppressSceneNumbers: Bool = false
    )

    public convenience init(file filePath: String, parser: ParserType = .fast) throws
    public convenience init(string: String, parser: ParserType = .fast) throws
    public convenience init(highland url: URL) throws
    public convenience init(textBundle url: URL) throws

    public func stringFromDocument() -> String
    public func stringFromBody() -> String
    public func stringFromTitlePage() -> String
    public func write(toFile path: String) throws
    public func write(to url: URL) throws

    public func extractCharacters() -> CharacterList
    public func extractSceneLocations() -> [SceneLocation]
    public func extractOutline() -> [OutlineElement]
    public func extractOutlineTree() -> OutlineTree
}
```

### GuionElement

```swift
public struct GuionElement: Sendable, Codable {
    public let elementType: String
    public let elementText: String
    public let sceneNumber: String?
    public let isCentered: Bool
    public let sectionDepth: Int
    public let isDualDialogue: Bool
    public let sceneId: String?

    public init(
        elementType: String,
        elementText: String,
        sceneNumber: String? = nil,
        isCentered: Bool = false,
        sectionDepth: Int = 0,
        isDualDialogue: Bool = false
    )
}
```

### GuionDocumentModel

```swift
@Model
public final class GuionDocumentModel {
    public var filename: String?
    public var rawContent: String?
    @Relationship(deleteRule: .cascade) public var elements: [GuionElementModel]
    @Relationship(deleteRule: .cascade) public var titlePage: [TitlePageEntryModel]
    public var suppressSceneNumbers: Bool

    @MainActor
    public static func from(
        _ screenplay: GuionParsedScreenplay,
        in context: ModelContext,
        generateSummaries: Bool = false
    ) async -> GuionDocumentModel

    public func toGuionParsedScreenplay() -> GuionParsedScreenplay
}
```

---

## JSON Export Formats

### characters.json

```json
{
  "characters": [
    {
      "id": "uuid",
      "name": "CHARACTER NAME",
      "scenes": ["scene-id-1", "scene-id-2"],
      "dialogueLines": 82,
      "dialogueWords": 558,
      "firstAppearance": "scene-id-1"
    }
  ]
}
```

### locations.json

```json
{
  "locations": [
    {
      "id": "uuid",
      "rawLocation": "INT. COFFEE SHOP - DAY",
      "lighting": "INT",
      "scene": "COFFEE SHOP",
      "setup": null,
      "timeOfDay": "DAY",
      "modifiers": [],
      "sceneIds": ["scene-id-1", "scene-id-5"]
    }
  ]
}
```

### info.json

```json
{
  "version": "1.0",
  "format": "guion-textpack",
  "created": "2025-10-13T12:00:00Z",
  "modified": "2025-10-13T12:00:00Z",
  "filename": "screenplay.fountain",
  "suppressSceneNumbers": false,
  "resources": [
    "characters.json",
    "locations.json",
    "elements.json",
    "titlepage.json"
  ],
  "importedFiles": []
}
```

---

## Migration from Old APIs

| Old API | New API | Notes |
|---------|---------|-------|
| `FountainScript` | `GuionParsedScreenplay` | Renamed, made immutable |
| `FastFountainParser` | `FountainParser` | Renamed for clarity |
| `FDXDocumentParser` | `FDXParser` | Renamed for consistency |
| `script.loadFile()` | `init(file:)` | No mutable loading |
| `script.loadString()` | `init(string:)` | No mutable loading |
| Manual SwiftData conversion | `GuionDocumentModel.from()` | Explicit conversion method |

---

## Resources

- **README.md**: User-facing documentation with examples
- **API.md**: Complete API reference for all types
- **ARCHITECTURE_REDESIGN.md**: Design document for current architecture
- **MIGRATION_GUIDE.md**: Guide for updating to new APIs
- **Examples/FountainDocumentApp/**: Complete sample application

---

## Bot-Specific Notes

### For Code Completion Agents

- **Always use current type names**: `GuionParsedScreenplay`, `FountainParser`, `FDXParser`
- **Prefer immutable patterns**: Create new instances instead of mutating
- **Use conversion methods**: `GuionDocumentModel.from()` and `toGuionParsedScreenplay()`
- **Thread safety**: GuionParsedScreenplay is Sendable, safe to pass between threads

### For Documentation Agents

- **Architecture**: Emphasize immutable core with explicit conversions
- **File formats**: Four formats supported (.fountain, .fdx, .highland, .guion)
- **TextPack**: Native format with structured JSON exports
- **Parsers**: FountainParser (state machine) and FDXParser (XML)

### For Testing Agents

- **Test count**: 128 tests, 100% pass rate
- **Fixtures**: bigfish.fountain, bigfish.fdx, bigfish.highland in Fixtures/
- **Highland note**: Extracts to "text.md", not original filename
- **Command**: `swift test` to run full suite

### For Refactoring Agents

- **Immutability**: All GuionParsedScreenplay properties are `let` constants
- **Sendable**: GuionParsedScreenplay conforms to Sendable, no @unchecked
- **MainActor**: Conversion methods use @MainActor for SwiftData context
- **File reading**: Use Read tool, not `cat` commands

---

## Contact & Support

- **Repository**: https://github.com/intrusive-memory/SwiftGuion
- **Issues**: https://github.com/intrusive-memory/SwiftGuion/issues
- **License**: MIT License

---

**Last Updated**: 2025-10-13 (Architecture Redesign completion)
