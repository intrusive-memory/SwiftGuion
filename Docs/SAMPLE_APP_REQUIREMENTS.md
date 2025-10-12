# SwiftGuion Sample App Requirements

**Document Version:** 1.2
**Date:** October 12, 2025
**Status:** Draft

---

## Executive Summary

This document defines the requirements for **GuionView**, a macOS sample application that demonstrates the capabilities of the SwiftGuion library. The app will showcase file format import/export capabilities (.fountain, .highland, .fdx, .guion), visual screenplay structure browsing, and native document-based architecture.

---

## 1. Overview

### 1.1 Purpose

**GuionView** serves as:
- A reference implementation for developers using the SwiftGuion library
- A demonstration of the library's core features, particularly the GuionViewer component
- A working example of document-based app architecture with SwiftData
- A testing tool for screenplay file format compatibility
- A simple, focused viewer application for .guion screenplay files

### 1.2 Target Audience

- **Primary**: Developers integrating SwiftGuion into their projects
- **Secondary**: Screenwriters evaluating SwiftGuion-based applications
- **Tertiary**: Contributors to the SwiftGuion project

### 1.3 Scope

**In Scope:**
- Native .guion file support (open/save)
- Import from .fountain, .highland, and .fdx formats
- Export to .fountain, .highland, and .fdx formats
- Scene browser visualization with hierarchical outline structure
- Resizable window interface
- macOS-native document architecture

**Out of Scope:**
- Screenplay editing capabilities (text editing, formatting)
- Printing or PDF generation
- Collaboration features (sharing, comments)
- Cloud synchronization
- iOS/iPadOS versions
- Plugin architecture
- Custom themes or UI customization

---

## 2. Functional Requirements

### 2.1 Document Management

#### 2.1.1 Native .guion File Support

**REQ-DOC-001**: Open .guion Files
**Priority**: P0 (Critical)
**Description**: The app shall open native .guion files using the standard macOS file open dialog or by double-clicking files in Finder.

**Acceptance Criteria:**
- User can select File → Open or press Cmd+O to open a .guion file
- .guion files associated with the app open when double-clicked in Finder
- File contents load into SwiftData model without data loss
- Document displays in Scene Browser Widget upon successful load
- Error message shown if file is corrupted or incompatible version

---

**REQ-DOC-002**: Save .guion Files
**Priority**: P0 (Critical)
**Description**: The app shall save documents to .guion format, preserving all screenplay data and metadata.

**Acceptance Criteria:**
- User can select File → Save or press Cmd+S to save current document
- File → Save As... or Cmd+Shift+S prompts for file location
- All screenplay elements saved to binary property list format
- Location cache data preserved
- Title page metadata preserved
- Unsaved changes tracked with standard macOS dirty document indicator
- Auto-save functionality works as per macOS standards

---

**REQ-DOC-003**: New Document Creation
**Priority**: P0 (Critical)
**Description**: The app shall create new, empty .guion documents.

**Acceptance Criteria:**
- File → New or Cmd+N creates new document window
- New document shows empty state in Scene Browser
- Document ready for import or manual data entry (future)
- Untitled document name assigned by default

---

#### 2.1.2 Import Capabilities

**REQ-IMP-001**: Import .fountain Files
**Priority**: P0 (Critical)
**Description**: The app shall import Fountain-formatted screenplay files (.fountain extension) via File menu or drag-and-drop.

**Acceptance Criteria:**
- File → Import → Fountain... or Cmd+I prompts file selection dialog filtered to .fountain
- Drag-and-drop .fountain files directly onto GuionViewer window
- Parser successfully reads Fountain syntax
- All element types imported (scene headings, action, dialogue, etc.)
- Title page metadata preserved
- Scene numbers preserved (if present)
- Section headers preserved with correct hierarchy
- Import progress indicated for large files
- Success/failure message shown after import
- Imported content displayed in GuionViewer

