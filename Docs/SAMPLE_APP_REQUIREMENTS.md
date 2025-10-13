# SwiftGuion Sample App Requirements

**Document Version:** 2.1 MVP
**Date:** October 13, 2025
**Status:** Draft - Simplified for v2.1.0 Release
**Target:** SwiftGuion v2.1.0 Sample App

---

## Executive Summary

This document defines the **MVP requirements** for **GuionView**, a macOS sample application that demonstrates the capabilities of the SwiftGuion library.

**Primary Goal:** Serve as a reference implementation showing how to integrate SwiftGuion into a document-based macOS app.

**Scope for v2.1.0:**
- Open and save .guion TextPack files
- Import from .fountain, .highland, and .fdx formats
- Export to .fountain, .highland, and .fdx formats
- Display screenplay structure using GuionViewer component
- Basic error handling and user feedback

**Out of Scope for v2.1.0:** Complex features like undo/redo, preferences UI, crash recovery, find functionality, and advanced window management. These are deferred to Phase 2 (post-v2.1.0).

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

### 1.3 Scope for v2.1.0 MVP

**✅ In Scope (v2.1.0):**
- Native .guion TextPack file support (open/save)
- Import from .fountain, .highland, and .fdx formats
- Export to .fountain, .highland, and .fdx formats
- GuionViewer component for screenplay structure browsing
- Resizable window interface (600x800 minimum)
- Basic error handling with simple alerts
- File type associations (.guion, .fountain, .highland, .fdx)
- Drag-and-drop file import
- macOS-native DocumentGroup architecture

**❌ Out of Scope (v2.1.0) - Deferred to Phase 2:**
- Undo/Redo operations (REQ-EDIT-001)
- User preferences UI (REQ-PREF-001)
- Crash recovery/auto-save UI (REQ-DOC-004)
- Version browsing (REQ-DOC-005)
- Custom unsaved dialogs (REQ-DOC-006)
- Export validation (REQ-EXP-005)
- Format migration UI (REQ-EXP-006)
- Complex import error recovery (REQ-IMP-005)
- Time estimation for operations (REQ-IMP-004)
- Window state persistence (REQ-WIN-004)
- Advanced window commands (REQ-WIN-005)
- User notifications (REQ-UI-005)
- Complex progress feedback (REQ-UI-006)
- In-app Help Book (REQ-HELP-001)
- Find in document (REQ-FIND-001)

**🚫 Permanently Out of Scope:**
- Screenplay editing (text editing, formatting)
- Printing or PDF generation
- Collaboration features (sharing, comments)
- Cloud synchronization
- iOS/iPadOS versions
- Plugin architecture
- Custom themes or UI customization

---

## 2. v2.1.0 MVP Requirements Summary

### 2.0.1 Requirements Included in v2.1.0

**Document Management (P0 - Critical):**
- ✅ REQ-DOC-001: Open .guion Files
- ✅ REQ-DOC-002: Save .guion Files (TextPack format)
- ✅ REQ-DOC-003: New Document Creation

**Import (P0 - Critical):**
- ✅ REQ-IMP-001: Import .fountain Files
- ✅ REQ-IMP-002: Import .highland Files
- ✅ REQ-IMP-003: Import .fdx Files
- ✅ REQ-IMP-006: File Menu Structure (simplified shortcuts)

**Export (P0 - Critical):**
- ✅ REQ-EXP-001: Export to .fountain Format
- ✅ REQ-EXP-002: Export to .highland Format
- ✅ REQ-EXP-003: Export to .fdx Format
- ✅ REQ-EXP-004: Export Menu Structure

**User Interface (P0 - Critical):**
- ✅ REQ-UI-001: Display GuionViewer
- ✅ REQ-UI-002: GuionViewer Interaction
- ✅ REQ-UI-003: Empty State Display
- ✅ REQ-UI-004: Drag-and-Drop Import

**Window Management (P0 - Critical):**
- ✅ REQ-WIN-001: Resizable Window
- ✅ REQ-WIN-002: Multiple Windows
- ✅ REQ-WIN-003: Standard Window Controls

**Platform (P0 - Critical):**
- ✅ REQ-APP-001: Application Name and Branding
- ✅ REQ-APP-002: Application Icon
- ✅ REQ-PLAT-001: macOS Version Support
- ✅ REQ-PLAT-002: Architecture (SwiftUI, SwiftData, DocumentGroup)
- ✅ REQ-PLAT-003: Bundle Configuration
- ✅ REQ-FTA-001: File Type Registration
- ✅ REQ-FTA-002: UTType Declarations

**Reliability (P0 - Critical):**
- ✅ REQ-REL-001: Error Handling (simplified - basic alerts)
- ✅ REQ-REL-002: Data Integrity

**Accessibility (P1 - High):**
- ✅ REQ-ACC-001: VoiceOver Support (basic)
- ✅ REQ-ACC-002: Keyboard Navigation
- ✅ REQ-ACC-003: Visual Accessibility

**Performance (P2 - Medium, soft requirements):**
- ✅ REQ-PERF-001: File Load Performance (no hard numbers)
- ✅ REQ-PERF-002: Scene Browser Rendering
- ✅ REQ-PERF-003: Export Performance

**Total MVP Requirements: 28**

### 2.0.2 Requirements Deferred to Phase 2

