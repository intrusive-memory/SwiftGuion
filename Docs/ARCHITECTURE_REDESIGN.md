# SwiftGuion Architecture Redesign

## Overview

This document outlines the comprehensive refactoring of SwiftGuion's core architecture to improve concurrency safety, immutability, and file format design.

## Goals

1. **Immutable Parsed Representation**: `GuionParsedScreenplay` (renamed from `FountainScript`) becomes immutable and properly Sendable
2. **Clear Parser Naming**: Parsers named after their format (FountainParser, FDXParser, HighlandParser)
3. **TextPack File Format**: `.guion` files become TextPack bundles with structured content
4. **Concurrency Safety**: Clear separation between background parsing and MainActor editing
5. **Metadata Export**: Characters and locations exported as JSON in Resources

## Core Components

### 1. GuionParsedScreenplay (Immutable, Sendable)

**Purpose**: Immutable in-memory representation of a parsed screenplay

**Properties** (all `let`):
```swift
public final class GuionParsedScreenplay: Sendable {
    public let filename: String?
    public let elements: [GuionElement]  // immutable array
    public let titlePage: [[String: [String]]]  // immutable
    public let suppressSceneNumbers: Bool

    // No more mutable state or cached content
}
```

**Key Changes**:
- All properties become `let` (immutable)
- Remove `cachedContent` (no mutable state)
- Remove `loadFile()` and `loadString()` (construction only via init)
- Properly Sendable (not @unchecked)
- Can be safely passed between threads

### 2. Parsers (Background-Capable)

**FountainParser** (renamed from FastFountainParser):
```swift
public struct FountainParser {
    public static func parse(file: URL) throws -> GuionParsedScreenplay
    public static func parse(string: String) -> GuionParsedScreenplay
}
```

**FDXParser** (renamed from FDXDocumentParser):
```swift
public struct FDXParser {
    public static func parse(data: Data) throws -> GuionParsedScreenplay
    public static func parse(file: URL) throws -> GuionParsedScreenplay
}
```

**HighlandParser**:
```swift
public struct HighlandParser {
    public static func parse(file: URL) throws -> GuionParsedScreenplay
    // Handles .highland ZIP extraction
}
```

### 3. GuionFileDocument (@MainActor, TextPack Manager)

**Purpose**: Manages .guion TextPack bundle on disk, interfaces with SwiftData

```swift
@MainActor
public struct GuionFileDocument: FileDocument {
    public var documentModel: GuionDocumentModel

    // FileDocument requirements
    public init(configuration: ReadConfiguration) throws
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper

    // Import/Export
    public func importScreenplay(_ screenplay: GuionParsedScreenplay) throws
    public func exportToFountain() throws -> String
}
```

### 4. SwiftData Models (MainActor, Mutable)