---

**REQ-IMP-002**: Import .highland Files
**Priority**: P0 (Critical)
**Description**: The app shall import Highland 2 archive files (.highland extension) via File menu or drag-and-drop.

**Acceptance Criteria:**
- File → Import → Highland... prompts file selection dialog filtered to .highland
- Drag-and-drop .highland files directly onto GuionViewer window
- ZIP archive extracted to temporary location
- TextBundle structure parsed correctly
- Both .fountain and .md content files supported
- Character and outline JSON resources preserved (if present)
- Temporary files cleaned up after import
- Import failures handled gracefully with error messages
- Imported content displayed in GuionViewer

---

**REQ-IMP-003**: Import .fdx Files
**Priority**: P0 (Critical)
**Description**: The app shall import Final Draft XML files (.fdx extension) via File menu or drag-and-drop.

**Acceptance Criteria:**
- File → Import → Final Draft... prompts file selection dialog filtered to .fdx
- Drag-and-drop .fdx files directly onto GuionViewer window
- XML structure parsed using FDXDocumentParser
- All paragraph types mapped to GuionElement types
- Scene properties (numbers, etc.) preserved
- Title page content extracted and preserved
- Character formatting handled (bold, italic, underline)
- Import errors logged with diagnostic information
- Partial import supported (continues on non-critical errors)
- Imported content displayed in GuionViewer

---

**REQ-IMP-004**: Import User Experience
**Priority**: P1 (High)
**Description**: Import operations shall provide clear feedback and error handling.

**Acceptance Criteria:**
- Progress indicator shown during import (spinning cursor or progress bar)
- Estimated time shown for large files (> 1MB)
- Cancel button available during long imports
- Detailed error messages for parse failures
- File path shown in error dialogs
- Import source format preserved in document metadata
- Original content available in rawContent field

---

**REQ-IMP-005**: File Menu Structure
**Priority**: P0 (Critical)
**Description**: The File menu shall provide a comprehensive and organized structure for all document operations.

**Acceptance Criteria:**
- File menu includes the following structure:
  - New (Cmd+N)
  - Open... (Cmd+O)
  - Open Recent → [submenu with recent files]
  - Close (Cmd+W)
  - **Import** → [submenu]
    - Fountain... (Cmd+Shift+I, F)
    - Highland... (Cmd+Shift+I, H)
    - Final Draft... (Cmd+Shift+I, D)
  - Save (Cmd+S)
  - Save As... (Cmd+Shift+S)
  - **Export** → [submenu]
    - Fountain... (Cmd+Shift+E, F)
    - Highland... (Cmd+Shift+E, H)
    - Final Draft... (Cmd+Shift+E, D)
- Menu items properly enabled/disabled based on context
- Import submenu disabled when no document is open
- Export submenu disabled when document is empty
- Keyboard shortcuts follow macOS conventions

---

#### 2.1.3 Export Capabilities

**REQ-EXP-001**: Export to .fountain Format
**Priority**: P0 (Critical)
**Description**: The app shall export documents to Fountain format (.fountain).

**Acceptance Criteria:**
- File → Export → Fountain... or Cmd+Shift+E,F prompts save dialog
- All elements converted to valid Fountain syntax
- Title page formatted as Fountain front matter
- Scene numbers included (unless suppressSceneNumbers is true)
- Section headers formatted with appropriate # syntax
- Dual dialogue properly formatted
- Round-trip fidelity maintained (export → import → compare)
- UTF-8 encoding used
- Unix line endings (LF) used

---

**REQ-EXP-002**: Export to .highland Format
**Priority**: P0 (Critical)
**Description**: The app shall export documents to Highland 2 format (.highland).

**Acceptance Criteria:**
- File → Export → Highland... or Cmd+Shift+E,H prompts save dialog
- TextBundle structure created with correct hierarchy
- Fountain content written to info.json-specified file
- Character data exported to characters.json (if available)
- Outline data exported to outline.json (if available)
- ZIP archive created with correct structure
- Archive validates when opened in Highland 2
- Metadata preserved in info.json