**Deferred - Too Complex for Sample App:**
- ❌ REQ-DOC-004: Crash Recovery (system auto-save sufficient)
- ❌ REQ-DOC-005: Version Browsing (system provides)
- ❌ REQ-DOC-006: Close Unsaved Document (system provides)
- ❌ REQ-EDIT-001: Undo/Redo Operations
- ❌ REQ-IMP-004: Import User Experience (time estimation removed)
- ❌ REQ-IMP-005: Import Failure Recovery (complex error UI removed)
- ❌ REQ-EXP-005: Export Validation
- ❌ REQ-EXP-006: Format Version Migration
- ❌ REQ-WIN-004: Window State Persistence
- ❌ REQ-WIN-005: Window Management Commands (advanced)
- ❌ REQ-UI-005: Operation Success Feedback (notifications removed)
- ❌ REQ-UI-006: Operation Progress Feedback (time estimates removed)
- ❌ REQ-PREF-001: User Preferences
- ❌ REQ-USE-001: First-Run Experience
- ❌ REQ-USE-002: Error Recovery (advanced)
- ❌ REQ-HELP-001: In-App Help System
- ❌ REQ-HELP-002: Sample Screenplay (simplified to basic .fountain file)
- ❌ REQ-FIND-001: Find in Document

**Total Deferred: 18**

**Simplification Impact:** ~64% reduction in complexity (18/46 requirements deferred)

---

## 3. Functional Requirements (Detailed)

This section contains the complete requirement specifications. Requirements marked as **DEFERRED** are listed for completeness but not included in v2.1.0 MVP.

### 3.1 Document Management

#### 3.1.1 Native .guion File Support

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
**Description**: The app shall save documents to .guion TextPack format, preserving all screenplay data and metadata.

**Acceptance Criteria:**
- User can select File → Save or press Cmd+S to save current document
- File → Save As... or Cmd+Shift+S prompts for file location
- All screenplay elements saved to TextPack bundle format
- TextPack structure includes:
  - info.json (metadata: version, dates, filename)
  - screenplay.fountain (complete screenplay)
  - Resources/ directory with JSON exports:
    - characters.json (character dialogue counts, scene appearances)
    - locations.json (location data with INT/EXT, time-of-day)
    - elements.json (all screenplay elements with IDs)
    - titlepage.json (title page entries)
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

**REQ-DOC-004**: Crash Recovery
**Priority**: ~~P0 (Critical)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: The app shall automatically recover documents after unexpected crashes or force quits.

**Rationale for Deferral**: macOS DocumentGroup provides automatic auto-save functionality. Custom crash recovery UI is over-engineered for a sample app demonstrating library capabilities.

**Acceptance Criteria:**
- Auto-saved versions preserved in `~/Library/Application Support/GuionView/AutoSave/`
- Auto-save creates backup every N minutes based on preferences (default: 5 minutes)
- Temporary backup named: `[filename].[random-uuid].guion`
- On clean application quit, temporary backups deleted
- On crash/force quit, temporary backups preserved
- On relaunch after crash, recovery dialog shown automatically
- Recovery dialog displays:
  - Document name
  - Last auto-save time (human-readable, e.g., "5 minutes ago")
  - File size of recovered version
- User options: "Recover", "Don't Recover", "Show in Finder"
- Recovered documents marked with "Recovered" badge in title bar until explicitly saved
- Recovery data automatically cleaned up after 7 days
- Maximum 10 recovery files retained (oldest deleted first)

---

**REQ-DOC-005**: Version Browsing
**Priority**: ~~P1 (High)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: The app shall support macOS Versions for browsing document history.

**Rationale for Deferral**: macOS FileDocument provides this automatically. No custom implementation needed for sample app.

**Acceptance Criteria:**
- File → Revert To → Browse All Versions... available when document has been saved
- Integration with Time Machine backups (if available)
- User can browse and compare current version with previous versions
- Restore previous version with confirmation dialog:
  - "Are you sure you want to restore [filename] to the version from [date/time]?"
  - "Your current version will be saved as a backup."
- Version metadata shows date/time stamp for each saved version
- Standard macOS Versions interface used (no custom implementation needed)
- Menu item disabled for unsaved documents

---

**REQ-DOC-006**: Close Unsaved Document
**Priority**: ~~P0 (Critical)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP - System provides this automatically
**Description**: The app shall prompt users before closing documents with unsaved changes.

**Rationale for Deferral**: FileDocument protocol provides standard macOS unsaved changes handling automatically. No custom implementation needed.

**Acceptance Criteria:**
- "Do you want to save changes to [filename]?" alert sheet appears
- Three options provided:
  - **Save** (default, blue button): Triggers save or save dialog if never saved
  - **Don't Save** (destructive, red text): Discards all changes since last save
  - **Cancel**: Returns to document without closing
- Alert triggered by:
  - Cmd+W (Close Window)
  - Red close button click
  - Quit application with unsaved documents
  - System shutdown/logout with unsaved documents
- If document never saved, "Save" button shows save dialog with suggested filename
- Don't Save confirms with secondary alert if > 100 elements would be lost
- Auto-save reduces frequency of this dialog (only shown if changes since last auto-save)
- When quitting with multiple unsaved documents, shows "Review Unsaved..." dialog

---

#### 3.1.2 Document Editing

**REQ-EDIT-001**: Undo/Redo Operations
**Priority**: ~~P1 (High)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: Users shall be able to undo and redo document-modifying operations.

**Rationale for Deferral**: Full undo/redo system with grouping, descriptive names, and 50-level stack is production-grade feature. Too complex for sample app. For MVP, operations are either accepted or cancelled.

**Acceptance Criteria:**
- Undo and Redo commands available in Edit menu
- Edit → Undo (Cmd+Z): Reverses last operation
- Edit → Redo (Cmd+Shift+Z): Re-applies last undone operation
- Menu items show descriptive action names:
  - "Undo Import Fountain" (not generic "Undo")
  - "Redo Export to FDX"
  - "Undo Title Page Change"
- Undoable operations include:
  - Import from any format
  - Element modifications (when editing implemented)
  - Title page changes
  - Scene number modifications
  - Bulk operations (delete, move)
- Undo stack maximum depth configurable in Preferences (default: 50 levels)
- Undo stack cleared when:
  - Document closed
  - Document saved and preference "Clear undo after save" enabled (default: off)
  - Explicit "Clear History" command (Edit → Clear History)
