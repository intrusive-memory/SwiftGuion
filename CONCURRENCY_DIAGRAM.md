# SwiftGuion Concurrency & Threading Architecture

## Overview

This diagram shows the concurrency model of SwiftGuion, delineating which classes require MainActor isolation (for SwiftData/UI operations) and which can safely operate on background threads.

## Entity Relationship Diagram with Concurrency Boundaries

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         MAIN THREAD (@MainActor)                        │
│                    SwiftData Models & UI Operations                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ GuionDocumentModel (@Model - implicitly @MainActor)              │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • filename: String?                                              │  │
│  │ • rawContent: String?                                            │  │
│  │ • suppressSceneNumbers: Bool                                     │  │
│  │ • elements: [GuionElementModel] (cascade delete)                 │  │
│  │ • titlePage: [TitlePageEntryModel] (cascade delete)              │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│           │                                                              │
│           │ @Relationship (inverse)                                     │
│           ├─────────────────────────────────────────┐                   │
│           │                                         │                   │
│           ▼                                         ▼                   │
│  ┌────────────────────────┐              ┌──────────────────────┐      │
│  │ GuionElementModel      │              │ TitlePageEntryModel  │      │
│  │ (@Model)               │              │ (@Model)             │      │
│  ├────────────────────────┤              ├──────────────────────┤      │
│  │ • elementText          │              │ • key: String        │      │
│  │ • elementType          │              │ • values: [String]   │      │
│  │ • sceneNumber          │              │ • document ref       │      │
│  │ • summary              │              └──────────────────────┘      │
│  │ • location cache       │                                            │
│  │ • document ref         │                                            │
│  └────────────────────────┘                                            │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ GuionDocumentConfiguration (FileDocument - nonisolated)          │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • document: GuionDocumentModel ⚠️ SENDABLE WARNING               │  │
│  │ • init(configuration:) - reads files                             │  │
│  │ • fileWrapper(configuration:) - writes files                     │  │
│  │                                                                   │  │
│  │ PROBLEM: Stores non-Sendable GuionDocumentModel                  │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ Export Documents (FileDocument - nonisolated)                    │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ FountainExportDocument                                           │  │
│  │ • sourceDocument: GuionDocumentModel ⚠️ SENDABLE WARNING         │  │
│  │                                                                   │  │
│  │ FDXExportDocument                                                │  │
│  │ • sourceDocument: GuionDocumentModel ⚠️ SENDABLE WARNING         │  │
│  │                                                                   │  │
│  │ PROBLEM: Store non-Sendable GuionDocumentModel                   │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ Parser/Serialization (@MainActor methods)                        │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ GuionDocumentParserSwiftData                                     │  │
│  │ • loadAndParse(from:in:) @MainActor                              │  │
│  │ • parseDocument(_:in:) @MainActor                                │  │
│  │                                                                   │  │
│  │ GuionDocumentSerialization                                       │  │
│  │ • toFountainScript(from:) @MainActor                             │  │
│  │ • toFDXData(from:) @MainActor                                    │  │
│  │ • serializeElements(_:) @MainActor                               │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ GuionDocumentModel.parseContent() @MainActor                     │  │
│  │ • Async parsing from raw content                                 │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                      BACKGROUND THREADS (Sendable)                      │
│              Value Types & Concurrent-Safe Operations                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ FountainScript (class with @unchecked Sendable)                  │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • filename: String?                                              │  │
│  │ • elements: [GuionElement]                                       │  │
│  │ • titlePage: [[String: [String]]]                                │  │
│  │ • suppressSceneNumbers: Bool                                     │  │
│  │                                                                   │  │
│  │ Methods (all thread-safe):                                       │  │
│  │ • loadFile(_:parser:)                                            │  │
│  │ • loadString(_:parser:)                                          │  │
│  │ • stringFromDocument()                                           │  │
│  │ • write(toFile:)                                                 │  │
│  │                                                                   │  │
│  │ WARNING: @unchecked Sendable - not truly thread-safe             │  │
│  │ (mutable properties)                                             │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ GuionElement (struct, Sendable) ✓                                │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ • elementText: String                                            │  │
│  │ • elementType: String                                            │  │
│  │ • sceneNumber: String?                                           │  │
│  │ • isCentered: Bool                                               │  │
│  │ • isDualDialogue: Bool                                           │  │
│  │ • sectionDepth: Int                                              │  │
│  │ • sceneId: String?                                               │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ Analysis Data (all Sendable) ✓                                   │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ SceneLocation (struct, Sendable)                                 │  │
│  │ SceneLighting (enum, Sendable)                                   │  │
│  │ SceneBrowserData (struct, Sendable)                              │  │
│  │ ChapterData (struct, Sendable)                                   │  │
│  │ SceneGroupData (struct, Sendable)                                │  │
│  │ SceneData (struct, Sendable)                                     │  │
│  │ OutlineElement (struct, Sendable)                                │  │
│  │ SceneWithLocation (struct, Sendable)                             │  │
│  │ LocationGroup (struct, Sendable)                                 │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ Parsers & Writers (stateless, thread-safe)                       │  │
│  ├──────────────────────────────────────────────────────────────────┤  │
│  │ FastFountainParser                                               │  │
│  │ • parse(_:) -> [GuionElement]                                    │  │
│  │                                                                   │  │
│  │ FountainWriter                                                   │  │
│  │ • document(from:) -> String                                      │  │
│  │                                                                   │  │
│  │ FDXDocumentParser                                                │  │
│  │ • parse(data:) -> [GuionElement]                                 │  │
│  │                                                                   │  │
│  │ FDXDocumentWriter                                                │  │
│  │ • write(_:) -> Data                                              │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

