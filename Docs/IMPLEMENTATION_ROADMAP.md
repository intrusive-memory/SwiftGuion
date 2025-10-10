# SwiftGuion .guion Format Implementation Roadmap

**Version:** 1.0
**Date:** October 9, 2025
**Status:** Planning

---

## Current State Analysis

### ✅ What's Already Implemented

1. **Import Pipeline** (90% complete)
   - ✅ Fountain format parsing (`FountainScript`)
   - ✅ FDX format parsing (`FDXDocumentParser`)
   - ✅ Highland format extraction (ZIP → `.textbundle` → Fountain)
   - ✅ SwiftData model conversion (`GuionDocumentParserSwiftData.parse()`)
   - ✅ Scene location caching in `GuionElementModel`
   - ✅ Character extraction

2. **Export Functionality** (80% complete)
   - ✅ Fountain export (`GuionDocumentParserSwiftData.toFountainScript()`)
   - ✅ FDX export (`GuionDocumentParserSwiftData.toFDXData()`)
   - ⚠️ Currently exports happen via `fileWrapper()` in save dialog

3. **SwiftData Models** (100% complete)
   - ✅ `GuionDocumentModel`
   - ✅ `GuionElementModel` (with location caching)
   - ✅ `TitlePageEntryModel`
   - ✅ All relationships defined

4. **UI Components** (90% complete)
   - ✅ `DocumentGroup` setup in `GuionDocumentAppApp.swift`
   - ✅ `GuionDocumentConfiguration` (FileDocument implementation)
   - ✅ `ContentView` with async parsing
   - ✅ Scene browser, character inspector, locations window

### ❌ What's Missing (Gaps to Fill)

1. **`.guion` File Format** (0% complete)
   - ❌ Binary serialization format not defined
   - ❌ SwiftData model encoding/decoding for file storage
   - ❌ File read/write implementation in `GuionDocumentConfiguration`

2. **Document Naming Workflow** (0% complete)
   - ❌ Automatic `.guion` extension on import
   - ❌ "Save As" dialog on first save
   - ❌ Filename pre-population logic

3. **File Type Differentiation** (30% complete)
   - ✅ UTType declarations exist
   - ⚠️ Import vs. native open logic needs separation
   - ❌ Export menu commands (currently mixed with save)

4. **Testing Infrastructure** (20% complete)
   - ✅ Basic parsing tests exist
   - ❌ No round-trip serialization tests
   - ❌ No document lifecycle tests
   - ❌ No UI workflow tests

---

## Phased Implementation Plan

Each phase has **clear acceptance criteria** and **test gates** that must pass before moving to the next phase.

---

## Phase 1: `.guion` Binary Format Foundation
**Duration:** 2-3 days
**Goal:** Establish the `.guion` file format with serialization/deserialization

### Deliverables

#### 1.1 Define Binary Serialization Strategy
- [ ] Research SwiftData file persistence options:
  - Option A: Use `ModelContainer` with file-based storage
  - Option B: Use `Codable` encoding of SwiftData models
  - Option C: Custom binary format with Protocol Buffers/MessagePack
- [ ] **Decision document**: Choose serialization approach (recommend: Option A with ModelContainer)

#### 1.2 Implement `.guion` File Reader
**File:** `Sources/SwiftGuion/GuionDocumentModel.swift` (extension)

```swift
extension GuionDocumentModel {
    /// Load a .guion file from disk
    static func load(from url: URL) throws -> GuionDocumentModel {
        // Deserialize SwiftData models from binary file
    }
}
```

#### 1.3 Implement `.guion` File Writer
**File:** `Sources/SwiftGuion/GuionDocumentModel.swift` (extension)

```swift
extension GuionDocumentModel {
    /// Save to .guion file format
    func save(to url: URL) throws {
        // Serialize SwiftData models to binary file
    }
}
```

#### 1.4 Update `GuionDocumentConfiguration`
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocument.swift`

- [ ] Update `init(configuration:)` to detect `.guion` vs. import formats
- [ ] Update `fileWrapper(configuration:)` to write `.guion` binary format

### Test Gate 1: Binary Serialization Tests

**File:** `Tests/SwiftGuionTests/GuionSerializationTests.swift` (NEW)

```swift
import XCTest
@testable import SwiftGuion

