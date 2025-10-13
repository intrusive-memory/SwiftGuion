# SwiftGuion Sample App - Phased Development Plan

**Document Version:** 1.0
**Date:** October 13, 2025
**Target:** GuionView v2.1.0 MVP
**Approach:** Test-Gated Incremental Delivery

---

## Overview

This document defines the phased development approach for building the GuionView sample application. Each phase delivers a **complete, working, tested feature** before proceeding to the next phase. All phases are **test-gated**: tests must pass before moving forward.

### Principles

1. **Incremental Delivery**: Each phase builds on the previous phase
2. **Test-Gated Progress**: Cannot proceed to next phase until current phase tests pass
3. **Working Software**: Each phase produces a runnable, demonstrable application
4. **Minimal Dependencies**: Phases designed to minimize blocking dependencies

---

## Phase 1: Core Document Operations (Import/Export/Open/Save)

**Goal:** Establish complete document lifecycle with all file format support.

**Status:** 🔴 Not Started

### Features Included

#### File Operations
- REQ-DOC-001: Open .guion Files
- REQ-DOC-002: Save .guion Files (TextPack format)
- REQ-DOC-003: New Document Creation

#### Import Capabilities
- REQ-IMP-001: Import .fountain Files
- REQ-IMP-002: Import .highland Files
- REQ-IMP-003: Import .fdx Files
- REQ-IMP-004: Import User Experience (simplified)
- REQ-IMP-005: Import Failure Recovery (simplified)
- REQ-IMP-006: File Menu Structure

#### Export Capabilities
- REQ-EXP-001: Export to .fountain Format
- REQ-EXP-002: Export to .highland Format
- REQ-EXP-003: Export to .fdx Format
- REQ-EXP-004: Export Menu Structure

#### Platform Requirements
- REQ-PLAT-002: Architecture (SwiftUI, SwiftData, DocumentGroup)
- REQ-PLAT-003: Bundle Configuration
- REQ-FTA-001: File Type Registration
- REQ-FTA-002: UTType Declarations

#### Error Handling
- REQ-REL-001: Error Handling (basic)
- REQ-REL-002: Data Integrity

**Total Requirements: 18**

### Deliverables

1. **GuionViewApp.swift**
   - DocumentGroup setup
   - File type declarations
   - Menu structure

2. **GuionDocument.swift**
   - FileDocument implementation
   - Read/write .guion TextPack files
   - Import from .fountain, .highland, .fdx
   - Lazy loading with Sendable types
   - MainActor accessor for GuionDocumentModel

3. **ImportCommands.swift**
   - Import menu commands for all formats
   - File open panels with filters
   - Error handling with user feedback

4. **ExportCommands.swift**
   - Export menu commands for all formats
   - Save panels with appropriate extensions
   - Format conversion logic

5. **ContentView.swift** (Minimal)
   - Simple placeholder view showing document loaded
   - Text: "Document loaded: [filename]"
   - Element count display

6. **Info.plist**
   - Bundle configuration
   - UTType declarations for all formats
   - File type associations

### Test Requirements (Gate to Phase 2)

#### Unit Tests (GuionViewTests/)

**Test File: `GuionDocumentTests.swift`**

```swift
// MARK: - .guion File Tests
✅ testOpenGuionFile()
   - Open valid .guion file
   - Verify GuionDocumentModel created
   - Verify screenplay data loaded

✅ testSaveGuionFile()
   - Create new GuionDocument
   - Save to .guion TextPack format
   - Verify file structure (info.json, screenplay.fountain, Resources/)

✅ testRoundTripGuionFile()
   - Open .guion → modify → save → reopen
   - Verify data preserved

// MARK: - Import Tests
✅ testImportFountainFile()
   - Import bigfish.fountain from fixtures
   - Verify GuionParsedScreenplay created
   - Verify conversion to GuionDocumentModel
   - Verify element count matches expected

✅ testImportHighlandFile()
   - Import bigfish.highland from fixtures
   - Verify ZIP extraction
   - Verify screenplay parsed
   - Verify element count matches expected

✅ testImportFDXFile()
   - Import bigfish.fdx from fixtures
   - Verify XML parsing
   - Verify element mapping
   - Verify element count matches expected

// MARK: - Export Tests
✅ testExportToFountain()
   - Load .guion document
   - Export to .fountain
   - Parse exported file
   - Verify element preservation

✅ testExportToHighland()
   - Load .guion document
   - Export to .highland
   - Verify ZIP structure
   - Verify TextBundle format

✅ testExportToFDX()
   - Load .guion document
   - Export to .fdx
   - Verify XML validity
   - Verify FinalDraft format

// MARK: - Error Handling Tests
✅ testImportCorruptedFile()
   - Attempt to import invalid file
   - Verify error thrown
   - Verify error message clear

✅ testImportMissingFile()
   - Attempt to open non-existent file
   - Verify error handling

✅ testSaveToReadOnlyLocation()
   - Attempt to save to read-only path
   - Verify error handling

// MARK: - Data Integrity Tests
✅ testAtomicSave()
   - Save document
   - Verify atomic write (no partial files)

✅ testConcurrencySafety()
   - Verify GuionParsedScreenplay is Sendable
   - Verify no MainActor conflicts in init
```

