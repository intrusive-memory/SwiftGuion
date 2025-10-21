# Changelog

All notable changes to SwiftGuion will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- macCatalyst platform support (v26)
- Parallel builds using 80% of available CPUs for improved CI performance
- Comprehensive documentation for Claude Code integration

### Changed
- GitHub Actions workflows now use parallel builds and tests with `-j` flag
- CI performance improvements through CPU-optimized parallel execution

## [2.2.0] - 2025-01-XX

### Fixed
- FountainWriter character formatting and location persistence
- Scene content extraction for scenes without sceneId
- Section Heading double-space issue in Fountain export
- testWriteOutlineJSON to handle elements with empty range/type
- testMrMrCharlesDocument to use inline content instead of fixture file

### Changed
- Convert ElementType from String to strongly-typed enum with outline support
- Improved outline support with compile-time type safety

### Removed
- Speakable elements concept from SwiftGuion (no longer needed)

## [2.1.1] - 2025-01-XX

### Added
- App icon for example applications
- Xcode template implementation methodology documentation

## [2.1.0] - 2025-01-XX

### Added
- Scene content extraction improvements
- Xcode template requirements document

### Fixed
- Scene content extraction for scenes without sceneId
- Display tweaks for better UI rendering

## [2.0.0] - 2025-01-XX

### Added
- Complete SwiftData integration for screenplay persistence
- GuionViewer SwiftUI component for drop-in screenplay viewing
- Hierarchical scene browser with chapters and scene groups
- TextPack (.guion) bundle format with JSON resource exports
- Character analysis with dialogue statistics and scene appearances
- Location analysis with INT/EXT detection and time-of-day parsing
- Outline extraction with hierarchical parent-child relationships
- OutlineTree structure for tree-based navigation
- SceneLocation parsing for scene heading components
- FDX (Final Draft XML) import/export support
- Highland 2 (.highland) archive support
- TextBundle format support
- Immutable GuionParsedScreenplay for thread-safe parsing
- Mutable GuionDocumentModel for SwiftData persistence
- Bidirectional conversion between immutable and mutable models

### Changed
- Complete rewrite from Objective-C to Swift
- Modernized API with Swift 6.2 features
- Sendable conformance for thread safety
- SwiftUI-first architecture

### Removed
- Objective-C compatibility layers
- Legacy parsing implementations

## [1.0.3] - 2024-XX-XX

### Fixed
- Minor bug fixes and performance improvements

## [1.0.2] - 2024-XX-XX

### Fixed
- Parser edge cases
- Memory optimization improvements

## [1.0.1] - 2024-XX-XX

### Fixed
- Initial bug fixes after release

## [1.0.0] - 2024-XX-XX

### Added
- Initial Swift conversion from Objective-C Fountain parser
- Basic Fountain format parsing
- FountainParser implementation
- GuionElement structure
- Title page extraction
- Basic screenplay element types

### Notes
- Original Objective-C implementation by Nima Yousefi & John August
- Swift conversion using Claude Code 4.5 Sonnet

---

## Version History Summary

- **2.x**: SwiftData integration, comprehensive UI components, multi-format support
- **1.x**: Initial Swift conversion with basic Fountain parsing

## Migration Guides

### Migrating from 1.x to 2.x

Version 2.0 introduces significant architectural changes:

**Breaking Changes:**
- ElementType is now a strongly-typed enum instead of String
- GuionParsedScreenplay is now immutable and Sendable
- SwiftData models separated from parsing logic

**Migration Steps:**

1. **Update ElementType usage:**
```swift
// Old (1.x)
if element.elementType == "Scene Heading" { }

// New (2.x)
if element.elementType == .sceneHeading { }
```

2. **Use immutable parsing:**
```swift
// Old (1.x) - mutable parsing
let parser = FountainParser(file: "script.fountain")
parser.elements[0].elementText = "modified"  // Was possible

// New (2.x) - immutable parsing
let screenplay = try GuionParsedScreenplay(file: "script.fountain")
// screenplay.elements are immutable - cannot be modified
```

3. **SwiftData integration:**
```swift
// Convert to SwiftData for persistence
let document = await GuionDocumentModel.from(screenplay, in: modelContext)

// Convert back to immutable form
let screenplay2 = document.toGuionParsedScreenplay()
```

4. **Use GuionViewer for UI:**
```swift
// New SwiftUI component
GuionViewer(document: document)
    .frame(minWidth: 600, minHeight: 800)
```

## Links

- [Repository](https://github.com/intrusive-memory/SwiftGuion)
- [Issue Tracker](https://github.com/intrusive-memory/SwiftGuion/issues)
- [Fountain Specification](https://fountain.io)