final class GuionSerializationTests: XCTestCase {

    // GATE 1.1: Round-trip serialization
    func testRoundTripSerialization() async throws {
        let modelContext = createTestModelContext()

        // Create a document with test data
        let original = GuionDocumentModel(filename: "test.guion")
        original.elements.append(GuionElementModel(
            elementText: "INT. TEST LOCATION - DAY",
            elementType: "Scene Heading"
        ))
        modelContext.insert(original)

        // Save to file
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.guion")
        try original.save(to: tempURL)

        // Load from file
        let loaded = try GuionDocumentModel.load(from: tempURL)

        // Verify data integrity
        XCTAssertEqual(loaded.filename, original.filename)
        XCTAssertEqual(loaded.elements.count, original.elements.count)
        XCTAssertEqual(loaded.elements[0].elementText, original.elements[0].elementText)
        XCTAssertEqual(loaded.elements[0].elementType, original.elements[0].elementType)
    }

    // GATE 1.2: Preserve relationships
    func testPreserveRelationships() async throws {
        // Verify cascade deletes work
        // Verify inverse relationships maintained
    }

    // GATE 1.3: Preserve scene locations
    func testPreserveSceneLocations() async throws {
        // Verify cached location data survives round-trip
    }

    // GATE 1.4: Handle large documents
    func testLargeDocumentPerformance() async throws {
        // Test with 1000+ elements
        // Assert load time < 1 second
    }
}
```

**Acceptance Criteria:**
- ✅ All 4 test cases pass
- ✅ Round-trip produces byte-identical SwiftData models
- ✅ Performance: < 1s for documents with 1000 elements
- ✅ No memory leaks detected

---

## Phase 2: Import Format Detection & Naming
**Duration:** 2 days
**Goal:** Separate native `.guion` opening from import workflows

### Deliverables

#### 2.1 Add Format Detection in `GuionDocumentConfiguration`
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocument.swift`

```swift
init(configuration: ReadConfiguration) throws {
    // Detect if native .guion or import format
    if configuration.contentType == .guionDocument {
        // Load binary .guion file directly
        self.document = try GuionDocumentModel.load(from: fileURL)
    } else {
        // Import workflow (existing code)
        // Extract content, parse, set filename to {name}.guion
    }
}
```

#### 2.2 Implement Filename Transformation
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocument.swift`

```swift
private func transformFilename(_ originalFilename: String?, for import: Bool) -> String? {
    guard let original = originalFilename else { return nil }

    if `import` {
        // Strip original extension, add .guion
        let baseName = (original as NSString).deletingPathExtension
        return "\(baseName).guion"
    }

    return original
}
```

#### 2.3 Update Document State Tracking
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocument.swift`

- [ ] Track whether document is "imported but unsaved"
- [ ] Set document as modified after import
- [ ] Store original import filename for reference

### Test Gate 2: Import Detection Tests

**File:** `Tests/SwiftGuionTests/DocumentImportTests.swift` (NEW)

```swift
final class DocumentImportTests: XCTestCase {

    // GATE 2.1: Open native .guion file
    func testOpenNativeGuionFile() throws {
        // Save a .guion file
        // Open it via GuionDocumentConfiguration
        // Verify: Elements loaded, filename unchanged, not modified
    }

    // GATE 2.2: Import .fountain file
    func testImportFountainFile() throws {
        // Open BigFish.fountain
        // Verify: filename becomes "BigFish.guion"
        // Verify: document marked as modified
        // Verify: elements parsed correctly
    }

    // GATE 2.3: Import .fdx file
    func testImportFDXFile() throws {
        // Similar to fountain test
    }

    // GATE 2.4: Import .highland file
    func testImportHighlandFile() throws {
        // Similar to fountain test
    }

    // GATE 2.5: Filename transformation
    func testFilenameTransformation() {
        XCTAssertEqual(transformFilename("script.fountain", for: true), "script.guion")
        XCTAssertEqual(transformFilename("test.fdx", for: true), "test.guion")
        XCTAssertEqual(transformFilename("movie.highland", for: true), "movie.guion")
        XCTAssertEqual(transformFilename("already.guion", for: false), "already.guion")
    }
}
```

