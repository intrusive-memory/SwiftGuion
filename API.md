# API Reference

This guide lists the main entry points exposed by the SwiftGuion package so that tools can look up type signatures without opening the sources.

## Core Types

| Type | Role |
| --- | --- |
| `GuionParsedScreenplay` | Immutable parsed screenplay representation (Sendable, thread-safe). |
| `GuionElement` | Represents a single screenplay element (scene heading, dialogue, etc.). |
| `CharacterInfo` / `CharacterList` | Aggregated character statistics derived from a script. |
| `OutlineElement` / `OutlineTree` | Structural outline abstraction with hierarchical helpers. |
| `FountainWriter` | Serializes screenplays back to Fountain format. |

## GuionParsedScreenplay

`GuionParsedScreenplay` is an immutable, Sendable class representing a parsed screenplay. All properties are `let` constants, making it safe to pass between threads. Key properties and initializers include:

- `init(filename:elements:titlePage:suppressSceneNumbers:)` – create from explicit data.
- `init(file:parser:)` – parse a `.fountain` file.
- `init(string:parser:)` – parse Fountain text from memory.
- `init(highland:)` – parse Highland `.highland` archive.
- `init(textBundle:)` – parse TextBundle format.

**Properties** (all immutable):
- `filename: String?` – original filename
- `elements: [GuionElement]` – ordered screenplay elements
- `titlePage: [[String: [String]]]` – title page metadata
- `suppressSceneNumbers: Bool` – whether to hide scene numbers

**Methods**:
- `stringFromDocument()` – serialize complete screenplay to Fountain
- `write(to:)` / `write(toFile:)` – save as Fountain file
- `extractOutline()` – generate hierarchical outline
- `extractCharacters()` – extract character information
- `extractSceneLocations()` – extract location data

## Guion Elements

`GuionElement` stores the textual payload and metadata needed to reconstruct Fountain markup:

- `elementType`, `elementText`, `isCentered`
- Scene-specific info (`sceneNumber`, `sectionDepth`, `isDualDialogue`)
- `CustomStringConvertible` implementation for debug printing

Instances are created and managed by the parsers but can be constructed manually if necessary. 【F:Sources/SwiftGuion/FountainElement.swift†L18-L45】

## Characters API

`CharacterInfo` tracks per-character statistics with nested `CharacterCounts` (dialogue lines/words) and `CharacterGender` metadata. `CharacterList` is a simple `[String: CharacterInfo]` alias. FountainScript adds:

- `extractCharacters()` – builds the dictionary, populating scenes, line counts, and word counts.
- `writeCharactersJSON(toFile:)` / `writeCharactersJSON(to:)` – export summaries as pretty-printed JSON.
- `firstDialogue(for:)` – find the first spoken line of a character.

These utilities rely on the parsed `GuionElement` sequence; names are normalized (case-insensitive, extension-free). 【F:Sources/SwiftGuion/CharacterInfo.swift†L28-L74】【F:Sources/SwiftGuion/FountainScript+Characters.swift†L30-L154】

## Outline API

`OutlineElement` encodes hierarchy for sections, scenes, and `NOTE:` comments, including parent/child relationships, directive metadata, and helper predicates (`isSceneDirective`, `isChapter`, `isMainTitle`). The companion `OutlineTree` builds a tree of `OutlineTreeNode` objects and offers queries such as `node(for:)`, `allNodes`, and `leafNodes`. FountainScript exposes:

- `extractOutline()` – generates ordered outline entries with auto-added title/root markers.
- `extractOutlineTree()` – convenience wrapper returning an `OutlineTree`.
- `writeOutlineJSON(toFile:)` / `writeOutlineJSON(to:)` – exports a trimmed outline ready for Highland/TextBundle resources.

Parent-child relationships are automatically tracked and exported in JSON-friendly form. 【F:Sources/SwiftGuion/OutlineElement.swift†L28-L268】【F:Sources/SwiftGuion/FountainScript+Outline.swift†L30-L273】

## Writing Output

`FountainWriter` rebuilds title pages and guión bodies from the parsed elements. Notable methods:

- `document(from:)` – produce the full Fountain text (title page + body).
- `body(from:)` – serialize only the guión body, applying Fountain formatting rules for each element type.
- `titlePage(from:)` – render the title page entries back into Fountain front matter.

`FountainScript` wraps these helpers via `stringFromDocument`, `stringFromBody`, and `stringFromTitlePage`, and passes the generated text to the file/bundle writers described above. 【F:Sources/SwiftGuion/FountainWriter.swift†L29-L158】【F:Sources/SwiftGuion/FountainScript.swift†L88-L108】【F:Sources/SwiftGuion/FountainScript+TextBundle.swift†L84-L179】