- Undo/Redo state persists across auto-save (not cleared)
- Memory-efficient: Stores diffs when possible, not full document copies
- Undo grouping: Related operations grouped into single undo action
  - Example: Import creates single undo group even if multiple internal operations
- Menu items disabled when no undo/redo available (grayed out)
- Keyboard shortcuts work throughout application
- VoiceOver announces undo/redo action descriptions
- Undo/Redo triggers dirty document indicator appropriately:
  - Undo to last saved state clears dirty indicator
  - Redo from last saved state sets dirty indicator
- Performance: Undo operations complete in < 100ms for typical changes
- If undo stack exceeds maximum, oldest actions removed (FIFO)

---

### 3.2 Import Capabilities

**REQ-IMP-001**: Import .fountain Files
**Priority**: P0 (Critical)
**Description**: The app shall import Fountain-formatted screenplay files (.fountain extension) via File menu or drag-and-drop.

**Acceptance Criteria:**
- File → Import → Fountain... or Cmd+I prompts file selection dialog filtered to .fountain
- Drag-and-drop .fountain files directly onto GuionViewer window
- Uses FountainParser (state machine parser) for parsing
- All element types imported (scene headings, action, dialogue, etc.)
- Title page metadata preserved
- Scene numbers preserved (if present)
- Section headers preserved with correct hierarchy
- Import creates immutable GuionParsedScreenplay first, then converts to GuionDocumentModel
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
- XML structure parsed using FDXParser (renamed from FDXDocumentParser)
- All paragraph types mapped to GuionElement types
- Scene properties (numbers, etc.) preserved
- Title page content extracted and preserved
- Character formatting handled (bold, italic, underline)
- Creates GuionParsedScreenplay from FDX elements, then converts to GuionDocumentModel
- Import errors logged with diagnostic information
- Partial import supported (continues on non-critical errors)
- Imported content displayed in GuionViewer

---

**REQ-IMP-004**: Import User Experience
**Priority**: ~~P0 (Critical)~~ **SIMPLIFIED FOR v2.1.0 MVP**
**Status**: Included in v2.1.0 with simplifications
**Description**: Import operations shall provide clear feedback and error handling.

**Rationale for Simplification**: Time estimation adds complexity without being essential for MVP. Basic progress indication and error messages are sufficient.

**Acceptance Criteria (v2.1.0 MVP):**
- Progress indicator shown during import (spinning cursor or progress bar)
- ~~Estimated time shown for large files~~ **REMOVED** - Simple progress bar sufficient
- Cancel button available during long imports (operations are cancellable)
- Detailed error messages for parse failures with specific line numbers
- File path shown in error dialogs
- Import source format preserved in document metadata

---

**REQ-IMP-005**: Import Failure Recovery
**Priority**: ~~P0 (Critical)~~ **SIMPLIFIED FOR v2.1.0 MVP**
**Status**: Included in v2.1.0 with simplifications
**Description**: Import failures shall provide clear error messages.

**Rationale for Simplification**: Complex error recovery UI with log viewing, context display, and "View in Editor" is over-engineered for sample app. Basic error alerts are sufficient for MVP.

**Acceptance Criteria (v2.1.0 MVP):**
- Parsing errors display simple alert dialog with:
  - Error type (e.g., "Invalid Scene Heading", "Parse Error")
  - Line number where error occurred (if available)
  - Error message text
- Error dialog buttons:
  - **OK**: Dismisses dialog, returns to previous state
  - **Copy Error**: Copies error message to clipboard for bug reporting
- Failed imports never modify or delete original file
- ~~Error logging system~~ **REMOVED** - Console logging sufficient for MVP
- ~~Help menu log access~~ **REMOVED** - Not needed for sample app

---

**REQ-IMP-006**: File Menu Structure
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

### 3.3 Export Capabilities

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
- Converts GuionDocumentModel to GuionParsedScreenplay, then to FDX
- Uses FDXDocumentWriter for XML generation
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

**REQ-EXP-005**: Export Validation
**Priority**: ~~P1 (High)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: Exported files shall be validated for correctness before completion.

**Rationale for Deferral**: Export validation with parse-back, element counting, and detailed reporting is production-grade feature. For MVP, exports are trusted to work correctly if library tests pass. Users can manually verify exports.

**Acceptance Criteria (Deferred):**
- After export write completes, file is parsed back to verify validity
- Validation checks:
  - File can be read successfully
  - File parses without errors
  - Element count matches source document (±5% tolerance for format differences)
  - Title page entries preserved
  - Critical data not lost (scene headings, character names)
- If validation fails:
  - Warning dialog: "Export may have issues. Validation found [N] problems."
  - Show list of validation issues (e.g., "3 scene headings missing")
  - Options: "Export Anyway", "Cancel and Review", "Show Details"
  - Details button expands to show full validation report
- If validation succeeds:
  - Success notification: "Exported to [filename]" with "Reveal in Finder" button
  - No modal dialog (non-intrusive)
- Validation can be disabled in Preferences → Advanced → "Validate exports"
- Validation errors logged to `~/Library/Logs/GuionView/export-errors.log`
- Validation timeout: 30 seconds (after which export is considered successful with warning)

---

**REQ-EXP-006**: Format Version Migration
**Priority**: ~~P0 (Critical)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: The app shall migrate documents from older .guion format versions transparently.

**Rationale for Deferral**: v2.1.0 introduces TextPack format as version 1.0. No previous versions exist yet, so migration is not needed in MVP. Will be required when format v2.0 is introduced.

**Acceptance Criteria:**
- Document format version stored in file header
- Current format version: 1.0
- On open, if document version < current version:
  - Document automatically upgraded to current version
  - Original file backed up to: `[filename].guion.v[N].backup`
  - Backup created before any modifications
  - Backup kept until user explicitly saves migrated document
  - Info banner shown: "Document upgraded from version [N] to [M]"
  - Banner includes "Learn More" link to format changes documentation