---

**REQ-EXP-003**: Export to .fdx Format
**Priority**: P0 (Critical)
**Description**: The app shall export documents to Final Draft XML format (.fdx).

**Acceptance Criteria:**
- File → Export → Final Draft... or Cmd+Shift+E,D prompts save dialog
- Valid FDX XML structure generated
- All element types mapped to appropriate Paragraph types
- Scene numbers included in SceneProperties (if present)
- Title page formatted in TitlePage section
- Character names properly formatted
- XML validates against FDX schema
- Files open successfully in Final Draft

---

**REQ-EXP-004**: Export Menu Structure
**Priority**: P1 (High)
**Description**: Export commands shall be organized in a consistent, accessible menu structure.

**Acceptance Criteria:**
- File → Export submenu contains all export options
- Keyboard shortcuts follow macOS conventions
- Menu items disabled when no document open
- Format name clearly indicated in menu items
- Recently used export locations remembered
- Export preserves original filename (changes extension only)

---

### 2.2 User Interface

#### 2.2.1 GuionViewer Component

**REQ-UI-001**: Display GuionViewer
**Priority**: P0 (Critical)
**Description**: The main window shall display the GuionViewer component as the primary content view in a resizable window.

**Acceptance Criteria:**
- GuionViewer fills main window content area
- Window is fully resizable with minimum size of 600x800 points
- Hierarchical structure displayed: Title → Chapters → Scene Groups → Scenes
- Title displayed at top with large, bold typography
- Chapters displayed as collapsible sections (Level 2)
- Scene groups displayed under chapters (Level 3)
- Individual scenes displayed with scene headings (Level 4)
- Empty state shown when document has no chapters
- Smooth scrolling for long screenplays
- Loading states displayed during file operations
- Error states displayed with user-friendly messages

---

**REQ-UI-002**: GuionViewer Interaction
**Priority**: P1 (High)
**Description**: Users shall be able to interact with the GuionViewer to explore screenplay structure.

**Acceptance Criteria:**
- Chapters can be expanded/collapsed by clicking
- Scene groups can be expanded/collapsed by clicking
- Individual scenes can be expanded to show elements
- Pre-scene content (before first chapter) displayed if present
- Disclosure triangles indicate expandable items
- Visual hierarchy clear through indentation and typography
- Keyboard navigation supported (arrow keys, space to expand/collapse)
- VoiceOver accessibility labels present

---

**REQ-UI-003**: Empty State Display
**Priority**: P1 (High)
**Description**: The app shall display an appropriate empty state when no content is available.

**Acceptance Criteria:**
- Empty state shown for new documents
- Empty state shown when screenplay has no chapter markers
- Icon displayed (doc.text.magnifyingglass system symbol)
- Message: "No Chapters Found"
- Explanation: "This screenplay doesn't have chapter markers (##)."
- Centered in window
- Accessible via VoiceOver

---

**REQ-UI-004**: Drag-and-Drop Import
**Priority**: P0 (Critical)
**Description**: GuionViewer shall support drag-and-drop of importable screenplay files directly onto the window.

**Acceptance Criteria:**
- Accepts .fountain, .highland, and .fdx file drops
- Visual feedback when dragging files over window (highlight border or overlay)
- Drop zone covers entire window content area
- Dropped files are imported automatically
- Multiple files dropped show import dialog for selection
- Invalid file types rejected with visual feedback (no action)
- Drag-and-drop works in both empty state and when document is loaded
- Progress indicator shown during import from drop
- Error handling same as File → Import
- Keyboard accessibility: Paste file path imports file (Cmd+V)

---

#### 2.2.2 Window Management

