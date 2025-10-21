# Claude Code Guide for SwiftGuion

This document provides guidance for using Claude Code with the SwiftGuion project.

## Quick Start

SwiftGuion has been configured with Claude Code-friendly permissions to streamline development. See `.claude/settings.json` for the complete configuration.

## Project Overview

**SwiftGuion** is a performant Swift parser for screenplay formats (Fountain, FDX, Highland) with SwiftData integration and SwiftUI components.

**Tech Stack:**
- Swift 6.2
- SwiftData (macOS 14.0+, iOS 17.0+)
- SwiftUI
- Swift Package Manager
- GitHub Actions CI/CD

**Platforms:**
- macOS 26+
- iOS 26+
- macCatalyst 26+

## Common Development Tasks

### Building the Project

```bash
# Build with parallelism (recommended)
swift build -j 8

# Build for specific platform
swift build --platform macos

# Clean build
swift package clean && swift build
```

Claude Code has permission to run `swift build` commands automatically.

### Running Tests

```bash
# Run all tests with parallelism
swift test -j 8

# Run specific test
swift test --filter FountainParserTests

# Run with code coverage
swift test --enable-code-coverage

# Skip performance tests (like CI does)
swift test \
  --skip IntegrationTests.testLargeDocumentPerformance \
  --skip IntegrationTests.testRapidSaveLoad \
  --skip IntegrationTests.testSceneLocationCachingPerformance \
  --skip DocumentExportTests.testExportPerformance \
  --skip DocumentImportTests.testImportVsNativePerformance \
  --skip GuionSerializationTests.testLargeDocumentPerformance \
  --skip SceneBrowserUITests.testLargeScriptPerformance
```

Claude Code has permission to run `swift test` commands automatically.

### Working with Git

Claude Code is configured to:
- Create commits with proper formatting
- Push to remote branches
- Create and manage pull requests via `gh` CLI
- View PR status and CI checks

**Example workflow:**
1. Make changes to code
2. Ask Claude: "commit these changes and create a PR"
3. Claude will automatically commit, push, and create a GitHub PR

### Resolving CI Failures

When tests fail in CI:

```bash
# Check PR status
gh pr checks <PR_NUMBER>

# View workflow logs
gh run view <RUN_ID> --log

# Run the same tests locally that CI runs
swift test --enable-code-coverage \
  --skip IntegrationTests.testLargeDocumentPerformance \
  [... other skipped tests ...]
```

## Project Structure

```
SwiftGuion/
├── Sources/SwiftGuion/
│   ├── Core/                 # Immutable GuionParsedScreenplay, OutlineElement
│   ├── FileFormat/           # GuionElement, ElementType, SwiftData models
│   ├── ImportExport/         # Parsers (Fountain, FDX) and Writers
│   ├── Analysis/             # Character, SceneLocation, Scene analysis
│   └── UI/                   # GuionViewer, scene browser widgets
├── Tests/SwiftGuionTests/    # Comprehensive test suite
├── Examples/                 # Example applications
│   └── FountainDocumentApp/  # Document-based macOS app
├── Package.swift             # Swift Package Manager manifest
├── .github/workflows/        # CI/CD configuration
│   └── tests.yml             # Test workflow with parallel builds
├── README.md                 # Main documentation
├── CHANGELOG.md              # Version history
└── CLAUDE.md                 # This file

```

## Architecture Overview

### Immutable vs Mutable Design

SwiftGuion separates concerns between parsing and persistence:

```
┌─────────────────────────┐
│  Fountain/FDX/Highland  │  Source Files
│  (.fountain, .fdx,      │  (Never Modified)
│   .highland, .guion)    │
└───────────┬─────────────┘
            │ Parse
            ▼
┌─────────────────────────┐
│  GuionParsedScreenplay  │  Immutable, Sendable
│  + GuionElement[]       │  Thread-safe
└───────────┬─────────────┘
            │ Convert
            ▼
┌─────────────────────────┐
│  GuionDocumentModel     │  Mutable, SwiftData
│  + GuionElementModel[]  │  Reactive UI
└─────────────────────────┘
```

**Key Classes:**
- `GuionParsedScreenplay`: Immutable screenplay (thread-safe, Sendable)
- `GuionDocumentModel`: SwiftData model for persistence
- `GuionElement`: Lightweight element struct (immutable)
- `GuionElementModel`: SwiftData-backed element (mutable)
- `ElementType`: Strongly-typed enum (.sceneHeading, .action, .dialogue, etc.)