- Migration process:
  - Reads old format
  - Converts to new format in memory
  - Original file unchanged until user saves
  - Save operation writes new format
- Migration errors:
  - If migration fails, document refuses to open
  - Error dialog: "Cannot upgrade document from version [N]"
  - Suggestion: "This version requires GuionView [X.Y] or later"
  - "Show Backup" button reveals backup file in Finder
- User can revert to backup via File → Revert To → [Version N Backup]
- Format changes documented in Help → Release Notes

---

### 3.4 User Interface

#### 3.4.1 GuionViewer Component

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

#### 3.4.2 Window Management

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

**REQ-WIN-004**: Window State Persistence
**Priority**: ~~P1 (High)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: Window state shall persist across application launches for improved user experience.

**Rationale for Deferral**: Window state persistence with per-document tracking, scroll position, and expanded/collapsed state requires significant implementation complexity. macOS provides basic window position persistence automatically. Custom persistence is nice-to-have for sample app.

**Acceptance Criteria:**
- Window state stored per-document (by file path) in local preferences
- Window state includes:
  - Window size (width and height in points)
  - Window position (x, y coordinates)
  - Scroll position (vertical offset)
  - Expanded/collapsed chapter IDs
  - Expanded/collapsed scene group IDs
- On document reopen, window restores to previous state
- If window position is off-screen (external monitor disconnected), window centered on main screen
- Default window state for new documents: 800×1000 points, centered on main screen
- State stored in: `~/Library/Application Support/GuionView/window-state.plist`
- State cleared for documents not opened in 90 days (automatic cleanup)
- Preference toggle in Preferences → General → "Restore window positions" (on by default)
- State migration handled gracefully if file moved/renamed

---

**REQ-WIN-005**: Window Management Commands
**Priority**: ~~P1 (High)~~ **SIMPLIFIED FOR v2.1.0 MVP**
**Status**: Included in v2.1.0 with simplifications
**Description**: Users shall be able to manage multiple document windows efficiently.

**Rationale for Simplification**: Basic window menu with document list is sufficient for MVP. Advanced commands like "Minimize All", "Zoom All", and "More Windows..." submenu are over-engineered for sample app.

**Acceptance Criteria (v2.1.0 MVP):**
- Window menu includes basic commands:
  - **Minimize** (Cmd+M): Minimizes current window
  - ~~**Minimize All**~~ **REMOVED** - Not essential
  - **Zoom** (no shortcut): Toggles current window zoom
  - ~~**Zoom All**~~ **REMOVED** - Not essential
  - ~~**Bring All to Front**~~ **REMOVED** - System provides this
  - Separator
  - List of open documents (all documents shown, no limit)
  - ~~"More Windows..." submenu~~ **REMOVED** - Sample app unlikely to have 10+ documents