**Acceptance Criteria:**
- ✅ All 5 test cases pass
- ✅ Native `.guion` files open without re-parsing
- ✅ Import formats automatically renamed to `.guion`
- ✅ Document modified state correctly set

---

## Phase 3: Save Workflow & Dialog Logic
**Duration:** 3 days
**Goal:** Implement "Save As" on first save with correct filename pre-population

### Deliverables

#### 3.1 Track Save State in Document
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocument.swift`

```swift
struct GuionDocumentConfiguration: FileDocument {
    var document: GuionDocumentModel

    // NEW: Track if this document has been saved
    private var hasBeenSaved: Bool = false
    private var originalImportFilename: String?
}
```

#### 3.2 Implement Smart Save Logic
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocument.swift`

```swift
func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    // Determine if this is first save
    let isFirstSave = !hasBeenSaved

    if configuration.contentType == .guionDocument {
        // Native save
        let data = try encodeGuionDocument(document)
        hasBeenSaved = true
        return FileWrapper(regularFileWithContents: data)
    } else {
        // Export (Fountain, FDX)
        return try exportToFormat(configuration.contentType)
    }
}
```

#### 3.3 Add Save Dialog Configuration
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocumentAppApp.swift`

- [ ] Configure `DocumentGroup` to use custom save panel
- [ ] Pre-populate filename based on `document.filename`
- [ ] Force `.guion` extension on first save

**Note:** SwiftUI's `DocumentGroup` handles save dialogs automatically. We may need to use `fileExporter` modifier or custom commands for more control.

#### 3.4 Add Export Menu Commands
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocumentAppApp.swift` (NEW)

```swift
.commands {
    CommandGroup(after: .saveItem) {
        Button("Export as Fountain...") {
            // Trigger export dialog
        }
        .keyboardShortcut("e", modifiers: [.command, .shift])

        Button("Export as Final Draft...") {
            // Trigger export dialog
        }
    }
}
```

### Test Gate 3: Save Workflow Tests

**File:** `Tests/SwiftGuionTests/DocumentSaveTests.swift` (NEW)

```swift
final class DocumentSaveTests: XCTestCase {

    // GATE 3.1: First save after import
    func testFirstSaveAfterImport() throws {
        // Import BigFish.fountain
        // Trigger save
        // Verify: Save dialog appears with "BigFish.guion"
        // Verify: File saved as .guion format
        // Verify: Document no longer modified
    }

    // GATE 3.2: Subsequent saves
    func testSubsequentSaves() throws {
        // Open existing .guion file
        // Modify document
        // Save
        // Verify: No dialog (silent save)
        // Verify: File overwritten
    }

    // GATE 3.3: Save As always shows dialog
    func testSaveAs() throws {
        // Open existing .guion file
        // Trigger "Save As"
        // Verify: Dialog appears with current filename
    }
}
```

**Note:** These are integration tests that may require UI testing framework.

**Acceptance Criteria:**
- ✅ First save after import shows "Save As" dialog
- ✅ Filename pre-populated correctly
- ✅ Subsequent saves are silent
- ✅ Save As always shows dialog

---

## Phase 4: Export Functionality Separation
**Duration:** 2 days
**Goal:** Separate export from save, add export menu commands

### Deliverables

#### 4.1 Add Export State Management
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/ContentView.swift`

```swift
@State private var showExportDialog = false
@State private var exportFormat: ExportFormat?

enum ExportFormat {
    case fountain
    case fdx
}
```

#### 4.2 Implement Export Dialog
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/ContentView.swift`

```swift
.fileExporter(
    isPresented: $showExportDialog,
    document: exportDocument,
    contentType: exportFormat == .fountain ? .fountainDocument : .fdxDocument,
    defaultFilename: defaultExportFilename()
) { result in
    // Handle export result
}
```