### Data Flow

```
Source File → Parser → GuionElement[] → GuionParsedScreenplay
                                             ↓
                                   GuionDocumentModel (SwiftData)
                                             ↓
                                        UI (GuionViewer)
```

## Key APIs to Know

### Parsing

```swift
// From file
let screenplay = try GuionParsedScreenplay(file: "/path/to/script.fountain")

// From string
let screenplay = try GuionParsedScreenplay(string: fountainText)

// From Highland archive
let screenplay = try GuionParsedScreenplay(highland: highlandURL)
```

### Analysis

```swift
// Extract characters with dialogue stats
let characters = screenplay.extractCharacters()

// Extract scene locations
let locations = screenplay.extractSceneLocations()

// Extract outline hierarchy
let outline = screenplay.extractOutline()
let tree = screenplay.extractOutlineTree()
```

### SwiftData Integration

```swift
// Convert to SwiftData
let document = await GuionDocumentModel.from(screenplay, in: modelContext)

// Convert back
let screenplay2 = document.toGuionParsedScreenplay()
```

### UI Components

```swift
// Complete viewer component
GuionViewer(document: document)

// From file URL (async loading)
GuionViewer(fileURL: fileURL)
```

## Testing Guidelines

### Running Specific Test Suites

```bash
# Parser tests
swift test --filter FountainParserTests
swift test --filter FDXParserTests

# Character analysis tests
swift test --filter CharacterInfoTests

# Location parsing tests
swift test --filter SceneLocationTests

# Outline tests
swift test --filter OutlineTests

# UI tests
swift test --filter GuionViewerTests
```

### Test Fixtures

Test fixtures are located in `Tests/SwiftGuionTests/Fixtures/` and include:
- Sample Fountain files
- FDX documents
- Highland archives
- Expected output JSON files

### Writing New Tests

```swift
import XCTest
@testable import SwiftGuion

final class MyNewTests: XCTestCase {
    func testSomething() throws {
        // Arrange
        let screenplay = try GuionParsedScreenplay(string: """
        INT. TEST SCENE - DAY

        This is action.
        """)

        // Act
        let elements = screenplay.elements

        // Assert
        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0].elementType, .sceneHeading)
        XCTAssertEqual(elements[1].elementType, .action)
    }
}
```

## CI/CD Integration

### GitHub Actions Workflow

The project uses GitHub Actions for CI (`.github/workflows/tests.yml`):

**Features:**
- Runs on macOS 26 with Xcode
- Parallel builds (80% of CPU cores)
- Code coverage reporting
- Coverage threshold checking (80%)
- Test summary generation
- Artifact uploads for test results

**Parallel Build Configuration:**
```yaml
- name: Calculate parallel jobs
  run: |
    CPUS=$(sysctl -n hw.ncpu)
    JOBS=$(echo "scale=0; $CPUS * 0.8 / 1" | bc)
    echo "jobs=$JOBS" >> $GITHUB_OUTPUT

- name: Build
  run: swift build -j ${{ steps.jobs.outputs.jobs }}
```

### Pull Request Workflow

1. **Create feature branch**: `git checkout -b my-feature`
2. **Make changes**: Code, test, commit
3. **Push**: `git push -u origin my-feature`
4. **Create PR**: `gh pr create --title "My Feature" --body "Description"`
5. **Wait for CI**: GitHub Actions runs tests automatically
6. **Address failures**: Fix any failing tests
7. **Merge**: Once tests pass, merge to main

Claude Code can handle this entire workflow when you ask it to "create a PR for this branch."

## Common Scenarios

### Adding a New Fountain Element Type

1. **Update ElementType enum** (`FileFormat/ElementType.swift`):
```swift
public enum ElementType: Equatable, Sendable {
    // ... existing cases
    case myNewType
}
```

2. **Update FountainParser** (`ImportExport/FountainParser.swift`):
   - Add regex pattern for recognition
   - Update state machine logic

3. **Update FountainWriter** (`ImportExport/FountainWriter.swift`):
   - Add export formatting for new type

4. **Add tests** (`Tests/SwiftGuionTests/FountainParserTests.swift`):
```swift
func testMyNewType() throws {
    let parser = FountainParser(string: "!NEW_TYPE content")
    XCTAssertEqual(parser.elements[0].elementType, .myNewType)
    XCTAssertEqual(parser.elements[0].elementText, "content")
}
```

### Adding New Analysis Features

