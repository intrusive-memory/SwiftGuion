# Screenplay SwiftData Import/Export Skill

An AI assistant skill for working with SwiftGuion screenplay parsing and SwiftData integration.

## ⚠️ Important: SwiftGuion API Note

**SwiftGuion's `GuionParsedScreenplay` uses synchronous parsing:**
- ❌ No built-in `async`/`await` support
- ❌ No built-in progress reporting (`OperationProgress`)
- ✅ Thread-safe and Sendable (safe to use from background threads)
- ✅ Synchronous `throws` initializers

**For background parsing:**
```swift
let parsed = try await Task.detached {
    try GuionParsedScreenplay(file: url.path, parser: .fast)
}.value
```

**Note:** If you need async/await with progress support, see the SwiftCompartido package which provides `GuionParsedScreenplay` with those features.

## Overview

This skill enables AI assistants (like Claude Code, GitHub Copilot, Cursor, etc.) to help developers:

- Import screenplay files (Fountain, FDX, Highland) into SwiftData
- Export SwiftData models back to screenplay formats
- Extract analysis data (characters, locations, outline)
- Build screenplay editing and production tools
- Integrate SwiftGuion with SwiftUI applications

## Quick Start

### For AI Assistants

When a user asks for help with screenplay import/export or SwiftGuion integration:

1. **Read the skill prompt**: `screenplay-swiftdata.md` contains comprehensive guidance
2. **Reference examples**: `examples.md` provides copy-paste code snippets
3. **Follow the architecture**: Understand immutable vs mutable design patterns
4. **Use the workflows**: Follow established patterns for import, export, and analysis

### For Developers

To use this skill with your AI assistant:

1. **Point your AI to this directory** when working on SwiftGuion integration
2. **Reference specific sections** for targeted help
3. **Copy examples** and adapt them to your needs
4. **Ask questions** about screenplay parsing, SwiftData integration, or analysis

## Skill Contents

### `screenplay-swiftdata.md` (Main Skill Prompt)

The comprehensive AI assistant prompt containing:

- Core capabilities and workflows
- SwiftGuion architecture overview
- Complete import/export pipelines
- Element type reference
- Scene location parsing
- Progress reporting patterns
- Error handling strategies
- Performance considerations
- UI integration guidance
- Common pitfalls and solutions

**Use this when:** You need comprehensive understanding of SwiftGuion integration patterns.

### `examples.md` (Practical Examples)

Ready-to-use code examples for:

- Basic screenplay import
- Import with progress tracking
- Export to Fountain format
- Export to Final Draft (FDX)
- Character analysis and extraction
- Location parsing and grouping
- Outline generation
- SwiftUI document list views
- Drag and drop file handling
- Batch import operations
- Unit testing

**Use this when:** You need working code to adapt for your specific use case.

### This README

Overview and usage guide for the skill itself.

## Key Concepts

### Immutable vs Mutable Design

SwiftGuion separates concerns:

```
Screenplay File
    ↓ Parse (immutable, thread-safe)
GuionParsedScreenplay
    ↓ Convert (to SwiftData)
GuionDocumentModel (mutable, reactive)
    ↓ UI (SwiftUI, reactive)
GuionViewer
```

**Benefits:**
- Thread-safe parsing in background
- Clean separation of concerns
- Reactive UI updates via SwiftData
- Easy export back to files

### Thread Safety Architecture

**CRITICAL: Always follow this pattern for thread safety:**

```
Background Thread          MainActor
─────────────────         ──────────
Parse screenplay    ──→   Receive Sendable data
(GuionParsedScreenplay)  │
                           ↓
                    Create SwiftData models
                    (GuionDocumentModel, etc.)
                           │
                           ↓
                    modelContext.insert()
                    modelContext.save()
```

**The Three Rules:**

1. **Parse on background thread**
   - `GuionParsedScreenplay` is `Sendable` and thread-safe
   - Parsing happens automatically on background when using `async`
   - Never blocks the UI

2. **Transfer via Sendable**
   - Parsed data is `Sendable` and safe to transfer between threads
   - Swift's concurrency system handles this automatically

3. **SwiftData ONLY on @MainActor**
   - All `ModelContext` operations must be on main thread
   - All SwiftData model creation/modification on main thread
   - Use `@MainActor` functions or `await MainActor.run { }`

**Example:**

