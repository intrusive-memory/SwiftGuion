# Scene Browser Widget - Requirements Document

## Overview
A scene browser widget that displays screenplay scenes in a hierarchical, collapsible view organized by outline structure. The hierarchy follows the Fountain outline element levels (determined by hashtag count):
- **Level 1 (#)**: Root/Title element - Single top-level title for the entire document
- **Level 2 (##)**: Chapter elements - Major divisions of the screenplay
- **Level 3 (###)**: Scene Group elements - Collections of related scenes
- **Scenes**: Individual scenes within scene groups

Each scene is represented as a disclosure group with its slugline as the label. Content before a scene (marked as "OVER BLACK") appears in a separate expandable/collapsable "preScene" box attached to the scene's disclosure group.

## Outline Element Hierarchy

### Document Structure
```
Document/Screenplay/Guion
└── Title (Level 1: #)
    ├── Chapter 1 (Level 2: ##)
    │   ├── Scene Group 1 (Level 3: ###)
    │   │   ├── Scene 1
    │   │   │   ├── PreScene Box (if OVER BLACK exists)
    │   │   │   └── Scene Content
    │   │   ├── Scene 2
    │   │   └── Scene 3
    │   ├── Scene Group 2 (Level 3: ###)
    │   │   ├── Scene 4
    │   │   └── Scene 5
    ├── Chapter 2 (Level 2: ##)
    │   └── Scene Group 3 (Level 3: ###)
    │       └── Scene 6
    └── ...
```

### Outline Element Levels
Based on `OutlineElement.swift`:

**Level 1 - Title/Root** (`#`)
- Single element at the top of the document
- Root from which all other outline elements extend
- Properties: `isMainTitle == true`, `level == 1`
- Visual: Largest heading, bold, primary color
- Behavior: Always visible, non-collapsible (acts as browser header)

**Level 2 - Chapter** (`##`)
- Major structural divisions
- Contains multiple scene groups
- Properties: `isChapter == true`, `level == 2`
- Visual: Large heading, bold, distinct styling
- Behavior: Collapsible, contains scene groups

**Level 3 - Scene Group** (`###`)
- Organizational units for related scenes
- Contains multiple scenes
- May be scene directives (with colon-separated metadata)
- Properties: `isSceneDirective == true` (if directive), `level == 3`
- Visual: Medium heading, distinct from scenes
- Behavior: Collapsible, contains scenes
- Example: `### PROLOGUE S#{{SERIES: 1001}}`

**Scenes** (No hashtags)
- Individual scene headings (INT/EXT/OVER BLACK)
- Leaf nodes in the hierarchy
- Contained within scene groups
- Properties: `type == "sceneHeader"`, scene has `sceneId`
- Visual: Scene slugline as disclosure label
- Behavior: Expandable to show content

### Integration with OutlineElement
The scene browser leverages the existing `OutlineElement` structure:

```swift
// From OutlineElement.swift
public var isMainTitle: Bool {
    return level == 1 && type == "sectionHeader"
}

public var isChapter: Bool {
    return level == 2 && type == "sectionHeader"
}

public var isSceneDirective: Bool {
    if level != 3 { return false }
    if type == "sectionHeader" { return true }
    return type == "sceneHeader" && sceneDirective != nil
}
```

The browser uses:
- `OutlineElement.parentId` to determine hierarchy
- `OutlineElement.childIds` to build tree structure
- `OutlineElement.sceneId` to link scenes to their content
- `OutlineElement.sceneDirective` for scene group metadata

## Architecture

### Core Components

#### 1. SceneBrowserWidget (Main Container)
- **Purpose**: Container view that displays the hierarchical outline structure
- **Properties**:
  - `outline: OutlineList` - Full outline from FountainScript
  - `rootElement: OutlineElement?` - Level 1 title element
  - `expandedElements: Set<String>` - Tracks expansion state by element ID
  - `expandedScenes: Set<String>` - Tracks which scenes are expanded
- **Behavior**:
  - Scrollable vertical list
  - Displays title as header (always visible)
  - Recursively renders chapters → scene groups → scenes
  - Manages expansion/collapse state globally
  - Handles scene filtering/search (future enhancement)

#### 2. SceneWidget (Individual Scene)
- **Purpose**: Displays a single scene with its content and optional preScene material
- **Properties**:
  - `scene: SceneViewModel` - The scene data
  - `isExpanded: Bool` - Expansion state
  - `hasPreSceneContent: Bool` - Whether preScene material exists
  - `preSceneExpanded: Bool` - PreScene expansion state
- **Structure**:
  ```
  ┌─────────────────────────────────┐
  │ [PreScene Box] (if exists)      │
  │ └─ Expandable/Collapsable       │
  ├─────────────────────────────────┤
  │ ▼ SCENE SLUGLINE (Disclosure)   │
  │   ┌─────────────────────────┐   │
  │   │ Scene Content           │   │
  │   │ - Action                │   │
  │   │ - Dialogue              │   │
  │   │ - etc.                  │   │
  │   └─────────────────────────┘   │
  └─────────────────────────────────┘
  ```

#### 3. ChapterWidget (Level 2 Container)
- **Purpose**: Displays a chapter with its scene groups
- **Properties**:
  - `chapter: OutlineElement` - Level 2 outline element
  - `sceneGroups: [OutlineElement]` - Child level 3 elements
  - `isExpanded: Bool` - Expansion state
- **Visual Design**:
  - Large heading with chapter title
  - Disclosure group containing scene groups
  - Distinct styling from scene groups

#### 4. SceneGroupWidget (Level 3 Container)
- **Purpose**: Displays a scene group with its scenes
- **Properties**:
  - `sceneGroup: OutlineElement` - Level 3 outline element
  - `scenes: [OutlineElement]` - Child scene elements
  - `directive: String?` - Optional scene directive metadata
  - `isExpanded: Bool` - Expansion state
- **Visual Design**:
  - Medium heading with scene group title
  - Shows directive metadata if present
  - Disclosure group containing scenes
  - Distinct styling from chapters and scenes

#### 5. PreSceneBox (Optional Attachment)
- **Purpose**: Displays content that appears before the scene (OVER BLACK, etc.)
- **Properties**:
  - `content: [GuionElement]` - Elements before scene
  - `isExpanded: Bool` - Expansion state
- **Visual Design**:
  - Attached to top of scene disclosure group
  - Distinct visual styling (subtle background, italic text, etc.)
  - Expandable/collapsable independently of scene
  - Label: "OVER BLACK" or content preview

## Data Models

### SceneViewModel
```swift
struct SceneViewModel: Identifiable {
    let id: String                          // OutlineElement.id
    let slugline: String                    // Scene heading text
    let sceneLocation: SceneLocation       // Parsed location data
    let sceneElements: [GuionElement]      // Content of the scene
    let preSceneElements: [GuionElement]?  // Optional OVER BLACK content
    let sceneNumber: String?               // Scene number if present
    let sceneId: String?                   // UUID linking to GuionElement
    let outlineElement: OutlineElement     // Reference to outline element

    // Computed properties
    var hasPreScene: Bool {
        preSceneElements?.isEmpty == false
    }

    var preSceneText: String {
        preSceneElements?.map { $0.elementText }.joined(separator: "\n") ?? ""
    }
}
```

### Outline-Based Extraction Logic
The scene browser leverages the existing `FountainScript.extractOutline()` method:

1. **Extract Outline**: Use `FountainScript.extractOutline()` to get hierarchical structure
2. **Identify Root**: Find level 1 element (`isMainTitle == true`)
3. **Build Hierarchy**:
   - Find all level 2 elements (chapters) that are children of root
   - For each chapter, find level 3 elements (scene groups)
   - For each scene group, find scene elements
4. **Process Scenes**:
   - Use `OutlineElement.sceneText(from:outline:)` to get scene content
   - Detect OVER BLACK scenes and mark as preScene content
   - Link scenes via `sceneId` for duplicate heading support
5. **Handle OVER BLACK**:
   - Identify OVER BLACK scene headings
   - Collect their content using `sceneText()`
   - Attach to the next actual scene as `preSceneElements`

### Scene Extraction from Outline
```swift
extension FountainScript {
    func extractSceneBrowserData() -> SceneBrowserData {
        let outline = extractOutline()
        let root = outline.first { $0.isMainTitle }
        let chapters = outline.filter { $0.isChapter && $0.parentId == root?.id }

        // Build tree structure for browser
        return SceneBrowserData(
            title: root,
            chapters: chapters.map { chapter in
                ChapterData(
                    element: chapter,
                    sceneGroups: outline.filter {
                        $0.level == 3 && $0.parentId == chapter.id
                    }.map { group in
                        SceneGroupData(
                            element: group,
                            scenes: outline.filter {
                                $0.type == "sceneHeader" && $0.parentId == group.id
                            }
                        )
                    }
                )
            }
        )
    }
}
```

## UI Specifications

### SceneBrowserWidget
- **Layout**: `ScrollView` with `LazyVStack`
- **Spacing**: 12pt between scenes
- **Padding**: 16pt horizontal, 8pt vertical
- **Background**: System background

### SceneWidget Disclosure Group
- **Label**: Scene slugline (bold, system font)
- **Content**: Scene elements with proper formatting
- **Expansion State**: Persisted per-scene
- **Styling**:
  - Border: 1pt, secondary color
  - Corner radius: 8pt
  - Padding: 12pt

### PreSceneBox
- **Position**: Attached to top of disclosure group
- **Layout**:
  - Collapsable section with chevron indicator
  - Label: "OVER BLACK" or first line preview
  - Content: Centered, italic text
- **Styling**:
  - Background: Secondary background color with 50% opacity
  - Border: Top corners rounded (8pt), bottom square
  - Padding: 8pt
  - Font: Italic, secondary color
  - Distinct from scene content visually

### Element Rendering
Reuse existing `ElementView` component from `ContentView.swift`:
- Scene Heading: Bold, monospaced
- Action: Regular, monospaced
- Character: Indented, monospaced, bold
- Dialogue: Indented, monospaced
- Parenthetical: Indented, secondary color
- Transition: Right-aligned, secondary color

## Scene Detection Algorithm

### Input
- `FountainScript` with `elements: [GuionElement]`

### Process
1. Iterate through elements
2. When encountering Scene Heading:
   - Check if it's "OVER BLACK" (case-insensitive)
   - If OVER BLACK:
     - Mark as preScene content
     - Collect following elements until next Scene Heading
     - Attach to next actual scene as preSceneElements
   - If regular scene heading:
     - Create new SceneViewModel
     - Set slugline from element text
     - Parse SceneLocation
     - Collect elements until next Scene Heading
     - Check if previous elements were OVER BLACK
     - If yes, attach as preSceneElements
3. Return `[SceneViewModel]`

### Edge Cases
- **Multiple OVER BLACK sections**: Each attaches to its following scene
- **OVER BLACK at end**: Ignore or create special "end card" scene
- **No scenes**: Show empty state
- **Scene with only OVER BLACK**: Show scene with only preScene content
- **OVER BLACK without following scene**: Attach to last scene or show as standalone

## Implementation Methodology

### Development Approach
We will follow a **bottom-up, test-driven approach**, building from the data layer up to the UI layer. This ensures each component is testable and works correctly before integration.

### Implementation Phases

#### Phase 1: Data Layer (Foundation)
**Goal**: Establish data models and extraction logic

**Step 1.1: Create SceneBrowserData.swift**
- Define data models: `SceneBrowserData`, `ChapterData`, `SceneGroupData`, `SceneData`
- Ensure all models conform to `Identifiable` for SwiftUI
- Add computed properties for convenience
- Write unit tests for model initialization

**Step 1.2: Create FountainScript+SceneBrowser.swift**
- Implement `extractSceneBrowserData() -> SceneBrowserData`
- Use existing `extractOutline()` method
- Identify and structure hierarchy: root → chapters → scene groups → scenes
- Handle OVER BLACK detection and attachment
- Write unit tests with test.fountain fixture
  - Test hierarchy extraction
  - Test OVER BLACK detection
  - Test scene directive parsing
  - Test edge cases (missing levels, orphaned elements)

**Step 1.3: OVER BLACK Processing**
- Implement logic to detect OVER BLACK scenes
- Attach OVER BLACK content to following scenes as preScene elements
- Handle multiple OVER BLACK sections
- Test with fixtures containing OVER BLACK

**Validation**: Run unit tests to ensure data extraction works correctly

#### Phase 2: UI Components (Bottom-Up)
**Goal**: Build individual UI components, starting with leaf nodes

**Step 2.1: Create PreSceneBox.swift**
- Build expandable/collapsable box for OVER BLACK content
- Implement distinct visual styling (background, italic text)
- Add chevron animation
- Create SwiftUI preview with sample data

**Step 2.2: Create SceneWidget.swift**
- Build scene disclosure group with slugline as label
- Integrate PreSceneBox (conditional rendering)
- Render scene elements using existing ElementView patterns
- Add proper indentation (24pt)
- Create SwiftUI preview with sample scene data

**Step 2.3: Create SceneGroupWidget.swift**
- Build level 3 disclosure group
- Display scene group title and directive metadata
- Render child SceneWidget components
- Apply scene group styling (title3, 12pt indent)
- Create SwiftUI preview with sample scene group data

**Step 2.4: Create ChapterWidget.swift**
- Build level 2 disclosure group
- Display chapter title
- Render child SceneGroupWidget components
- Apply chapter styling (title2, 0pt indent)
- Create SwiftUI preview with sample chapter data

**Validation**: Each component should have a working preview showing correct styling and behavior

#### Phase 3: Main Container & Integration
**Goal**: Assemble components into complete browser

**Step 3.1: Create SceneBrowserWidget.swift**
- Build main container with ScrollView + LazyVStack
- Render title header (level 1, static)
- Render ChapterWidget components
- Implement expansion state management
  - `@State private var expandedElements: Set<String>`
  - `@State private var expandedScenes: Set<String>`
- Pass expansion state through to child widgets
- Add proper spacing and padding

**Step 3.2: State Management**
- Implement expansion/collapse logic for all levels
- Ensure state is properly passed to children
- Test expansion state persistence in UI
- Consider UserDefaults for session persistence (optional)

**Validation**: Full browser should render complete hierarchy with working expand/collapse

#### Phase 4: Integration with App
**Goal**: Connect browser to existing app infrastructure

**Step 4.1: Add to GuionDocumentApp**
- Determine navigation pattern (sidebar, sheet, or window)
- Add toolbar button in ContentView.swift
- Implement navigation/presentation logic
- Pass FountainScript to SceneBrowserWidget

**Step 4.2: Testing with Real Scripts**
- Test with test.fountain
- Test with "You're Nobody til Somebody Wants You Dead.highland"
- Verify performance with large scripts
- Test edge cases (no outline, flat structure, etc.)

**Validation**: Browser accessible from main app, works with all test files

#### Phase 5: Polish & Refinement
**Goal**: Enhance UX and handle edge cases

**Step 5.1: Visual Polish**
- Refine fonts, colors, and spacing
- Ensure visual hierarchy is clear
- Add animations (chevron rotation, smooth expansion)
- Test with light/dark mode

**Step 5.2: Accessibility**
- Add VoiceOver labels
- Test with Dynamic Type
- Ensure keyboard navigation works
- Test with accessibility inspector

**Step 5.3: Performance Optimization**
- Profile with Instruments
- Optimize for large scripts (100+ scenes)
- Ensure smooth scrolling
- Consider virtualization if needed

**Step 5.4: Edge Case Handling**
- No outline elements (flat script)
- Missing levels (scenes without groups)
- Multiple OVER BLACK sections
- Empty scenes
- Very long scene content

**Validation**: Smooth, accessible, performant experience across all scenarios

### Testing Strategy

#### Unit Tests
- [ ] SceneBrowserData model initialization
- [ ] Hierarchy extraction from FountainScript
- [ ] OVER BLACK detection and attachment
- [ ] Scene directive parsing
- [ ] Edge cases (missing levels, orphans, etc.)

#### UI Tests
- [ ] Scene expansion/collapse
- [ ] Chapter expansion/collapse
- [ ] Scene group expansion/collapse
- [ ] PreScene box interaction
- [ ] Scrolling performance
- [ ] Accessibility labels

#### Integration Tests
- [ ] Full browser with test.fountain
- [ ] Full browser with highland files
- [ ] Navigation from main app
- [ ] State persistence

### Development Order (File Creation)
1. `SceneBrowserData.swift` - Data models
2. `FountainScript+SceneBrowser.swift` - Extraction logic
3. Unit tests for data layer
4. `PreSceneBox.swift` - Leaf UI component
5. `SceneWidget.swift` - Scene UI with PreSceneBox
6. `SceneGroupWidget.swift` - Scene group UI with SceneWidgets
7. `ChapterWidget.swift` - Chapter UI with SceneGroupWidgets
8. `SceneBrowserWidget.swift` - Main container
9. Integration with ContentView/App
10. Polish, accessibility, and performance

### Validation Gates
Each phase must pass validation before proceeding:
- ✅ Phase 1: All data layer unit tests pass
- ✅ Phase 2: All UI components have working previews
- ✅ Phase 3: Full browser renders correctly with test data
- ✅ Phase 4: Browser integrated and working in app
- ✅ Phase 5: Accessibility and performance validated

### Rollback Strategy
- Each file should be committed individually after validation
- Branch strategy: `feature/scene-browser-widget`
- If issues arise, revert to last working commit
- Keep requirements.md updated with any changes

## Implementation Files

### New Files to Create
1. **`SceneBrowserWidget.swift`**
   - Main container view
   - Displays title header
   - Manages hierarchical outline structure
   - Manages expansion state for all levels

2. **`ChapterWidget.swift`**
   - Level 2 disclosure group
   - Contains scene groups
   - Chapter-specific styling

3. **`SceneGroupWidget.swift`**
   - Level 3 disclosure group
   - Contains scenes
   - Shows directive metadata if present
   - Scene group-specific styling

4. **`SceneWidget.swift`**
   - Individual scene disclosure group
   - Integrates PreSceneBox
   - Renders scene content

5. **`PreSceneBox.swift`**
   - Expandable/collapsable box for OVER BLACK content
   - Distinct visual styling

6. **`SceneBrowserData.swift`**
   - Data models: `SceneBrowserData`, `ChapterData`, `SceneGroupData`
   - Hierarchical structure for browser
   - Integration with OutlineElement

7. **`FountainScript+SceneBrowser.swift`** (Extension)
   - `func extractSceneBrowserData() -> SceneBrowserData`
   - Outline-based extraction logic
   - OVER BLACK detection and attachment

### Integration Points
- **ContentView.swift**: Add toolbar button for scene browser
- **GuionDocumentAppApp.swift**: Navigation/window management for scene browser
- **Existing types**: Leverage `GuionElement`, `SceneLocation`, `FountainScript`

## User Interactions

### Scene Disclosure
- **Tap slugline**: Toggle scene content visibility
- **Default state**: Configurable (all collapsed/expanded/last state)
- **Visual feedback**: Chevron rotation animation

### PreScene Box
- **Tap header**: Toggle preScene content visibility
- **Default state**: Collapsed
- **Visual feedback**: Chevron rotation, subtle background change
- **Label behavior**:
  - If collapsed: Show "OVER BLACK" or preview
  - If expanded: Show "OVER BLACK" label

### Navigation
- **Scroll**: Smooth scrolling through scenes
- **Search**: Filter scenes by slugline/content (future)
- **Jump to**: Tap to jump to scene in main editor (future)

## Visual Hierarchy

```
SceneBrowserWidget (Container)
├── Title Header (Level 1 - Always Visible)
│   └── Text: Document Title
│
├── ChapterWidget (Level 2)
│   ├── ▼ Chapter Disclosure Label
│   └── Content:
│       ├── SceneGroupWidget (Level 3)
│       │   ├── ▼ Scene Group Disclosure Label
│       │   │   └── (Optional: Directive metadata)
│       │   └── Content:
│       │       ├── SceneWidget (Scene 1)
│       │       │   ├── PreSceneBox (Optional)
│       │       │   │   ├── Header: "OVER BLACK" [Chevron]
│       │       │   │   └── Content: Centered, italic text
│       │       │   └── ▼ Scene Slugline Disclosure
│       │       │       └── Scene Elements
│       │       ├── SceneWidget (Scene 2)
│       │       │   └── ▼ Scene Slugline Disclosure...
│       │       └── ...
│       │
│       ├── SceneGroupWidget (Level 3)
│       │   └── ...
│       └── ...
│
├── ChapterWidget (Level 2)
│   └── ...
└── ...
```

### Visual Distinction by Level

**Level 1 - Title**
- Font: `.title` or `.largeTitle`, bold
- Color: Primary
- Background: None
- Spacing: Large bottom padding (24pt)
- Behavior: Static header, no disclosure

**Level 2 - Chapter**
- Font: `.title2`, bold
- Color: Primary
- Background: Subtle tint (optional)
- Border: Bottom border, secondary color
- Spacing: 20pt top/bottom padding
- Indent: 0pt
- Disclosure: Chevron animation

**Level 3 - Scene Group**
- Font: `.title3`, semibold
- Color: Primary
- Background: None
- Spacing: 16pt top/bottom padding
- Indent: 12pt from left
- Disclosure: Chevron animation
- Metadata: Secondary text below title if directive exists

**Scenes**
- Font: `.body`, bold (for slugline)
- Color: Primary
- Background: None
- Spacing: 12pt top/bottom padding
- Indent: 24pt from left
- Disclosure: Chevron animation
- Content: Formatted screenplay elements

## Accessibility

- **VoiceOver**: Proper labels for all interactive elements
- **Dynamic Type**: Support system font scaling
- **Keyboard Navigation**: Full keyboard support for expansion/collapse
- **Labels**:
  - Scene disclosure: "Scene {number}: {slugline}"
  - PreScene box: "Over Black content for scene {number}"

## Performance Considerations

- **Lazy Loading**: Use `LazyVStack` for scene list
- **State Management**: Minimize re-renders with `@State` and `@Binding`
- **Large Scripts**: Test with 100+ scene scripts
- **Memory**: Release collapsed scene content if needed
- **Caching**: Cache parsed `SceneViewModel` array

## Testing Requirements

### Unit Tests
- Scene extraction from FountainScript
- OVER BLACK detection and attachment
- SceneViewModel creation
- Edge cases (no scenes, only OVER BLACK, etc.)

### UI Tests
- Scene expansion/collapse
- PreScene box interaction
- Scrolling performance
- Accessibility

### Test Files/Scripts
- `test.fountain` (has OVER BLACK examples)
- "You're Nobody til Somebody Wants You Dead.highland" (real-world example)
- Edge case test files

## Future Enhancements

1. **Scene Filtering**: Search/filter by location, character, content
2. **Scene Reordering**: Drag-and-drop to reorder scenes
3. **Scene Details**: Show scene duration, character count, page count
4. **Scene Linking**: Jump to scene in main editor
5. **Scene Notes**: Add notes/annotations per scene
6. **Scene Summaries**: Integration with `SceneSummarizer`
7. **Export**: Export scene list as outline/beat sheet
8. **Scene Color Coding**: By location, time of day, or custom tags

## Dependencies

### Existing SwiftGuion Types
- `FountainScript` - Main script model
- `GuionElement` - Individual script elements
- `SceneLocation` - Parsed location data
- `OutlineElement` - Outline structure (optional integration)
- `SceneSummarizer` - Future summary integration

### SwiftUI Components
- `DisclosureGroup` - Scene content expansion
- `LazyVStack` - Performance for long lists
- `ScrollView` - Scrollable scene list

### External
- None (all functionality using SwiftUI and existing types)

## Success Criteria

1. ✅ Document title (Level 1) displayed as static header
2. ✅ Chapters (Level 2) displayed as collapsible sections
3. ✅ Scene Groups (Level 3) displayed as nested collapsible sections
4. ✅ All scenes from a FountainScript are displayed in correct hierarchy
5. ✅ Scene sluglines serve as disclosure group labels
6. ✅ Scene content properly formatted and expandable
7. ✅ OVER BLACK content detected and attached as preScene
8. ✅ PreScene box visually distinct and independently collapsable
9. ✅ Visual hierarchy clear: Title > Chapter > Scene Group > Scene
10. ✅ Each level has distinct visual styling
11. ✅ Proper indentation for nested levels
12. ✅ Scene directive metadata displayed for scene groups
13. ✅ Smooth performance with large scripts (100+ scenes, multiple chapters)
14. ✅ Accessibility compliant
15. ✅ Visual design matches existing app aesthetic
16. ✅ Edge cases handled gracefully (missing levels, orphaned scenes, etc.)
17. ✅ Integration with existing ContentView and app structure
18. ✅ Leverages existing OutlineElement hierarchy

## Open Questions

1. **Default Expansion State**: Should scenes be expanded or collapsed by default?
2. **PreScene Visual Treatment**: What color/styling best distinguishes OVER BLACK content?
3. **Navigation Integration**: Should scene browser be a sidebar, sheet, or separate window?
4. **State Persistence**: Should expansion states be saved between sessions?
5. **Scene Heading Format**: Should we show scene numbers in the browser?
6. **Multiple OVER BLACK**: How to handle multiple consecutive OVER BLACK sections?

## Example Usage

```swift
// In ContentView or separate window
SceneBrowserWidget(script: fountainScript)
    .frame(minWidth: 300, idealWidth: 400)

// Extract hierarchical data
let browserData = fountainScript.extractSceneBrowserData()

// Main browser structure
VStack(alignment: .leading, spacing: 0) {
    // Title header (always visible)
    if let title = browserData.title {
        Text(title.string)
            .font(.largeTitle)
            .bold()
            .padding()
    }

    ScrollView {
        LazyVStack(alignment: .leading, spacing: 0) {
            // Chapters
            ForEach(browserData.chapters) { chapter in
                ChapterWidget(
                    chapter: chapter,
                    isExpanded: expandedElements.contains(chapter.element.id)
                )
            }
        }
    }
}

// Chapter widget example
DisclosureGroup(
    isExpanded: $isExpanded,
    content: {
        ForEach(sceneGroups) { group in
            SceneGroupWidget(
                sceneGroup: group,
                isExpanded: expandedElements.contains(group.element.id)
            )
        }
    },
    label: {
        Text(chapter.element.string)
            .font(.title2)
            .bold()
    }
)
```

## Notes

- "OVER BLACK" is recognized as a scene heading by the parser (line 287 in FastFountainParser.swift)
- Scene IDs (UUIDs) are assigned during parsing for duplicate heading support
- Existing `SceneLocation` parsing handles complex slugline formats
- Consider reusing disclosure/expansion patterns from existing app
- Outline hierarchy is already established by `FountainScript.extractOutline()`
- `OutlineElement` provides `parentId`, `childIds`, and hierarchy traversal methods
- Level 1 title element can be identified with `isMainTitle` property
- Level 2 chapter elements can be identified with `isChapter` property
- Level 3 scene groups can be identified with `isSceneDirective` property or `level == 3`
- Scene directive metadata stored in `sceneDirective` and `sceneDirectiveDescription` properties
- `OutlineElement.sceneText(from:outline:)` method retrieves complete scene content
- Scene groups in test.fountain use format: `### PROLOGUE S#{{SERIES: 1001}}`
