# GuionViewer Document Flow Architecture

**Date:** 2025-10-14
**Status:** Design Document
**Library Version:** SwiftGuion with Summary Elements (v2.0)

---

## Overview

This document outlines the complete flow of screenplay documents through the GuionViewer application, from file opening to UI display, with emphasis on the new **summary element architecture** where summaries are stored as `Section Heading` elements with `depth: 4` rather than properties.

---

## Key Architectural Change

### OLD Architecture (Property-Based Summaries)
```
GuionElementModel.summary: String? property
↓
SceneData.summary computed property reads from model
↓
UI displays summary in collapsed state
```

### NEW Architecture (Element-Based Summaries)
```
Section Heading element (depth 4, text: " SUMMARY: ...")
↓
Stored as GuionElementModel in elements array
↓
SceneData.summary extracts from sceneElementModels array
↓
UI displays summary element in both collapsed AND expanded states
```

**Critical Difference:**
- Summaries are now **outline elements** that can be exported/imported
- Format: `#### SUMMARY: <text>` in Fountain files
- Displayed as italic caption text when scene is expanded

---

## Document Lifecycle Flow

### Phase 1: File Open & Import

```
┌─────────────────────────────────────────────────────────────┐
│ 1. USER ACTION: Opens file (.guion, .fountain, .fdx, etc.) │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. GuionDocument.init(configuration:)                       │
│    File: GuionDocument.swift:69                             │
│    Thread: Background (FileDocument init is nonisolated)    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 3a. GUION FILES: TextPackReader.readTextPack()             │
│     Returns: GuionParsedScreenplay                          │
│     - Contains GuionElement structs (value types)           │
│     - Summary elements already present as Section Headings  │
│                                                             │
│ 3b. FOUNTAIN FILES: GuionParsedScreenplay(string:)         │
│     Parses: #### SUMMARY: ... as Section Heading elements  │
│     - elementType: "Section Heading"                        │
│     - sectionDepth: 4                                       │
│     - elementText: " SUMMARY: <summary text>"               │
│                                                             │
│ 3c. FDX FILES: FDXParser.parse() → GuionParsedScreenplay   │
│     Note: FDX files won't have summary elements (yet)      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. GuionDocumentModel(from: screenplay)                     │
│    File: GuionDocumentModel.swift (sample app version)      │
│    Converts: GuionParsedScreenplay → GuionDocumentModel     │
│    Thread: MainActor                                        │
│                                                             │
│    For each element in screenplay.elements:                 │
│      - Create GuionElementModel(from: element)              │
│      - Summary elements included as Section Heading models  │
│      - Append to document.elements array                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. GuionDocument.documentModel assigned                     │
│    File: GuionDocument.swift:121                            │
│    Type: @Published GuionDocumentModel                      │
│    Thread: MainActor                                        │
│                                                             │
│    SwiftUI @ObservedObject will react to changes            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. COMPLETE: Document ready for UI binding                 │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 2: UI Display

```
┌─────────────────────────────────────────────────────────────┐
│ 1. ContentView renders                                      │
│    File: ContentView.swift:21                               │
│    Thread: MainActor                                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. GuionViewer(script:) initialized                         │
│    ⚠️  CURRENT ISSUE: Uses toGuionParsedScreenplay()        │
│    - Converts model back to value types                     │
│    - Loses SwiftData reactivity                             │
│                                                             │
│    ✅ SHOULD BE: GuionViewer(document:)                     │
│    - Bind directly to GuionDocumentModel                    │
│    - Maintain SwiftData reactivity                          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. GuionViewer.extractSceneBrowserData()                    │
│    Library: SwiftGuion/UI/GuionViewer.swift                 │
│                                                             │
│    ⚠️  CURRENT PATH:                                        │
│    screenplay.extractSceneBrowserData()                     │
│    → Returns value-based SceneBrowserData                   │
│                                                             │
│    ✅ SHOULD BE:                                            │
│    document.extractSceneBrowserData()                       │
│    → Returns model-based SceneBrowserData                   │
│    → SceneData contains sceneElementModels (not values)     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. SceneBrowserData structure                               │
│    Library: SwiftGuion/Analysis/SceneBrowserData.swift      │
│                                                             │
│    Title (OutlineElement)                                   │
│    └── Chapters (ChapterData[])                             │
│        └── Scene Groups (SceneGroupData[])                  │
│            └── Scenes (SceneData[])                         │
│                                                             │
│    Each SceneData contains:                                 │
│    #if canImport(SwiftData)                                 │
│      - sceneHeadingModel: GuionElementModel?                │
│      - sceneElementModels: [GuionElementModel]              │
│        ↑ Includes summary elements!                         │
│      - preSceneElementModels: [GuionElementModel]?          │
│    #endif                                                   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. SceneWidget renders each scene                           │
│    Library: SwiftGuion/UI/SceneWidget.swift                 │
│                                                             │
│    COLLAPSED STATE (isExpanded = false):                    │
│    ├── Scene slugline (bold, monospaced)                    │
│    ├── Location badge (INT/EXT capsule)                     │
│    └── Summary text (caption, secondary)                    │
│        ↑ Extracted from SceneData.summary                   │
│        ↑ Which searches sceneElementModels for depth-4      │
│                                                             │
│    EXPANDED STATE (isExpanded = true):                      │
│    ├── Scene slugline                                       │
│    └── ForEach(sceneElementModels):                         │
│        ├── Scene Heading element                            │
│        ├── SUMMARY element (italic caption, secondary)      │
│        ├── Action elements                                  │
│        ├── Character elements                               │
│        └── Dialogue elements                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. SceneData.summary computed property                      │
│    Library: SwiftGuion/Analysis/SceneBrowserData.swift:178  │
│                                                             │
│    Logic:                                                   │
│    for element in sceneElementModels {                      │
│      if element.elementType == "Section Heading" &&         │
│         element.sectionDepth == 4 {                         │
│        let trimmed = element.elementText.trimmed()          │
│        if trimmed.hasPrefix("SUMMARY:") {                   │
│          return text after "SUMMARY: "                      │
│        }                                                    │
│      }                                                      │
│    }                                                        │
│    return nil                                               │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 3: Summary Generation (Optional - AI)

