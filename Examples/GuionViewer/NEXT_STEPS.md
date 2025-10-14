# GuionViewer Phase 1 - Next Steps

## ✅ Completed in SwiftGuion Library

1. **Added FDXDocumentWriter.write() method**
   - Exports `GuionParsedScreenplay` directly to FDX format
   - Supports title page and all element types
   - Committed to `sample-app` branch

## 🔧 Required: Add SwiftGuion Dependency in Xcode

### Steps to Fix Build Errors

1. **Open the project in Xcode:**
   ```
   open /Users/stovak/Projects/SwiftGuion/Examples/GuionViewer/GuionViewer.xcodeproj
   ```

2. **Add SwiftGuion as a local package:**
   - In Project Navigator, select the **GuionViewer** project (top item)
   - Select the **GuionViewer** target
   - Go to **General** tab
   - Scroll to **Frameworks, Libraries, and Embedded Content**
   - Click the **+** button
   - Click **Add Other** → **Add Package Dependency...**
   - Click **Add Local...**
   - Navigate to `/Users/stovak/Projects/SwiftGuion` (two directories up from GuionViewer)
   - Click **Add Package**
   - In the dialog, select **SwiftGuion** library
   - Click **Add Package**

3. **Build the project (⌘B)**
   - Should now compile successfully

## 🐛 Known Issues to Fix in GuionViewer Code

### 1. GuionDocument.swift - API Mismatches

**Line 117**: Change from:
```swift
self.documentModel = GuionDocumentModel.fromScreenplay(screenplay)
```

To:
```swift
// GuionDocumentModel.from() requires ModelContext and is async
// For now, create a simple conversion without SwiftData
self.documentModel = GuionDocumentModel()
self.documentModel.filename = screenplay.filename
// TODO: Implement proper conversion
```

**Line 127**: Change from:
```swift
let screenplay = documentModel.toGuionParsedScreenplay()
```

To:
```swift
let screenplay = documentModel.toGuionParsedScreenplay()
```
This is correct! ✅

### 2. ImportCommands.swift - API Mismatches

**Lines 48, 68, 92**: All instances of `GuionDocumentModel.fromScreenplay()` need fixing

Change from:
```swift
newDocument.documentModel = GuionDocumentModel.fromScreenplay(screenplay)
```

To:
```swift
// Option A: Simple assignment (no SwiftData)
newDocument.documentModel.filename = screenplay.filename
// Copy elements...

// Option B: If we have ModelContext available
// let model = await GuionDocumentModel.from(screenplay, in: context)
// newDocument.documentModel = model
```

### 3. GuionViewerApp.swift - Simplify for Phase 1

The current app file has template code. Replace with:
```swift
import SwiftUI

@main
struct GuionViewerApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { GuionDocument() }) { file in
            ContentView(document: file.$document)
        }
        .commands {
            ImportCommands()
            ExportCommands()
        }
    }
}
```

## 📝 Alternative Approach: Simplify GuionDocument

Instead of using SwiftData's `GuionDocumentModel`, we could simplify GuionDocument to work directly with GuionParsedScreenplay:

```swift
@MainActor
final class GuionDocument: ReferenceFileDocument {
    static var readableContentTypes: [UTType] {
        [.guionDocument, .fountain, .highland, .fdx]
    }

    static var writableContentTypes: [UTType] {
        [.guionDocument]
    }

    @Published var screenplay: GuionParsedScreenplay

    init() {
        self.screenplay = GuionParsedScreenplay(
            filename: "Untitled.guion",
            elements: [],
            titlePage: [],
            suppressSceneNumbers: false
        )
    }

    required init(configuration: ReadConfiguration) throws {
        // Parse based on content type
        if configuration.contentType == .guionDocument {
            self.screenplay = try TextPackReader.readTextPack(from: configuration.file)
        } else if configuration.contentType == .fountain {
            let data = configuration.file.regularFileContents ?? Data()
            let content = String(data: data, encoding: .utf8) ?? ""
            self.screenplay = try GuionParsedScreenplay(string: content)
        }
        // ... etc
    }

    typealias Snapshot = Data

    func snapshot(contentType: UTType) throws -> Data {
        let textPack = try TextPackWriter.createTextPack(from: screenplay)
        return try textPack.serializedData()
    }

    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(serializedRepresentation: snapshot)
    }
}
```

This removes the SwiftData dependency for Phase 1 and makes the document simpler.

## 🎯 Phase 1 Goal

Once the dependency is added and API issues are fixed:

1. ✅ App builds successfully
2. ✅ Can create new documents
3. ✅ Can open .guion files
4. ✅ Can save .guion files
5. ✅ Can import .fountain, .highland, .fdx
6. ✅ Can export to .fountain, .fdx
7. ✅ ContentView shows filename and element count

Then we move to writing the 21 Phase 1 tests!

## 📚 Reference

- Phase 1 Requirements: `/Users/stovak/Projects/SwiftGuion/Docs/SAMPLE_APP_DEVELOPMENT_PHASES.md`
- SwiftGuion API: `/Users/stovak/Projects/SwiftGuion/API.md`
- Architecture: `/Users/stovak/Projects/SwiftGuion/ARCHITECTURE_REDESIGN.md`
