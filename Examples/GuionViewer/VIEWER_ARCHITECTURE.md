# GuionViewer - Read-Only Viewer Architecture

**Date:** 2025-10-14
**Status:** Architecture Design
**Pattern:** Read-Only Viewer with Explicit Export

---

## Philosophy

GuionViewer is a **viewer application**, not an editor. Think Preview.app or QuickTime Player:
- Open files read-only
- Display content without modification
- Export to different formats explicitly
- Original files **never** modified unless user chooses "Save As" → "Replace"

---

## Document Lifecycle

### Phase 1: Open File (Read-Only)

```
┌─────────────────────────────────────────────────────────────┐
│ USER ACTION: Open file                                      │
│ File → Open... or drag & drop                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Read file into memory (READ-ONLY)                           │
│                                                             │
│ ├─ .guion   → TextPackReader                               │
│ ├─ .fountain → FountainParser                              │
│ ├─ .fdx      → FDXParser                                   │
│ └─ .highland → HighlandReader                              │
│                                                             │
│ Result: GuionParsedScreenplay (immutable, Sendable)        │
│                                                             │
│ ⚠️  File handle CLOSED after reading                        │
│ ⚠️  No file monitoring / auto-save                          │
│ ⚠️  Original file UNTOUCHED                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Create in-memory document state                             │
│                                                             │
│ @Observable class ViewerDocument {                          │
│   let sourceURL: URL?           // Original file location   │
│   let sourceType: UTType        // Original format          │
│   var screenplay: GuionParsedScreenplay                     │
│   var displayModel: GuionDocumentModel  // For UI binding   │
│   var hasUnsavedChanges: Bool = false   // Always false!    │
│ }                                                           │
│                                                             │
│ ⚠️  NOT FileDocument or ReferenceFileDocument               │
│ ⚠️  Just @Observable for SwiftUI binding                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Display in GuionViewer component                            │
│                                                             │
│ Window title: "filename.fountain" (no "Edited" indicator)  │
│ Status: Read-only                                           │
│                                                             │
│ ⚠️  No save button, no auto-save                            │
│ ⚠️  File menu "Save" is DISABLED                            │
│ ✅ File menu "Export..." is ENABLED                         │
│ ✅ File menu "Save As..." is ENABLED                        │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 2: View Content (In-Memory Only)

```
┌─────────────────────────────────────────────────────────────┐
│ Display pipeline                                            │
│                                                             │
│ ViewerDocument.screenplay                                   │
│      │                                                      │
│      ▼                                                      │
│ ViewerDocument.displayModel                                 │
│  (GuionDocumentModel - SwiftData for UI reactivity)        │
│      │                                                      │
│      ▼                                                      │
│ SceneBrowserData.extractSceneBrowserData()                  │
│      │                                                      │
│      ▼                                                      │
│ GuionViewer → SceneWidget                                   │
│                                                             │
│ ⚠️  All in RAM, nothing persisted                           │
│ ⚠️  SwiftData ModelContext: isStoredInMemoryOnly = true     │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 3: Optional - Generate Summaries (Transient)

```
┌─────────────────────────────────────────────────────────────┐
│ USER ACTION: Menu → "Generate Summaries" (optional)        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ SceneSummarizer generates summaries                         │
│ - Runs in background                                        │
│ - Creates summary elements in memory                        │
│ - Updates displayModel.elements                             │
│                                                             │
│ ⚠️  Changes ONLY in memory                                  │
│ ⚠️  Not saved to original file                              │
│ ⚠️  Lost when window closes (unless exported)               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ UI updates to show summaries                                │
│ - Summary elements visible in expanded scenes               │
│ - Summary text in collapsed scenes                          │
│                                                             │
│ Window title: "filename.fountain" (still no "Edited")      │
│                                                             │
│ ✅ User can now export with summaries included              │
│ ❌ Original file still unchanged                            │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 4: Export to Different Format

```
┌─────────────────────────────────────────────────────────────┐
│ USER ACTION: File → Export → Fountain / FDX / Highland     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Show save panel                                             │
│ - Suggested name: original filename                         │
│ - Format: Selected export format                            │
│ - Location: User chooses                                    │
│                                                             │
│ ⚠️  Default location: NOT same as original file             │
│ ⚠️  Suggested location: ~/Documents or ~/Desktop            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Convert current in-memory state                             │
│                                                             │
│ displayModel.toGuionParsedScreenplay()                      │
│      │                                                      │
│      ├─ Export to Fountain → FountainWriter.document()     │
│      ├─ Export to FDX → FDXDocumentWriter.write()          │
│      └─ Export to Highland → TextPackWriter + convert      │
│                                                             │
│ ✅ Includes any generated summaries                         │
│ ✅ Preserves all formatting                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Write to new file location                                  │
│                                                             │
│ ⚠️  Original file UNTOUCHED                                 │
│ ✅ New file created at user-selected location               │
│                                                             │
│ Post-export:                                                │
│ - Window still shows original filename                      │
│ - sourceURL still points to original                        │
│ - User can export again to different formats               │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 5: Save As (Explicit Replace)