```
┌─────────────────────────────────────────────────────────────┐
│ TRIGGER: Document parsing complete                          │
│ Option A: On file open (batch all scenes)                   │
│ Option B: On demand (when scene viewed)                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 1. GuionDocumentModel.from(screenplay, generateSummaries:)  │
│    Library: SwiftGuion/FileFormat/GuionDocumentModel.swift  │
│    Thread: MainActor                                        │
│                                                             │
│    When generateSummaries = true:                           │
│    - Extract outline from screenplay                        │
│    - For each scene heading:                                │
│      - Call SceneSummarizer.summarizeScene()                │
│      - Insert summary element AFTER scene heading           │
│      - Insert summary AFTER OVER BLACK (if exists)          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. SceneSummarizer.summarizeScene()                         │
│    Library: SwiftGuion/Analysis/SceneSummarizer.swift       │
│    Thread: Background (Task.detached)                       │
│                                                             │
│    Paths:                                                   │
│    A. Foundation Models (iOS 18.2+, macOS 15.2+)            │
│       - await FoundationModel.summarize(text)               │
│       - Returns: AI-generated summary                       │
│                                                             │
│    B. Extractive fallback (all platforms)                   │
│       - Extract characters: "Characters: ALICE, BOB."       │
│       - Extract first action line                           │
│       - Returns: "Characters: ALICE. First action..."       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Create summary element                                   │
│    Library: SwiftGuion/FileFormat/GuionDocumentModel.swift  │
│                                                             │
│    var summaryElement = GuionElement(                       │
│      elementType: "Section Heading",                        │
│      elementText: " SUMMARY: \(summaryText)"                │
│    )                                                        │
│    summaryElement.sectionDepth = 4                          │
│                                                             │
│    Insert order:                                            │
│    1. Scene Heading                                         │
│    2. OVER BLACK (if exists)                                │
│    3. SUMMARY element ← NEW                                 │
│    4. Regular scene content                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Convert to GuionElementModel                             │
│    Thread: MainActor                                        │
│                                                             │
│    let elementModel = GuionElementModel(from: summaryEl)    │
│    elementModel.document = document                         │
│    document.elements.append(elementModel)                   │
│                                                             │
│    SwiftData automatically:                                 │
│    - Persists to ModelContext                               │
│    - Notifies SwiftUI observers                             │
│    - Triggers UI updates                                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. UI automatically updates                                 │
│    SceneWidget re-renders with new summary                  │
└─────────────────────────────────────────────────────────────┘
```