**REQ-WIN-001**: Resizable Window
**Priority**: P0 (Critical)
**Description**: The document window shall be fully resizable with GuionViewer adapting to window size changes.

**Acceptance Criteria:**
- Window can be resized horizontally and vertically
- Minimum window size: 600x800 points (optimal for GuionViewer)
- Maximum window size: unrestricted (up to screen bounds)
- Window size persisted between launches (per-user preference)
- GuionViewer content reflows appropriately when resized
- No content clipping at minimum size
- Scrollbars appear when content exceeds viewport
- GuionViewer frame constrained to window bounds using .frame(minWidth:minHeight:)

---

**REQ-WIN-002**: Multiple Windows
**Priority**: P1 (High)
**Description**: The app shall support multiple document windows simultaneously.

**Acceptance Criteria:**
- File → New opens new window
- File → Open opens document in new window
- Each window operates independently
- Window → [Document Name] menu lists all open windows
- Cmd+` cycles through windows
- Closing window doesn't quit application (unless last window)
- Each window shows correct document title in title bar

---

**REQ-WIN-003**: Standard Window Controls
**Priority**: P0 (Critical)
**Description**: Document windows shall include standard macOS window controls.

**Acceptance Criteria:**
- Close button (red) closes window
- Minimize button (yellow) minimizes to Dock
- Zoom button (green) toggles full-screen
- Title bar shows document name
- Proxy icon in title bar supports drag-and-drop
- Dirty document indicator (dot in close button) when unsaved

---

### 2.3 File Type Associations

**REQ-FTA-001**: File Type Registration
**Priority**: P0 (Critical)
**Description**: The app shall register itself as a handler for supported file types.

**Acceptance Criteria:**
- .guion files associated with app (primary handler)
- .fountain files can be opened (secondary handler)
- .highland files can be opened (secondary handler)
- .fdx files can be opened (secondary handler)
- File icons display correctly in Finder
- Quick Look previews available (if implemented)
- Spotlight metadata indexed (if implemented)

---

**REQ-FTA-002**: UTType Declarations
**Priority**: P0 (Critical)
**Description**: The app shall declare proper UTType information for all supported formats.

**Acceptance Criteria:**
- Info.plist contains CFBundleDocumentTypes array
- Info.plist contains UTImportedTypeDeclarations
- .guion: com.swiftguion.guion-document
- .fountain: com.quote-unquote.fountain
- .highland: com.highland.highland2
- .fdx: com.finaldraft.fdx
- Conformance relationships correctly defined
- MIME types declared where applicable

---

### 2.4 Performance Requirements

**REQ-PERF-001**: File Load Performance
**Priority**: P1 (High)
**Description**: Files shall load within acceptable time limits.

**Acceptance Criteria:**
- Small files (< 100 KB): < 500ms
- Medium files (100 KB - 1 MB): < 2s
- Large files (1 MB - 5 MB): < 5s
- Progress indicator shown for loads > 1s
- UI remains responsive during load (background thread)

---

**REQ-PERF-002**: Scene Browser Rendering
**Priority**: P1 (High)
**Description**: Scene browser shall render smoothly even for large screenplays.

**Acceptance Criteria:**
- LazyVStack used for efficient rendering
- Scrolling maintains 60 FPS for screenplays up to 200 pages
- Memory usage scales linearly (no memory leaks)
- Initial render time < 1s for typical feature screenplay

---

**REQ-PERF-003**: Export Performance
**Priority**: P2 (Medium)
**Description**: Export operations shall complete in reasonable time.

**Acceptance Criteria:**
- Export time < 3s for typical feature screenplay
- Progress shown for exports > 1s
- UI remains responsive during export (background thread)

---

## 3. Non-Functional Requirements

### 3.1 Application Identity

**REQ-APP-001**: Application Name and Branding
**Priority**: P0 (Critical)
**Description**: The application shall be named "GuionView" across all user-facing elements.

**Acceptance Criteria:**
- App name in Finder: **GuionView**
- App name in menu bar: **GuionView**
- Bundle display name (CFBundleDisplayName): **GuionView**
- Bundle name (CFBundleName): **GuionView**
- Product name in Xcode: **GuionView**
- About panel shows "GuionView" as application name
- Dock icon label shows "GuionView"
- No references to "GuionDocumentApp" or other placeholder names in UI

---

**REQ-APP-002**: Application Icon
**Priority**: P0 (Critical)
**Description**: The application icon shall be a creative reinterpretation of the macOS Preview.app icon, clearly distinguishing it as a screenplay viewer.

**Acceptance Criteria:**
- Icon design inspired by macOS Preview.app icon (magnifying glass aesthetic)
- Distinguishing elements that identify it as screenplay-related:
  - Incorporate screenplay/script visual elements (e.g., stacked pages, scene markers, or screenplay formatting indicators)
  - Use complementary but distinct color palette from Preview.app
  - Maintain macOS design language (rounded square, gradient, shadow)
- All required icon sizes provided (1024x1024, 512x512, 256x256, 128x128, 64x64, 32x32, 16x16)
- Icons work well at all sizes (details remain visible at 16x16)
- Retina @2x versions provided for all sizes
- Icon passes macOS icon design guidelines
- Icon exported in .icns format for Assets.xcassets
- Document type icons use consistent visual language

**Design Notes:**
- Preview.app uses a magnifying glass over layered documents
- GuionView could use similar magnifying glass but with screenplay-specific elements:
  - Pages showing screenplay formatting (scene headings, dialogue)
  - Film/clapperboard iconography
  - Script/document imagery with distinct screenplay layout
- Color suggestions: Complementary to Preview.app's blue/gray tones (e.g., warmer tones, screenplay-green, or film-amber)

---

### 3.2 Platform Requirements

**REQ-PLAT-001**: macOS Version Support
**Priority**: P0 (Critical)
**Description**: The app shall run on supported macOS versions.

**Acceptance Criteria:**
- Minimum: macOS 14.0 (Sonoma)
- Recommended: macOS 15.0 (Sequoia) or later
- Universal binary (Apple Silicon + Intel)

---

**REQ-PLAT-002**: Architecture
**Priority**: P0 (Critical)
**Description**: The app shall use modern Apple frameworks and patterns.

**Acceptance Criteria:**
- SwiftUI for user interface
- SwiftData for data persistence
- DocumentGroup for document management
- FileDocument protocol implementation
- Sendable/concurrency-safe throughout

---

**REQ-PLAT-003**: Bundle Configuration
**Priority**: P0 (Critical)
**Description**: The app shall use proper bundle identifiers and naming conventions.

**Acceptance Criteria:**
- Bundle identifier: **com.swiftguion.GuionView**
- Bundle display name: **GuionView**
- Product name: **GuionView**
- Executable name: **GuionView**
- No placeholder or generic identifiers in production build

---

### 3.3 Reliability

**REQ-REL-001**: Error Handling
**Priority**: P0 (Critical)
**Description**: All errors shall be handled gracefully without crashes.

**Acceptance Criteria:**
- All file operations wrapped in do-catch blocks
- User-facing error messages are clear and actionable
- Errors logged to console with diagnostic info
- App never crashes due to malformed input files
- Recovery suggestions provided in error dialogs

---

**REQ-REL-002**: Data Integrity
**Priority**: P0 (Critical)
**Description**: User data shall never be lost or corrupted.

**Acceptance Criteria:**
- Auto-save prevents data loss
- Atomic file writes (all-or-nothing)
- Validation performed on load
- Corrupted files detected and reported
- Backup/recovery mechanisms available

---

### 3.4 Accessibility

**REQ-ACC-001**: VoiceOver Support
**Priority**: P1 (High)
**Description**: The app shall be fully accessible via VoiceOver.

**Acceptance Criteria:**
- All UI elements have accessibility labels
- Navigation hierarchy properly exposed
- Meaningful descriptions for complex elements
- VoiceOver can access all functionality
- Keyboard shortcuts announced

---

**REQ-ACC-002**: Keyboard Navigation
**Priority**: P1 (High)
**Description**: All features shall be accessible via keyboard.

**Acceptance Criteria:**
- Tab navigation works throughout UI
- All menu items have keyboard shortcuts
- Standard shortcuts follow macOS conventions
- Focus indicators clearly visible
- No mouse-only functionality

---

**REQ-ACC-003**: Visual Accessibility
**Priority**: P2 (Medium)
**Description**: The app shall support visual accessibility features.

**Acceptance Criteria:**
- Respects system text size preferences
- Supports high contrast mode
- Color is not the only indicator of state
- Minimum contrast ratios met (WCAG AA)

---

### 3.5 Usability

**REQ-USE-001**: First-Run Experience
**Priority**: P2 (Medium)
**Description**: New users shall quickly understand how to use the app.

**Acceptance Criteria:**
- Welcome screen shown on first launch (optional)
- Sample screenplay available via File → Open Sample
- Help menu links to documentation
- Tooltips available for non-obvious UI elements

---

**REQ-USE-002**: Error Recovery
**Priority**: P1 (High)
**Description**: Users shall be able to recover from errors without losing work.

**Acceptance Criteria:**
- Import errors preserve original file
- Export errors don't overwrite existing files
- Undo/redo available where applicable
- Confirm dialogs for destructive actions

---

## 4. Technical Architecture

### 4.1 Application Structure

```
GuionView/
├── GuionViewApp.swift               # Main app entry point with DocumentGroup
├── GuionDocument.swift              # FileDocument implementation
├── ContentView.swift                # Main document view (GuionViewer wrapper)
├── ImportCommands.swift             # Import menu commands
├── ExportCommands.swift             # Export menu commands
├── Info.plist                       # Bundle configuration & UTTypes
└── Assets.xcassets/                 # App icons and resources
    ├── AppIcon.appiconset/          # GuionView app icon (Preview-inspired)
    └── [Document type icons]