#### 4.3 Add Export Menu Commands
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocumentAppApp.swift`

```swift
.commands {
    CommandGroup(after: .saveItem) {
        Divider()

        Button("Export as Fountain...") {
            NotificationCenter.default.post(name: .exportAsFountain, object: nil)
        }
        .keyboardShortcut("E", modifiers: [.command, .shift])

        Button("Export as Final Draft...") {
            NotificationCenter.default.post(name: .exportAsFDX, object: nil)
        }
    }
}
```

#### 4.4 Create Export Wrapper Types
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/ExportDocument.swift` (NEW)

```swift
struct FountainExportDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.fountainDocument] }
    let sourceDocument: GuionDocumentModel

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let script = GuionDocumentParserSwiftData.toFountainScript(from: sourceDocument)
        let text = script.stringFromDocument()
        return FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}
```

### Test Gate 4: Export Tests

**File:** `Tests/SwiftGuionTests/DocumentExportTests.swift` (NEW)

```swift
final class DocumentExportTests: XCTestCase {

    // GATE 4.1: Export to Fountain
    func testExportToFountain() throws {
        // Open .guion file
        // Export to Fountain
        // Verify: Output is valid Fountain
        // Verify: Original .guion unchanged
    }

    // GATE 4.2: Export to FDX
    func testExportToFDX() throws {
        // Similar to Fountain test
    }

    // GATE 4.3: Export filename defaults
    func testExportFilenameDefaults() {
        // Open "MyScript.guion"
        // Trigger Fountain export
        // Verify: Default filename is "MyScript.fountain"
    }

    // GATE 4.4: Round-trip import/export fidelity
    func testImportExportFidelity() throws {
        // Import BigFish.fountain
        // Save as .guion
        // Export as .fountain
        // Compare with original
        // Assert: All elements preserved
    }
}
```

**Acceptance Criteria:**
- ✅ Export menu commands work
- ✅ Export dialog pre-populates correct filename
- ✅ Export doesn't modify original document
- ✅ Round-trip preserves screenplay content

---

## Phase 5: Error Handling & Edge Cases
**Duration:** 2 days
**Goal:** Robust error handling for all failure scenarios

### Deliverables

#### 5.1 Add Error Types
**File:** `Sources/SwiftGuion/GuionDocumentError.swift` (NEW)

```swift
public enum GuionDocumentError: LocalizedError {
    case corruptedFile(String)
    case unsupportedVersion(Int)
    case deserializationFailed(Error)
    case insufficientPermissions
    case diskFull

    public var errorDescription: String? {
        switch self {
        case .corruptedFile(let filename):
            return "The document '\(filename)' is corrupted and cannot be opened."
        // ... other cases
        }
    }

    public var recoverySuggestion: String? {
        // Provide helpful recovery suggestions
    }
}
```

#### 5.2 Implement Error Recovery
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocument.swift`

```swift
init(configuration: ReadConfiguration) throws {
    do {
        // Attempt to load
    } catch let error as GuionDocumentError {
        // Present user-friendly error
        // Offer recovery options (e.g., load from rawContent backup)
        throw error
    }
}
```

#### 5.3 Add Corruption Detection
**File:** `Sources/SwiftGuion/GuionDocumentModel.swift`

```swift
extension GuionDocumentModel {
    func validate() throws {
        // Check for corrupt relationships
        // Verify required fields present
        // Validate scene location caching
    }
}
```

#### 5.4 Implement Auto-Recovery
**File:** `Examples/GuionDocumentApp/GuionDocumentApp/GuionDocument.swift`

```swift
private func attemptRecovery(from error: Error) -> GuionDocumentModel? {
    // Try to recover from rawContent if available
    // Parse as Fountain fallback
}
```

### Test Gate 5: Error Handling Tests

**File:** `Tests/SwiftGuionTests/ErrorHandlingTests.swift` (NEW)

```swift
final class ErrorHandlingTests: XCTestCase {

    // GATE 5.1: Corrupted file detection
    func testCorruptedFileDetection() throws {
        // Create corrupted .guion file
        // Attempt to open
        // Verify: Error thrown with helpful message
    }

    // GATE 5.2: Recovery from rawContent
    func testRecoveryFromRawContent() throws {
        // Create .guion with corrupt models but valid rawContent
        // Open file
        // Verify: Recovers by re-parsing rawContent
    }