---

### Phase 4: File Save & Export

```
┌─────────────────────────────────────────────────────────────┐
│ 1. USER ACTION: Saves document (⌘S)                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. GuionDocument.snapshot()                                 │
│    File: GuionDocument.swift:131                            │
│    Thread: MainActor                                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. documentModel.toGuionParsedScreenplay()                  │
│    Sample App: GuionDocumentModel.swift                     │
│                                                             │
│    Converts:                                                │
│    GuionDocumentModel → GuionParsedScreenplay               │
│    - Title page entries                                     │
│    - All GuionElementModel → GuionElement                   │
│    - Summary elements preserved as Section Headings         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. TextPackWriter.createTextPack()                          │
│    Library: SwiftGuion/FileFormat/TextPackWriter.swift      │
│                                                             │
│    Creates FileWrapper bundle:                              │
│    └── screenplay.fountain (Fountain text)                  │
│        ├── Title page                                       │
│        ├── # Title                                          │
│        ├── ## Chapter                                       │
│        ├── ### Scene Group                                  │
│        ├── INT. SCENE - DAY                                 │
│        ├── #### SUMMARY: <text> ← Exported!                 │
│        └── Scene content...                                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. FountainWriter.document()                                │
│    Library: SwiftGuion/ImportExport/FountainWriter.swift    │
│                                                             │
│    For Section Heading elements:                            │
│    - Prepend hashtags: "#### " + elementText                │
│    - Result: "#### SUMMARY: <text>"                         │
│    - Summaries preserved in Fountain format!                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. File written to disk                                     │
│    Format: .guion (TextPack bundle)                         │
│    Contains: screenplay.fountain with summary elements      │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Type Flow Diagram

```
FILE ON DISK
    │
    ├─ .guion   → TextPackReader → GuionParsedScreenplay
    ├─ .fountain → FountainParser → GuionParsedScreenplay
    ├─ .fdx      → FDXParser      → GuionParsedScreenplay
    └─ .highland → HighlandReader → GuionParsedScreenplay
           │
           ▼
    GuionParsedScreenplay (Sendable, value type)
    ├─ filename: String
    ├─ elements: [GuionElement]  ← Summary elements here
    │   └─ GuionElement(
    │        elementType: "Section Heading",
    │        elementText: " SUMMARY: ...",
    │        sectionDepth: 4
    │      )
    └─ titlePage: [[String: [String]]]
           │
           ▼
    GuionDocumentModel (SwiftData @Model, reference type)
    ├─ filename: String
    ├─ elements: [GuionElementModel]  ← Summary elements here
    │   └─ GuionElementModel(
    │        elementType: "Section Heading",
    │        elementText: " SUMMARY: ...",
    │        sectionDepth: 4
    │      )
    └─ titlePage: [TitlePageEntryModel]
           │
           ▼
    SceneBrowserData (struct, extracted hierarchy)
    └─ chapters: [ChapterData]
        └─ sceneGroups: [SceneGroupData]
            └─ scenes: [SceneData]
                ├─ sceneHeadingModel: GuionElementModel?
                └─ sceneElementModels: [GuionElementModel]
                    ├─ Scene Heading
                    ├─ SUMMARY element ← Here!
                    ├─ Action
                    └─ Dialogue
           │
           ▼
    SceneWidget (SwiftUI View)
    ├─ COLLAPSED: Shows SceneData.summary (extracted)
    └─ EXPANDED: Shows all sceneElementModels (including SUMMARY)
