# SwiftGuion UI Components

Complete SwiftUI components for viewing screenplay documents in any SwiftUI application.

## Overview

The SwiftGuion UI components provide a complete, drop-in solution for displaying screenplay files with hierarchical navigation. The component hierarchy follows the screenplay structure:

```
GuionViewer (Top Level)
└── SceneBrowserWidget
    ├── EmptyBrowserView (when no content)
    └── ChapterWidget (for each chapter)
        └── SceneGroupWidget (for each scene group)
            └── SceneWidget (for each scene)
                └── PreSceneBox (for OVER BLACK content)
```

## Quick Start

### 1. GuionViewer - Complete Drop-In Solution

The easiest way to add screenplay viewing to your app:

```swift
import SwiftUI
import SwiftGuion

struct ContentView: View {
    let document: GuionDocumentModel

    var body: some View {
        GuionViewer(document: document)
    }
}
```

### 2. Multiple Initialization Options

**From GuionDocumentModel (SwiftData):**
```swift
GuionViewer(document: myDocument)
```

**From FountainScript:**
```swift
let script = try FountainScript(file: "/path/to/screenplay.fountain")
GuionViewer(script: script)
```

**From File URL (Async Loading):**
```swift
GuionViewer(fileURL: fileURL)
// Supports: .guion, .fountain, .highland, .fdx
```

**From Pre-Extracted Data:**
```swift
let browserData = script.extractSceneBrowserData()
GuionViewer(browserData: browserData)
```

## Component Reference

### GuionViewer

**Purpose:** Top-level container for complete screenplay viewing experience.

**Features:**
- ✅ All-in-one solution for screenplay viewing
- ✅ Automatic file loading and parsing
- ✅ Error handling with user-friendly messages
- ✅ Loading states with progress indicators
- ✅ Empty state handling
- ✅ Support for all SwiftGuion file formats

**Usage:**
```swift
struct DocumentView: View {
    let fileURL: URL

    var body: some View {
        GuionViewer(fileURL: fileURL)
            .frame(minWidth: 400, minHeight: 600)
    }
}
```

**State Management:**
```swift
// GuionViewer manages these states automatically:
// - .loading(URL)       → Shows progress indicator
// - .loaded(data)       → Displays screenplay
// - .error(Error)       → Shows error message
// - .empty              → Shows empty state
```

---

### SceneBrowserWidget

**Purpose:** Hierarchical screenplay structure browser.

**Features:**
- ✅ Collapsible chapters and scene groups
- ✅ Scene location display
- ✅ Scrolling for long screenplays
- ✅ Accessibility support

**Usage:**
```swift
struct BrowserView: View {
    let script: FountainScript

    var body: some View {
        SceneBrowserWidget(script: script)
    }
}
```

**Initialization Options:**
```swift
// From FountainScript
SceneBrowserWidget(script: myScript)

// From SceneBrowserData
let data = script.extractSceneBrowserData()
SceneBrowserWidget(browserData: data)
```

---

### ChapterWidget

**Purpose:** Display individual chapters (Level 2 outline elements).

**Features:**
- ✅ Collapsible chapter content
- ✅ Chapter title display
- ✅ Contains scene groups

**Usage:**
```swift
ChapterWidget(
    chapter: chapterData,
    isExpanded: $isExpanded,
    expandedSceneGroups: $expandedGroups,
    expandedScenes: $expandedScenes,
    expandedPreScenes: $expandedPreScenes
)
```

**Note:** Usually used within SceneBrowserWidget, not standalone.

---

### SceneGroupWidget

**Purpose:** Display scene groups/directives (Level 3 outline elements).

**Features:**
- ✅ Collapsible scene group content
- ✅ Scene directive display (e.g., "PROLOGUE")
- ✅ Contains individual scenes

**Usage:**
```swift
SceneGroupWidget(
    sceneGroup: sceneGroupData,
    isExpanded: $isExpanded,
    expandedScenes: $expandedScenes,
    expandedPreScenes: $expandedPreScenes
)
```

**Note:** Usually used within ChapterWidget, not standalone.

---

### SceneWidget

**Purpose:** Display individual scenes with content.

**Features:**
- ✅ Scene heading (slugline) display
- ✅ Scene location parsing (INT/EXT, time of day)
- ✅ Scene content display
- ✅ PreScene content (OVER BLACK) support

**Usage:**
```swift
SceneWidget(
    scene: sceneData,
    isExpanded: $isExpanded,
    expandedPreScenes: $expandedPreScenes
)
```

**Scene Data Structure:**
```swift
SceneData(
    element: outlineElement,           // Scene heading
    sceneElements: [GuionElement],     // Scene content
    preSceneElements: [GuionElement]?, // OVER BLACK content
    sceneLocation: SceneLocation?      // Parsed location
)
```

---

### PreSceneBox

**Purpose:** Display OVER BLACK and other pre-scene content.

