# SwiftGuion UI Components

Reusable SwiftUI widgets for displaying screenplay data from SwiftGuion.

## Overview

These widgets provide a hierarchical view of a screenplay's structure, allowing users to browse and navigate through chapters, scene groups, and individual scenes.

## Components

### SceneBrowserWidget

The main container widget that displays the complete screenplay structure.

```swift
import SwiftUI
import SwiftGuion

struct MyView: View {
    let script: FountainScript

    var body: some View {
        SceneBrowserWidget(script: script)
    }
}
```

**Features:**
- Displays screenplay title
- Hierarchical chapter/scene group/scene structure
- Collapsible disclosure groups
- Empty state when no chapters are found
- Accessibility support

### ChapterWidget

Displays a Level 2 chapter with its contained scene groups.

**Features:**
- Bold chapter title
- Collapsible scene groups
- Visual separator
- Accessibility labels

### SceneGroupWidget

Displays a Level 3 scene group with its contained scenes.

**Features:**
- Scene group title with optional directive metadata
- Collapsible scene list
- Indented to show hierarchy

### SceneWidget

Displays an individual scene with its elements.

**Features:**
- Scene slugline (e.g., "INT. STEAM ROOM - DAY")
- Lighting indicator badge (INT/EXT)
- Optional pre-scene content (OVER BLACK)
- Collapsible scene elements
- Formatted screenplay elements (Action, Dialogue, Character, etc.)

### PreSceneBox

Displays pre-scene content (OVER BLACK) in a collapsible box.

**Features:**
- "OVER BLACK" header with chevron
- Expandable/collapsible content
- Italic, centered text styling
- Smooth animations

## Element Types

Scene elements are rendered with appropriate styling:

- **Scene Heading**: Bold, monospaced
- **Action**: Standard text
- **Character**: Indented, primary color
- **Dialogue**: Further indented
- **Parenthetical**: Indented, secondary color
- **Transition**: Secondary color

## Accessibility

All widgets include:
- Proper accessibility labels
- Accessibility hints for interactive elements
- Trait annotations for buttons and headers
- Hierarchical element containment

## Example Usage

### Basic Scene Browser

```swift
import SwiftUI
import SwiftGuion

struct ContentView: View {
    @State private var script: FountainScript

    var body: some View {
        SceneBrowserWidget(script: script)
            .frame(minWidth: 400, minHeight: 600)
    }
}
```

### With Custom Navigation

```swift
struct SceneNavigator: View {
    let browserData: SceneBrowserData

    var body: some View {
        NavigationSplitView {
            SceneBrowserWidget(browserData: browserData)
        } detail: {
            Text("Select a scene")
        }
    }
}
```

## Requirements

- macOS 26.0+
- SwiftUI
- SwiftGuion package

## Related Types

- `SceneBrowserData`: Container for screenplay structure
- `ChapterData`: Chapter information
- `SceneGroupData`: Scene group information
- `SceneData`: Individual scene information
- `GuionElement`: Screenplay element
- `SceneLocation`: Scene location parsing