## Concurrency Issues & Warnings

### Current Problems

1. **FileDocument Sendable Violations**
   - `GuionDocumentConfiguration.document: GuionDocumentModel`
   - `FountainExportDocument.sourceDocument: GuionDocumentModel`
   - `FDXExportDocument.sourceDocument: GuionDocumentModel`

   **Issue:** FileDocument is nonisolated but stores @MainActor-isolated SwiftData models

2. **FountainScript @unchecked Sendable**
   - Marked as `@unchecked Sendable` but has mutable properties
   - Could cause data races if accessed from multiple threads
   - Properties: `elements`, `titlePage`, `cachedContent` are all mutable

### Why These Issues Exist

**SwiftData Models (@Model) are implicitly @MainActor:**
- They must only be accessed on the main thread
- ModelContext is @MainActor
- All operations require main actor isolation

**FileDocument protocol is nonisolated:**
- init(configuration:) can be called from any thread
- fileWrapper(configuration:) can be called from any thread
- Storing @MainActor types violates Sendable requirements

## Thread Boundaries

### ✅ Can Run on Background Threads
- Parsing Fountain/FDX text (FastFountainParser, FDXDocumentParser)
- Writing Fountain/FDX text (FountainWriter, FDXDocumentWriter)
- Creating GuionElement structs (value types)
- Creating analysis data structures (SceneLocation, etc.)
- FountainScript operations (if properly synchronized)

### ⚠️ MUST Run on Main Thread
- Any SwiftData model access (GuionDocumentModel, GuionElementModel)
- ModelContext operations
- Converting between GuionDocumentModel ↔ FountainScript
- FileDocument operations that touch SwiftData models
- UI operations

### 🔄 Mixed Context (Needs Careful Handling)
- GuionDocumentConfiguration: nonisolated but accesses @MainActor models
- Export documents: nonisolated but access @MainActor models
- Parser methods that create SwiftData models

## Solutions to Consider

### Option 1: Make FileDocument Sendable-Safe
```swift
struct GuionDocumentConfiguration: FileDocument {
    // Store Sendable data instead
    private var documentData: Data?
    private var script: FountainScript?

    // Compute model on demand with @MainActor
    @MainActor
    var documentModel: GuionDocumentModel {
        // Create from data/script when needed
    }
}
```

### Option 2: Make FountainScript Truly Thread-Safe
```swift
actor FountainScript {
    // All properties become actor-isolated
    // Automatic synchronization
}
```

### Option 3: Make FountainScript Immutable
```swift
public final class FountainScript: Sendable {
    public let filename: String?
    public let elements: [GuionElement]  // immutable
    public let titlePage: [[String: [String]]]  // immutable
    // All properties become let constants
}
```

### Option 4: Lazy Loading Pattern (Current Approach)
```swift
// Store data, compute model on demand
private var documentData: Data?
@MainActor
func getModel() -> GuionDocumentModel {
    // Parse data when accessed
}
```

## Key Takeaways

1. **SwiftData = MainActor:** All `@Model` classes require main thread
2. **Value Types = Background Safe:** GuionElement, SceneLocation, etc. are Sendable
3. **FountainScript = Problematic:** @unchecked Sendable with mutable state
4. **FileDocument = Boundary Issue:** Nonisolated but needs @MainActor data

## Recommended Fixes

1. Fix FileDocument Sendable warnings by using lazy loading pattern
2. Make FountainScript truly immutable or convert to actor
3. Ensure all SwiftData access is properly @MainActor isolated
4. Add proper Sendable conformance where needed