**Expected Test Count: ~15 tests**

#### UI Tests (GuionViewUITests/)

**Test File: `Phase1UITests.swift`**

```swift
// MARK: - File Menu Tests
✅ testFileMenuStructure()
   - Launch app
   - Verify File menu contains Import/Export submenus
   - Verify keyboard shortcuts registered

✅ testOpenGuionFileFromMenu()
   - File → Open
   - Select sample.guion
   - Verify window opens with content

✅ testImportFountainFromMenu()
   - File → Import → Fountain
   - Select bigfish.fountain
   - Verify import success

✅ testExportToFountainFromMenu()
   - Open document
   - File → Export → Fountain
   - Verify save panel appears
   - Verify file created

// MARK: - File Type Association Tests
✅ testGuionFileIcon()
   - Verify .guion files show custom icon in Finder

✅ testDoubleClickGuionFile()
   - Double-click .guion file in Finder
   - Verify app launches
   - Verify file opens
```

**Expected Test Count: ~6 tests**

### Acceptance Criteria (Phase 1 Complete)

- ✅ All 21 unit tests passing
- ✅ All 6 UI tests passing
- ✅ App builds without warnings
- ✅ App launches successfully
- ✅ Can open .guion files via File → Open
- ✅ Can save .guion files via File → Save
- ✅ Can import from .fountain, .highland, .fdx
- ✅ Can export to .fountain, .highland, .fdx
- ✅ Error dialogs appear for failures
- ✅ File type associations work (double-click opens app)
- ✅ Bundle configuration correct (app name, identifier)

**Gate:** All tests must pass before proceeding to Phase 2.

---

## Phase 2: GuionViewer Display

**Goal:** Display screenplay structure with full hierarchical browsing.

**Status:** 🔴 Blocked by Phase 1

### Features Included

#### User Interface
- REQ-UI-001: Display GuionViewer
- REQ-UI-002: GuionViewer Interaction
- REQ-UI-003: Empty State Display
- REQ-UI-004: Drag-and-Drop Import

**Total Requirements: 4**

### Deliverables

1. **ContentView.swift** (Complete Implementation)
   - Replace placeholder with GuionViewer component
   - Pass GuionDocumentModel to GuionViewer
   - Set up drag-and-drop handlers

2. **Drag-and-Drop Support**
   - Accept .fountain, .highland, .fdx drops
   - Visual feedback on hover
   - Import on drop

### Test Requirements (Gate to Phase 3)

#### Unit Tests

**Test File: `GuionViewerIntegrationTests.swift`**

```swift
// MARK: - GuionViewer Display Tests
✅ testGuionViewerDisplaysDocument()
   - Load document with known structure
   - Verify GuionViewer receives GuionDocumentModel
   - Verify SceneBrowserData created

✅ testGuionViewerHierarchy()
   - Load bigfish.fountain
   - Verify title displayed
   - Verify chapters displayed
   - Verify scene groups displayed
   - Verify scenes displayed

✅ testEmptyStateDisplay()
   - Create new empty document
   - Verify empty state shown
   - Verify message: "No Chapters Found"

// MARK: - Interaction Tests
✅ testExpandCollapseChapters()
   - Load document
   - Expand chapter
   - Verify scenes visible
   - Collapse chapter
   - Verify scenes hidden

✅ testExpandCollapseSceneGroups()
   - Load document
   - Expand scene group
   - Verify scenes visible
   - Collapse scene group
   - Verify scenes hidden
```

**Expected Test Count: ~5 tests**

#### UI Tests

**Test File: `Phase2UITests.swift`**