```
┌─────────────────────────────────────────────────────────────┐
│ USER ACTION: File → Save As...                             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Show save panel                                             │
│ - Format: Same as original OR user chooses                 │
│ - Location: User chooses                                    │
│                                                             │
│ Scenario A: User chooses DIFFERENT location                │
│   → Same as Export (create new file)                        │
│                                                             │
│ Scenario B: User chooses SAME filename/location            │
│   → System shows "Replace?" confirmation                    │
│      ├─ User clicks "Cancel" → abort                        │
│      └─ User clicks "Replace" → proceed ↓                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ EXPLICIT REPLACE CONFIRMATION                               │
│                                                             │
│ ┌───────────────────────────────────────────────┐           │
│ │ "example.fountain" already exists.            │           │
│ │ Do you want to replace it?                    │           │
│ │                                               │           │
│ │ [Cancel]  [Replace]                           │           │
│ └───────────────────────────────────────────────┘           │
│                                                             │
│ ⚠️  ONLY way to modify original file                        │
│ ⚠️  User MUST explicitly confirm                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Write to file (replacing original)                          │
│                                                             │
│ ✅ Original file now updated                                │
│ ✅ Includes any generated summaries                         │
│ ✅ Preserves format and structure                           │
│                                                             │
│ Post-save:                                                  │
│ - sourceURL updated to new location (if changed)           │
│ - Window title updated (if filename changed)               │
└─────────────────────────────────────────────────────────────┘
```

---

## Architecture Components

### 1. ViewerDocument (NOT FileDocument)

```swift
@Observable
final class ViewerDocument {
    // Original file metadata
    let sourceURL: URL?
    let sourceType: UTType
    let originalFilename: String

    // In-memory state (read-only from file)
    private(set) var screenplay: GuionParsedScreenplay

    // Display model (SwiftData for UI reactivity)
    private(set) var displayModel: GuionDocumentModel

    // State tracking
    var hasSummaries: Bool {
        displayModel.elements.contains {
            $0.elementType == "Section Heading" && $0.sectionDepth == 4
        }
    }

    // Initialize from file
    init(contentsOf url: URL) throws {
        self.sourceURL = url
        self.sourceType = /* detect from extension */
        self.originalFilename = url.lastPathComponent

        // Parse file based on type
        switch sourceType {
        case .guionDocument:
            self.screenplay = try TextPackReader.readTextPack(from: url)
        case .fountain:
            let content = try String(contentsOf: url)
            self.screenplay = try GuionParsedScreenplay(string: content)
        // ... other formats
        }

        // Create in-memory SwiftData model
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(...)
        let context = ModelContext(container)

        self.displayModel = GuionDocumentModel(from: screenplay)
        context.insert(displayModel)
    }

    // Generate summaries (transient, in-memory only)
    @MainActor
    func generateSummaries() async {
        // Update displayModel.elements with summary elements
        // UI automatically updates via SwiftData observation
    }

    // Export to different format
    func export(to url: URL, as format: UTType) throws {
        let screenplay = displayModel.toGuionParsedScreenplay()

        switch format {
        case .fountain:
            let text = FountainWriter.document(from: screenplay)
            try text.write(to: url, atomically: true, encoding: .utf8)
        case .fdx:
            let data = try FDXDocumentWriter.write(screenplay)
            try data.write(to: url)
        // ... other formats
        }

        // NOTE: sourceURL NOT updated (original file unchanged)
    }

    // Save As (potentially replacing original)
    func saveAs(to url: URL, as format: UTType) throws {
        try export(to: url, as: format)

        // If user saved to different location, update source
        if url != sourceURL {
            // This creates a new "view" of the new file
            // (but we're still viewing, not editing)
        }
    }
}
```

---

### 2. GuionViewerApp (Simplified)

```swift
@main
struct GuionViewerApp: App {
    var body: some Scene {
        // NOT DocumentGroup (that's for editable documents)
        // Use WindowGroup with custom file opening

        WindowGroup {
            ContentView()
        }
        .commands {
            FileMenuCommands()      // Open, Close
            ExportCommands()        // Export to Fountain, FDX, Highland
            SaveAsCommands()        // Save As... (with replace confirmation)
            SummaryCommands()       // Generate Summaries (optional)
        }
    }
}
```

