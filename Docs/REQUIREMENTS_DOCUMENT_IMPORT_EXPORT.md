# SwiftGuion Document Import/Export Requirements

**Version:** 1.0
**Date:** October 9, 2025
**Status:** Draft

## Executive Summary

This document defines the requirements for opening, saving, importing, and exporting screenplay documents in the SwiftGuion application. The `.guion` file format serves as the native document format, while other screenplay formats (`.fountain`, `.fdx`, `.highland`) are treated as import sources.

---

## 1. File Format Specifications

### 1.1 Native Format: `.guion`

#### 1.1.1 Format Definition
- **File Extension:** `.guion`
- **UTType Identifier:** `com.swiftguion.screenplay`
- **UTType Conformance:** `public.data`
- **MIME Type:** `application/x-guion-screenplay`

#### 1.1.2 File Structure
The `.guion` file format SHALL contain native binary serialized SwiftData objects that can be directly consumed by a SwiftData `ModelContext`.

**Required Data Models:**
1. `GuionDocumentModel` - Root document container
2. `GuionElementModel` - Individual screenplay elements
3. `TitlePageEntryModel` - Title page metadata

**File Contents:**
- Binary serialized SwiftData model objects
- All relationships preserved (cascade deletes, inverse relationships)
- Complete screenplay structure including:
  - Parsed screenplay elements
  - Scene locations (cached and parsed)
  - Character information
  - Title page metadata
  - Document settings (e.g., `suppressSceneNumbers`)
  - Original raw content (for reference/backup)

#### 1.1.3 Data Integrity Requirements
- All SwiftData relationships MUST be preserved
- Scene location data MUST be cached in parsed form
- Character extraction data MUST be derivable on-demand
- Document MUST be self-contained (no external dependencies)

---

### 1.2 Import Formats

The following formats SHALL be supported for import only:

#### 1.2.1 Fountain Format
- **File Extension:** `.fountain`
- **UTType Identifier:** `com.fountain`
- **UTType Conformance:** `public.plain-text`
- **Import Method:** Parse via `FountainParser` to `GuionDocumentModel`

#### 1.2.2 Final Draft Format
- **File Extension:** `.fdx`
- **UTType Identifier:** `com.finaldraft.fdx`
- **UTType Conformance:** `public.xml`
- **Import Method:** Parse via `FDXDocumentParser` to `GuionDocumentModel`

#### 1.2.3 Highland Format
- **File Extension:** `.highland`
- **UTType Identifier:** `com.highland`
- **UTType Conformance:** `public.data` (ZIP archive)
- **Import Method:**
  1. Extract ZIP archive
  2. Locate `.textbundle` directory
  3. Extract Fountain content from:
     - `text.md` (Highland 2 standard) OR
     - `*.fountain` files OR
     - `*.md` files
  4. Parse extracted Fountain content to `GuionDocumentModel`

---

## 2. Document Lifecycle Workflows

### 2.1 Opening Documents

#### 2.1.1 Opening Native `.guion` Files

**User Action:** User selects Open from File menu or double-clicks a `.guion` file

**System Behavior:**
1. System SHALL load the binary SwiftData objects directly into the `ModelContext`
2. System SHALL deserialize all models and relationships
3. System SHALL verify data integrity
4. Document window SHALL display with the original filename
5. Document SHALL be marked as unmodified

**Expected State:**
- Document filename: `{original-name}.guion`
- Document modified state: `false`
- All SwiftData models loaded and ready

#### 2.1.2 Importing Screenplay Files (`.fountain`, `.fdx`, `.highland`)

**User Action:** User selects Open from File menu or double-clicks a supported screenplay file

**System Behavior:**
1. System SHALL detect file type by extension and UTType
2. System SHALL extract raw content:
   - For `.fountain`: Read UTF-8 text directly
   - For `.fdx`: Read XML content directly
   - For `.highland`: Extract ZIP, locate `.textbundle`, extract Fountain content
3. System SHALL parse content to intermediate `FountainScript` representation
4. System SHALL convert to SwiftData models (`GuionDocumentModel`, `GuionElementModel`, etc.)
5. System SHALL cache scene location data for all scene headings
6. System SHALL generate internal document identifier
7. Document window SHALL display

**Document Naming:**
- **Displayed Document Name:** `{imported-filename}.guion`
  - Example: `BigFish.fountain` → `BigFish.guion`
  - Example: `MyScript.fdx` → `MyScript.guion`
  - Example: `Screenplay.highland` → `Screenplay.guion`