```swift
// MARK: - Display Tests
✅ testGuionViewerRendersContent()
   - Open bigfish.guion
   - Verify GuionViewer visible
   - Verify title displayed
   - Verify chapters visible

✅ testChapterInteraction()
   - Open document
   - Click chapter disclosure triangle
   - Verify expansion/collapse

✅ testSceneGroupInteraction()
   - Open document
   - Expand chapter
   - Click scene group disclosure triangle
   - Verify expansion/collapse

// MARK: - Drag and Drop Tests
✅ testDragDropFountainFile()
   - Create new document
   - Drag bigfish.fountain onto window
   - Verify import occurs
   - Verify content displayed

✅ testDragDropHighlandFile()
   - Drag bigfish.highland onto window
   - Verify import and display

✅ testDragDropFDXFile()
   - Drag bigfish.fdx onto window
   - Verify import and display

✅ testDragDropInvalidFile()
   - Drag .txt file onto window
   - Verify rejection (no visual feedback)

// MARK: - Empty State Tests
✅ testEmptyStateVisible()
   - Create new document
   - Verify empty state icon visible
   - Verify "No Chapters Found" message
```

**Expected Test Count: ~8 tests**

### Acceptance Criteria (Phase 2 Complete)

- ✅ All 13 tests passing (5 unit + 8 UI)
- ✅ GuionViewer displays screenplay structure
- ✅ Chapters expand/collapse on click
- ✅ Scene groups expand/collapse on click
- ✅ Empty state shown for new documents
- ✅ Drag-and-drop imports work for all formats
- ✅ Invalid file types rejected gracefully
- ✅ VoiceOver can navigate hierarchy

**Gate:** All tests must pass before proceeding to Phase 3.

---

## Phase 3: Window Management

**Goal:** Support multiple windows with proper controls and navigation.

**Status:** 🔴 Blocked by Phase 2

### Features Included

#### Window Management
- REQ-WIN-001: Resizable Window
- REQ-WIN-002: Multiple Windows
- REQ-WIN-003: Standard Window Controls
- REQ-WIN-005: Window Management Commands (simplified)

**Total Requirements: 4**

### Deliverables

1. **Window Configuration**
   - Set minimum window size (600x800)
   - Enable window resizing
   - Configure standard controls

2. **Window Menu Commands**
   - Minimize (Cmd+M)
   - Zoom
   - Window list with checkmarks
   - Cmd+` window cycling

### Test Requirements (Gate to Phase 4)

#### Unit Tests

**Test File: `WindowManagementTests.swift`**

```swift
// MARK: - Window Configuration Tests
✅ testMinimumWindowSize()
   - Verify window enforces 600x800 minimum

✅ testWindowResize()
   - Resize window
   - Verify GuionViewer adapts to size

// MARK: - Multiple Windows Tests
✅ testMultipleDocumentsOpen()
   - Open document A
   - Open document B
   - Verify two windows exist
   - Verify independent operation
```

**Expected Test Count: ~3 tests**

#### UI Tests

**Test File: `Phase3UITests.swift`**

```swift
// MARK: - Window Controls Tests
✅ testCloseWindow()
   - Open document
   - Click red close button
   - Verify window closes

✅ testMinimizeWindow()
   - Open document
   - Click yellow minimize button
   - Verify window minimizes to Dock

✅ testZoomWindow()
   - Open document
   - Click green zoom button
   - Verify window toggles full-screen

// MARK: - Multiple Windows Tests
✅ testOpenMultipleDocuments()
   - Open document A
   - File → Open → document B
   - Verify two windows visible

✅ testWindowMenuList()
   - Open 3 documents
   - Click Window menu
   - Verify 3 documents listed
   - Verify current window has checkmark

✅ testCycleWindows()
   - Open 2 documents
   - Press Cmd+`
   - Verify window focus switches

// MARK: - Window Resize Tests
✅ testWindowResize()
   - Open document
   - Resize window smaller
   - Verify content adapts
   - Verify scrollbar appears

✅ testMinimumWindowSize()
   - Open document
   - Attempt to resize below 600x800
   - Verify size enforced
```

**Expected Test Count: ~8 tests**

### Acceptance Criteria (Phase 3 Complete)