## FileFormat Module

The FileFormat module contains types for working with Guion's native .guion document format:

### GuionDocument

`GuionDocumentConfiguration` is a `FileDocument` that handles reading and writing .guion files as well as importing Fountain, FDX, and Highland formats:

- `init(document:)` – create configuration with an existing model
- `init(configuration: ReadConfiguration)` – parse documents from file wrappers
- `fileWrapper(configuration:)` – serialize documents for writing
- `extractContent(from:filename:)` – extract content from files including Highland ZIP archives
- Supports UTTypes: `.guionDocument`, `.fountainDocument`, `.fdxDocument`, `.highlandDocument`

### GuionDocumentModel

`GuionDocumentModel` is the SwiftData-backed model representing a complete screenplay:

- `filename: String?` – original filename
- `rawContent: String?` – raw screenplay text
- `elements: [GuionElementModel]` – parsed screenplay elements
- `titlePage: [TitlePageEntryModel]` – title page metadata
- `parseContent(rawContent:filename:contentType:modelContext:)` – async parsing from raw text
- `extractCharacters()` – extract character information from the document

### GuionElement

`GuionElement` represents a single screenplay element with:

- `elementType: String` – type (Scene Heading, Action, Character, Dialogue, etc.)
- `elementText: String` – the actual text content
- `sceneNumber: String?` – optional scene number
- `isCentered: Bool` – whether element is centered
- `sectionDepth: Int` – section nesting level (for # headers)
- `isDualDialogue: Bool` – dual dialogue flag

### GuionDocumentSerialization

Provides serialization between `GuionDocumentModel` and Fountain/FDX formats:

- `toFountainScript(from:)` – convert GuionDocumentModel to FountainScript
- `toFDXData(from:)` – export GuionDocumentModel as FDX XML
- `loadAndParse(from:in:generateSummaries:)` – unified parser for all screenplay formats

## Analysis Module

The Analysis module contains types for screenplay analysis and UI data structures:

### SceneBrowserData

Hierarchical data structures for scene browsing:

- `SceneBrowserData` – root structure with title and chapters
- `ChapterData` – level 2 outline elements containing scene groups
- `SceneGroupData` – level 3 outline elements containing scenes
- `SceneData` – individual scenes with elements and location info

Each structure includes:
- `id: String` – unique identifier
- `element: OutlineElement` – associated outline element
- `title/slugline: String` – display text
- Navigation properties for hierarchical traversal

### SceneLocation

`SceneLocation` tracks location information extracted from scene headings:

- `rawLocation: String` – full location string (e.g., "INT. BEDROOM")
- `timeOfDay: String?` – time descriptor (DAY, NIGHT, etc.)
- `intExt: String?` – interior/exterior indicator
- `setting: String?` – the actual location name
- `sceneId: String` – links back to scene element

### CharacterInfo

`CharacterInfo` aggregates per-character statistics:

- `name: String` – character name
- `scenes: [String]` – scene IDs where character appears
- `counts: CharacterCounts` – dialogue statistics
- `gender: CharacterGender` – character gender metadata

### SceneSummarizer

`SceneSummarizer` generates natural language summaries of scenes:

- `summarize(scene:)` – create summary from scene elements
- Extracts characters, action, and dialogue
- Produces human-readable scene descriptions

### SpeakableContent

`SpeakableContent` extracts dialogue for text-to-speech or analysis:

- `speakableLines(from:)` – extract all spokentext
- Filters out stage directions and action
- Preserves character attribution

## ImportExport Module

The ImportExport module handles parsing and writing of various screenplay formats:

### FountainParser

High-performance Fountain parser using hand-optimized state machine:

- `init(file:)` / `init(string:)` – parse Fountain from file or string
- `elements: [GuionElement]` – parsed screenplay elements
- `titlePage: [[String: [String]]]` – extracted title page metadata
- Significantly faster than regex-based parser
- Handles all Fountain specification features

### FountainWriter

Serializes parsed screenplays back to Fountain format:

- `document(from:)` – generate complete Fountain document with title page
- `body(from:)` – serialize screenplay body only
- `titlePage(from:)` – render title page front matter
- Preserves formatting and special markers

### FDXParser

Parses Final Draft XML documents:

- `parse(data:filename:)` – parse FDX XML into GuionElements
- Returns `FDXParsedDocument` with elements and metadata
- Handles FDX-specific features (scene numbers, revisions)
- Compatible with Final Draft 8-12

### FDXDocumentWriter

Exports screenplays to Final Draft XML format:

- `write(_:)` – generate FDX XML from GuionElements
- `writeTitlePage(_:)` – serialize metadata
- Properly escapes XML entities
- Creates valid FDX documents readable by Final Draft

### ExportDocument

File document wrappers for export operations:

- `FountainExportDocument` – exports GuionDocumentModel to .fountain
- `FDXExportDocument` – exports GuionDocumentModel to .fdx
- `ExportFormat` – enum for format selection (fountain, fdx)
- `ExportError` – error types for export operations

### FountainRegexes

Constants for Fountain regex patterns (legacy regex-based parser):

- Pattern constants for all Fountain elements (scenes, dialogue, action, etc.)
- Template strings for regex replacement
- Styling patterns (bold, italic, underline)
- Used by legacy regex parser (FountainParser is preferred)

## TextPack Format (.guion)

TextPack is Gu's native file format - a bundle directory containing structured screenplay data.

### TextPack Structure

```
MyScript.guion/
├── info.json                    # Document metadata
├── screenplay.fountain          # Complete screenplay
└── Resources/                   # Additional data
    ├── characters.json          # Character information
    ├── locations.json           # Location data
    ├── elements.json            # All screenplay elements
    └── titlepage.json           # Title page entries
```

### TextPackWriter

Creates TextPack bundles from screenplay data:

- `createTextPack(from: GuionParsedScreenplay)` – create bundle from screenplay
- `createTextPack(from: GuionDocumentModel)` – create bundle from SwiftData model
- Generates all JSON resources automatically
- Uses ISO8601 date encoding and pretty-printed JSON
- Extracts character dialogue counts and scene appearances
- Parses location data with lighting and time-of-day information

### TextPackReader

Reads TextPack bundles back into screenplay data:

- `readTextPack(from:)` – load as `GuionParsedScreenplay`
- `readTextPack(from:in:)` – load as `GuionDocumentModel` (SwiftData)
- `readCharacters(from:)` – extract character JSON
- `readLocations(from:)` – extract location JSON
- `readElements(from:)` – extract elements JSON
- `readTitlePage(from:)` – extract title page JSON
- Handles missing optional resources gracefully

### TextPack Metadata

**TextPackInfo** (info.json):
- `version: String` – format version ("1.0")
- `format: String` – identifier ("guion-textpack")
- `created/modified: Date` – timestamps
- `filename: String?` – original filename
- `suppressSceneNumbers: Bool` – scene number flag
- `resources: [String]` – list of included resource files

**CharacterData** (characters.json):
- `name: String` – character name
- `scenes: [String]` – scene IDs where character appears
- `dialogueLines: Int` – number of dialogue lines
- `dialogueWords: Int` – total words spoken
- `firstAppearance: String?` – scene ID of first appearance

**LocationData** (locations.json):
- `rawLocation: String` – full scene heading text
- `lighting: String` – INT/EXT/etc (abbreviated form)
- `scene: String` – primary location name
- `setup/timeOfDay: String?` – optional details
- `modifiers: [String]` – additional tags (FLASHBACK, etc.)
- `sceneIds: [String]` – scenes using this location

**ElementData** (elements.json):
- All `GuionElement` properties serialized as JSON
- Preserves scene IDs for cross-referencing

### GuionDocumentModel Conversion

SwiftData integration with explicit conversion methods:

- `GuionDocumentModel.from(_:in:generateSummaries:)` – create from GuionParsedScreenplay
- `GuionDocumentModel.toGuionParsedScreenplay()` – convert to immutable screenplay
- Handles title page, elements, and metadata conversion
- Optional AI-powered scene summary generation

## Package Layout

SwiftGuion ships as a single SwiftPM library target organized into functional modules:

- **Core/** – GuionParsedScreenplay (immutable, Sendable) and core screenplay model
- **FileFormat/** – Guion native .guion TextPack format and SwiftData models
- **ImportExport/** – Format parsers (Fountain, FDX, Highland) and writers
- **Analysis/** – Scene analysis, character extraction, and UI data structures
- **UI/** – SwiftUI components (GuionViewer, SceneBrowserWidget, etc.)

### Key Dependencies

- **ZIPFoundation** – Highland archive extraction
- **SwiftData** – Document persistence (macOS 14.0+)
- **SwiftUI** – User interface components (macOS 14.0+)

### Test Coverage

Tests live under `SwiftGuionTests` with fixture bundles for:
- Fountain files (`.fountain`)
- Highland archives (`.highland`)
- TextBundle formats (`.textbundle`)
- FDX documents (`.fdx`)
- TextPack bundles (`.guion`)

**Current Test Count**: 128 tests covering parsing, serialization, analysis, and TextPack format.