```

---

## Critical Integration Points

### 1. GuionViewer Initialization (NEEDS UPDATE)

**Current (Incorrect):**
```swift
// ContentView.swift:21
GuionViewer(script: document.documentModel.toGuionParsedScreenplay())
```

**Problem:**
- Converts models back to values
- Loses SwiftData reactivity
- Summary updates won't trigger UI refresh

**Should Be:**
```swift
GuionViewer(document: document.documentModel)
```

**Required Library Change:**
```swift
// SwiftGuion/UI/GuionViewer.swift
public init(document: GuionDocumentModel) {
    self._browserData = State(initialValue: document.extractSceneBrowserData())
    // ... bind to SwiftData for reactivity
}
```

---

### 2. Summary Display (ALREADY WORKING)

**SceneWidget.swift:100-107** (collapsed state):
```swift
if let summary = scene.summary, !isExpanded {
    Text(summary)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(2)
}
```

**SceneData.summary** (computed property):
```swift
public var summary: String? {
    for element in sceneElementModels {
        if element.elementType == "Section Heading" &&
           element.sectionDepth == 4 {
            let trimmed = element.elementText.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("SUMMARY:") {
                return extract text after "SUMMARY: "
            }
        }
    }
    return nil
}
```

✅ **This already works with new architecture!**

---

### 3. Summary Generation (OPTIONAL ENHANCEMENT)

**When to Generate:**
- Option A: On document open (batch all scenes)
- Option B: Never (use existing summaries from file)
- Option C: Manual "Generate Summaries" command

**Recommended: Option B for Phase 1**
- Just display existing summary elements
- Don't auto-generate on open
- Add generation in Phase 2

---

## Summary Element Format Reference

### Fountain Format
```fountain
INT. COFFEE SHOP - DAY

#### SUMMARY: Alice orders coffee and meets Bob. They discuss the plan.

ALICE walks to the counter.

ALICE
One coffee, please.
```

### Internal Structure
```swift
GuionElement(
    elementType: "Section Heading",
    elementText: " SUMMARY: Alice orders coffee and meets Bob. They discuss the plan.",
    sectionDepth: 4
)
```

### SwiftData Model
```swift
GuionElementModel(
    elementType: "Section Heading",
    elementText: " SUMMARY: Alice orders coffee and meets Bob. They discuss the plan.",
    sectionDepth: 4
)
```

**Note:** Leading space in `elementText` is required for Fountain parsing compatibility.

---

## Required Changes for GuionViewer App

### Priority 1: Fix GuionViewer Initialization

**File:** `ContentView.swift:21`

**Change:**
```swift
// OLD
GuionViewer(script: document.documentModel.toGuionParsedScreenplay())

// NEW
GuionViewer(document: document.documentModel)
```

**But wait!** The library's `GuionViewer` currently only has `init(script:)` and `init(browserData:)`.

**Need to add to library:**
```swift
// SwiftGuion/UI/GuionViewer.swift
public init(document: GuionDocumentModel) {
    self._browserData = State(initialValue: document.extractSceneBrowserData())
}
```

---

### Priority 2: Summary Element Display (Already Done!)

✅ SceneWidget already displays summary elements correctly:
- Collapsed: Shows extracted summary text
- Expanded: Shows summary element with italic styling

---

### Priority 3: Optional - Summary Generation

**If adding AI summarization:**

```swift
// GuionDocument.swift:121
if let screenplay = self.screenplay {
    // Add ModelContext
    let config = ModelConfiguration(isStoredInMemoryOnly: false)
    let container = try ModelContainer(for: GuionDocumentModel.self)
    let context = ModelContext(container)

    // Generate summaries on import
    self.documentModel = await GuionDocumentModel.from(
        screenplay,
        in: context,
        generateSummaries: true  // ← Enable AI summarization
    )
}
```

**Note:** Requires:
- macOS 15.2+ for Foundation Models
- Fallback to extractive summarization on older OS

---

## Testing Checklist

### Phase 1: Basic Summary Display
- [ ] Open .guion file with existing summaries
- [ ] Verify summaries display in collapsed scenes
- [ ] Expand scene, verify summary element visible with italic styling
- [ ] Save document, verify summaries preserved in .guion file

### Phase 2: Import/Export
- [ ] Import .fountain with #### SUMMARY elements
- [ ] Verify summaries parse correctly
- [ ] Export to .fountain, verify summaries preserved
- [ ] Round-trip: import → modify → export → re-import

### Phase 3: Summary Generation (Optional)
- [ ] Generate summaries for new document
- [ ] Verify summaries created as Section Heading elements
- [ ] Verify correct positioning (after scene heading / OVER BLACK)
- [ ] Verify UI updates automatically after generation

---

## Next Steps

1. ✅ Review this architecture document
2. Add `GuionViewer.init(document:)` to library
3. Update `ContentView.swift` to use new initializer
4. Test with existing .guion files that have summaries
5. (Optional) Add AI summary generation

---

## Notes

- Summary elements are **persistent** (saved to .guion files)
- Format is **standardized** (`#### SUMMARY: <text>`)
- Display is **automatic** (no code changes needed)
- Generation is **optional** (can be added later)

---

**End of Document**