- ✅ All 11 tests passing (3 unit + 8 UI)
- ✅ Window resizes correctly (min 600x800)
- ✅ Multiple windows can be open simultaneously
- ✅ Standard controls work (close, minimize, zoom)
- ✅ Window menu lists all open documents
- ✅ Cmd+` cycles through windows
- ✅ Cmd+M minimizes window
- ✅ Content adapts to window size changes

**Gate:** All tests must pass before proceeding to Phase 4.

---

## Phase 4: User Feedback & Progress

**Goal:** Provide clear feedback for all operations.

**Status:** 🔴 Blocked by Phase 3

### Features Included

#### User Feedback
- REQ-UI-005: Operation Success Feedback (simplified)
- REQ-UI-006: Operation Progress Feedback (simplified)

**Total Requirements: 2**

### Deliverables

1. **Success Messages**
   - Import success: "Imported [filename]"
   - Export success: "Exported to [filename]"
   - Simple alerts or status messages

2. **Progress Indicators**
   - Spinner for imports > 2 seconds
   - Spinner for exports > 2 seconds
   - Operation title and filename display

### Test Requirements (Gate to Phase 5)

#### Unit Tests

**Test File: `UserFeedbackTests.swift`**

```swift
// MARK: - Success Feedback Tests
✅ testImportSuccessMessage()
   - Import file
   - Verify success message shown
   - Verify message contains filename

✅ testExportSuccessMessage()
   - Export file
   - Verify success message shown
   - Verify message contains destination

// MARK: - Progress Indicator Tests
✅ testProgressIndicatorForLongImport()
   - Mock long-running import
   - Verify progress indicator appears

✅ testProgressIndicatorDismissesOnComplete()
   - Mock import completion
   - Verify progress indicator dismisses
```

**Expected Test Count: ~4 tests**

#### UI Tests

**Test File: `Phase4UITests.swift`**

```swift
// MARK: - Success Message Tests
✅ testImportSuccessFeedback()
   - Import bigfish.fountain
   - Verify success message appears
   - Verify message auto-dismisses

✅ testExportSuccessFeedback()
   - Export document
   - Verify success message appears

// MARK: - Progress Indicator Tests
✅ testProgressIndicatorVisible()
   - Import large file
   - Verify spinner appears
   - Verify operation title shown

✅ testProgressIndicatorDisappears()
   - Complete import
   - Verify spinner dismisses automatically
```

**Expected Test Count: ~4 tests**

### Acceptance Criteria (Phase 4 Complete)

- ✅ All 8 tests passing (4 unit + 4 UI)
- ✅ Import success message shown
- ✅ Export success message shown
- ✅ Progress spinner shown for long operations
- ✅ Progress indicator shows operation title
- ✅ Progress indicator shows filename
- ✅ Progress indicator dismisses on completion
- ✅ VoiceOver announces success/progress

**Gate:** All tests must pass before proceeding to Phase 5.

---

## Phase 5: Performance & Accessibility

**Goal:** Meet performance targets and accessibility standards.

**Status:** 🔴 Blocked by Phase 4

### Features Included

#### Performance
- REQ-PERF-001: File Load Performance (soft targets)
- REQ-PERF-002: Scene Browser Rendering
- REQ-PERF-003: Export Performance

#### Accessibility
- REQ-ACC-001: VoiceOver Support
- REQ-ACC-002: Keyboard Navigation
- REQ-ACC-003: Visual Accessibility

**Total Requirements: 6**

### Deliverables

1. **Performance Optimizations**
   - LazyVStack for scene browser
   - Background threading for file operations
   - Memory-efficient rendering

2. **Accessibility Improvements**
   - Accessibility labels for all UI elements
   - Keyboard navigation throughout
   - High contrast support
   - Dynamic type support

### Test Requirements (Gate to Release)

#### Performance Tests

**Test File: `PerformanceTests.swift`**

```swift
// MARK: - Load Performance Tests
✅ testSmallFileLoadPerformance()
   - Load file < 100KB
   - Measure time
   - Soft target: < 500ms

✅ testMediumFileLoadPerformance()
   - Load file 100KB-1MB
   - Measure time
   - Soft target: < 2s

✅ testLargeFileLoadPerformance()
   - Load file 1MB-5MB
   - Measure time
   - Soft target: < 5s

// MARK: - Rendering Performance Tests
✅ testSceneBrowserRenderPerformance()
   - Load bigfish.fountain (150+ pages)
   - Measure initial render time
   - Target: < 1s

✅ testSceneBrowserScrollPerformance()
   - Load large screenplay
   - Measure scroll FPS
   - Target: 60 FPS