- Document modified state: `true` (unsaved changes)

**Expected State:**
- Document is in-memory only (not yet saved to disk)
- Document name shows `.guion` extension
- Document marked as modified
- All content parsed and loaded into SwiftData models

---

### 2.2 First Save Workflow

#### 2.2.1 First Save After Import

**User Action:** User selects Save (⌘S) for the first time after importing a screenplay

**System Behavior:**
1. System SHALL present a "Save As" dialog
2. Dialog SHALL pre-populate filename with `{imported-filename}.guion`
   - Example: If imported `BigFish.fountain`, default save name is `BigFish.guion`
3. Dialog SHALL default to `.guion` file type
4. Dialog SHALL allow user to modify filename and location
5. On confirmation:
   - System SHALL serialize all SwiftData models to binary format
   - System SHALL write to selected location with `.guion` extension
   - System SHALL mark document as unmodified
   - System SHALL update document filename to saved name

**Dialog Configuration:**
- **Default Filename:** `{basename-of-imported-file}.guion`
- **Default Location:** Last used save location OR user's Documents folder
- **Allowed File Types:** `.guion` only for first save
- **Dialog Title:** "Save Screenplay As"

#### 2.2.2 First Save of New Document

**User Action:** User creates a new document and selects Save (⌘S)

**System Behavior:**
1. System SHALL present a "Save As" dialog
2. Dialog SHALL pre-populate filename with `Untitled.guion`
3. System SHALL follow same save process as 2.2.1

---

### 2.3 Subsequent Save Operations

#### 2.3.1 Save Existing Document

**User Action:** User selects Save (⌘S) on a previously saved `.guion` document

**System Behavior:**
1. System SHALL serialize current SwiftData models to binary format
2. System SHALL overwrite existing file at current location
3. System SHALL mark document as unmodified
4. NO dialog SHALL be presented (silent save)

#### 2.3.2 Save As

**User Action:** User selects Save As (⌘⇧S)

**System Behavior:**
1. System SHALL present "Save As" dialog
2. Dialog SHALL pre-populate with current document filename
3. Dialog SHALL allow selection of file format:
   - `.guion` (native format - recommended)
4. On confirmation, system SHALL follow save process

---

### 2.4 Export Operations

#### 2.4.1 Export to Fountain

**User Action:** User selects File → Export → Fountain Format

**System Behavior:**
1. System SHALL present "Export As" dialog
2. Dialog SHALL pre-populate filename with `{current-name}.fountain`
3. System SHALL convert `GuionDocumentModel` to `FountainScript`
4. System SHALL serialize to Fountain plain text format
5. System SHALL write to selected location
6. Original `.guion` document SHALL remain open and unmodified

**Export Method:**
```swift
let script = GuionDocumentParserSwiftData.toFountainScript(from: document)
let fountainText = script.stringFromDocument()
```

#### 2.4.2 Export to Final Draft

**User Action:** User selects File → Export → Final Draft Format

**System Behavior:**
1. System SHALL present "Export As" dialog
2. Dialog SHALL pre-populate filename with `{current-name}.fdx`
3. System SHALL convert `GuionDocumentModel` to FDX XML format
4. System SHALL write to selected location
5. Original `.guion` document SHALL remain open and unmodified

**Export Method:**
```swift
let data = GuionDocumentParserSwiftData.toFDXData(from: document)
```

---

## 3. File Format Implementation Requirements

### 3.1 `.guion` File Format Technical Specification

#### 3.1.1 Serialization Format
The `.guion` file SHALL use SwiftData's native binary serialization format.

**Serialization Requirements:**
- All `@Model` decorated classes MUST be serializable
- All relationships MUST preserve delete rules and inverse mappings
- Optional properties MUST handle `nil` values correctly
- Array properties MUST preserve order

#### 3.1.2 Model Schema

**GuionDocumentModel Structure:**
```swift
@Model
public final class GuionDocumentModel {
    var filename: String?
    var rawContent: String?  // Original imported content (backup)
    var suppressSceneNumbers: Bool

    @Relationship(deleteRule: .cascade, inverse: \GuionElementModel.document)
    var elements: [GuionElementModel]

    @Relationship(deleteRule: .cascade, inverse: \TitlePageEntryModel.document)
    var titlePage: [TitlePageEntryModel]
}
```