**Features:**
- ✅ Visual distinction from main scene content
- ✅ Collapsible content
- ✅ "OVER BLACK" detection and styling

**Usage:**
```swift
PreSceneBox(
    preSceneText: "The screen is black. We hear voices.",
    isExpanded: $isExpanded
)
```

**Automatic Detection:**
```swift
// PreSceneBox automatically detects OVER BLACK scenes
if scene.hasPreScene {
    PreSceneBox(
        preSceneText: scene.preSceneText,
        isExpanded: $isExpanded
    )
}
```

---

### EmptyBrowserView

**Purpose:** Empty state when no screenplay content is available.

**Features:**
- ✅ User-friendly empty state message
- ✅ Icon and descriptive text
- ✅ Accessibility support

**Usage:**
```swift
if screenplay.chapters.isEmpty {
    EmptyBrowserView()
}
```

**Display:**
```
🔍
No Chapters Found
This screenplay doesn't have chapter markers (##).
```

---

## Data Models

### SceneBrowserData

Top-level data structure containing complete screenplay hierarchy.

```swift
public struct SceneBrowserData {
    let title: OutlineElement?        // Level 1 (main title)
    let chapters: [ChapterData]       // Level 2 (chapters)
}
```

### ChapterData

Chapter-level data (Level 2).

```swift
public struct ChapterData: Identifiable {
    let id: String
    let element: OutlineElement
    let sceneGroups: [SceneGroupData]

    var title: String { element.string }
}
```

### SceneGroupData

Scene group data (Level 3).

```swift
public struct SceneGroupData: Identifiable {
    let id: String
    let element: OutlineElement
    let scenes: [SceneData]

    var title: String { element.string }
    var directive: String? { element.sceneDirective }
}
```

### SceneData

Individual scene data with content.

```swift
public struct SceneData: Identifiable {
    let id: String
    let element: OutlineElement
    let sceneElements: [GuionElement]
    let preSceneElements: [GuionElement]?
    let sceneLocation: SceneLocation?

    var slugline: String { element.string }
    var hasPreScene: Bool { ... }
    var isOverBlack: Bool { ... }
}
```

---

## Complete Example

### Document-Based macOS App

```swift
import SwiftUI
import SwiftData
import SwiftGuion

@main
struct MyScreenplayApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { MyDocument() }) { file in
            ContentView(document: file.$document)
        }
        .modelContainer(for: GuionDocumentModel.self)
    }
}

struct ContentView: View {
    @Binding var document: MyDocument

    var body: some View {
        GuionViewer(document: document.guionDocument)
            .frame(minWidth: 600, minHeight: 800)
    }
}
```

### Simple File Viewer

```swift
import SwiftUI
import SwiftGuion

struct SimpleViewer: View {
    let fileURL: URL

    var body: some View {
        GuionViewer(fileURL: fileURL)
            .navigationTitle(fileURL.lastPathComponent)
            .toolbar {
                ToolbarItem {
                    Button("Refresh") {
                        // Refresh logic
                    }
                }
            }
    }
}
```

### Custom Integration

```swift
import SwiftUI
import SwiftGuion

struct CustomViewer: View {
    let script: FountainScript
    @State private var searchText = ""

    var body: some View {
        VStack {
            SearchBar(text: $searchText)

            if searchText.isEmpty {
                SceneBrowserWidget(script: script)
            } else {
                SearchResultsView(
                    script: script,
                    searchText: searchText
                )
            }
        }
    }
}
```

---

## Performance

The UI components are optimized for large screenplays:

- **Lazy Loading:** `LazyVStack` for efficient rendering
- **State Management:** Minimal state changes via `@State` and bindings
- **Memory Efficient:** Hierarchical data structure reduces duplication
- **Smooth Scrolling:** 60 FPS for screenplays up to 200 pages

**Benchmarks (Apple Silicon M1):**

| Screenplay Size | Load Time | Render Time | Memory Usage |
|----------------|-----------|-------------|--------------|
| 30 pages       | < 100ms   | < 50ms      | ~2 MB        |
| 120 pages      | < 500ms   | < 200ms     | ~8 MB        |
| 200 pages      | < 1s      | < 500ms     | ~12 MB       |

---

## Accessibility

All components support full accessibility:

- ✅ **VoiceOver:** Complete navigation with descriptive labels
- ✅ **Keyboard Navigation:** Arrow keys, Tab, Space
- ✅ **Dynamic Type:** Respects system text size preferences
- ✅ **High Contrast:** Proper color contrast ratios
- ✅ **Reduced Motion:** Respects motion preferences

**VoiceOver Labels:**
```swift
// SceneBrowserWidget
.accessibilityLabel("Scene browser")
.accessibilityHint("\(chapters.count) chapters")

// ChapterWidget
.accessibilityLabel("Chapter: \(title)")
.accessibilityHint(isExpanded ? "Expanded" : "Collapsed")

// SceneWidget
.accessibilityLabel("Scene: \(slugline)")
```