```

### 4.2 Key Components

#### 4.2.1 GuionDocument (FileDocument)

**Purpose**: Implements FileDocument protocol for document-based architecture.

**Responsibilities:**
- Read/write .guion files via GuionDocumentModel serialization
- Import from .fountain, .highland, .fdx formats
- Lazy-load document data to avoid MainActor conflicts
- Provide GuionDocumentModel to views via @MainActor accessor

**Key Methods:**
```swift
init(configuration: ReadConfiguration)
func fileWrapper(configuration: WriteConfiguration) -> FileWrapper
@MainActor var documentModel: GuionDocumentModel
```

#### 4.2.2 ContentView

**Purpose**: Displays document content using GuionViewer component.

**Responsibilities:**
- Receive GuionDocument binding
- Pass GuionDocumentModel to GuionViewer
- Set up drag-and-drop functionality for file imports
- Handle window frame constraints (minimum 600x800)
- Coordinate with ImportCommands for drag-and-drop imports

**Key Implementation:**
```swift
struct ContentView: View {
    @Binding var document: GuionDocument

    var body: some View {
        GuionViewer(document: document.documentModel)
            .frame(minWidth: 600, minHeight: 800)
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                handleFileDrop(providers)
            }
    }
}

#### 4.2.3 ImportCommands