**GuionElementModel Structure:**
```swift
@Model
public final class GuionElementModel {
    var elementText: String
    var elementType: String
    var isCentered: Bool
    var isDualDialogue: Bool
    var sceneNumber: String?
    var sectionDepth: Int
    var sceneId: String?
    var summary: String?

    // Cached scene location data
    var locationLighting: String?
    var locationScene: String?
    var locationSetup: String?
    var locationTimeOfDay: String?
    var locationModifiers: [String]?

    var document: GuionDocumentModel?
}
```

**TitlePageEntryModel Structure:**
```swift
@Model
public final class TitlePageEntryModel {
    var key: String
    var values: [String]
    var document: GuionDocumentModel?
}
```

#### 3.1.3 File Reading Implementation

**Reading `.guion` Files:**
```swift
init(configuration: ReadConfiguration) throws {
    guard configuration.contentType == .guionDocument else {
        // Handle as import (see Section 3.2)
    }

    // Deserialize SwiftData models directly
    let data = configuration.file.regularFileContents
    self.document = try SwiftDataDecoder.decode(GuionDocumentModel.self, from: data)
}
```

#### 3.1.4 File Writing Implementation

**Writing `.guion` Files:**
```swift
func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    guard configuration.contentType == .guionDocument else {
        // Handle as export (see Section 3.3)
    }

    let data = try SwiftDataEncoder.encode(document)
    return FileWrapper(regularFileWithContents: data)
}
```

---

### 3.2 Import Processing Requirements

#### 3.2.1 Import Pipeline

All imported formats SHALL follow this processing pipeline:

1. **Content Extraction**
   - Extract raw text/XML from file
   - For Highland: Extract from ZIP → `.textbundle` → Fountain content

2. **Format Detection**
   - Detect format by UTType and file extension
   - Route to appropriate parser

3. **Parsing**
   - Parse to intermediate `FountainScript` representation
   - Extract all screenplay elements, title page, metadata

4. **SwiftData Conversion**
   - Convert `FountainScript` elements to `GuionElementModel`
   - Convert title page to `TitlePageEntryModel`
   - Create `GuionDocumentModel` container

5. **Location Caching**
   - Parse and cache all scene heading locations
   - Store in `GuionElementModel` location properties

6. **Document Preparation**
   - Set filename to `{original-name}.guion`
   - Store raw content for backup
   - Insert into `ModelContext`
   - Mark as modified

#### 3.2.2 Import Method Implementation

**Current Implementation Reference:**
```swift
@MainActor
static func parseContent(
    rawContent: String,
    filename: String?,
    contentType: UTType,
    modelContext: ModelContext
) async throws -> GuionDocumentModel {
    // Determine file extension for parsing
    let ext = (contentType == .highlandDocument) ? "fountain" : fileExtension(for: contentType)

    // Write to temp file for parser
    let tempURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("temp_screenplay.\(ext)")
    try rawContent.write(to: tempURL, atomically: true, encoding: .utf8)

    defer {
        try? FileManager.default.removeItem(at: tempURL)
    }

    // Parse using unified parser
    let parsedDocument = try await GuionDocumentParserSwiftData.loadAndParse(
        from: tempURL,
        in: modelContext,
        generateSummaries: false
    )

    // Store original content
    parsedDocument.rawContent = rawContent
    parsedDocument.filename = filename

    return parsedDocument
}
```

---

### 3.3 Export Processing Requirements

#### 3.3.1 Export to Fountain

**Conversion Process:**
1. Convert `GuionDocumentModel` to `FountainScript`
2. Serialize `FountainScript` to plain text
3. Write to `.fountain` file

**Implementation:**
```swift
let script = GuionDocumentParserSwiftData.toFountainScript(from: document)
let fountainText = script.stringFromDocument()
let data = Data(fountainText.utf8)
```

#### 3.3.2 Export to FDX

**Conversion Process:**
1. Convert `GuionDocumentModel` to FDX XML structure
2. Serialize to XML data
3. Write to `.fdx` file

**Implementation:**
```swift
let data = GuionDocumentParserSwiftData.toFDXData(from: document)
```

---

## 4. User Interface Requirements

### 4.1 File Open Dialog

**Native `.guion` Files:**
- Dialog title: "Open Screenplay"
- Allowed types: `.guion`, `.fountain`, `.fdx`, `.highland`
- Default filter: All supported types
- Action button: "Open"

**Behavior:**
- Double-clicking a file SHALL open immediately
- Selecting a file and clicking "Open" SHALL open immediately
- Canceling SHALL return to previous state

### 4.2 Save Dialog (First Save)

