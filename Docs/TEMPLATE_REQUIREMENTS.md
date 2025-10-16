# GuionViewer Xcode Document Application Template Requirements

## Overview

An Xcode project template that enables developers to quickly create a SwiftGuion-based document application for iOS 26+ or macOS 26+. The template should generate a fully functional screenplay editor with document persistence, outline navigation, and scene browsing capabilities.

## Template Location

```
SwiftGuion/
└── Templates/
    └── SwiftGuion Document App.xctemplate/
        ├── TemplateInfo.plist
        ├── TemplateIcon.png
        ├── TemplateIcon@2x.png
        └── [template files]
```

**Installation Path:**
```
~/Library/Developer/Xcode/Templates/Project Templates/Application/
```

## Platform Requirements

### Minimum Deployment Targets
- **iOS**: 26.0+
- **macOS**: 26.0+
- **Swift**: 6.0+
- **Xcode**: 17.0+

### Platform Support Matrix
- iOS (iPhone and iPad)
- macOS (Apple Silicon and Intel)
- Catalyst (optional, but not required initially)

## Core Requirements

### 1. Template Configuration

#### Template Options
The template should present these options during project creation:

- **Product Name**: Standard Xcode product name input
- **Organization Name**: Standard Xcode organization input
- **Organization Identifier**: Standard bundle identifier prefix
- **Platform**:
  - [ ] iOS
  - [ ] macOS
  - [ ] Multiplatform (iOS + macOS)
- **Document Type**:
  - [ ] SwiftData-based (default)
  - [ ] Value-based (in-memory)
- **Include Sample Content**: [ ] Yes / [ ] No

#### Generated Project Structure
```
[ProductName]/
├── [ProductName]App.swift
├── Models/
│   ├── GuionDocument.swift
│   └── GuionDocumentModel.swift (if SwiftData)
├── Views/
│   ├── ContentView.swift
│   ├── DocumentView.swift
│   ├── SceneBrowserView.swift
│   ├── OutlineNavigator.swift
│   └── EditorView.swift
├── Components/
│   ├── SceneCard.swift
│   ├── ChapterSection.swift
│   └── SceneGroupSection.swift
├── Resources/
│   ├── Assets.xcassets
│   └── SampleScreenplay.fountain (if selected)
├── Info.plist
└── [ProductName].entitlements
```

### 2. Document Handling

#### Document Types
The template must register support for:
- `.guion` - Native SwiftGuion format (primary)
- `.fountain` - Fountain screenplay format (import/export)
- `.fdx` - Final Draft XML format (import/export)
- `.highland` - Highland format (import/export)

#### Document Persistence
- **SwiftData Mode**: Full persistence with undo/redo
- **Value Mode**: In-memory with save/load functionality
- File coordination for iCloud/shared documents
- Autosave support (macOS)
- Version browsing support (macOS)

#### Document Configuration
```swift
struct GuionDocumentConfiguration: FileDocument {
    static var readableContentTypes: [UTType] = [
        .guionDocument,
        .fountainDocument,
        .fdxDocument,
        .highlandDocument
    ]

    static var writableContentTypes: [UTType] = [
        .guionDocument
    ]
}
```

### 3. User Interface Components

#### iOS Interface
- **Document Browser**: Native iOS document picker
- **Split View**:
  - Scene Browser (leading sidebar)
  - Editor (center)
  - Inspector (trailing sidebar, compact on iPhone)
- **Toolbar**:
  - Export button
  - Outline toggle
  - Format controls
- **Scene Browser**:
  - Hierarchical list (Title → Chapters → Scene Groups → Scenes)
  - Collapsible sections
  - Scene summaries (if available)
  - Location badges

#### macOS Interface
- **Document Window**: Standard macOS document window
- **Triple Column Layout**:
  - Outline/Scene Browser (sidebar)
  - Editor (main)
  - Inspector (trailing sidebar)
- **Menu Bar**:
  - File → Export As... (Fountain, FDX)
  - View → Show Outline, Show Inspector
  - Format → Character, Action, Dialogue, etc.
- **Toolbar**:
  - Export dropdown
  - View toggles
  - Format toolbar