---

### 3. File Menu Structure

```
File
├─ Open...                    ⌘O  (Read-only)
├─ Open Recent               ▶
├─ ────────────────────
├─ Close                     ⌘W
├─ ────────────────────
├─ Save                      ⌘S  [DISABLED - no editing]
├─ Save As...              ⇧⌘S  [ENABLED - explicit save with replace confirm]
├─ ────────────────────
├─ Export                    ▶
│  ├─ Export as Fountain...
│  ├─ Export as FDX...
│  └─ Export as Highland...
├─ ────────────────────
├─ Generate Summaries         [ENABLED - creates summaries in memory]
├─ ────────────────────
└─ Print...                  ⌘P
```

---

## Data Flow Diagram

```
┌────────────────────────┐
│  Original File         │
│  (On Disk, Read-Only)  │
└───────────┬────────────┘
            │ Open
            ▼
┌────────────────────────┐
│  GuionParsedScreenplay │ ← Immutable, Sendable
│  (In Memory)           │
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│  ViewerDocument        │ ← @Observable
│  ├─ sourceURL          │
│  ├─ screenplay         │
│  └─ displayModel       │
└───────────┬────────────┘
            │
            ├─────────────────┐
            │                 │
            ▼                 ▼
┌────────────────────┐  ┌────────────────────┐
│ Generate Summaries │  │ GuionViewer UI     │
│ (Optional)         │  │ ├─ Chapters        │
│ ↓                  │  │ ├─ Scene Groups    │
│ Updates            │  │ └─ Scenes          │
│ displayModel       │  │    └─ Summaries    │
└────────────────────┘  └─────────┬──────────┘
            │                     │
            │ Export / Save As    │
            ▼                     │
┌────────────────────────────────┐│
│  New File                      ││
│  (User-Selected Location)      ││
│  ✅ With summaries (if generated)│
└────────────────────────────────┘│
                                  │
            ⚠️ Original File UNCHANGED (unless explicit replace)
```

---

## Summary Generation Flow (Optional Feature)

```
┌─────────────────────────────────────────────────────────────┐
│ USER: Menu → "Generate Summaries"                           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ Show progress dialog                                         │
│ "Generating summaries for 47 scenes..."                     │
│ [████████░░░░░░░░] 60%                                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ For each scene without summary:                             │
│                                                             │
│ Task.detached {                                             │
│   let outline = screenplay.extractOutline()                 │
│   let scene = outline[sceneIndex]                           │
│                                                             │
│   // Generate summary                                       │
│   let summaryText = await SceneSummarizer.summarizeScene(   │
│     scene,                                                  │
│     from: screenplay,                                       │
│     outline: outline                                        │
│   )                                                         │
│                                                             │
│   // Create summary element                                 │
│   await MainActor.run {                                     │
│     let summaryElement = GuionElementModel(                 │
│       elementType: "Section Heading",                       │
│       elementText: " SUMMARY: \(summaryText)",              │
│       sectionDepth: 4                                       │
│     )                                                       │
│                                                             │
│     // Insert after scene heading (and OVER BLACK if exists)│
│     displayModel.elements.insert(                           │
│       summaryElement,                                       │
│       at: insertionIndex                                    │
│     )                                                       │
│   }                                                         │
│ }                                                           │
│                                                             │
│ ⚠️  Changes ONLY in displayModel (memory)                   │
│ ⚠️  Original file UNTOUCHED                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ UI updates automatically (SwiftData observation)            │
│ - Summaries appear in collapsed scenes                      │
│ - Summary elements visible when scenes expanded             │
│                                                             │
│ User can now:                                               │
│ ✅ Export with summaries → Creates new file                 │
│ ✅ Save As with summaries → Replaces original (if confirmed)│
│ ❌ Summaries lost if window closed without export           │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Differences from Editor Pattern

| Aspect | Editor (Old) | Viewer (New) |
|--------|-------------|--------------|
| **File Access** | ReferenceFileDocument | Custom @Observable class |
| **Save Behavior** | Auto-save on change | No auto-save, explicit export only |
| **File Menu** | Save (⌘S) enabled | Save disabled, Export/Save As only |
| **Modifications** | Tracked, persisted | In-memory only until exported |
| **Window Title** | "Edited" indicator | No editing indicator |
| **Original File** | Modified in place | Never modified (except Save As → Replace) |
| **Generated Summaries** | Saved automatically | Transient until exported |

---

## Example User Workflows

### Workflow 1: Simple Viewing

```
1. User: Open "script.fountain"
   → Loads in memory, displays in GuionViewer