**Dialog Configuration:**
- Dialog title: "Save Screenplay As"
- Default filename: `{imported-filename}.guion` OR `Untitled.guion`
- Default location: Last save location OR Documents folder
- Allowed file type: `.guion` only
- Action button: "Save"

**Validation:**
- Filename MUST not be empty
- Filename MUST end with `.guion` extension (auto-append if missing)
- Location MUST be writable

### 4.3 Export Dialog

**Dialog Configuration:**
- Dialog title: "Export Screenplay As"
- Default filename: `{current-name}.{export-extension}`
- Allowed file types:
  - Fountain Format (`.fountain`)
  - Final Draft Format (`.fdx`)
- File type selector: Dropdown or radio buttons
- Action button: "Export"

### 4.4 Document Window Title

**Display Format:**
- **Unmodified:** `{filename}.guion`
- **Modified:** `{filename}.guion` (edited) OR with bullet indicator
- **Imported (unsaved):** `{filename}.guion` (unsaved)

---

## 5. Data Preservation Requirements

### 5.1 Lossless Round-Trip

**Requirement:** Opening a `.guion` file and saving it again SHALL result in byte-identical output (excluding system metadata like timestamps).

**Test Criteria:**
```swift
let original = loadGuionFile("test.guion")
let document = parseGuionFile(original)
let resaved = saveGuionFile(document)
assert(original == resaved)
```

### 5.2 Import Fidelity

**Requirement:** Importing a screenplay format SHALL preserve all supported screenplay elements:
- Scene headings (with parsed locations)
- Action
- Character names
- Dialogue
- Parentheticals
- Transitions
- Title page entries
- Scene numbers
- Section headers
- Notes/boneyard (if supported by format)

### 5.3 Export Fidelity

**Requirement:** Exporting to Fountain or FDX SHALL produce valid, standard-compliant output that can be opened in other screenplay applications.

**Validation:**
- Exported Fountain files MUST open in Highland, Slugline, etc.
- Exported FDX files MUST open in Final Draft

---

## 6. Error Handling Requirements

### 6.1 Import Errors

**Scenario:** Corrupted or invalid screenplay file

**Behavior:**
1. System SHALL present error alert: "Unable to import screenplay"
2. Alert SHALL include specific error message
3. Alert SHALL offer option to view raw content (for debugging)
4. System SHALL NOT create a document
5. System SHALL log error details

### 6.2 Save Errors

**Scenario:** Unable to write to disk (permissions, disk full, etc.)

**Behavior:**
1. System SHALL present error alert: "Unable to save screenplay"
2. Alert SHALL include specific error message
3. Alert SHALL offer option to save to alternate location
4. Document SHALL remain open and modified
5. User's work SHALL NOT be lost

### 6.3 Data Corruption Detection

**Scenario:** Opening a corrupted `.guion` file

**Behavior:**
1. System SHALL detect deserialization failure
2. System SHALL present error alert: "This document is corrupted"
3. Alert SHALL offer option to recover from raw content (if available)
4. System SHALL log error details for support

---

## 7. Performance Requirements

### 7.1 File Size Limits

**Native `.guion` Files:**
- SHALL support documents up to 100MB
- SHALL load documents under 10MB in < 1 second
- SHALL load documents 10-100MB in < 5 seconds

**Import Files:**
- SHALL support import files up to 50MB
- SHALL parse files under 5MB in < 2 seconds

### 7.2 Memory Usage

**Requirement:** Documents loaded in memory SHALL NOT exceed 2x the file size on disk.

---

## 8. Compatibility Requirements

### 8.1 Platform Support

**Required Platforms:**
- macOS 14.0+
- iOS 17.0+ (if applicable)

### 8.2 Format Versions

**`.guion` Format:**
- Version: 1.0 (initial release)
- Future versions SHALL maintain backward compatibility
- System SHALL detect format version on open
- System SHALL upgrade older formats transparently

### 8.3 Third-Party Format Support

**Fountain:**
- Specification version: 1.1
- SHALL support all standard Fountain syntax

**FDX:**
- Final Draft version: 11/12 compatible
- SHALL support FDX 6.0+ XML schema

**Highland:**
- Highland 2.x format
- `.textbundle` structure
- Fountain content extraction

---

## 9. Security Requirements

### 9.1 Sandbox Compliance

**Requirement:** All file operations SHALL comply with macOS App Sandbox requirements.

**Implementation:**
- Use `DocumentGroup` for document management
- Request file access permissions via security-scoped bookmarks
- Handle temporary files within app's sandbox

### 9.2 Data Privacy

**Requirement:** No screenplay content SHALL be transmitted over network without explicit user consent.

