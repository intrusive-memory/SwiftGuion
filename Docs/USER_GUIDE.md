# SwiftGuion User Guide

**Version:** 1.0
**Last Updated:** October 10, 2025

---

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Importing Screenplays](#importing-screenplays)
4. [Working with .guion Files](#working-with-guion-files)
5. [Exporting to Other Formats](#exporting-to-other-formats)
6. [User Interface Overview](#user-interface-overview)
7. [Advanced Features](#advanced-features)
8. [Troubleshooting](#troubleshooting)
9. [Keyboard Shortcuts](#keyboard-shortcuts)

---

## Introduction

Welcome to SwiftGuion, a powerful screenplay management application for macOS. SwiftGuion lets you import, edit, and export screenplays in multiple formats while providing advanced features like scene browser, character tracking, and location analysis.

### What is SwiftGuion?

SwiftGuion is built on top of the Fountain screenplay format, adding powerful organization and analysis tools. It uses a native `.guion` file format for optimal performance and features like:

- **Fast scene browsing** with cached locations
- **Character tracking** across your screenplay
- **Location analysis** and grouping
- **Import/Export** support for Fountain, Final Draft (FDX), and Highland formats

---

## Getting Started

### System Requirements

- **macOS:** 14.0 (Sonoma) or later
- **Disk Space:** 50 MB
- **Memory:** 4 GB RAM recommended

### First Launch

1. Launch **SwiftGuion** from your Applications folder
2. You'll see the document browser
3. Choose to create a new document or open an existing screenplay

---

## Importing Screenplays

SwiftGuion supports importing from multiple screenplay formats.

### Supported Import Formats

| Format | Extension | Description |
|--------|-----------|-------------|
| **Fountain** | `.fountain` | Plain-text screenplay format |
| **Highland** | `.highland` | Highland app format (ZIP archive) |
| **Final Draft** | `.fdx` | Final Draft XML format |
| **TextBundle** | `.textbundle` | Text bundle format |

### How to Import

#### Method 1: File > Open

1. Go to **File → Open** (⌘O)
2. Select your screenplay file
3. Click **Open**
4. SwiftGuion will parse the file and convert it to `.guion` format

#### Method 2: Drag and Drop

1. Drag a `.fountain`, `.fdx`, or `.highland` file onto the SwiftGuion icon
2. The file will open and be ready to save as `.guion`

#### Method 3: Right-Click (Finder)

1. Right-click a screenplay file in Finder
2. Select **Open With → SwiftGuion**
3. File imports automatically

### What Happens During Import?

When you import a screenplay:

1. **Parsing**: The source file is parsed into screenplay elements
2. **Conversion**: Elements are converted to SwiftGuion's internal format
3. **Analysis**: Scene locations are parsed and cached
4. **Naming**: The document is named based on the original filename (e.g., `BigFish.fountain` → `BigFish.guion`)
5. **Ready to Save**: The document is marked as modified and ready to save

### Import Examples

#### Importing a Fountain File

```
Original: MyScript.fountain
After Import: MyScript.guion (unsaved)
```

When you save, it will be stored as `MyScript.guion`.

#### Importing a Final Draft File

```
Original: MyAwesomeScript.fdx
After Import: MyAwesomeScript.guion (unsaved)
```

All Final Draft formatting is preserved and converted.

---

## Working with .guion Files

The `.guion` format is SwiftGuion's native file format, optimized for performance and feature-richness.

### Creating a New Document

1. **File → New** (⌘N)
2. A new empty screenplay opens
3. Start writing using Fountain syntax
4. Save when ready (**File → Save**, ⌘S)

### Opening Existing .guion Files

1. **File → Open** (⌘O)
2. Select a `.guion` file
3. Click **Open**

The document loads instantly with all cached data intact.

### Saving Documents

#### First Save (New or Imported)

1. **File → Save** (⌘S)
2. Choose a location
3. Enter a filename (`.guion` extension is added automatically)
4. Click **Save**

#### Subsequent Saves

Press **⌘S** to save silently to the existing location.

#### Save As

1. **File → Duplicate** (⌘⇧S)
2. Choose a new name/location
3. Click **Save**

### Auto-Save and Versions

SwiftGuion uses macOS Auto-Save:
- Changes are automatically saved while you work
- Browse previous versions via **File → Revert To → Browse All Versions**

### iCloud Support

.guion files support iCloud Drive:
1. Save your file to **iCloud Drive → SwiftGuion**
2. Access from any Mac signed in to your Apple ID
3. Automatic sync across devices

---

## Exporting to Other Formats

SwiftGuion can export your screenplay to industry-standard formats.

### Supported Export Formats

| Format | Extension | Use Case |
|--------|-----------|----------|
| **Fountain** | `.fountain` | Plain-text editing, version control |
| **Final Draft** | `.fdx` | Production, collaboration with FD users |

### How to Export

#### Export to Fountain

1. Open your `.guion` document
2. **File → Export → Fountain** (⌘⇧E)
3. Choose a location
4. Click **Export**

Your screenplay is exported as a `.fountain` file, readable in any text editor.

#### Export to Final Draft (FDX)

1. Open your `.guion` document
2. **File → Export → Final Draft**
3. Choose a location
4. Click **Export**

Your screenplay is exported as an `.fdx` file, compatible with Final Draft.

### Export Filename Conventions

When exporting, SwiftGuion suggests filenames based on your document:

```
MyScript.guion → MyScript.fountain
MyScript.guion → MyScript.fdx
```

### Round-Trip Fidelity

SwiftGuion maintains 100% fidelity during export/import:

1. Export `.guion` → `.fountain`
2. Modify in external editor
3. Re-import `.fountain` → `.guion`
4. All elements preserved

---

## User Interface Overview

### Main Window

The SwiftGuion main window consists of:

```
┌──────────────────────────────────────────────────┐
│ Title Bar (Document Name)                        │
├──────────┬───────────────────────────────────────┤
│          │                                       │
│  Scene   │                                       │
│  Browser │         Screenplay View               │
│          │                                       │
│          │                                       │
├──────────┴───────────────────────────────────────┤
│ Status Bar                                       │
└──────────────────────────────────────────────────┘
```

### Scene Browser (Left Sidebar)

The Scene Browser shows:
- **Chapter headings** (from section markers)
- **Scene headings** organized hierarchically
- **Scene numbers** (if enabled)
- **Location information**

#### Using the Scene Browser

- **Click a scene** to jump to it in the screenplay
- **Expand/collapse chapters** to organize your view
- **Right-click** for scene-specific actions

### Screenplay View (Main Area)

The main editing area displays your screenplay with:
- **Syntax highlighting** for different element types
- **Real-time formatting** following screenplay conventions
- **Scene numbers** (when enabled)

### Toolbar

The toolbar provides quick access to:
- **Character Inspector**: View all characters
- **Locations Window**: See all locations used
- **Export Options**: Quick export buttons

---

## Advanced Features

### Scene Browser

#### Navigating Scenes

The Scene Browser provides powerful navigation:

**Hierarchical Organization:**
```
# Act One
    # Chapter 1
        Scene 1: INT. HOUSE - DAY
        Scene 2: EXT. STREET - DAY
    # Chapter 2
        Scene 3: INT. OFFICE - NIGHT
# Act Two
    ...
```

**Quick Jump:**
- Click any scene to jump directly to it
- See scene count in each section

#### Scene Grouping

Scenes are automatically grouped by:
1. **Section Headings**: `# Act`, `## Chapter`
2. **Location**: Scenes at the same location
3. **Time**: Day vs. Night scenes

### Character Inspector

View all characters in your screenplay:

**Access:** Menu Bar → **View → Characters** (⌘⇧C)

The Character Inspector shows:
- **Character names**: Alphabetically sorted
- **Appearance count**: How many times each character speaks
- **First appearance**: Where they're introduced

### Locations Window

Analyze locations in your screenplay:

**Access:** Menu Bar → **View → Locations** (⌘⇧L)

The Locations Window displays:
- **All locations**: Extracted from scene headings
- **Scene count**: Scenes at each location
- **INT/EXT breakdown**: Interior vs. exterior
- **Time distribution**: Day, night, etc.

### Search and Filter

#### Find in Screenplay

1. **Edit → Find** (⌘F)
2. Enter search term
3. Use **Next** (⌘G) and **Previous** (⌘⇧G)

#### Filter by Location

1. Open Locations Window
2. Click a location
3. See all scenes at that location

#### Filter by Character

1. Open Character Inspector
2. Click a character
3. See all their dialogue scenes

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: File Won't Open

**Symptom:** "The document is corrupted and cannot be opened"

**Solutions:**
1. Check file isn't corrupted: Open in TextEdit (if Fountain)
2. Try re-importing from original source
3. Restore from Time Machine backup

#### Issue: Import Fails

**Symptom:** Error when importing `.fdx` or `.fountain` file

**Solutions:**
1. **Verify file format**: Ensure file is actually the claimed format
2. **Check file size**: Very large files (>10MB) may need extra time
3. **Try in external editor**: Open in text editor to verify contents
4. **Report issue**: File may have unusual formatting

#### Issue: Slow Performance

**Symptom:** App is sluggish with large screenplay

**Solutions:**
1. **Check screenplay size**: Files >5000 elements may be slow
2. **Disable auto-save temporarily**: System Preferences → General
3. **Close other windows**: Keep only main screenplay open
4. **Restart app**: Fresh start can help

#### Issue: Export Problems

**Symptom:** Exported file doesn't look right

**Solutions:**
1. **Re-export**: Try exporting again
2. **Check destination app**: Open in target application (Final Draft, etc.)
3. **Verify source**: Ensure `.guion` file displays correctly
4. **Use alternate format**: Try Fountain if FDX fails

#### Issue: Syncing Problems (iCloud)

**Symptom:** Changes not appearing on other devices

**Solutions:**
1. **Check iCloud status**: System Preferences → Apple ID → iCloud
2. **Wait for sync**: Can take several minutes
3. **Force upload**: Close file, wait 1 minute, re-open
4. **Check storage**: Ensure iCloud has free space

### Getting Help

If you encounter issues not covered here:

1. **Check Documentation**: See [IMPLEMENTATION_ROADMAP.md](./IMPLEMENTATION_ROADMAP.md) for technical details
2. **File Format Spec**: See [GUION_FILE_FORMAT.md](./GUION_FILE_FORMAT.md) for format details
3. **Report Issues**: File bug reports at [GitHub Issues](https://github.com/your-repo/issues)

---

## Keyboard Shortcuts

### File Operations

| Shortcut | Action |
|----------|--------|
| ⌘N | New Document |
| ⌘O | Open Document |
| ⌘S | Save |
| ⌘⇧S | Duplicate (Save As) |
| ⌘W | Close Window |
| ⌘Q | Quit SwiftGuion |

### Export

| Shortcut | Action |
|----------|--------|
| ⌘⇧E | Export as Fountain |
| ⌘⇧F | Export as Final Draft |

### View

| Shortcut | Action |
|----------|--------|
| ⌘⇧C | Show Characters |
| ⌘⇧L | Show Locations |
| ⌘⇧B | Show Scene Browser |

### Editing

| Shortcut | Action |
|----------|--------|
| ⌘Z | Undo |
| ⌘⇧Z | Redo |
| ⌘X | Cut |
| ⌘C | Copy |
| ⌘V | Paste |
| ⌘A | Select All |
| ⌘F | Find |
| ⌘G | Find Next |
| ⌘⇧G | Find Previous |

---

## Best Practices

### File Organization

**Recommended Structure:**
```
~/Documents/Screenplays/
    MyProject/
        MyScript.guion          (working copy)
        Backups/
            MyScript-v1.fountain
            MyScript-v2.fountain
        Exports/
            MyScript.fountain
            MyScript.fdx
```

### Backup Strategy

1. **Use Time Machine**: Automatic macOS backups
2. **Export to Fountain**: Plain-text backup monthly
3. **Version Control**: Use git for text-based history
4. **iCloud Sync**: Enable for automatic cloud backup

### Performance Tips

1. **Keep screenplays under 5000 elements** for optimal performance
2. **Close unused windows** (Characters, Locations) when editing
3. **Save regularly** even with auto-save enabled
4. **Export to Fountain** for large-scale editing in text editors

### Writing Tips

#### Use Fountain Syntax

SwiftGuion understands Fountain:

```fountain
# Act One

## Chapter 1 - The Beginning

INT. COFFEE SHOP - DAY

JOHN enters, looking nervous.

JOHN
(whispering)
I think we're being followed.

JANE looks up from her laptop.

JANE
Not again.
```

#### Section Your Screenplay

Use section headings for structure:

```fountain
# ACT ONE

## Sequence 1 - Setup

### Establishing Scenes

INT. LOCATION - DAY
```

#### Scene Numbers

- **Auto-numbering**: Enabled by default
- **Custom numbers**: Use `#123#` syntax
- **Suppress numbering**: Check "Suppress Scene Numbers" in settings

---

## Additional Resources

- **Fountain Specification**: [fountain.io](https://fountain.io)
- **SwiftGuion GitHub**: [github.com/your-repo](https://github.com/your-repo)
- **Migration Guide**: See [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md)
- **Format Specification**: See [GUION_FILE_FORMAT.md](./GUION_FILE_FORMAT.md)

---

## About SwiftGuion

SwiftGuion is an open-source screenplay management tool built with Swift and SwiftUI, designed to provide professional screenwriters with powerful organization and analysis tools while maintaining compatibility with industry-standard formats.

**Version:** 1.0
**License:** MIT
**Copyright:** © 2025 SwiftGuion Project

---

## Feedback and Support

We'd love to hear from you!

- **Bug Reports**: File issues on GitHub
- **Feature Requests**: Submit via GitHub Discussions
- **Questions**: Check documentation first, then ask on GitHub

**Happy Writing!** 🎬