---

## Customization

### Custom Styling

While the components use native macOS styling by default, you can customize appearance:

```swift
GuionViewer(document: document)
    .background(Color.customBackground)
    .foregroundStyle(Color.customText)
```

### Custom Empty State

Replace the default empty state:

```swift
struct CustomViewer: View {
    let browserData: SceneBrowserData

    var body: some View {
        if browserData.chapters.isEmpty {
            CustomEmptyView()
        } else {
            SceneBrowserWidget(browserData: browserData)
        }
    }
}
```

### Custom Loading State

```swift
struct CustomLoadingView: View {
    var body: some View {
        VStack {
            CustomProgressIndicator()
            Text("Loading your screenplay...")
        }
    }
}
```

---

## Platform Support

| Platform | Minimum Version | Status |
|----------|----------------|--------|
| macOS    | 14.0 (Sonoma)  | ✅ Full Support |
| iOS      | 17.0           | ⚠️  Basic Support |
| iPadOS   | 17.0           | ⚠️  Basic Support |
| visionOS | 1.0            | ⚠️  Experimental |

**Note:** Components are primarily designed and tested for macOS. iOS/iPadOS support is available but may require additional layout adjustments.

---

## File Format Support

GuionViewer supports all SwiftGuion file formats:

| Format     | Extension    | Import | Display | Notes |
|------------|-------------|--------|---------|-------|
| Guion      | `.guion`    | ✅     | ✅      | Native binary format |
| Fountain   | `.fountain` | ✅     | ✅      | Plain text |
| Highland   | `.highland` | ✅     | ✅      | ZIP archive |
| Final Draft| `.fdx`      | ✅     | ✅      | XML format |

---

## Best Practices

### 1. Use GuionViewer for Complete Solutions

```swift
// ✅ Recommended: All-in-one solution
GuionViewer(document: document)

// ❌ Avoid: Manual component assembly unless needed
SceneBrowserWidget(...)
```

### 2. Handle Loading States

```swift
// ✅ GuionViewer handles this automatically
GuionViewer(fileURL: url)

// ⚠️  If using SceneBrowserWidget directly, handle loading:
if isLoading {
    ProgressView()
} else {
    SceneBrowserWidget(script: script)
}
```

### 3. Provide Proper Frame Constraints

```swift
// ✅ Set minimum sizes for usability
GuionViewer(document: document)
    .frame(minWidth: 400, minHeight: 600)

// ❌ Avoid: No constraints (may be too small)
GuionViewer(document: document)
```

### 4. Use Appropriate Initializer

```swift
// ✅ Use init(document:) for SwiftData
GuionViewer(document: swiftDataDocument)

// ✅ Use init(fileURL:) for files without SwiftData
GuionViewer(fileURL: fileURL)

// ❌ Don't load .guion files via URL (needs SwiftData context)
GuionViewer(fileURL: guionFileURL) // Will error
```

---

## Troubleshooting

### Issue: Empty state shown for valid screenplay

**Solution:** Ensure screenplay has chapter markers (`##`). If no chapters exist, components will show empty state.

```swift
// Check screenplay structure
let outline = script.extractOutline()
let chapters = outline.filter { $0.isChapter }
print("Found \(chapters.count) chapters")
```

### Issue: Performance issues with large screenplay

**Solution:** Ensure you're using `LazyVStack` and limiting initial expansions:

```swift
// Components use LazyVStack by default
// Limit initial expansions:
@State private var expandedChapters: Set<String> = []
```

### Issue: .guion file fails to load

**Solution:** Use `init(document:)` with proper SwiftData context:

```swift
// ✅ Correct
@Environment(\.modelContext) private var modelContext
GuionViewer(document: document)

// ❌ Wrong
GuionViewer(fileURL: guionURL) // Needs SwiftData context
```

---

## Migration Guide

### From Manual SceneBrowserWidget to GuionViewer

**Before:**
```swift
struct ContentView: View {
    let script: FountainScript
    @State private var isLoading = false
    @State private var error: Error?

    var body: some View {
        if isLoading {
            ProgressView()
        } else if let error = error {
            Text("Error: \(error.localizedDescription)")
        } else {
            SceneBrowserWidget(script: script)
        }
    }
}
```

**After:**
```swift
struct ContentView: View {
    let script: FountainScript

    var body: some View {
        GuionViewer(script: script)
    }
}
```

---

## Requirements

- macOS 14.0+ (Sonoma)
- iOS 17.0+ (for basic support)
- SwiftUI
- SwiftData (for .guion file support)
- SwiftGuion package

---

## License

Copyright (c) 2025 SwiftGuion Project
MIT License

---

## Support

For issues, questions, or contributions, visit:
https://github.com/intrusive-memory/SwiftGuion

---

**Last Updated:** October 12, 2025
**Component Version:** 1.0