### 4. Essential Features

#### Editor
- [ ] Syntax-highlighted Fountain editing
- [ ] Auto-formatting (INT./EXT. detection, character names, etc.)
- [ ] Element type detection and styling
- [ ] Scene number display (if enabled)
- [ ] Character autocomplete
- [ ] Keyboard shortcuts for element types

#### Scene Browser
- [ ] Hierarchical navigation (Title → Chapters → Scene Groups → Scenes)
- [ ] Scene cards with:
  - Scene heading
  - Location badge (INT/EXT, time of day)
  - Scene summary (if available)
  - Scene number
- [ ] Tap/click to navigate to scene
- [ ] Drag-to-reorder scenes (optional enhancement)
- [ ] Collapsible chapters and scene groups

#### Outline Navigator
- [ ] Hierarchical section headings (#, ##, ###)
- [ ] Scene headings
- [ ] Filtering by level
- [ ] Jump-to navigation

#### Export
- [ ] Export to Fountain (.fountain)
- [ ] Export to Final Draft (.fdx)
- [ ] Export to Highland (.highland)
- [ ] Share sheet integration (iOS)
- [ ] Save panel with format picker (macOS)

#### Import
- [ ] Import from Fountain
- [ ] Import from FDX
- [ ] Import from Highland
- [ ] Convert to native .guion format on import

### 5. SwiftData Integration (Default Mode)

#### Model Container
```swift
@main
struct [ProductName]App: App {
    var body: some Scene {
        DocumentGroup(editing: GuionDocumentModel.self,
                     contentType: .guionDocument) {
            ContentView()
        }
        .modelContainer(for: [
            GuionDocumentModel.self,
            GuionElementModel.self
        ])
    }
}
```

#### Data Models
- `GuionDocumentModel`: Main document container
- `GuionElementModel`: Individual screenplay elements
- Relationships properly configured
- Migration support

### 6. App Capabilities & Entitlements

#### Required Capabilities
- [ ] Document-based application
- [ ] File access (user-selected files)
- [ ] iCloud Documents (optional, user choice)

#### Entitlements File
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "...">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <!-- Optional: iCloud -->
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.$(CFBundleIdentifier)</string>
    </array>
    <key>com.apple.developer.ubiquity-container-identifiers</key>
    <array>
        <string>iCloud.$(CFBundleIdentifier)</string>
    </array>
</dict>
</plist>
```

### 7. Package Dependencies

#### SwiftGuion Package
Template should add SwiftGuion as a package dependency:

```swift
dependencies: [
    .package(url: "https://github.com/intrusive-memory/SwiftGuion.git",
            .upToNextMajor(from: "1.0.0"))
]
```

#### Optional Dependencies
- SwiftData (included in iOS 26+/macOS 26+)
- UniformTypeIdentifiers (included)

### 8. Sample Content (Optional)

If "Include Sample Content" is selected:

#### Sample Screenplay
A minimal `.fountain` file demonstrating:
- Title page
- Section headings (# Act One, ## Scene 1)
- Scene headings (INT./EXT.)
- Action lines
- Character dialogue
- Parentheticals
- Transitions

Example:
```fountain
Title: Sample Screenplay
Author: Your Name
Draft date: 2025-01-15

# Act One

## Opening

INT. COFFEE SHOP - DAY

JANE sits at a table, typing on her laptop.

JOHN enters, spots Jane, and approaches.

JOHN
Hey, Jane!

JANE
(looking up)
Oh, hi John!

FADE OUT.
```

### 9. Build Configuration

#### Build Settings
- Swift Language Version: 6.0
- iOS Deployment Target: 26.0
- macOS Deployment Target: 26.0
- Supports Mac Catalyst: Optional
- Strict Concurrency Checking: Complete

#### Info.plist Entries
```xml
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeName</key>
        <string>Guion Screenplay</string>
        <key>LSHandlerRank</key>
        <string>Owner</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>com.yourcompany.guion</string>
        </array>
    </dict>
    <dict>
        <key>CFBundleTypeName</key>
        <string>Fountain Screenplay</string>
        <key>LSHandlerRank</key>
        <string>Alternate</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>com.highland2.fountain</string>
        </array>
    </dict>
</array>

<key>UTExportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeIdentifier</key>
        <string>com.yourcompany.guion</string>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.data</string>
            <string>public.content</string>
        </array>
        <key>UTTypeDescription</key>
        <string>Guion Screenplay Document</string>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>guion</string>
            </array>
        </dict>
    </dict>
</array>
```

### 10. Code Quality Requirements

#### Code Standards
- [ ] SwiftLint compatible (optional config included)
- [ ] Comprehensive code comments
- [ ] Protocol-oriented where appropriate
- [ ] Observable macro for view models
- [ ] Sendable conformance for concurrent types

#### Error Handling
- [ ] Graceful import failures
- [ ] User-facing error alerts
- [ ] Validation before save
- [ ] Recovery suggestions

#### Performance
- [ ] Lazy loading for large documents
- [ ] Pagination for scene browser
- [ ] Background parsing
- [ ] Efficient SwiftData queries

### 11. Documentation Included

#### README Template
```markdown
# [Product Name]

A screenplay editor built with SwiftGuion.

## Features
- Native .guion document format
- Import/export Fountain, FDX, Highland
- Scene browser with hierarchical navigation
- Syntax-highlighted editing
- iCloud document sync (optional)

## Requirements
- iOS 26.0+ or macOS 26.0+
- Xcode 17.0+

## Getting Started
1. Open a .fountain file or create new document
2. Use the scene browser to navigate
3. Export to your preferred format

## License
[Your License]
```

#### Inline Code Documentation
All template files should include:
- Header comments explaining purpose
- DocC-compatible documentation comments
- Usage examples where appropriate
- TODO markers for customization points

### 12. Template Testing Requirements

Before release, the template must:
- [ ] Generate a buildable project on first try
- [ ] Pass all SwiftGuion tests
- [ ] Successfully import sample .fountain files
- [ ] Successfully export to .fountain and .fdx
- [ ] Run on iOS simulator
- [ ] Run on macOS
- [ ] Handle document lifecycle (new, open, save, close)
- [ ] Persist changes with SwiftData
- [ ] Navigate scene browser without crashes
- [ ] Display all UI components correctly

### 13. Installation Instructions

#### For End Users
```bash
# 1. Clone or download SwiftGuion
git clone https://github.com/intrusive-memory/SwiftGuion.git

# 2. Install template
cd SwiftGuion/Templates
./install-template.sh

# 3. Restart Xcode
# 4. File → New → Project → Application → SwiftGuion Document App
```

#### Install Script Requirements
The template should include `install-template.sh`:
```bash
#!/bin/bash
TEMPLATE_DIR="$HOME/Library/Developer/Xcode/Templates/Project Templates/Application"
mkdir -p "$TEMPLATE_DIR"
cp -R "SwiftGuion Document App.xctemplate" "$TEMPLATE_DIR/"
echo "✅ Template installed successfully"
echo "Restart Xcode and look for 'SwiftGuion Document App' under File → New → Project"
```

### 14. Future Enhancements (Nice to Have)

- [ ] visionOS support
- [ ] tvOS support (read-only viewer)
- [ ] Collaborative editing (CloudKit)
- [ ] PDF export
- [ ] Production breakdown features
- [ ] Character relationship graphs
- [ ] Timeline visualization
- [ ] Script comparison/diffing
- [ ] Version history UI

## Success Criteria

The template is successful if a developer can:

1. Install the template in < 1 minute
2. Create a new project with zero configuration
3. Build and run immediately without errors
4. Open a .fountain file and see formatted content
5. Navigate scenes using the browser
6. Export to .fountain successfully
7. Understand how to customize the app through comments/docs

## Maintenance Plan

- Update template when SwiftGuion API changes
- Test with each new Xcode release
- Update minimum deployment targets annually
- Incorporate user feedback for common customizations
- Keep sample content current with best practices

## References

- [SwiftGuion Documentation](../README.md)
- [Xcode Template Documentation](https://developer.apple.com/documentation/xcode)
- [Document-Based App Tutorial](https://developer.apple.com/documentation/swiftui/building-a-document-based-app-with-swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