**Implementation:**
- All parsing and processing happens locally
- No analytics on screenplay content
- No cloud sync without user opt-in

---

## 10. Testing Requirements

### 10.1 Unit Tests

**Required Test Coverage:**
- [ ] GuionDocumentModel serialization/deserialization
- [ ] Fountain import parsing
- [ ] FDX import parsing
- [ ] Highland ZIP extraction and parsing
- [ ] Export to Fountain format
- [ ] Export to FDX format
- [ ] Scene location caching
- [ ] Character extraction

### 10.2 Integration Tests

**Required Test Coverage:**
- [ ] Open `.guion` file → modify → save → reopen
- [ ] Import `.fountain` → save as `.guion` → reopen
- [ ] Import `.fdx` → save as `.guion` → reopen
- [ ] Import `.highland` → save as `.guion` → reopen
- [ ] Open `.guion` → export to Fountain → verify output
- [ ] Open `.guion` → export to FDX → verify output

### 10.3 UI Tests

**Required Test Coverage:**
- [ ] Open dialog shows correct file types
- [ ] Save As dialog pre-populates filename correctly
- [ ] Document window title updates correctly
- [ ] Modified indicator appears/disappears correctly
- [ ] Export dialog offers correct format options

---

## 11. Future Enhancements

### 11.1 Planned Features (Not in v1.0)

- **Auto-save:** Automatic saving of `.guion` files
- **Versions:** Integration with macOS Versions for document history
- **iCloud sync:** Sync `.guion` files across devices
- **Package format:** `.guion` as a package/bundle with attachments
- **Compression:** Optional compression for `.guion` files
- **Export templates:** Customizable export settings

---

## 12. Acceptance Criteria

### 12.1 Definition of Done

This feature SHALL be considered complete when:

1. ✅ User can open `.guion` files natively
2. ✅ User can import `.fountain`, `.fdx`, and `.highland` files
3. ✅ Imported files are automatically named with `.guion` extension
4. ✅ First save presents Save As dialog with correct default filename
5. ✅ `.guion` format preserves all SwiftData models and relationships
6. ✅ User can export to Fountain format
7. ✅ User can export to FDX format
8. ✅ All unit tests pass
9. ✅ All integration tests pass
10. ✅ All UI tests pass
11. ✅ Performance requirements are met
12. ✅ Error handling is robust
13. ✅ Documentation is complete

---

## Appendix A: File Extension Summary

| Format | Extension | UTType Identifier | Purpose | Read | Write |
|--------|-----------|-------------------|---------|------|-------|
| Guion | `.guion` | `com.swiftguion.screenplay` | Native format | ✅ | ✅ |
| Fountain | `.fountain` | `com.fountain` | Import/Export | ✅ | ✅ (export) |
| Final Draft | `.fdx` | `com.finaldraft.fdx` | Import/Export | ✅ | ✅ (export) |
| Highland | `.highland` | `com.highland` | Import only | ✅ | ❌ |

---

## Appendix B: Workflow Examples

### Example 1: Import and Save Fountain File

```
1. User: File → Open → Select "BigFish.fountain"
2. System: Parses fountain content
3. System: Creates GuionDocumentModel in memory
4. System: Shows document window titled "BigFish.guion (unsaved)"
5. User: ⌘S (Save)
6. System: Shows Save As dialog with "BigFish.guion" pre-filled
7. User: Confirms save location
8. System: Writes binary .guion file to disk
9. System: Updates window title to "BigFish.guion"
```

### Example 2: Open Existing `.guion` File

```
1. User: Double-clicks "MyScript.guion" in Finder
2. System: Deserializes SwiftData models from file
3. System: Loads all elements and relationships
4. System: Shows document window titled "MyScript.guion"
5. User: Makes edits
6. System: Updates window title to "MyScript.guion (edited)"
7. User: ⌘S (Save)
8. System: Silently overwrites existing file
9. System: Updates window title to "MyScript.guion"
```

### Example 3: Export to Fountain

```
1. User: Has "MyScript.guion" open
2. User: File → Export → Fountain Format
3. System: Shows Export As dialog with "MyScript.fountain" pre-filled
4. User: Confirms export location
5. System: Converts GuionDocumentModel to FountainScript
6. System: Writes Fountain plain text to disk
7. System: Original "MyScript.guion" remains open and unchanged
```

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-09 | Initial Draft | Complete requirements specification |

---

**Document Status:** Draft
**Next Review Date:** TBD
**Approvers:** TBD
