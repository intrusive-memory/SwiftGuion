# Screenplay SwiftData Skill - File Index

Quick navigation guide for the screenplay-swiftdata skill files.

## Files in This Skill

### 📘 `screenplay-swiftdata.md` (Main AI Prompt)
**Size**: ~15KB | **Type**: AI Prompt | **Audience**: AI Assistants

Complete AI assistant prompt with:
- Architecture overview
- Complete workflows (import/export/analysis)
- Element type reference
- Scene location parsing
- Error handling patterns
- Performance optimization
- Common pitfalls
- Code generation guidelines

**Read this when**: You need comprehensive understanding of SwiftGuion integration patterns.

**Key sections**:
- Line 1-50: Overview and capabilities
- Line 51-150: Import workflow
- Line 151-250: Export workflow
- Line 251-350: Analysis workflow
- Line 351-450: Element types and APIs
- Line 451-550: UI integration
- Line 551-650: Common pitfalls

---

### 📋 `examples.md` (Code Examples)
**Size**: ~25KB | **Type**: Code Examples | **Audience**: Developers & AI

Ready-to-use code examples:
1. Basic Import
2. Import with Progress
3. Export to Fountain
4. Export to Final Draft
5. Character Analysis
6. Location Extraction
7. Outline Generation
8. SwiftUI Document List
9. File Drag & Drop
10. Batch Import

**Read this when**: You need working code to adapt for your use case.

**Key sections**:
- Line 1-100: Basic import examples
- Line 101-200: Export examples
- Line 201-350: Character/location analysis
- Line 351-450: Outline generation
- Line 451-650: SwiftUI integration
- Line 651-750: Drag & drop
- Line 751-850: Batch operations
- Line 851-950: Testing examples

---

### 📖 `README.md` (Skill Overview)
**Size**: ~12KB | **Type**: Documentation | **Audience**: Developers

Human-readable guide covering:
- Skill overview and purpose
- Quick start instructions
- Key concepts (immutable/mutable design, chapter indexing)
- Common use cases
- Integration points (SwiftUI, UIKit, CLI)
- Performance tips
- Troubleshooting guide

**Read this when**: You're starting a new project or planning integration.

**Key sections**:
- Line 1-50: Overview and quick start
- Line 51-150: Key concepts
- Line 151-250: Use cases
- Line 251-350: Integration patterns
- Line 351-450: Performance and troubleshooting

---

### ⚡ `QUICKREF.md` (Quick Reference)
**Size**: ~3KB | **Type**: Cheat Sheet | **Audience**: Everyone

One-page reference with:
- Setup snippets
- Import/export one-liners
- Common operations
- Element types list
- Frequent mistakes
- File type reference

**Read this when**: You need a quick reminder or syntax lookup.

**Structure**: All content fits on one screen for quick scanning.

---

### 📑 `INDEX.md` (This File)
**Size**: ~2KB | **Type**: Navigation | **Audience**: Everyone

Navigation guide to all skill files.

---

## Quick Navigation by Task

### "I want to import a screenplay file"
→ Start with: `QUICKREF.md` (line 15-45)
→ Detailed: `examples.md` → "Basic Import"
→ With progress: `examples.md` → "Import with Progress"
→ Full workflow: `screenplay-swiftdata.md` → "Workflow 1"

### "I want to export to Fountain/FDX"
→ Start with: `QUICKREF.md` (line 46-60)
→ Fountain: `examples.md` → "Export to Fountain"
→ FDX: `examples.md` → "Export to Final Draft"
→ Full workflow: `screenplay-swiftdata.md` → "Workflow 2"

### "I want to analyze characters/locations"
→ Start with: `QUICKREF.md` (line 61-95)
→ Characters: `examples.md` → "Character Analysis"
→ Locations: `examples.md` → "Location Extraction"
→ Outline: `examples.md` → "Outline Generation"

### "I want to build a SwiftUI app"
→ Start with: `README.md` → "Integration Points"
→ Full example: `examples.md` → "SwiftUI Document List"
→ Drag & drop: `examples.md` → "File Drag & Drop"

### "I'm getting errors/bugs"
→ Common mistakes: `QUICKREF.md` (line 96-140)
→ Troubleshooting: `README.md` → "Troubleshooting"
→ Pitfalls: `screenplay-swiftdata.md` → "Common Pitfalls"

### "I need to understand the architecture"
→ Quick concepts: `README.md` → "Key Concepts"
→ Full architecture: `screenplay-swiftdata.md` → "SwiftGuion Architecture"