// MARK: - Export Performance Tests
✅ testExportPerformance()
   - Export typical screenplay
   - Measure time
   - Soft target: < 3s
```

**Expected Test Count: ~6 tests**

#### Accessibility Tests

**Test File: `AccessibilityTests.swift`**

```swift
// MARK: - VoiceOver Tests
✅ testVoiceOverLabels()
   - Verify all buttons have accessibility labels
   - Verify all controls have descriptions

✅ testVoiceOverNavigation()
   - Navigate GuionViewer with VoiceOver
   - Verify hierarchy exposed correctly

// MARK: - Keyboard Navigation Tests
✅ testKeyboardMenuAccess()
   - Navigate all menus via keyboard
   - Verify shortcuts work

✅ testKeyboardWindowNavigation()
   - Navigate between windows via Cmd+`
   - Verify focus moves correctly

✅ testKeyboardSceneBrowserNavigation()
   - Navigate scene browser with arrow keys
   - Expand/collapse with Space

// MARK: - Visual Accessibility Tests
✅ testHighContrastMode()
   - Enable high contrast
   - Verify UI remains readable

✅ testDynamicType()
   - Change system text size
   - Verify UI adapts

✅ testColorBlindness()
   - Verify state not indicated by color alone
```

**Expected Test Count: ~8 tests**

### Acceptance Criteria (Phase 5 Complete)

- ✅ All 14 tests passing (6 performance + 8 accessibility)
- ✅ File load performance meets soft targets
- ✅ Scene browser renders in < 1s
- ✅ Scrolling maintains 60 FPS
- ✅ All UI elements have accessibility labels
- ✅ Keyboard navigation works throughout
- ✅ VoiceOver can access all features
- ✅ High contrast mode supported
- ✅ Dynamic type supported

**Gate:** All tests must pass before proceeding to Phase 6.

---

## Phase 6: Application Identity & Polish

**Goal:** Complete branding, icons, and final polish.

**Status:** 🔴 Blocked by Phase 5

### Features Included

#### Application Identity
- REQ-APP-001: Application Name and Branding
- REQ-APP-002: Application Icon
- REQ-PLAT-001: macOS Version Support

**Total Requirements: 3**

### Deliverables

1. **Application Icon**
   - Design Preview-inspired icon with screenplay elements
   - All required sizes (1024x1024 down to 16x16)
   - Retina @2x versions
   - .icns format for Assets.xcassets

2. **Document Type Icons**
   - .guion file icon
   - .fountain file icon (optional)
   - .highland file icon (optional)
   - .fdx file icon (optional)

3. **Branding Polish**
   - Verify "GuionView" used throughout
   - About panel content
   - Bundle display name
   - Copyright information

4. **Sample Screenplay**
   - Create sample.fountain (5-10 pages)
   - Include in Resources/
   - Demonstrate chapter/scene structure

### Test Requirements (Gate to Release)

#### Integration Tests

**Test File: `Phase6IntegrationTests.swift`**

```swift
// MARK: - Branding Tests
✅ testApplicationName()
   - Verify bundle display name is "GuionView"
   - Verify product name is "GuionView"

✅ testApplicationIcon()
   - Verify app icon renders correctly
   - Verify all sizes present

✅ testDocumentIcons()
   - Verify .guion files show custom icon

// MARK: - Platform Tests
✅ testMacOSVersionSupport()
   - Verify app runs on macOS 14.0+
   - Verify minimum deployment target set

// MARK: - Sample Screenplay Tests
✅ testSampleScreenplayExists()
   - Verify sample.fountain bundled
   - Verify sample can be opened

✅ testSampleScreenplayStructure()
   - Open sample.fountain
   - Verify chapters present
   - Verify scene groups present
   - Verify scenes present
```

**Expected Test Count: ~6 tests**

#### Manual Testing Checklist

```
✅ App icon displays correctly in Finder
✅ App icon displays correctly in Dock
✅ App icon displays correctly in Applications folder
✅ Document icons display correctly in Finder
✅ About panel shows "GuionView"
✅ Menu bar shows "GuionView"
✅ Sample screenplay opens and displays correctly
✅ App runs on macOS 14.0 (Sonoma)
✅ App runs on macOS 15.0 (Sequoia)
✅ Universal binary (Apple Silicon + Intel) builds
```

### Acceptance Criteria (Phase 6 Complete - RELEASE READY)