**Purpose**: Implements import menu commands.

**Responsibilities:**
- Define File → Import submenu
- Handle import from .fountain, .highland, .fdx
- Show open panels with appropriate filters
- Execute import operations and update document
- Support drag-and-drop import coordination

**Menu Structure:**
```
File
├── Import
│   ├── Fountain...       (Cmd+Shift+I, F)
│   ├── Highland...       (Cmd+Shift+I, H)
│   └── Final Draft...    (Cmd+Shift+I, D)
```

#### 4.2.4 ExportCommands

**Purpose**: Implements export menu commands.

**Responsibilities:**
- Define File → Export submenu
- Handle export to .fountain, .highland, .fdx
- Show save panels with appropriate filters
- Execute export operations via FountainScript

**Menu Structure:**
```
File
└── Export
    ├── Fountain...       (Cmd+Shift+E, F)
    ├── Highland...       (Cmd+Shift+E, H)
    └── Final Draft...    (Cmd+Shift+E, D)
```

### 4.3 Data Flow

#### Import Flow:
```
1. User: File → Import → [Format]
2. Show NSOpenPanel filtered to format
3. Read file data
4. Parse using appropriate parser (FastFountainParser/FDXDocumentParser)
5. Create GuionDocumentModel from parsed data
6. Set as current document
7. Update SceneBrowserWidget display
```

