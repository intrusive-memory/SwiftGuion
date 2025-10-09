# Guion Document App

A document-based macOS application for viewing and managing screenplay files using SwiftGuion.

## Features

- **Multi-format support**: Import and view `.fountain`, `.fdx` (Final Draft), and `.highland` screenplay files
- **Unified parsing**: Single code path for all screenplay formats via `GuionDocumentParserSwiftData`
- **Main window**: Scrolling view of the entire script with proper formatting
- **Locations window**: Browse all scene locations with grouping and search
- **Characters window**: View character list with dialogue statistics and search
- **SwiftData integration**: Screenplay data stored as queryable SwiftData models

## Architecture

The app uses:
- **SwiftUI** for the user interface
- **FileDocument** for document handling
- **SwiftData** for screenplay model persistence
- **SwiftGuion** library for all parsing operations

### Key Design Principles

**Single Point of Parsing**: All screenplay formats (Fountain, FDX, Highland) flow through `GuionDocumentParserSwiftData.loadAndParse()`. This eliminates redundancy and ensures consistent parsing behavior.

**Format Detection**: The library automatically detects file format based on extension and routes to the appropriate parser (FountainParser, FDXDocumentParser, Highland extractor).

**Lazy Parsing**: Documents are parsed on-demand when opened, displaying a progress indicator during the parsing phase.

**Bi-directional Conversion**: The app can:
- Read any supported format into SwiftData models
- Export SwiftData models back to Fountain or FDX formats

## Setup Instructions

### Configure Package Dependencies

The example app needs to reference the local SwiftGuion package (not the GitHub version). To configure this in Xcode:

1. Open `GuionDocumentApp.xcodeproj` in Xcode
2. Select the project in the navigator
3. Go to the "Package Dependencies" tab
4. Remove the existing SwiftGuion package dependency (GitHub version)
5. Click "+" to add a local package
6. Navigate to the parent SwiftGuion directory (two levels up)
7. Add the local SwiftGuion package

This ensures the app uses the development version with SwiftData models.

## Parsing Architecture

### How File Import Works

1. **FileDocument reads** the file as raw data
2. **GuionDocumentConfiguration** stores raw content temporarily
3. **ContentView** triggers async parsing via `.task {}`
4. **GuionDocumentModel.parseContent()** creates temp file and calls library
5. **GuionDocumentParserSwiftData.loadAndParse()** handles all formats:
   - `.fountain` → FountainParser
   - `.fdx` → FDXDocumentParser
   - `.highland` → Highland extractor → FountainParser
6. **SwiftData models** populated and ready for display

### Export Flow

1. User saves document
2. **GuionDocumentConfiguration.fileWrapper()** determines format
3. **GuionDocumentParserSwiftData** converts models to format:
   - FDX: `toFDXData(from:)`
   - Fountain: `toFountainScript(from:)` → FountainWriter
4. Data written to file

## File Structure

```
GuionDocumentApp/
├── GuionDocumentAppApp.swift      # App entry point with window configuration
├── GuionDocument.swift            # Document reading/writing logic
├── ContentView.swift              # Main screenplay viewer
├── LocationsWindowView.swift      # Locations browser window
├── CharactersWindowView.swift     # Characters list window
├── Info.plist                     # Document type registration
└── Assets.xcassets                # App assets
```

## Document Types

The app registers handlers for:
- `.guion` - Native document format
- `.fountain` - Fountain screenplay format
- `.fdx` - Final Draft XML format
- `.highland` - Highland package format

## Windows

### Main Window
Displays the full screenplay with:
- Title page
- Formatted script elements (scene headings, action, dialogue, etc.)
- Proper indentation and spacing
- Text selection support

### Locations Window
Shows all scene locations with:
- Grouping by unique location
- Scene count per location
- INT/EXT indicators with icons
- Search functionality
- Expandable scene lists

### Characters Window
Displays character information including:
- Alphabetical or statistical sorting
- Line count and word count per character
- Scene appearances
- First dialogue preview
- Search functionality

## Usage

1. Launch the app
2. Open a screenplay file (File > Open)
3. View the script in the main window
4. Use toolbar buttons to open Locations or Characters windows
5. Use search bars to filter locations or characters

## Development

To build and run:
1. Configure the local package dependency (see Setup Instructions)
2. Build in Xcode (⌘+B)
3. Run the app (⌘+R)

## Future Enhancements

Potential improvements:
- Edit screenplay content
- Export to different formats
- Scene navigator
- Character arc tracking
- Scene beat sheets
- Production scheduling features