- Current window indicated with checkmark (✓) in window list
- Clicking window menu item brings that window to front and focuses it
- Window titles shown as-is in menu (no truncation needed for MVP)
- Keyboard shortcut Cmd+` cycles through windows

---

#### 3.4.3 User Feedback

**REQ-UI-005**: Operation Success Feedback
**Priority**: ~~P1 (High)~~ **SIMPLIFIED FOR v2.1.0 MVP**
**Status**: Included in v2.1.0 with simplifications
**Description**: Successful operations shall provide clear, non-intrusive feedback to users.

**Rationale for Simplification**: Native macOS notifications with subtitles, action buttons, and Do Not Disturb integration are over-engineered. Simple status messages are sufficient for MVP.

**Acceptance Criteria (v2.1.0 MVP):**
- Import success:
  - Simple message in status area or brief alert: "Imported [filename]"
  - No statistics needed
- Export success:
  - Simple message: "Exported to [filename]"
  - ~~Action button "Reveal in Finder"~~ **REMOVED** - User can find file manually
- Save success:
  - No message (dirty indicator cleared is sufficient feedback)
- ~~Notifications system~~ **REMOVED** - Simple alerts sufficient
- ~~Preference toggle~~ **REMOVED** - No preferences UI in MVP
- Screen reader announces success (VoiceOver compatible)

---

**REQ-UI-006**: Operation Progress Feedback
**Priority**: ~~P1 (High)~~ **SIMPLIFIED FOR v2.1.0 MVP**
**Status**: Included in v2.1.0 with simplifications
**Description**: Long-running operations shall show basic progress indication.

**Rationale for Simplification**: Detailed progress sheets with time estimation, detailed status text, and 60 FPS throttling are over-engineered. Simple indeterminate progress indicator is sufficient for MVP.

**Acceptance Criteria (v2.1.0 MVP):**
- Basic progress indicator appears for operations expected to take > 2 seconds
- Progress indicator attached to document window
- Progress indicator shows:
  - **Title**: Operation type (e.g., "Importing Screenplay", "Exporting...")
  - **Filename**: Filename being processed
  - **Progress bar**: Indeterminate spinner or simple progress bar
  - ~~**Status text**~~ **REMOVED** - Title sufficient
  - ~~**Details count**~~ **REMOVED** - Not needed for MVP
  - ~~**Time remaining**~~ **REMOVED** - Not needed for MVP
  - ~~**Cancel button**~~ **REMOVED** - Operations complete quickly enough
- ~~Progress updates throttled~~ **REMOVED** - Simple implementation
- ~~Detailed status messages~~ **REMOVED** - Basic title sufficient
- On completion:
  - Progress indicator dismisses automatically
- On error:
  - Progress indicator dismissed
  - Error dialog shown

---

### 3.5 File Type Associations

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

### 3.6 Performance Requirements

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

## 4. Non-Functional Requirements

### 4.1 Application Identity

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

### 4.2 Platform Requirements

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

### 4.3 Reliability

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

### 4.4 Accessibility

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

### 4.5 Usability

**REQ-USE-001**: First-Run Experience
**Priority**: ~~P2 (Medium)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: New users shall quickly understand how to use the app.

**Rationale for Deferral**: Welcome screens, tooltips, and first-run onboarding are nice-to-have for sample app. README and sample screenplay are sufficient for MVP.

**Acceptance Criteria:**
- Welcome screen shown on first launch (optional)
- Sample screenplay available via File → Open Sample
- Help menu links to documentation
- Tooltips available for non-obvious UI elements

---

**REQ-USE-002**: Error Recovery
**Priority**: ~~P1 (High)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: Users shall be able to recover from errors without losing work.

**Rationale for Deferral**: Advanced error recovery is covered by system auto-save. Undo/redo is already deferred. Confirm dialogs for destructive actions are provided by FileDocument automatically. This requirement is redundant with existing system features.

**Acceptance Criteria:**
- Import errors preserve original file
- Export errors don't overwrite existing files
- Undo/redo available where applicable
- Confirm dialogs for destructive actions

---

### 4.6 Preferences

**REQ-PREF-001**: User Preferences
**Priority**: ~~P1 (High)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: Users shall be able to configure application behavior through a Preferences window.

**Rationale for Deferral**: Full preferences UI with tabbed interface, sliders, and multiple settings is production-grade feature. Sample app can use sensible defaults without configuration UI.

**Acceptance Criteria:**
- GuionView → Preferences... (Cmd+,) opens Preferences window
- Preferences window uses native macOS tabbed interface
- Preferences window is singleton (only one instance, reuses existing if open)
- Window size: 600×400 points, not resizable
- Three tabs: **General**, **Appearance**, **Advanced**
- **General Tab:**
  - **Auto-save interval**: Slider with values 1, 2, 5, 10, 15, 30 minutes (default: 5)
    - Label: "Auto-save documents every: [N] minutes"
    - Tooltip: "How often unsaved changes are automatically backed up"
  - **Window state persistence**: Checkbox (default: on)
    - Label: "Restore window positions"
    - Description: "Remember window size and position for each document"
  - **Success notifications**: Checkbox (default: on)
    - Label: "Show success notifications"
    - Description: "Display notifications for completed imports and exports"
- **Appearance Tab:**
  - **Font size**: Slider with percentage 80%, 90%, 100%, 110%, 125%, 150% (default: 100%)
    - Label: "Scene browser text size: [N]%"
    - Live preview of sample text at selected size
  - **Spacing mode**: Radio buttons (default: Comfortable)
    - Options: "Compact", "Comfortable", "Spacious"
    - Description: "Vertical spacing between scene elements"
  - **Show element counts**: Checkbox (default: on)
    - Label: "Show scene element counts"
    - Description: "Display number of elements in each scene group"
- **Advanced Tab:**
  - **Validation settings**:
    - "Validate exports" checkbox (default: on)
    - "Validate imports" checkbox (default: on)
    - Description: "Verify file integrity after import/export operations"
  - **Performance**:
    - "Maximum undo levels": Stepper with range 10-100 (default: 50)
    - Label: "Maximum undo levels: [N]"
    - Description: "More levels use more memory"
  - **Developer**:
    - "Enable debug logging" checkbox (default: off)
    - Button: "Show Logs Folder"
    - Button: "Clear Import/Export Logs"
- All preferences persist to UserDefaults immediately on change
- No "Apply" or "OK" button needed (changes are immediate)
- Preferences apply to all open documents and future launches
- Preferences reset available: "Restore Defaults" button on each tab
- Keyboard navigation works throughout (Tab, Space, Arrow keys)
- VoiceOver announces all controls and their current values
- Help button (?) opens help book to Preferences section

---

## 5. Technical Architecture

### 5.1 Application Structure

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

### 5.2 Key Components

#### 5.2.1 GuionDocument (FileDocument)

**Purpose**: Implements FileDocument protocol for document-based architecture.

**Responsibilities:**
- Read/write .guion TextPack files using TextPackReader/TextPackWriter
- Import from .fountain, .highland, .fdx formats
- Lazy-load document data to avoid MainActor conflicts
- Store immutable GuionParsedScreenplay (Sendable)
- Provide GuionDocumentModel to views via @MainActor accessor
- Convert between immutable (GuionParsedScreenplay) and mutable (GuionDocumentModel) representations

**Key Methods:**
```swift
// Nonisolated initializer - reads file, creates GuionParsedScreenplay
init(configuration: ReadConfiguration) throws

// Nonisolated write - converts model to GuionParsedScreenplay, then to TextPack
func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper

// MainActor accessor - converts GuionParsedScreenplay to GuionDocumentModel
@MainActor var documentModel: GuionDocumentModel { get }
```

**Architecture:**
```swift
final class GuionDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.guionDocument, .fountain, .highland, .fdx]

    // Immutable, Sendable screenplay (safe to store in nonisolated context)
    private var screenplay: GuionParsedScreenplay?

    // Cache for converted model (MainActor-isolated)
    @MainActor private var cachedModel: GuionDocumentModel?

    init(configuration: ReadConfiguration) throws {
        // Parse file to GuionParsedScreenplay (nonisolated, Sendable)
        if configuration.contentType == .guionDocument {
            self.screenplay = try TextPackReader.readTextPack(from: configuration.file)
        } else if configuration.contentType == .fountain {
            let data = try configuration.file.regularFileContents ?? Data()
            let content = String(data: data, encoding: .utf8) ?? ""
            self.screenplay = try GuionParsedScreenplay(string: content)
        }
        // ... other formats
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Convert model back to screenplay, then to TextPack
        let screenplay = await documentModel.toGuionParsedScreenplay()
        return try TextPackWriter.createTextPack(from: screenplay)
    }

    @MainActor
    var documentModel: GuionDocumentModel {
        // Convert and cache on first access
        // ...
    }
}
```

#### 5.2.2 ContentView

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

#### 5.2.3 ImportCommands

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

#### 5.2.4 ExportCommands

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

### 5.3 Data Flow

#### Import Flow:
```
1. User: File → Import → [Format]
2. Show NSOpenPanel filtered to format
3. Read file data
4. Parse using appropriate parser:
   - .fountain: FountainParser (state machine)
   - .fdx: FDXParser (XML)
   - .highland: Extract ZIP, parse TextBundle → Fountain