#### Save Flow:
```
1. User: File → Save (Cmd+S)
2. GuionDocument.fileWrapper() called
3. GuionDocumentModel.encodeToBinaryData() creates snapshot
4. PropertyListEncoder encodes to binary plist
5. FileWrapper created from data
6. System writes to disk atomically
```

#### Export Flow:
```
1. User: File → Export → [Format]
2. Show NSSavePanel with suggested filename
3. Convert GuionDocumentModel to FountainScript
4. Call appropriate writer method:
   - .fountain: script.write(to:)
   - .highland: script.writeToHighland()
   - .fdx: FDXDocumentWriter.makeFDX()
5. Write data to selected location
6. Show success/error message
```

### 4.4 Concurrency Strategy

**Challenge**: SwiftData's @MainActor requirements conflict with FileDocument's nonisolated initializers.

**Solution**: Lazy Loading Pattern

```swift
// Store Sendable data in nonisolated context
private var documentData: Data?
private var script: FountainScript?

// Compute model on-demand in MainActor context
@MainActor
var documentModel: GuionDocumentModel {
    // Creates model from stored data when accessed
}
```

**Benefits:**
- No MainActor isolation conflicts
- Maintains proper concurrency safety
- Allows FileDocument to work with SwiftData
- Performance impact minimal (one-time conversion)

---

## 5. Testing Requirements

### 5.1 Unit Tests

**Test Coverage Required:**
- Import from each format (.fountain, .highland, .fdx)
- Export to each format
- Round-trip testing (import → export → import → compare)
- Error handling (corrupted files, unsupported versions)
- Empty document handling
- Large file handling (> 5 MB)

### 5.2 Integration Tests

**Test Scenarios:**
- Open .guion file → displays in Scene Browser
- Import .fountain → save as .guion → reopen
- Create new document → import → export → verify
- Multiple windows with different documents
- Window state persistence across launches

### 5.3 Manual Testing Checklist

- [ ] Double-click .guion file in Finder opens app
- [ ] File icons display correctly
- [ ] All keyboard shortcuts work
- [ ] VoiceOver can navigate Scene Browser
- [ ] Window resizing works smoothly
- [ ] Export menu items appear and function
- [ ] Error dialogs are clear and helpful
- [ ] Auto-save works (test by force-quitting)
- [ ] Multiple documents can be open simultaneously

---

## 6. Documentation Requirements

### 6.1 README

**Required Sections:**
- Brief description of app purpose
- Features list
- Installation instructions
- Build instructions
- Usage examples with screenshots
- Known limitations
- License information

### 6.2 Code Documentation

**Requirements:**
- All public types documented with /// comments
- Complex algorithms explained
- Concurrency patterns noted
- Example usage in documentation

### 6.3 User Documentation

**Optional (for full product):**
- User guide with screenshots
- Tutorial for first-time users
- FAQ section
- Troubleshooting guide

---

## 7. Delivery Checklist

### 7.1 Code Completeness