### "I want code examples"
→ Quick snippets: `QUICKREF.md`
→ Full examples: `examples.md`
→ Tests: `examples.md` → "Testing Examples"

## File Relationships

```
┌─────────────────────────────────────────┐
│  README.md (START HERE)                 │
│  - Overview                             │
│  - Quick start                          │
│  - Key concepts                         │
└────────────┬────────────────────────────┘
             │
             ├──────────────┬──────────────┬──────────────┐
             │              │              │              │
    ┌────────▼─────┐  ┌────▼──────┐  ┌───▼──────┐  ┌───▼──────┐
    │ QUICKREF.md  │  │screenplay-│  │examples. │  │ INDEX.md │
    │              │  │swiftdata. │  │md        │  │(this)    │
    │ Quick lookup │  │md         │  │          │  │          │
    │ Common tasks │  │           │  │ Working  │  │ Navigate │
    │ Cheat sheet  │  │ AI prompt │  │ code     │  │ files    │
    └──────────────┘  │ Complete  │  │ Examples │  └──────────┘
                      │ reference │  │ Tests    │
                      └───────────┘  └──────────┘
```

## Recommended Reading Order

### For First-Time Users
1. `README.md` - Understand what the skill does
2. `QUICKREF.md` - See basic patterns
3. `examples.md` - Find relevant example
4. `screenplay-swiftdata.md` - Deep dive if needed

### For AI Assistants
1. `screenplay-swiftdata.md` - Full context and patterns
2. `examples.md` - Code templates to adapt
3. `QUICKREF.md` - Quick syntax reference

### For Quick Tasks
1. `QUICKREF.md` - Find the operation
2. `examples.md` - Get full example
3. Done!

### For Complex Projects
1. `README.md` - Plan integration
2. `screenplay-swiftdata.md` - Understand workflows
3. `examples.md` - Implement with examples
4. `QUICKREF.md` - Reference during coding

## File Sizes and Load Times

| File | Size | Lines | Load Time* |
|------|------|-------|------------|
| `INDEX.md` | ~2KB | ~200 | <1s |
| `QUICKREF.md` | ~3KB | ~175 | <1s |
| `README.md` | ~12KB | ~450 | 1-2s |
| `examples.md` | ~25KB | ~900 | 2-3s |
| `screenplay-swiftdata.md` | ~15KB | ~650 | 2-3s |

*Approximate load times for AI context window

## Search Shortcuts

### By Keyword

**Import**: `examples.md` line 1-200, `QUICKREF.md` line 15-45
**Export**: `examples.md` line 201-300, `QUICKREF.md` line 46-60
**Character**: `examples.md` line 301-450, `QUICKREF.md` line 61-75
**Location**: `examples.md` line 451-600, `QUICKREF.md` line 76-90
**Outline**: `examples.md` line 601-750, `QUICKREF.md` line 91-110
**SwiftUI**: `examples.md` line 751-900, `README.md` line 200-300
**Progress**: `examples.md` line 100-200, `QUICKREF.md` line 111-125
**Error**: `README.md` line 400-450, `QUICKREF.md` line 96-140

### By Element Type

**GuionDocumentModel**: All files, primary focus in workflows
**GuionElementModel**: All files, focus on chapter indexing sections
**TitlePageEntryModel**: Import workflow sections
**GuionParsedScreenplay**: Import and parsing sections
**ElementType**: `screenplay-swiftdata.md` line 351-400, `QUICKREF.md` line 126-135
**SceneLocation**: Location extraction sections

### By Concept

**Chapter Indexing**: `README.md` line 50-100, `QUICKREF.md` line 96-110
**Element Sorting**: `QUICKREF.md` line 111-120, `screenplay-swiftdata.md` line 500-550
**Progress Reporting**: All files, search "OperationProgress"
**SwiftData Schema**: Setup sections in all files
**Immutable/Mutable**: `README.md` line 30-50, `screenplay-swiftdata.md` line 20-50

## Updates and Maintenance

**Last Updated**: 2025-01-21
**Skill Version**: 1.0.0
**SwiftGuion Version**: 2.2.0+

**When to update this index**:
- New files added to skill
- Major reorganization of content
- New sections added to existing files
- Line numbers change significantly

## Questions About This Skill?

- **What does it do?** → `README.md`
- **How do I use it?** → `QUICKREF.md`
- **Show me code** → `examples.md`
- **Full reference** → `screenplay-swiftdata.md`
- **Where's X?** → This file (INDEX.md)

---

**Navigation tip**: Use Cmd+F (Mac) or Ctrl+F (Windows) to search within files for specific keywords or concepts.