- ✅ All 6 tests passing
- ✅ Manual testing checklist complete
- ✅ Application icon designed and integrated
- ✅ Document type icons present
- ✅ "GuionView" branding consistent throughout
- ✅ Sample screenplay included and working
- ✅ macOS 14.0+ support verified
- ✅ Universal binary builds successfully
- ✅ No compiler warnings
- ✅ All 60+ tests passing across all phases

**Gate:** All tests pass → v2.1.0 READY FOR RELEASE

---

## Test Summary by Phase

| Phase | Unit Tests | UI Tests | Integration Tests | Total | Cumulative |
|-------|-----------|----------|-------------------|-------|------------|
| Phase 1 | 15 | 6 | 0 | 21 | 21 |
| Phase 2 | 5 | 8 | 0 | 13 | 34 |
| Phase 3 | 3 | 8 | 0 | 11 | 45 |
| Phase 4 | 4 | 4 | 0 | 8 | 53 |
| Phase 5 | 6 (perf) + 8 (a11y) | 0 | 0 | 14 | 67 |
| Phase 6 | 0 | 0 | 6 | 6 | 73 |
| **Total** | **41** | **26** | **6** | **73** | **73** |

---

## Development Workflow

### For Each Phase

1. **Review Requirements**
   - Read requirements for current phase
   - Understand acceptance criteria
   - Review test requirements

2. **Write Tests First (TDD)**
   - Write unit tests for phase
   - Write UI tests for phase
   - Verify tests fail (red)

3. **Implement Features**
   - Build minimum code to pass tests
   - Follow architecture from SAMPLE_APP_REQUIREMENTS.md
   - Keep code clean and documented

4. **Run Tests**
   - Run all tests for current phase
   - Fix failures until all pass (green)

5. **Verify Gate Criteria**
   - Check acceptance criteria
   - Run full test suite (all phases)
   - Manual smoke testing

6. **Commit and Document**
   - Commit phase completion
   - Update phase status in this document
   - Document any deviations or learnings

7. **Gate Review**
   - Review all acceptance criteria met
   - Confirm no regressions in previous phases
   - **ONLY THEN** proceed to next phase

### Test Execution

```bash
# Run all tests
swift test

# Run specific test target
swift test --filter GuionViewTests

# Run specific test
swift test --filter testOpenGuionFile

# Run with coverage
swift test --enable-code-coverage

# Generate coverage report
xcrun llvm-cov report ...
```

### Phase Status Tracking

Update this document as phases complete:

- 🔴 Not Started - Phase not begun
- 🟡 In Progress - Implementation underway
- 🟢 Complete - All tests passing, gate criteria met
- 🔵 Blocked - Waiting on previous phase

---

## Risk Management

### Potential Blockers

1. **Phase 1: TextPack Format Issues**
   - Risk: TextPack read/write fails
   - Mitigation: Extensive unit tests on TextPackReader/Writer first
   - Fallback: Use simpler .guion format temporarily

2. **Phase 2: GuionViewer Performance**
   - Risk: Slow rendering for large screenplays
   - Mitigation: LazyVStack from start, profile early
   - Fallback: Limit initial display to first 100 scenes

3. **Phase 3: Multiple Windows**
   - Risk: DocumentGroup coordination issues
   - Mitigation: Study SwiftUI DocumentGroup examples
   - Fallback: Single window mode temporarily

4. **Phase 5: Performance Targets**
   - Risk: Cannot meet soft targets
   - Mitigation: Profile and optimize incrementally
   - Fallback: Document actual performance, adjust targets

### Dependencies

- **SwiftGuion Library**: All tests depend on library working correctly
- **Test Fixtures**: bigfish.fountain, bigfish.highland, bigfish.fdx required
- **macOS 14.0+**: Development requires modern macOS SDK

---

## Success Criteria (v2.1.0 Release)

GuionView v2.1.0 is ready for release when:

1. ✅ All 6 phases complete
2. ✅ All 73 tests passing
3. ✅ Manual testing checklist complete
4. ✅ No compiler warnings
5. ✅ README.md written
6. ✅ Example screenshots captured
7. ✅ Code documented with /// comments
8. ✅ Release notes written
9. ✅ App builds for distribution (signed)
10. ✅ SwiftGuion library v2.1.0 published

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-13 | Claude Code | Initial phased development plan with test-gated approach. Organized 28 MVP requirements into 6 functional phases with comprehensive test requirements for each phase. |

---

**End of Development Phases Document**