**GuionDocumentModel** - Live editing model:
```swift
@Model
public final class GuionDocumentModel {
    public var filename: String?
    public var elements: [GuionElementModel]
    public var titlePage: [TitlePageEntryModel]

    // Conversion methods
    public func toGuionParsedScreenplay() -> GuionParsedScreenplay
    public static func from(_ screenplay: GuionParsedScreenplay) -> GuionDocumentModel
}
```

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         FILE SYSTEM LAYER                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  screenplay.fountain         screenplay.fdx         screenplay.highland  │
│  screenplay.guion (TextPack)                                             │
│                                                                           │
│  .guion TextPack Structure:                                              │
│  ├── info.json                  (metadata)                               │
│  ├── screenplay.fountain        (exported script)                        │
│  └── Resources/                                                          │
│      ├── characters.json        (character data)                         │
│      ├── locations.json         (location data)                          │
│      ├── elements.json          (all screenplay elements)                │
│      ├── titlepage.json         (title page entries)                     │
│      └── [imported-files]       (any additional files)                   │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
                    ▼               ▼               ▼
         ┌──────────────────────────────────────────────────┐
         │         PARSERS (Background Thread)              │
         ├──────────────────────────────────────────────────┤
         │                                                   │
         │  FountainParser          FDXParser                │
         │  (FastFountainParser)    (FDXDocumentParser)      │
         │  • parse(file:)          • parse(data:)           │
         │  • parse(string:)        • parse(file:)           │
         │                                                   │
         │  HighlandParser                                   │
         │  • parse(file:)                                   │
         │  • Extracts .textbundle from ZIP                  │
         │                                                   │
         └──────────────────────────────────────────────────┘
                                    │
                                    │ produces
                                    ▼
         ┌──────────────────────────────────────────────────┐
         │  GuionParsedScreenplay (Immutable, Sendable)     │
         ├──────────────────────────────────────────────────┤
         │  • let filename: String?                         │
         │  • let elements: [GuionElement]                  │
         │  • let titlePage: [[String: [String]]]           │
         │  • let suppressSceneNumbers: Bool                │
         │                                                   │
         │  Thread-safe, can be passed between threads      │
         │  No mutable state                                │
         └──────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                    ▼                               ▼
    ┌─────────────────────────┐       ┌──────────────────────────┐
    │  Writers (Background)   │       │  Conversion (MainActor)  │
    ├─────────────────────────┤       ├──────────────────────────┤
    │  FountainWriter         │       │  GuionDocumentModel      │
    │  • document(from:)      │       │  • from(screenplay)      │
    │  • body(from:)          │       │  • toScreenplay()        │
    │                         │       │                          │
    │  FDXWriter              │       │  Creates SwiftData       │
    │  • write(_:)            │       │  models for editing      │
    └─────────────────────────┘       └──────────────────────────┘
                                                    │
                                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    SWIFTDATA LAYER (MainActor)                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ GuionDocumentModel (@Model - mutable, for editing)              │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • var filename: String?                                          │  │
│  │ • var elements: [GuionElementModel]                              │  │
│  │ • var titlePage: [TitlePageEntryModel]                           │  │
│  │ • var suppressSceneNumbers: Bool                                 │  │
│  │                                                                   │  │
│  │ Conversion Methods:                                              │  │
│  │ • func toGuionParsedScreenplay() -> GuionParsedScreenplay        │  │
│  │ • static func from(_ screenplay: GuionParsedScreenplay)          │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│           │                                                              │
│           │ @Relationship (cascade delete)                              │
│           ├─────────────────────────────────────────┐                   │
│           │                                         │                   │
│           ▼                                         ▼                   │
│  ┌────────────────────────┐              ┌──────────────────────┐      │
│  │ GuionElementModel      │              │ TitlePageEntryModel  │      │
│  │ (@Model)               │              │ (@Model)             │      │
│  ├────────────────────────┤              ├──────────────────────┤      │
│  │ • var elementText      │              │ • var key: String    │      │
│  │ • var elementType      │              │ • var values: [Str]  │      │
│  │ • var sceneNumber      │              └──────────────────────┘      │
│  │ • location cache       │                                            │
│  └────────────────────────┘                                            │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ GuionFileDocument (@MainActor, FileDocument)                     │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • var documentModel: GuionDocumentModel                          │  │
│  │                                                                   │  │
│  │ FileDocument Protocol:                                           │  │
│  │ • init(configuration: ReadConfiguration)                         │  │
│  │ • func fileWrapper(configuration:) -> FileWrapper                │  │
│  │                                                                   │  │
│  │ Import/Export:                                                   │  │
│  │ • func importScreenplay(_ screenplay: GuionParsedScreenplay)     │  │
│  │ • func exportToTextPack() -> FileWrapper                         │  │
│  │                                                                   │  │
│  │ Manages TextPack bundle structure                                │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### Import Flow (User opens .fountain/.fdx/.highland file)