    // GATE 5.3: Permission errors
    func testPermissionErrors() throws {
        // Create read-only .guion file
        // Attempt to save
        // Verify: Proper error message
        // Verify: Offers "Save As" alternative
    }

    // GATE 5.4: Disk full errors
    func testDiskFullErrors() throws {
        // Mock disk full condition
        // Attempt save
        // Verify: Document not lost
        // Verify: User notified
    }
}
```

**Acceptance Criteria:**
- ✅ All error scenarios handled gracefully
- ✅ User-friendly error messages
- ✅ Recovery options offered where possible
- ✅ No data loss on error

---

## Phase 6: Performance Optimization & Testing
**Duration:** 2 days
**Goal:** Meet performance requirements, comprehensive test coverage

### Deliverables

#### 6.1 Performance Profiling
- [ ] Profile file loading with Instruments
- [ ] Optimize SwiftData query performance
- [ ] Add lazy loading for large documents

#### 6.2 Memory Optimization
- [ ] Audit memory usage with large documents
- [ ] Implement streaming for huge files (>100MB)
- [ ] Add memory pressure handling

#### 6.3 Comprehensive Test Suite
**File:** `Tests/SwiftGuionTests/IntegrationTests.swift` (NEW)

```swift
final class IntegrationTests: XCTestCase {

    // GATE 6.1: Full workflow test
    func testCompleteWorkflow() async throws {
        // Import BigFish.fountain
        // Verify elements parsed
        // Save as BigFish.guion
        // Close document
        // Reopen BigFish.guion
        // Verify elements match
        // Export as BigFish-export.fountain
        // Compare with original
    }

    // GATE 6.2: Large document performance
    func testLargeDocumentPerformance() async throws {
        // Create document with 5000 elements
        // Measure save time
        // Measure load time
        // Assert: < 5 seconds for both
    }

    // GATE 6.3: Concurrent document handling
    func testConcurrentDocuments() async throws {
        // Open 5 documents simultaneously
        // Verify: No conflicts
        // Verify: Each maintains separate state
    }
}
```

#### 6.4 UI Testing
**File:** `Examples/GuionDocumentApp/GuionDocumentAppUITests/DocumentWorkflowUITests.swift`

```swift
final class DocumentWorkflowUITests: XCTestCase {