5. Create immutable GuionParsedScreenplay from parsed data
6. Convert to GuionDocumentModel using GuionDocumentModel.from(_:in:)
7. Set as current document
8. Update GuionViewer display
```

#### Save Flow (TextPack):
```
1. User: File → Save (Cmd+S)
2. GuionDocument.fileWrapper() called
3. Convert GuionDocumentModel to GuionParsedScreenplay using toGuionParsedScreenplay()
4. Use TextPackWriter.createTextPack(from:) to create bundle
5. TextPack bundle structure created:
   - info.json (metadata)
   - screenplay.fountain (complete screenplay)
   - Resources/ directory:
     - characters.json
     - locations.json
     - elements.json
     - titlepage.json
6. FileWrapper returned with directory bundle
7. System writes to disk atomically
```

#### Export Flow:
```
1. User: File → Export → [Format]
2. Show NSSavePanel with suggested filename
3. Convert GuionDocumentModel to GuionParsedScreenplay using toGuionParsedScreenplay()
4. Call appropriate writer method:
   - .fountain: screenplay.write(to:)
   - .highland: Use TextPackWriter (similar to .guion but in ZIP)
   - .fdx: FDXDocumentWriter.write() with GuionParsedScreenplay elements
5. Write data to selected location
6. Validate exported file (parse back to verify)
7. Show success/error message
```

### 5.4 Concurrency Strategy

**Challenge**: SwiftData's @MainActor requirements conflict with FileDocument's nonisolated initializers.

**Solution**: Lazy Loading with Immutable Types

```swift
// Store Sendable, immutable data in nonisolated context
private var screenplay: GuionParsedScreenplay?  // Sendable, thread-safe