```
┌──────────────┐
│ User selects │
│   file       │
└──────┬───────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ GuionFileDocument.init(configuration:)  │ @MainActor
│ • Detects file type from extension     │
└──────┬──────────────────────────────────┘
       │
       │ Dispatch to background
       ▼
┌─────────────────────────────────────────┐
│ Parser (based on file type)             │ Background
│ • FountainParser.parse(file:)          │
│ • FDXParser.parse(file:)               │
│ • HighlandParser.parse(file:)          │
└──────┬──────────────────────────────────┘
       │
       │ Returns
       ▼
┌─────────────────────────────────────────┐
│ GuionParsedScreenplay (immutable)       │ Sendable
│ • Safe to pass back to main thread     │
└──────┬──────────────────────────────────┘
       │
       │ Back to MainActor
       ▼
┌─────────────────────────────────────────┐
│ GuionDocumentModel.from(screenplay)     │ @MainActor
│ • Creates SwiftData models              │
│ • Inserts into ModelContext             │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ User edits in SwiftUI                   │ @MainActor
│ • Live editing with SwiftData           │
└─────────────────────────────────────────┘
```

### Export Flow (User saves as .guion TextPack)

```
┌─────────────────────────────────────────┐
│ User saves document                     │ @MainActor
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ GuionFileDocument.fileWrapper(:)        │ @MainActor
│ • Accesses documentModel                │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ Convert to GuionParsedScreenplay        │ @MainActor
│ documentModel.toGuionParsedScreenplay() │
└──────┬──────────────────────────────────┘
       │
       │ Can dispatch to background
       ▼
┌─────────────────────────────────────────┐
│ Generate TextPack Contents              │ Background OK
│ • FountainWriter.document(from:)        │
│ • JSON serialization for metadata       │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ Create TextPack Bundle                  │
│ ├── info.json                           │
│ ├── screenplay.fountain                 │
│ └── Resources/                          │
│     ├── characters.json                 │
│     ├── locations.json                  │
│     ├── elements.json                   │
│     └── titlepage.json                  │
└──────┬──────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────┐
│ FileWrapper returned to system          │
└─────────────────────────────────────────┘
```

## File Format Specification

### .guion TextPack Structure

A `.guion` file is a TextPack bundle (directory with `.guion` extension) containing:

```
MyScript.guion/
├── info.json                    # Document metadata
├── screenplay.fountain          # Exported screenplay
└── Resources/                   # Additional data
    ├── characters.json          # Character information
    ├── locations.json           # Location data
    ├── elements.json            # All screenplay elements
    ├── titlepage.json           # Title page entries
    └── [other-files]            # Any imported assets
```

### info.json Format