2. User: Browse scenes, read content
   → All in memory, no changes to file

3. User: Close window
   → File unchanged on disk
```

### Workflow 2: Export to Different Format

```
1. User: Open "script.fountain"
   → Loads in memory

2. User: Menu → Export → Export as FDX...
   → Save panel appears
   → Default location: ~/Documents/script.fdx

3. User: Choose location, click "Save"
   → New FDX file created
   → Original script.fountain UNTOUCHED

4. User: Close window
   → Both files exist, original unchanged
```

### Workflow 3: Generate Summaries & Export

```
1. User: Open "script.fountain" (no existing summaries)
   → Loads in memory

2. User: Menu → "Generate Summaries"
   → Progress dialog appears
   → Summaries created in memory
   → UI updates to show summaries

3. User: Menu → Export → Export as Fountain...
   → Save panel: "script-with-summaries.fountain"
   → User chooses location

4. User: Click "Save"
   → New file created WITH summary elements
   → Original script.fountain still WITHOUT summaries

5. User: Close window
   → Original file unchanged (no summaries saved there)
```

### Workflow 4: Save As with Replace (Explicit)

```
1. User: Open "script.fountain"
   → Loads in memory

2. User: Menu → "Generate Summaries"
   → Summaries created in memory

3. User: Menu → "Save As..."
   → Save panel appears
   → User navigates to original file location
   → User types "script.fountain" (same name)

4. System: Shows alert
   "script.fountain already exists. Do you want to replace it?"
   [Cancel] [Replace]

5. User: Clicks "Replace"
   → Original file NOW updated with summaries
   → This is ONLY way to modify original
```

---

## Implementation Checklist

### Phase 1: Read-Only Viewer
- [ ] Create `ViewerDocument` class (replace `GuionDocument`)
- [ ] Remove `ReferenceFileDocument` / `FileDocument` conformance
- [ ] Implement file opening (read-only)
- [ ] Display in GuionViewer component
- [ ] Disable File → Save menu item
- [ ] Existing summary elements display correctly

### Phase 2: Export Commands
- [ ] Implement Export → Fountain command
- [ ] Implement Export → FDX command
- [ ] Implement Export → Highland command
- [ ] Save panel with suggested filename
- [ ] Write to user-selected location
- [ ] Verify original file unchanged

### Phase 3: Save As Command
- [ ] Implement Save As... menu command
- [ ] Detect when user chooses same location as original
- [ ] System "Replace?" confirmation works automatically
- [ ] Update sourceURL if location changes
- [ ] Verify explicit replace required for original file

### Phase 4: Summary Generation (Optional)
- [ ] Add "Generate Summaries" menu command
- [ ] Progress dialog during generation
- [ ] Create summary elements in displayModel
- [ ] UI updates automatically
- [ ] Summaries preserved in exports
- [ ] Summaries NOT saved to original (unless Save As → Replace)

---

## Testing Scenarios

### Test 1: Original File Unchanged
```
1. Open script.fountain
2. View content for 5 minutes
3. Close window
4. Verify: script.fountain last modified date UNCHANGED
```

### Test 2: Export Creates New File
```
1. Open script.fountain
2. Export as FDX to script.fdx
3. Close window
4. Verify: script.fountain EXISTS and UNCHANGED
5. Verify: script.fdx EXISTS and is valid FDX
```

### Test 3: Save As Requires Replace Confirmation
```
1. Open script.fountain
2. Generate summaries
3. Save As → choose "script.fountain" (same name/location)
4. Verify: System shows "Replace?" dialog
5. Click Cancel
6. Verify: Original file UNCHANGED
7. Repeat Save As → click Replace
8. Verify: Original file NOW has summaries
```

### Test 4: Generated Summaries Are Transient
```
1. Open script.fountain (no summaries)
2. Generate summaries
3. Verify: Summaries visible in UI
4. Close window WITHOUT exporting
5. Re-open script.fountain
6. Verify: NO summaries (they were transient)
```

### Test 5: Export Preserves Summaries
```
1. Open script.fountain (no summaries)
2. Generate summaries
3. Export as Fountain to script-new.fountain
4. Close window
5. Open script-new.fountain
6. Verify: Summaries ARE present
7. Open original script.fountain
8. Verify: NO summaries (original unchanged)
```

---

## Notes

- This pattern matches macOS Preview.app, QuickTime Player
- Original files are **sacred** - never modified without explicit user action
- Summary generation is a **transient enhancement** until explicitly saved
- All exports create **new files**, never modify originals
- Only "Save As" → "Replace" can modify the original file
- User has full control over when/if files are modified

---

**End of Document**