```swift
@MainActor
func importScreenplay(url: URL, modelContext: ModelContext) async throws {
    // Step 1: Parse on background (automatic)
    let parsed = try await GuionParsedScreenplay(
        file: url.path,
        parser: .fast
    )

    // Step 2: Create SwiftData models on MainActor (we're already here)
    let document = GuionDocumentModel(
        filename: parsed.filename ?? "Untitled",
        rawContent: nil,
        suppressSceneNumbers: parsed.suppressSceneNumbers
    )

    modelContext.insert(document)
    // ... convert elements ...
    try modelContext.save()
}
```

**What NOT to do:**

❌ **Wrong:** Accessing ModelContext from actor
```swift
actor Importer {
    let modelContext: ModelContext  // ❌ ModelContext not thread-safe

    func import() async {
        modelContext.insert(...)  // ❌ Crash or data corruption
    }
}
```

✅ **Correct:** Separate parsing and persistence
```swift
actor Parser {
    func parse() async -> GuionParsedScreenplay { ... }  // ✅ Returns Sendable
}

@MainActor
class Persister {
    let modelContext: ModelContext
    func persist(_ parsed: GuionParsedScreenplay) { ... }  // ✅ On MainActor
}
```

### Chapter Indexing

Elements are tracked with two indices:

- `chapterIndex`: Which chapter (0 = before first chapter)
- `orderIndex`: Position within chapter

**Chapter detection:** Section heading level 2 (`## Heading`)

```swift
var currentChapter = 0
var positionInChapter = 0

for element in parsedCollection.elements {
    if case .sectionHeading(2) = element.elementType {
        currentChapter += 1
        positionInChapter = 1
    } else {
        positionInChapter += 1
    }

    let model = GuionElementModel(
        from: element,
        chapterIndex: currentChapter,
        orderIndex: positionInChapter
    )
}
```

### Element Sorting

Always sort by chapter first, then position:

```swift
let sorted = document.elements.sorted {
    if $0.chapterIndex != $1.chapterIndex {
        return $0.chapterIndex < $1.chapterIndex
    }
    return $0.orderIndex < $1.orderIndex
}
```

## Common Use Cases

### 1. Document-Based App

Build a macOS/iOS app for screenplay editing:

```swift
// Setup SwiftData
let schema = Schema([
    GuionDocumentModel.self,
    GuionElementModel.self,
    TitlePageEntryModel.self
])

// Import screenplays
let parsedCollection = try await GuionParsedScreenplay(
    file: url.path,
    parser: .fast
)

// Display with GuionViewer
GuionViewer(document: document)
```

See: `examples.md` → "SwiftUI Document List"

### 2. Screenplay Analysis Tool

Extract and visualize screenplay data:

```swift
// Character analysis
let characters = screenplay.extractCharacters()

// Location breakdown
let locations = screenplay.extractSceneLocations()

// Outline structure
let outline = screenplay.extractOutlineTree()
```

See: `examples.md` → "Character Analysis", "Location Extraction", "Outline Generation"

### 3. Format Conversion

Convert between screenplay formats:

```swift
// Fountain → SwiftData → FDX
let parsedCollection = try await GuionParsedScreenplay(
    file: "script.fountain"
)

let document = GuionDocumentModel.from(parsedCollection)
let screenplay = document.toGuionParsedScreenplay()

let fdxWriter = FDXWriter(screenplay: screenplay)
try fdxWriter.write().write(to: outputURL, encoding: .utf8)
```

See: `examples.md` → "Export to Final Draft"

### 4. Production Management

Track scenes, locations, and characters for production:

```swift
// Extract all shooting locations
let locations = extractLocations(from: document)
let grouped = groupLocationsByLighting(locations)

// Breakdown by character
let characters = extractCharacters(from: document)
let majorCharacters = characters.filter { $0.lineCount >= 20 }
```

See: `examples.md` → "Location Extraction", "Character Analysis"

## Workflows

### Complete Import Pipeline

1. Setup SwiftData schema
2. Parse screenplay file with progress
3. Create GuionDocumentModel
4. Convert elements with chapter tracking
5. Import title page metadata
6. Save to SwiftData

See: `screenplay-swiftdata.md` → "Workflow 1: Import Screenplay File"

### Complete Export Pipeline

1. Retrieve document from SwiftData
2. Convert to GuionParsedScreenplay
3. Create format writer (Fountain, FDX)
4. Generate content
5. Write to file