// Compute model on-demand in MainActor context
@MainActor
var documentModel: GuionDocumentModel {
    guard let screenplay = screenplay else {
        return GuionDocumentModel()  // Empty document
    }

    // Convert immutable → mutable on first access
    // Cache the result to avoid repeated conversions
    if let cached = cachedModel {
        return cached
    }

    let model = await GuionDocumentModel.from(screenplay, in: modelContext)
    cachedModel = model
    return model
}
```

**Benefits:**
- No MainActor isolation conflicts
- GuionParsedScreenplay is Sendable (truly thread-safe, no @unchecked)
- Explicit conversion between immutable and mutable representations
- Clear separation of concerns (parsing vs persistence)
- Performance: Conversion cached after first access
- Thread safety: GuionParsedScreenplay can be passed between threads safely

**Architecture Pattern:**
1. **Read**: FileDocument reads file → creates GuionParsedScreenplay (nonisolated)
2. **Store**: Screenplay stored as private property (Sendable, safe)
3. **Convert**: On first access, convert to GuionDocumentModel (@MainActor)
4. **Cache**: Cache converted model to avoid repeated work
5. **Write**: Convert GuionDocumentModel back to GuionParsedScreenplay → TextPack

---

## 6. Testing Requirements

### 6.1 Unit Tests

**Test Coverage Required:**
- Import from each format (.fountain, .highland, .fdx)
- Export to each format
- Round-trip testing (import → export → import → compare)
- Error handling (corrupted files, unsupported versions)
- Empty document handling
- Large file handling (> 5 MB)

### 6.2 Integration Tests

**Test Scenarios:**
- Open .guion file → displays in Scene Browser
- Import .fountain → save as .guion → reopen
- Create new document → import → export → verify
- Multiple windows with different documents
- Window state persistence across launches

### 6.3 Manual Testing Checklist

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

## 7. Documentation Requirements

### 7.1 README

**Required Sections:**
- Brief description of app purpose
- Features list
- Installation instructions
- Build instructions
- Usage examples with screenshots
- Known limitations
- License information

### 7.2 Code Documentation

**Requirements:**
- All public types documented with /// comments
- Complex algorithms explained
- Concurrency patterns noted
- Example usage in documentation

### 7.3 In-App Help System

**REQ-HELP-001**: In-App Help System
**Priority**: ~~P1 (High)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: The app shall provide comprehensive built-in help documentation accessible from the Help menu.

**Rationale for Deferral**: macOS Help Book with searchable content, context-sensitive help, and detailed sections is production-grade feature. README documentation is sufficient for sample app MVP.

**Acceptance Criteria:**
- Help → GuionView Help (Cmd+?) opens macOS Help Book
- Help Book bundled with application (not web-based)
- Help content searchable via Spotlight Help search
- Help Book sections:
  - **Getting Started**: Overview, first steps, opening files
  - **Working with Documents**: Creating, saving, importing, exporting
  - **File Formats**: Detailed format explanations (.guion, .fountain, .highland, .fdx)
  - **Importing Screenplays**: Step-by-step import instructions for each format
  - **Exporting Screenplays**: Export process and format recommendations
  - **Scene Browser**: Understanding hierarchical structure, navigation
  - **Keyboard Shortcuts**: Complete reference table (Appendix B reproduced)
  - **Troubleshooting**: Common issues and solutions
  - **Preferences**: All preference explanations
- Help content written in clear, non-technical language
- Screenshots included for key workflows (import, export, preferences)
- Context-sensitive help available:
  - Help button (?) in Preferences opens relevant help section
  - Help → Search allows searching help content
  - Related help topics linked within pages
- Help menu also includes:
  - **GuionView Help** (Cmd+?)
  - Separator
  - **Send Feedback...**: Opens email or web form
  - **View Import Logs...**: Opens Finder to log directory
  - **Recent Import Errors...**: Shows recent error summary
  - **Release Notes**: Opens notes for current version
- Help Book indexed for macOS Help search (appears in menu bar search)
- Help content maintained in `.help` bundle format
- Help accessible without internet connection

---

**REQ-HELP-002**: Sample Screenplay
**Priority**: ~~P1 (High)~~ **SIMPLIFIED FOR v2.1.0 MVP**
**Status**: Included in v2.1.0 with simplifications
**Description**: The app shall include a bundled sample screenplay.

**Rationale for Simplification**: Full-featured sample with all formats, read-only enforcement, and detailed demonstrations is over-engineered. Simple sample.fountain file demonstrating basic structure is sufficient for MVP.

**Acceptance Criteria (v2.1.0 MVP):**
- ~~File → Open Sample menu item~~ **REMOVED** - User can manually open sample file
- Sample screenplay included as `sample.fountain` in project or resources
- Sample screenplay demonstrates basic structure:
  - Title page (simple)
  - Chapter markers (##) at Level 2
  - Scene groups (###) at Level 3
  - A few scene headings (INT/EXT)
  - Action, dialogue, character names
- Sample screenplay length: 5-10 pages (short and simple)
- Sample screenplay content: Original content or public domain
- ~~Sample in all formats~~ **REMOVED** - .fountain only for MVP
- Sample file bundled in `GuionView.app/Contents/Resources/sample.fountain`
- ~~Read-only enforcement~~ **REMOVED** - Treat as normal file
- ~~Info banner~~ **REMOVED** - Not needed
- ~~Help → About Sample~~ **REMOVED** - Credits in file header sufficient

---

### 7.4 Search and Navigation

**REQ-FIND-001**: Find in Document
**Priority**: ~~P2 (Medium)~~ **DEFERRED TO PHASE 2**
**Status**: Not included in v2.1.0 MVP
**Description**: Users shall be able to search for text within screenplay documents.

**Rationale for Deferral**: Full find functionality with incremental search, match highlighting, keyboard navigation, and preferences is production-grade feature. Not essential for sample app demonstrating library capabilities.

**Acceptance Criteria:**
- Edit → Find → Find... (Cmd+F) shows find bar
- Find bar appears at bottom of document window (non-modal)
- Find bar contains:
  - **Search field**: Text input with placeholder "Find"
  - **Match case checkbox**: Case-insensitive by default
  - **Previous button** (Cmd+Shift+G or up arrow in field)
  - **Next button** (Cmd+G or down arrow in field)
  - **Done button**: Closes find bar (Escape also closes)
- Search behavior:
  - Searches all text content: scene headings, action, dialogue, character names
  - Does not search: title page, section headers (unless preference enabled)
  - Incremental search: Results update as user types
  - Highlights all matches in yellow background
  - Current match highlighted in orange background
  - Scrolls to center current match in viewport
- Match counter: "3 of 47 matches" displayed in find bar
- No matches: "No matches found" displayed in red text
- Find bar state:
  - Find bar hidden by default
  - Find bar state per-window (not global)
  - Search term preserved when find bar reopened
  - Recent searches accessible via search field dropdown (last 10)
- Keyboard navigation:
  - Return/Enter in search field: Find next
  - Shift+Return: Find previous
  - Escape: Close find bar
  - Cmd+G: Find next (even when find bar closed)
  - Cmd+Shift+G: Find previous (even when find bar closed)
- Find bar respects VoiceOver:
  - Announces match count
  - Announces current match text
  - Accessible via keyboard navigation
- Preference available: "Search in section headers" (default: off)
- Preference available: "Wrap around when reaching end" (default: on)
- Find operations do not modify document (view-only)
- Performance: Search completes in < 100ms for typical screenplay
- Large screenplays (> 500 pages): Search shows progress for > 1s

---

## 8. Delivery Checklist

### 8.1 Code Completeness

- [ ] All REQ-* requirements implemented
- [ ] No compilation warnings
- [ ] No SwiftLint or formatting warnings
- [ ] All tests passing
- [ ] Code reviewed

### 8.2 Assets

- [ ] App icon (all sizes)
- [ ] Document icons for each file type
- [ ] About panel content
- [ ] Copyright and license files

### 8.3 Configuration

- [ ] Info.plist complete and correct
- [ ] Entitlements configured (if needed)
- [ ] Bundle identifier set
- [ ] Version numbers set
- [ ] Code signing configured (for distribution)

### 8.4 Documentation

- [ ] README.md complete
- [ ] Code documentation complete
- [ ] Example files included
- [ ] CHANGELOG.md started

---

## 9. Success Criteria

**GuionView** will be considered complete when:

1. **Functional**: All P0 and P1 requirements implemented and tested
2. **Reliable**: No crashes or data loss in normal operation
3. **Performant**: Meets all performance requirements
4. **Accessible**: VoiceOver and keyboard navigation work correctly
5. **Documented**: README and code documentation complete
6. **Exemplary**: Code quality suitable as reference implementation

---

## 10. Future Enhancements

Items out of scope for initial release but worth considering:

### 10.1 Phase 2 Features
- Scene editing capabilities (text editing)
- Character and location panels
- Search and filter functionality
- Print and PDF export
- Custom color schemes / themes

### 10.2 Phase 3 Features
- iOS/iPadOS companion app
- iCloud sync
- Collaboration features (comments, track changes)
- Integration with script analysis tools
- Plugin architecture for extensions

### 10.3 Advanced Features
- AI-powered scene analysis
- Beat sheet visualization
- Timeline view
- Character relationship graphs
- Export to production formats (call sheets, sides)

---

## 11. References

- [SwiftGuion Library Documentation](../README.md)
- [.guion File Format Specification](./GUION_FILE_FORMAT.md)
- [Fountain Format Specification](https://fountain.io)
- [Apple DocumentGroup Documentation](https://developer.apple.com/documentation/swiftui/documentgroup)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

---

## Appendix A: File Format Support Matrix

| Format | Extension | Import | Export | Native | Notes |
|--------|-----------|--------|--------|--------|-------|
| Guion TextPack | .guion | ✅ | ✅ | ✅ | Directory bundle with JSON exports |
| Fountain | .fountain | ✅ | ✅ | ❌ | Plain text, universal |
| Highland | .highland | ✅ | ✅ | ❌ | ZIP archive with TextBundle |
| Final Draft | .fdx | ✅ | ✅ | ❌ | XML format |
| TextBundle | .textbundle | ❌* | ❌ | ❌ | *Supported via .highland |

**TextPack Bundle Structure:**
```
MyScript.guion/
├── info.json              # Metadata (version, dates, filename)
├── screenplay.fountain    # Complete screenplay in Fountain format
└── Resources/
    ├── characters.json    # Character data (dialogue counts, scenes)
    ├── locations.json     # Location data (INT/EXT, time-of-day)
    ├── elements.json      # All screenplay elements with IDs
    └── titlepage.json     # Title page entries