- [ ] All REQ-* requirements implemented
- [ ] No compilation warnings
- [ ] No SwiftLint or formatting warnings
- [ ] All tests passing
- [ ] Code reviewed

### 7.2 Assets

- [ ] App icon (all sizes)
- [ ] Document icons for each file type
- [ ] About panel content
- [ ] Copyright and license files

### 7.3 Configuration

- [ ] Info.plist complete and correct
- [ ] Entitlements configured (if needed)
- [ ] Bundle identifier set
- [ ] Version numbers set
- [ ] Code signing configured (for distribution)

### 7.4 Documentation

- [ ] README.md complete
- [ ] Code documentation complete
- [ ] Example files included
- [ ] CHANGELOG.md started

---

## 8. Success Criteria

**GuionView** will be considered complete when:

1. **Functional**: All P0 and P1 requirements implemented and tested
2. **Reliable**: No crashes or data loss in normal operation
3. **Performant**: Meets all performance requirements
4. **Accessible**: VoiceOver and keyboard navigation work correctly
5. **Documented**: README and code documentation complete
6. **Exemplary**: Code quality suitable as reference implementation

---

## 9. Future Enhancements

Items out of scope for initial release but worth considering:

### 9.1 Phase 2 Features
- Scene editing capabilities (text editing)
- Character and location panels
- Search and filter functionality
- Print and PDF export
- Custom color schemes / themes

### 9.2 Phase 3 Features
- iOS/iPadOS companion app
- iCloud sync
- Collaboration features (comments, track changes)
- Integration with script analysis tools
- Plugin architecture for extensions

### 9.3 Advanced Features
- AI-powered scene analysis
- Beat sheet visualization
- Timeline view
- Character relationship graphs
- Export to production formats (call sheets, sides)

---

## 10. References

- [SwiftGuion Library Documentation](../README.md)
- [.guion File Format Specification](./GUION_FILE_FORMAT.md)
- [Fountain Format Specification](https://fountain.io)
- [Apple DocumentGroup Documentation](https://developer.apple.com/documentation/swiftui/documentgroup)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

---

## Appendix A: File Format Support Matrix

| Format | Extension | Import | Export | Native | Notes |
|--------|-----------|--------|--------|--------|-------|
| Guion | .guion | ✅ | ✅ | ✅ | Binary property list format |
| Fountain | .fountain | ✅ | ✅ | ❌ | Plain text, universal |
| Highland | .highland | ✅ | ✅ | ❌ | ZIP archive with TextBundle |
| Final Draft | .fdx | ✅ | ✅ | ❌ | XML format |
| TextBundle | .textbundle | ❌* | ❌ | ❌ | *Supported via .highland |

---

## Appendix B: Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| New Document | Cmd+N |
| Open... | Cmd+O |
| Save | Cmd+S |
| Save As... | Cmd+Shift+S |
| Close Window | Cmd+W |
| **Import Fountain...** | Cmd+Shift+I, F |
| **Import Highland...** | Cmd+Shift+I, H |
| **Import Final Draft...** | Cmd+Shift+I, D |
| Export to Fountain... | Cmd+Shift+E, F |
| Export to Highland... | Cmd+Shift+E, H |
| Export to Final Draft... | Cmd+Shift+E, D |
| Minimize | Cmd+M |
| Cycle Windows | Cmd+` |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-12 | Claude Code | Initial draft |
| 1.1 | 2025-10-12 | Claude Code | Updated to use GuionViewer component, added drag-and-drop support (REQ-UI-004), restructured File menu with Import submenu (REQ-IMP-005), updated keyboard shortcuts |
| 1.2 | 2025-10-12 | Claude Code | Named app "GuionView" (REQ-APP-001), added app icon requirements inspired by Preview.app (REQ-APP-002), added bundle configuration requirement (REQ-PLAT-003), updated application structure |

---

**End of Requirements Document**
