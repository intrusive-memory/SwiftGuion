# GuionViewer Sample App

Phase 1: Core Document Operations

## Building the Project

This app depends on the SwiftGuion library. To build:

### Setup (One-time)

1. Open `GuionViewer.xcodeproj` in Xcode
2. Add SwiftGuion package dependency:
   - Select project in Navigator
   - Select "GuionViewer" target
   - Go to "General" → "Frameworks, Libraries, and Embedded Content"
   - Click "+" → "Add Package Dependency"
   - Choose "Add Local..."
   - Navigate to `/Users/stovak/Projects/SwiftGuion` (two directories up)
   - Select SwiftGuion library

3. Build the project (⌘B)

### Alternatively: Use Workspace

Build from the workspace which includes both SwiftGuion package and GuionViewer app.

## Phase 1 Features

- ✅ Open .guion files
- ✅ Save .guion files (TextPack format)
- ✅ Import from .fountain, .highland, .fdx
- ✅ Export to .fountain, .highland, .fdx
- ✅ File menu commands
- ✅ Bundle configuration with UTTypes

## Tests

Phase 1 requires 21 tests:
- 15 unit tests (GuionViewerTests)
- 6 UI tests (GuionViewerUITests)

Run tests: ⌘U