```

---

## Appendix B: Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| **File Menu** | |
| New Document | Cmd+N |
| Open... | Cmd+O |
| Save | Cmd+S |
| Save As... | Cmd+Shift+S |
| Close Window | Cmd+W |
| Import Fountain... | Cmd+Shift+I, F |
| Import Highland... | Cmd+Shift+I, H |
| Import Final Draft... | Cmd+Shift+I, D |
| Export to Fountain... | Cmd+Shift+E, F |
| Export to Highland... | Cmd+Shift+E, H |
| Export to Final Draft... | Cmd+Shift+E, D |
| **Edit Menu** | |
| Undo | Cmd+Z |
| Redo | Cmd+Shift+Z |
| Find... | Cmd+F |
| Find Next | Cmd+G |
| Find Previous | Cmd+Shift+G |
| **Window Menu** | |
| Minimize | Cmd+M |
| Minimize All | Cmd+Option+M |
| Cycle Windows | Cmd+` |
| **Help Menu** | |
| GuionView Help | Cmd+? |
| **Application** | |
| Preferences... | Cmd+, |

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-12 | Claude Code | Initial draft |
| 1.1 | 2025-10-12 | Claude Code | Updated to use GuionViewer component, added drag-and-drop support (REQ-UI-004), restructured File menu with Import submenu (REQ-IMP-006), updated keyboard shortcuts |
| 1.2 | 2025-10-12 | Claude Code | Named app "GuionView" (REQ-APP-001), added app icon requirements inspired by Preview.app (REQ-APP-002), added bundle configuration requirement (REQ-PLAT-003), updated application structure |
| 1.3 | 2025-10-12 | Claude Code | Added critical requirements from analysis: crash recovery (REQ-DOC-004), version browsing (REQ-DOC-005), close unsaved (REQ-DOC-006), import failure recovery (REQ-IMP-005), export validation (REQ-EXP-005), format migration (REQ-EXP-006). Enhanced REQ-IMP-004 with specific progress calculation details. |
| 1.4 | 2025-10-12 | Claude Code | Added high-priority UX and window management requirements: window state persistence (REQ-WIN-004), window management commands (REQ-WIN-005), operation success feedback (REQ-UI-005), operation progress feedback (REQ-UI-006). Total requirements now: 41 (was 35). |
| 1.5 | 2025-10-12 | Claude Code | Added Phase 2B high-priority requirements: user preferences (REQ-PREF-001), undo/redo operations (REQ-EDIT-001), in-app help system (REQ-HELP-001), sample screenplay (REQ-HELP-002), find in document (REQ-FIND-001). Enhanced keyboard shortcuts table. Total requirements now: 46 (was 41). |
| 2.0 | 2025-10-13 | Claude Code | **ARCHITECTURE ALIGNMENT**: Updated all requirements to reflect SwiftGuion architecture redesign. Key changes: (1) Updated REQ-DOC-002 for TextPack bundle format with JSON exports. (2) Updated REQ-IMP-001/003 to use FountainParser/FDXParser (renamed). (3) Added immutable GuionParsedScreenplay → GuionDocumentModel conversion flow. (4) Updated REQ-EXP-003 to use new conversion pattern. (5) Completely rewrote Section 4.3 (Data Flow) with TextPack save flow. (6) Rewrote Section 4.4 (Concurrency Strategy) to explain lazy loading with Sendable types. (7) Expanded Section 4.2.1 (GuionDocument) with full architecture example. (8) Updated Appendix A with TextPack bundle structure. All parser references updated to current names. |
| 2.1 | 2025-10-13 | Claude Code | **v2.1.0 MVP SIMPLIFICATION**: Reduced requirements by 64% (28 core requirements, 18 deferred to Phase 2). Key changes: (1) Added Section 2 with comprehensive MVP requirements summary. (2) Deferred production-grade features: undo/redo (REQ-EDIT-001), preferences UI (REQ-PREF-001), crash recovery UI (REQ-DOC-004), version browsing (REQ-DOC-005), close unsaved custom UI (REQ-DOC-006), export validation (REQ-EXP-005), format migration (REQ-EXP-006), window state persistence (REQ-WIN-004), complex progress/success feedback (REQ-UI-005/006), in-app Help Book (REQ-HELP-001), find functionality (REQ-FIND-001), first-run experience (REQ-USE-001), advanced error recovery (REQ-USE-002). (3) Simplified 6 requirements to MVP-appropriate scope: import UX (REQ-IMP-004), import error recovery (REQ-IMP-005), window commands (REQ-WIN-005), sample screenplay (REQ-HELP-002). (4) All section numbering corrected. Focus: Demonstrate library capabilities with core open/save/import/export/display functionality. |

---

**End of Requirements Document**