See: `screenplay-swiftdata.md` → "Workflow 2: Export Screenplay from SwiftData"

### Analysis Pipeline

1. Parse or retrieve screenplay
2. Extract desired data (characters/locations/outline)
3. Process and group results
4. Display or export

See: `screenplay-swiftdata.md` → "Workflow 3: Extract Analysis Data"

## Integration Points

### SwiftUI

```swift
import SwiftUI
import SwiftData
import SwiftGuion

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            GuionDocumentModel.self,
            GuionElementModel.self,
            TitlePageEntryModel.self
        ])
    }
}
```

### UIKit

```swift
import UIKit
import SwiftData
import SwiftGuion

class ScreenplayViewController: UIViewController {
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init(nibName: nil, bundle: nil)
    }

    func loadScreenplay(url: URL) async throws {
        let parsedCollection = try await GuionParsedScreenplay(
            file: url.path
        )

        // Convert and save...
    }
}
```

### Command-Line Tools

```swift
import Foundation
import SwiftGuion

@main
struct ScreenplayConverter {
    static func main() async throws {
        let args = CommandLine.arguments

        guard args.count > 2 else {
            print("Usage: converter <input> <output>")
            return
        }

        let parsedCollection = try await GuionParsedScreenplay(
            file: args[1]
        )

        let writer = FountainWriter(screenplay: parsedCollection)
        try writer.write().write(toFile: args[2], atomically: true, encoding: .utf8)
    }
}
```

## Performance Tips

### Parsing

- Use `.fast` parser for most cases
- Parse in background tasks for large files
- Show progress for files > 10MB
- Cache parsed results when possible

### SwiftData

- Avoid unnecessary conversions
- Use `@Query` efficiently in SwiftUI
- Index frequently-queried fields
- Batch inserts for large imports

### UI

- Use lazy loading for long screenplays
- Virtualize lists with many elements
- Cache computed properties
- Use proper font sizing (65 chars/line)

## Testing

### Unit Tests

```swift
import XCTest
import SwiftData
@testable import SwiftGuion

final class ImportTests: XCTestCase {
    func testImport() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: GuionDocumentModel.self,
            configurations: config
        )

        // Test import logic...
    }
}
```

See: `examples.md` → "Testing Examples"

### Integration Tests

Test complete workflows:

- File import → SwiftData → File export
- Parse → Analyze → Verify results
- UI interaction → Data updates

## Troubleshooting

### Common Issues

**Chapter indexing wrong:**
- Ensure section heading level 2 detection
- Reset `positionInChapter` to 1 on new chapter
- Increment chapter counter correctly

**Elements out of order:**
- Always sort by `(chapterIndex, orderIndex)`
- Don't rely on insertion order

**Progress not updating:**
- Use `Task { @MainActor in ... }` for UI updates
- Pass closure to `OperationProgress`

**Export missing elements:**
- Verify all elements inserted into context
- Check `modelContext.save()` was called
- Ensure proper element conversion

### Debug Checklist

1. ✅ SwiftData schema includes all three models
2. ✅ Chapter indexing logic is correct
3. ✅ Elements sorted properly before display
4. ✅ Progress handler uses MainActor for UI
5. ✅ Error handling covers all operations
6. ✅ modelContext.save() called after changes

## Resources

### SwiftGuion Documentation

- **Main README**: `../../README.md`
- **API Documentation**: `../../Docs/`
- **Example Apps**: `../../Examples/`
- **Test Suite**: `../../Tests/SwiftGuionTests/`

### External Resources

- **Fountain Spec**: https://fountain.io
- **SwiftData Guide**: https://developer.apple.com/documentation/swiftdata
- **SwiftUI Guide**: https://developer.apple.com/documentation/swiftui

### Example Projects

- **Produciesta**: `../../../Produciesta` - Full document-based app
- **FountainDocumentApp**: `../../Examples/FountainDocumentApp` - Minimal example

## Contributing

To improve this skill:

1. **Add examples** for common use cases
2. **Document edge cases** and solutions
3. **Share workflows** that work well
4. **Report issues** with the skill content
5. **Suggest improvements** to documentation

## License

This skill documentation is part of the SwiftGuion project and follows the same MIT license.

---

**Version**: 1.0.0
**Last Updated**: 2025-01-21
**SwiftGuion Version**: 2.2.0+
**Compatible With**: Claude Code, GitHub Copilot, Cursor, and other AI coding assistants