```json
{
  "version": "1.0",
  "format": "guion-textpack",
  "created": "2025-01-15T10:30:00Z",
  "modified": "2025-01-15T14:20:00Z",
  "filename": "MyScript.guion",
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

### characters.json Format

```json
{
  "characters": [
    {
      "name": "JOHN DOE",
      "scenes": ["scene-uuid-1", "scene-uuid-2"],
      "dialogueLines": 42,
      "dialogueWords": 523,
      "firstAppearance": "scene-uuid-1"
    }
  ]
}
```

### locations.json Format

```json
{
  "locations": [
    {
      "id": "loc-uuid-1",
      "rawLocation": "INT. COFFEE SHOP - DAY",
      "lighting": "interior",
      "scene": "COFFEE SHOP",
      "timeOfDay": "DAY",
      "sceneIds": ["scene-uuid-1", "scene-uuid-3"]
    }
  ]
}
```

### elements.json Format

```json
{
  "elements": [
    {
      "id": "elem-uuid-1",
      "elementType": "Scene Heading",
      "elementText": "INT. COFFEE SHOP - DAY",
      "sceneNumber": "1",
      "sceneId": "scene-uuid-1",
      "isCentered": false,
      "isDualDialogue": false,
      "sectionDepth": 0
    }
  ]
}
```

### titlepage.json Format

```json
{
  "titlePage": [
    {
      "Title": ["My Great Screenplay"]
    },
    {
      "Author": ["John Doe"]
    },
    {
      "Draft date": ["January 15, 2025"]
    }
  ]
}
```

## Concurrency Model

### Thread Boundaries

```
┌─────────────────────────────────────────────────────────┐
│                    MAIN THREAD                          │
│                   (@MainActor)                          │
├─────────────────────────────────────────────────────────┤
│ • GuionDocumentModel (SwiftData)                        │
│ • GuionElementModel (SwiftData)                         │
│ • TitlePageEntryModel (SwiftData)                       │
│ • GuionFileDocument (FileDocument protocol)             │
│ • ModelContext operations                               │
│ • SwiftUI Views                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              BACKGROUND THREADS                         │
│              (Sendable types)                           │
├─────────────────────────────────────────────────────────┤
│ • GuionParsedScreenplay (immutable)                     │
│ • GuionElement (struct)                                 │
│ • FountainParser, FDXParser, HighlandParser             │
│ • FountainWriter, FDXWriter                             │
│ • All Analysis types (SceneLocation, etc.)              │
│ • JSON serialization/deserialization                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              TRANSITION POINTS                          │
│       (Sendable data crosses threads)                   │
├─────────────────────────────────────────────────────────┤
│ Background → Main:                                      │
│   GuionParsedScreenplay → GuionDocumentModel            │
│                                                          │
│ Main → Background:                                      │
│   GuionDocumentModel → GuionParsedScreenplay            │
└─────────────────────────────────────────────────────────┘
```

## Implementation Strategy

### Phase 1: Core Refactoring
1. Rename `FountainScript` → `GuionParsedScreenplay`
2. Make all properties `let` (immutable)
3. Remove mutable methods (`loadFile`, `loadString`)
4. Remove `@unchecked Sendable`, ensure proper Sendable conformance
5. Update all references in codebase

### Phase 2: Parser Renaming
1. Rename `FastFountainParser` → `FountainParser`
2. Rename `FDXDocumentParser` → `FDXParser`
3. Create `HighlandParser` (extract from current logic)
4. Make all parsers return `GuionParsedScreenplay`
5. Update all references

### Phase 3: SwiftData Conversion
1. Add `GuionDocumentModel.from(_ screenplay: GuionParsedScreenplay)`
2. Add `GuionDocumentModel.toGuionParsedScreenplay()`
3. Update import flow to use conversion
4. Test round-trip fidelity

### Phase 4: TextPack File Format
1. Define JSON schemas for all resource files
2. Implement TextPack creation in `GuionFileDocument`
3. Implement TextPack reading in `GuionFileDocument`
4. Add character/location extraction and JSON export
5. Update file I/O operations

### Phase 5: Testing & Documentation
1. Update all existing tests
2. Add new tests for TextPack format
3. Add tests for character/location JSON
4. Update API.md documentation
5. Update README with new architecture

## Benefits

1. **Thread Safety**: Clear separation between immutable (Sendable) and mutable (@MainActor) types
2. **No Data Races**: Immutable `GuionParsedScreenplay` eliminates race conditions
3. **Better Organization**: TextPack format keeps all related files together
4. **Portability**: JSON exports make data accessible to other tools
5. **Extensibility**: Easy to add new resource files to TextPack
6. **Clarity**: Parser names match their input format

## Migration Notes

### Breaking Changes
- `FountainScript` renamed to `GuionParsedScreenplay`
- All properties become immutable (`let`)
- No more `loadFile()` or `loadString()` methods
- Construction via init only
- Parser names changed

### Compatibility
- `.guion` files will have new TextPack structure
- Old `.guion` files (if any) will need migration
- Import of `.fountain`, `.fdx`, `.highland` unchanged
- Export to `.fountain`, `.fdx` unchanged

## Open Questions

1. **Backward Compatibility**: How to handle existing `.guion` files (if any exist)?
2. **Version Migration**: Strategy for updating TextPack format versions?
3. **File Size**: Is TextPack size acceptable with JSON exports?
4. **Compression**: Should we compress the TextPack bundle?