1. **Create analysis file** in `Sources/SwiftGuion/Analysis/`
2. **Add extraction method** to `GuionParsedScreenplay`
3. **Write comprehensive tests**
4. **Update documentation** in README.md

### Adding UI Components

1. **Create widget** in `Sources/SwiftGuion/UI/`
2. **Follow existing pattern**: SceneWidget, ChapterWidget, etc.
3. **Use `@Query` for SwiftData integration** when needed
4. **Add accessibility support**: VoiceOver labels, keyboard navigation
5. **Test with GuionViewerTests**

## Debugging Tips

### Parser Issues

```swift
// Enable detailed parsing output
let parser = FountainParser(string: fountainText)
for (index, element) in parser.elements.enumerated() {
    print("\(index): \(element.elementType) - \(element.elementText)")
}
```

### SwiftData Issues

```swift
// Verify conversion
let screenplay = try GuionParsedScreenplay(file: "test.fountain")
let document = await GuionDocumentModel.from(screenplay, in: context)
let roundtrip = document.toGuionParsedScreenplay()

// Compare
print("Original elements: \(screenplay.elements.count)")
print("SwiftData elements: \(document.elements.count)")
print("Roundtrip elements: \(roundtrip.elements.count)")
```

### UI Rendering Issues

```swift
// Check scene browser data extraction
let browserData = screenplay.extractSceneBrowserData()
print("Chapters: \(browserData.chapters.count)")
for chapter in browserData.chapters {
    print("  \(chapter.title): \(chapter.sceneGroups.count) groups")
}
```

## Performance Considerations

### Parser Performance

- FountainParser is optimized for line-by-line state machine parsing
- Large screenplays (200+ pages) parse in <100ms
- Parsing is thread-safe and can be done in background

### SwiftData Performance

- Scene locations are cached after first parse
- Avoid unnecessary SwiftData conversions (stay immutable when possible)
- Use `@Query` efficiently in UI components

### UI Performance

- GuionViewer uses lazy loading for large scripts
- Scene browser collapses chapters by default
- Async loading for file-based initialization

## Resources

### Documentation

- [README.md](README.md): Main project documentation
- [CHANGELOG.md](CHANGELOG.md): Version history and migration guides
- [Docs/GUION_VIEWER_API.md](Docs/GUION_VIEWER_API.md): GuionViewer component API
- [Sources/SwiftGuion/UI/README.md](Sources/SwiftGuion/UI/README.md): UI components

### External Resources

- [Fountain Specification](https://fountain.io): Official Fountain format spec
- [Swift Package Manager](https://swift.org/package-manager/): SPM documentation
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata): Apple's SwiftData guide

## Tips for Working with Claude Code

### When to Ask for Help

- "Run the tests and fix any failures"
- "Create a PR for this branch"
- "Add a new feature to parse [element type]"
- "Refactor [component] to improve performance"
- "Write tests for [feature]"
- "Update documentation for [API]"
- "Debug why [test] is failing"

### What Claude Can Do

✅ Run builds and tests automatically
✅ Create and manage git commits
✅ Create pull requests
✅ Fix failing tests
✅ Refactor code
✅ Write new features
✅ Update documentation
✅ Analyze code coverage
✅ Debug issues

### Pre-approved Commands

Claude Code has pre-approval for:
- `swift build`
- `swift test`
- `git commit`
- `git push`
- `gh pr create`
- `gh pr view`
- `gh pr checks`

These commands run without asking for permission.

## Getting Help

- **Issues**: https://github.com/intrusive-memory/SwiftGuion/issues
- **Pull Requests**: https://github.com/intrusive-memory/SwiftGuion/pulls
- **Discussions**: Use GitHub Issues for questions and discussions

## Contributing

When contributing with Claude Code:

1. **Create a feature branch**: Let Claude handle git operations
2. **Write comprehensive tests**: Claude can generate test cases
3. **Update documentation**: Claude will update README and docs
4. **Run CI locally**: Use `swift test` before pushing
5. **Create descriptive PRs**: Claude generates good PR descriptions

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable names
- Add inline documentation for public APIs
- Write comprehensive tests for new features
- Keep functions focused and small
- Use `// MARK:` for organization

### Commit Message Format

```
<type>: <subject>

<body>

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types:** feat, fix, docs, refactor, test, chore

## License

MIT License - See [LICENSE](LICENSE) for details

---

**Last Updated**: 2025-01-21
**Project Version**: 2.2.0+
**Claude Code Version**: Compatible with Claude Code 4.5 Sonnet
