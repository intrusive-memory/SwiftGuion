# SwiftGuion Quick Reference

One-page reference for common SwiftGuion tasks. For detailed examples, see `examples.md`.

## ⚠️ Thread Safety Rules

**CRITICAL - Always follow this pattern:**

1. ✅ **Parse on background thread**: `GuionParsedScreenplay` is Sendable
2. ✅ **Transfer to MainActor**: Parsed data is Sendable and safe to transfer
3. ✅ **Update SwiftData ONLY on @MainActor**: All ModelContext operations

**Never:**
- ❌ Access ModelContext from background threads
- ❌ Create/modify SwiftData models off main thread

## Setup SwiftData

```swift
let schema = Schema([
    GuionDocumentModel.self,
    GuionElementModel.self,
    TitlePageEntryModel.self
])

let container = try ModelContainer(for: schema, configurations: [
    ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
])
```

## Import Screenplay (Thread-Safe Pattern)

```swift
// CRITICAL: Parse on background, persist on MainActor

@MainActor
func importScreenplay(url: URL, modelContext: ModelContext) async throws {
    // Step 1: Parse on BACKGROUND thread (automatic)
    let parsed = try await GuionParsedScreenplay(
        file: url.path,
        parser: .fast,
        progress: progressHandler  // optional
    )
    // parsed is Sendable and now on main thread

    // Step 2: ALL SwiftData operations on MainActor (we're already here)
    let doc = GuionDocumentModel(
        filename: parsed.filename ?? "Untitled",
        rawContent: nil,
        suppressSceneNumbers: parsed.suppressSceneNumbers
    )
    modelContext.insert(doc)

    // Convert elements with chapter tracking
    var chapter = 0, position = 0
    for element in parsed.elements {
        if case .sectionHeading(2) = element.elementType {
            chapter += 1
            position = 1
        } else {
            position += 1
        }

        let model = GuionElementModel(
            from: element,
            chapterIndex: chapter,
            orderIndex: position
        )
        doc.elements.append(model)
        modelContext.insert(model)
    }

    try modelContext.save()
}

// Usage:
Task { @MainActor in
    try await importScreenplay(url: fileURL, modelContext: context)
}
```

## Export to Fountain

```swift
let screenplay = document.toGuionParsedScreenplay()
let writer = FountainWriter(screenplay: screenplay)
try writer.write().write(to: url, atomically: true, encoding: .utf8)
```

## Export to FDX

```swift
let screenplay = document.toGuionParsedScreenplay()
let writer = FDXWriter(screenplay: screenplay)
try writer.write().write(to: url, atomically: true, encoding: .utf8)
```

## Extract Characters

```swift
var characterLines: [String: Int] = [:]
var currentCharacter: String?

let sorted = document.elements.sorted {
    $0.chapterIndex == $1.chapterIndex
        ? $0.orderIndex < $1.orderIndex
        : $0.chapterIndex < $1.chapterIndex
}

for element in sorted {
    if element.elementType == .character {
        currentCharacter = element.elementText.trimmingCharacters(in: .whitespaces)
    } else if element.elementType == .dialogue, let char = currentCharacter {
        characterLines[char, default: 0] += 1
    }
}

// characterLines now has ["CHARACTER NAME": lineCount]
```

## Extract Locations

```swift
let sceneHeadings = document.elements.filter { $0.elementType == .sceneHeading }

for heading in sceneHeadings {
    if let location = heading.cachedSceneLocation {
        print("\(location.lighting.rawValue) \(location.scene)")
        // location.setup and location.timeOfDay available too
    }
}
```

## Extract Outline

```swift
let outline = document.elements.filter {
    $0.elementType == .synopsis || $0.elementType.isSectionHeading
}

for element in outline {
    if case .sectionHeading(let level) = element.elementType {
        let indent = String(repeating: "  ", count: level)
        print("\(indent)\(element.elementText)")
    }
}
```

## Progress Reporting

```swift
let progress = OperationProgress(totalUnits: nil) { update in
    Task { @MainActor in
        progressView.value = update.fractionCompleted ?? 0
        label.text = update.description
    }
}

let parsed = try await GuionParsedScreenplay(
    file: path,
    progress: progress
)
```

## Element Types

```swift
.sceneHeading           // INT. COFFEE SHOP - DAY
.action                 // Description/action
.character              // CHARACTER NAME
.dialogue               // Character's dialogue
.parenthetical          // (parenthetical)
.transition             // CUT TO:
.shot                   // CLOSE ON
.sectionHeading(level)  // # Heading (1-6)
.synopsis               // = Synopsis
.centered               // > Centered text <
.pageBreak              // ===
.lyric                  // ~ Song lyrics ~
.note                   // [[ Note ]]
.boneyard               // /* Omitted */
```

## Sort Elements

```swift
let sorted = document.elements.sorted {
    if $0.chapterIndex != $1.chapterIndex {
        return $0.chapterIndex < $1.chapterIndex
    }
    return $0.orderIndex < $1.orderIndex
}
```

## SwiftUI Integration

```swift
struct ScreenplayView: View {
    let document: GuionDocumentModel

    var body: some View {
        GuionViewer(document: document)
    }
}
```

## SwiftUI with Font Sizing

```swift
GeometryReader { geometry in
    let fontSize = ScreenplayPageFormat.calculateFontSize(
        forWidth: geometry.size.width
    )

    GuionViewer(document: document)
        .environment(\.screenplayFontSize, fontSize)
}
```

## Common Mistakes

❌ Wrong chapter indexing:
```swift
for (i, element) in elements.enumerated() {
    let model = GuionElementModel(..., chapterIndex: 0, orderIndex: i)
}
```

✅ Correct chapter indexing:
```swift
var chapter = 0, position = 0
for element in elements {
    if case .sectionHeading(2) = element.elementType {
        chapter += 1
        position = 1
    } else {
        position += 1
    }
    let model = GuionElementModel(..., chapterIndex: chapter, orderIndex: position)
}
```

❌ Wrong sorting:
```swift
elements.sorted { $0.orderIndex < $1.orderIndex }
```

✅ Correct sorting:
```swift
elements.sorted {
    $0.chapterIndex == $1.chapterIndex
        ? $0.orderIndex < $1.orderIndex
        : $0.chapterIndex < $1.chapterIndex
}
```

❌ Blocking UI with progress:
```swift
let progress = OperationProgress { update in
    progressView.update(update)  // Wrong thread!
}
```

✅ Async main actor:
```swift
let progress = OperationProgress { update in
    Task { @MainActor in
        progressView.update(update)
    }
}
```

## File Types

- `.fountain` - Plain text Fountain format
- `.fdx` - Final Draft XML
- `.highland` - Highland zip archive
- `.guion` - Native SwiftGuion bundle

## Parser Options

- `.fast` - Fast, lenient parsing (recommended)
- `.strict` - Validates structure, slower

## Resources

- Full documentation: `screenplay-swiftdata.md`
- Code examples: `examples.md`
- Skill overview: `README.md`
- SwiftGuion docs: `../../README.md`