    func testImportAndSaveWorkflow() throws {
        let app = XCUIApplication()
        app.launch()

        // UI test: File > Open > Select fountain file
        // UI test: File > Save (verify dialog appears)
        // UI test: Enter filename, save
        // UI test: Verify window title updated
    }
}
```

### Test Gate 6: Performance & Integration Tests

**Acceptance Criteria:**
- ✅ Load time < 1s for files under 10MB
- ✅ Load time < 5s for files 10-100MB
- ✅ Memory usage < 2x file size
- ✅ All integration tests pass
- ✅ UI tests pass on macOS

---

## Phase 7: Documentation & Polish
**Duration:** 1-2 days
**Goal:** Complete documentation, user-facing polish

### Deliverables

#### 7.1 API Documentation
- [ ] Add DocC documentation to all public APIs
- [ ] Create tutorials for common workflows
- [ ] Document `.guion` file format specification

#### 7.2 User-Facing Documentation
**File:** `Docs/USER_GUIDE.md` (NEW)

- [ ] How to import screenplays
- [ ] Working with .guion files
- [ ] Exporting to other formats
- [ ] Troubleshooting guide

#### 7.3 Migration Guide
**File:** `Docs/MIGRATION_GUIDE.md` (NEW)

- [ ] Guide for users with existing Fountain/FDX files
- [ ] Converting to .guion format
- [ ] Batch conversion script

#### 7.4 UI Polish
- [ ] Add progress indicators for long operations
- [ ] Improve error alert presentation
- [ ] Add tooltips and help buttons
- [ ] Ensure accessibility compliance

### Test Gate 7: Documentation Review

**Acceptance Criteria:**
- ✅ All public APIs documented
- ✅ User guide complete
- ✅ Migration guide tested
- ✅ UI polish complete
- ✅ Accessibility audit passed

---

## Overall Timeline

| Phase | Duration | Dependencies | Milestone |
|-------|----------|--------------|-----------|
| **Phase 1** | 2-3 days | None | `.guion` format working |
| **Phase 2** | 2 days | Phase 1 | Import detection working |
| **Phase 3** | 3 days | Phase 2 | Save workflows complete |
| **Phase 4** | 2 days | Phase 3 | Export separated |
| **Phase 5** | 2 days | Phase 4 | Error handling robust |
| **Phase 6** | 2 days | Phase 5 | Performance validated |
| **Phase 7** | 1-2 days | Phase 6 | Docs complete |

**Total Estimated Duration:** 14-18 days (2.5-3.5 weeks)

---

## Testing Strategy Summary

### Unit Tests (Per Phase)
- Each phase has dedicated unit tests
- Tests must pass before moving to next phase
- Minimum 80% code coverage for new code

### Integration Tests (Phase 6)
- End-to-end workflow tests
- Performance benchmarks
- Concurrent operation tests

### UI Tests (Phase 6)
- Critical user workflows
- Dialog interactions
- Error scenario handling

### Manual QA Checklist (Phase 7)
- [ ] Import all supported formats
- [ ] Save and reopen .guion files
- [ ] Export to all formats
- [ ] Test error scenarios
- [ ] Performance validation with real screenplays

---

## Risk Mitigation

### Risk: SwiftData serialization complexity
**Mitigation:** Phase 1 research includes proof-of-concept. If SwiftData file persistence is too complex, pivot to Codable-based approach.

### Risk: DocumentGroup API limitations
**Mitigation:** Phase 3 may require custom file handling if DocumentGroup doesn't support required dialog customization.

### Risk: Performance issues with large files
**Mitigation:** Phase 6 includes optimization pass. May need to implement lazy loading or pagination.

### Risk: Breaking changes during development
**Mitigation:** Use feature flags for new .guion format. Maintain backward compatibility with import-only mode.

---

## Success Metrics

### Functional Metrics
- ✅ All test gates passed
- ✅ 100% of requirements document features implemented
- ✅ Zero critical bugs in production

### Performance Metrics
- ✅ Load time < 1s for typical screenplays (100-150 pages)
- ✅ Save time < 500ms
- ✅ Memory usage < 50MB for typical screenplays

### Quality Metrics
- ✅ Code coverage > 80%
- ✅ Zero compiler warnings
- ✅ All UI tests passing
- ✅ Accessibility score > 90%

---

## Next Steps

1. **Review this roadmap** with stakeholders
2. **Set up project tracking** (GitHub issues, project board)
3. **Create feature branch** `feature/guion-native-format`
4. **Begin Phase 1** implementation
5. **Daily standups** to track progress

---

## Questions to Resolve

1. **Serialization Strategy:** Which approach for .guion binary format?
   - [ ] ModelContainer file-based storage
   - [ ] Codable encoding
   - [ ] Custom binary format

2. **Export UI:** Where should export commands live?
   - [ ] File menu (via CommandGroup)
   - [ ] Toolbar buttons
   - [ ] Context menu

3. **Version Compatibility:** How to handle future .guion format versions?
   - [ ] Version number in file header
   - [ ] Migration logic
   - [ ] Backward compatibility policy

4. **Cloud Sync:** Should .guion files support iCloud?
   - [ ] Phase 1 implementation
   - [ ] Future enhancement
   - [ ] Not supported

---

## Appendix: Test File Requirements

### Test Fixtures Needed
- `Fixtures/test-small.fountain` (10 scenes, ~5 pages)
- `Fixtures/test-medium.fountain` (50 scenes, ~50 pages)
- `Fixtures/test-large.fountain` (200 scenes, ~120 pages)
- `Fixtures/test.fdx` (FDX format screenplay)
- `Fixtures/test.highland` (Highland ZIP format)
- `Fixtures/test-corrupted.guion` (Intentionally corrupted file)
- `Fixtures/test-v1.guion` (Version 1 format for migration testing)

### Existing Test Fixtures
- ✅ `Tests/Fixtures/BigFish.fountain`
- ✅ Highland test files (from `HighlandParsingTests.swift`)

---

**Document Status:** Ready for Review
**Next Action:** Stakeholder approval, then begin Phase 1
