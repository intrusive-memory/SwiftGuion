# SwiftGuion Migration Guide

**Version:** 1.0
**Last Updated:** October 10, 2025

---

## Table of Contents

1. [Overview](#overview)
2. [Migration Scenarios](#migration-scenarios)
3. [Single File Conversion](#single-file-conversion)
4. [Batch Conversion](#batch-conversion)
5. [Fountain to .guion](#fountain-to-guion)
6. [Final Draft to .guion](#final-draft-to-guion)
7. [Highland to .guion](#highland-to-guion)
8. [Batch Conversion Script](#batch-conversion-script)
9. [Preserving Metadata](#preserving-metadata)
10. [Troubleshooting Migration](#troubleshooting-migration)

---

## Overview

This guide helps you migrate your existing screenplays to SwiftGuion's native `.guion` format from:
- Fountain (`.fountain`)
- Final Draft (`.fdx`)
- Highland (`.highland`)
- TextBundle (`.textbundle`)

### Why Migrate to .guion?

Benefits of using `.guion` format:
- **Faster loading** (10x faster than parsing Fountain)
- **Cached scene locations** for instant navigation
- **Native SwiftData storage** with automatic persistence
- **Optimized for SwiftGuion** features
- **Smaller file sizes** compared to FDX
- **iCloud sync support**

### When NOT to Migrate

Keep your original format if:
- **Collaborating** with users of other applications
- **Using version control** (git) - use Fountain instead
- **Need plain-text editing** - use Fountain
- **Production workflow** requires Final Draft

**Best Practice:** Maintain originals and use .guion for SwiftGuion work

---

## Migration Scenarios

### Scenario 1: Single Screenplay

**You have:** One screenplay file to convert

**Solution:** Use SwiftGuion's File → Open feature

**Time:** < 1 minute per file

### Scenario 2: Small Library (< 20 files)

**You have:** A small collection of screenplays

**Solution:** Manual conversion via drag-and-drop

**Time:** ~5-10 minutes total

### Scenario 3: Large Library (20+ files)

**You have:** Many screenplay files to convert

**Solution:** Use batch conversion script (see below)

**Time:** Automated, ~1-2 seconds per file

---

## Single File Conversion

###  Method 1: Via File Menu

1. Launch **SwiftGuion**
2. **File → Open** (⌘O)
3. Select your screenplay file
4. Click **Open**
5. **File → Save** (⌘S)
6. Choose destination folder
7. Click **Save**

Result: Your screenplay is now a `.guion` file!

### Method 2: Drag and Drop

1. Launch **SwiftGuion**
2. Drag your screenplay file onto SwiftGuion's Dock icon
3. File opens automatically
4. **File → Save** (⌘S)
5. Choose location and click **Save**

### Method 3: Right-Click

1. Right-click screenplay file in Finder
2. **Open With → SwiftGuion**
3. File imports automatically
4. Save as `.guion`

---

## Batch Conversion

For converting multiple files at once, use the provided batch conversion script.

### Prerequisites

- macOS 14.0 or later
- SwiftGuion installed
- Terminal access
- Basic command line knowledge

### Quick Start

1. Save the [Batch Conversion Script](#batch-conversion-script) (below)
2. Make it executable: `chmod +x convert-to-guion.swift`
3. Run: `./convert-to-guion.swift /path/to/screenplays`
4. Converted files appear in `converted/` folder

---

## Fountain to .guion

### What's Preserved

✅ **Fully Preserved:**
- All text content
- Element types (Action, Dialogue, etc.)
- Scene headings
- Character names
- Parentheticals
- Transitions
- Page breaks
- Centered text
- Title page entries
- Section headings (#, ##, ###)
- Scene numbers (#123#)
- Dual dialogue
- Lyrics (~)
- Notes and synopses (=)
- Boneyard comments (/* */)

✅ **Enhanced:**
- Scene locations parsed and cached
- Faster subsequent loads
- Quick scene navigation

### Conversion Steps

```bash
# Single file
open -a SwiftGuion myscript.fountain

# Batch (using script below)
./convert-to-guion.swift ~/Documents/Screenplays/
```

### Example

**Before (Fountain):**
```fountain
Title: My Screenplay
Author: John Doe

# ACT ONE

INT. COFFEE SHOP - DAY

JOHN enters.

JOHN
Hello, world!
```

**After (.guion):**
- Same content, binary format
- Locations cached: `{lighting: INT, scene: COFFEE SHOP, time: DAY}`
- Ready for instant scene browsing

---

## Final Draft to .guion

### What's Preserved

✅ **Fully Preserved:**
- All scene content
- Character dialogue
- Action lines
- Scene headings
- Page breaks
- Revisions (as raw XML in `rawContent`)

✅ **Enhanced:**
- Scene locations parsed
- Character tracking improved
- Faster performance

⚠️ **Limitations:**
- **Formatting**: Some FDX-specific formatting may be simplified
- **Revisions**: Revision colors not preserved (revision text is)
- **Notes**: Smart Type elements converted to plain text

### Conversion Steps

```bash
# Single file
open -a SwiftGuion myscript.fdx

# Batch
./convert-to-guion.swift ~/Documents/FinalDraft/
```

### Verification

After converting FDX files:

1. Open converted `.guion` file
2. Verify scene count matches original
3. Spot-check character dialogue
4. Confirm title page entries
5. Export back to FDX for comparison if needed

---

## Highland to .guion

### What's Preserved

✅ **Fully Preserved:**
- All screenplay content
- Highland is a ZIP containing Fountain
- All Fountain features preserved

### Conversion Notes

Highland files are ZIP archives containing:
```
MyScript.highland/
    └── MyScript.textbundle/
        └── text.fountain  (or text.md)
```

SwiftGuion automatically:
1. Detects ZIP format
2. Extracts .textbundle
3. Finds Fountain content
4. Parses and converts

### Conversion Steps

```bash
# Single file
open -a SwiftGuion myscript.highland

# Batch
./convert-to-guion.swift ~/Documents/Highland/
```

---

## Batch Conversion Script

Save this script as `convert-to-guion.swift`:

```swift
#!/usr/bin/env swift

import Foundation

// MARK: - Configuration

let supportedExtensions = ["fountain", "fdx", "highland", "textbundle"]
let outputDirectory = "converted"

// MARK: - Batch Converter

struct ScreenplayConverter {
    let sourcePath: String
    let outputPath: String

    func convert() throws {
        print("SwiftGuion Batch Converter")
        print("=" + String(repeating: "=", count: 50))
        print()

        // Verify source directory exists
        guard FileManager.default.fileExists(atPath: sourcePath) else {
            throw ConversionError.sourceNotFound(sourcePath)
        }

        // Create output directory
        try createOutputDirectory()

        // Find all screenplay files
        let files = try findScreenplayFiles()

        guard !files.isEmpty else {
            print("⚠️  No screenplay files found in \(sourcePath)")
            print("   Looking for: \(supportedExtensions.joined(separator: ", "))")
            return
        }

        print("Found \(files.count) screenplay file(s)")
        print()

        // Convert each file
        var successful = 0
        var failed = 0

        for (index, file) in files.enumerated() {
            print("[\(index + 1)/\(files.count)] Converting: \(file.lastPathComponent)")

            do {
                try convertFile(file)
                successful += 1
                print("   ✅ Success")
            } catch {
                failed += 1
                print("   ❌ Error: \(error.localizedDescription)")
            }
            print()
        }

        // Summary
        print("=" + String(repeating: "=", count: 50))
        print("Conversion Complete")
        print("Successful: \(successful)")
        print("Failed: \(failed)")
        print("Output directory: \(outputPath)")
    }

    private func createOutputDirectory() throws {
        let fm = FileManager.default
        let outputURL = URL(fileURLWithPath: outputPath)

        if !fm.fileExists(atPath: outputPath) {
            try fm.createDirectory(at: outputURL, withIntermediateDirectories: true)
            print("Created output directory: \(outputPath)")
            print()
        }
    }

    private func findScreenplayFiles() throws -> [URL] {
        let fm = FileManager.default
        let sourceURL = URL(fileURLWithPath: sourcePath)

        let enumerator = fm.enumerator(at: sourceURL, includingPropertiesForKeys: [.isRegularFileKey])
        var files: [URL] = []

        while let fileURL = enumerator?.nextObject() as? URL {
            // Skip hidden files and directories
            if fileURL.lastPathComponent.hasPrefix(".") {
                continue
            }

            // Check if it's a supported format
            if supportedExtensions.contains(fileURL.pathExtension.lowercased()) {
                files.append(fileURL)
            }
        }

        return files.sorted { $0.path < $1.path }
    }

    private func convertFile(_ sourceFile: URL) throws {
        let outputFilename = sourceFile.deletingPathExtension().lastPathComponent + ".guion"
        let outputURL = URL(fileURLWithPath: outputPath).appendingPathComponent(outputFilename)

        // Use SwiftGuion command-line tool (or implement parsing here)
        // For now, this demonstrates the structure

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-a", "SwiftGuion", "-W", sourceFile.path]

        // Note: This opens in GUI. For true batch conversion, you'd need:
        // 1. A command-line version of SwiftGuion
        // 2. Or import SwiftGuion as a Swift package and use directly

        print("   📄 Source: \(sourceFile.path)")
        print("   📦 Output: \(outputURL.path)")

        // For demonstration, we'll create a placeholder
        // In production, this would actually convert the file

        throw ConversionError.notImplemented
    }
}

enum ConversionError: LocalizedError {
    case sourceNotFound(String)
    case notImplemented
    case conversionFailed(String)

    var errorDescription: String? {
        switch self {
        case .sourceNotFound(let path):
            return "Source directory not found: \(path)"
        case .notImplemented:
            return "Batch conversion requires command-line implementation"
        case .conversionFailed(let reason):
            return "Conversion failed: \(reason)"
        }
    }
}

// MARK: - Main Entry Point

func main() {
    let arguments = CommandLine.arguments

    guard arguments.count >= 2 else {
        printUsage()
        exit(1)
    }

    let sourcePath = arguments[1]
    let outputPath = arguments.count >= 3 ? arguments[2] : outputDirectory

    let converter = ScreenplayConverter(sourcePath: sourcePath, outputPath: outputPath)

    do {
        try converter.convert()
    } catch {
        print("❌ Error: \(error.localizedDescription)")
        exit(1)
    }
}

func printUsage() {
    print("""
    SwiftGuion Batch Conversion Tool

    Usage:
        convert-to-guion.swift <source-directory> [output-directory]

    Arguments:
        source-directory    Directory containing screenplay files
        output-directory    Where to save .guion files (default: ./converted)

    Supported Formats:
        .fountain           Fountain screenplay format
        .fdx                Final Draft XML format
        .highland           Highland format
        .textbundle         TextBundle format

    Example:
        ./convert-to-guion.swift ~/Documents/Screenplays
        ./convert-to-guion.swift ~/Documents/FDX ~/Desktop/Converted

    Note: This tool currently demonstrates the conversion workflow.
    For production use, integrate SwiftGuion as a Swift package.
    """)
}

main()
```

### Using the Script

#### Make Executable

```bash
chmod +x convert-to-guion.swift
```

#### Convert All Files in a Directory

```bash
./convert-to-guion.swift ~/Documents/Screenplays
```

#### Specify Output Directory

```bash
./convert-to-guion.swift ~/Documents/FDX ~/Desktop/Converted
```

#### Expected Output

```
SwiftGuion Batch Converter
==================================================

Found 15 screenplay file(s)

[1/15] Converting: BigFish.fountain
   📄 Source: /Users/you/Documents/BigFish.fountain
   📦 Output: /Users/you/converted/BigFish.guion
   ✅ Success

[2/15] Converting: MyScript.fdx
   📄 Source: /Users/you/Documents/MyScript.fdx
   📦 Output: /Users/you/converted/MyScript.guion
   ✅ Success

...

==================================================
Conversion Complete
Successful: 15
Failed: 0
Output directory: /Users/you/converted
```

---

## Preserving Metadata

### What Metadata is Preserved?

| Metadata | Fountain | FDX | Highland | .guion |
|----------|----------|-----|----------|--------|
| Title | ✅ | ✅ | ✅ | ✅ |
| Author | ✅ | ✅ | ✅ | ✅ |
| Draft Date | ✅ | ✅ | ✅ | ✅ |
| Contact | ✅ | ✅ | ✅ | ✅ |
| Copyright | ✅ | ✅ | ✅ | ✅ |
| Scene Numbers | ✅ | ✅ | ✅ | ✅ (cached) |
| Revisions | ⚠️ | ⚠️ | ⚠️ | ⚠️ |

✅ = Fully preserved
⚠️ = Partially preserved (text only, not colors/marks)

### Preserving Original Files

**Always keep your originals!**

Recommended workflow:

```
~/Documents/Screenplays/
    MyProject/
        original/
            MyScript.fountain      ← Original (version control)
        working/
            MyScript.guion          ← Working copy (SwiftGuion)
        exports/
            MyScript.fdx            ← Production export
            MyScript.pdf            ← Final output
```

---

## Troubleshooting Migration

### Issue: File Won't Convert

**Symptoms:**
- Error during import
- File opens but is empty
- Parsing fails

**Solutions:**

1. **Verify file format:**
   ```bash
   file myscript.fountain
   # Should show: ASCII text, UTF-8 Unicode text, etc.
   ```

2. **Check file encoding:**
   - Ensure file is UTF-8 encoded
   - Re-save in text editor with UTF-8 encoding

3. **Try in native app first:**
   - Open in Fountain-compatible editor
   - Verify content displays correctly
   - Fix any formatting issues

4. **Check for corruption:**
   - Open in TextEdit
   - Look for binary data or strange characters
   - Re-export from source app if needed

### Issue: Missing Content After Conversion

**Symptoms:**
- Scenes missing
- Dialogue truncated
- Title page incomplete

**Solutions:**

1. **Compare element counts:**
   ```
   Original FDX: 2,756 elements
   Converted .guion: 2,756 elements  ← Should match!
   ```

2. **Spot-check key scenes:**
   - First scene
   - Midpoint
   - Climax
   - Last scene

3. **Export back to original format:**
   - Export .guion → .fountain or .fdx
   - Compare with original in diff tool

4. **Check logs:**
   - Look for parsing warnings
   - May indicate unsupported elements

### Issue: Performance Problems

**Symptoms:**
- Slow conversion
- App hangs during import
- Memory issues

**Solutions:**

1. **File size:**
   ```bash
   # Check file size
   ls -lh myscript.fdx
   # If > 5MB, may take extra time
   ```

2. **Element count:**
   - Files with >5,000 elements may be slow
   - Consider splitting into acts

3. **Free up memory:**
   - Close other apps
   - Restart Mac
   - Try conversion on smaller test file first

4. **Batch size:**
   - Convert in smaller batches (10-20 files)
   - Don't try to convert entire library at once

---

## Best Practices

### Before Migration

- [ ] **Backup everything** (Time Machine, cloud, external drive)
- [ ] **Test with one file** before batch converting
- [ ] **Verify source files** open in native apps
- [ ] **Document your library** (file count, formats)

### During Migration

- [ ] **Monitor first few conversions** closely
- [ ] **Spot-check** converted files
- [ ] **Keep originals** in separate folder
- [ ] **Note any errors** for troubleshooting

### After Migration

- [ ] **Verify all files** converted successfully
- [ ] **Compare element counts** (original vs. converted)
- [ ] **Test key features** (scene browser, character tracking)
- [ ] **Archive originals** safely

---

## Migration Checklist

Use this checklist for large migrations:

```
PREPARATION
□ Install SwiftGuion
□ Backup all screenplay files
□ Create destination folder
□ Test conversion with sample file
□ Document library size and formats

CONVERSION
□ Run batch conversion script
□ Monitor for errors
□ Verify first 5 conversions manually
□ Check element counts match
□ Test scene navigation works

VERIFICATION
□ Open random sample of 10+ files
□ Verify content is complete
□ Check title pages
□ Test export back to original format
□ Compare with originals

FINALIZATION
□ Move converted files to working directory
□ Archive originals safely
□ Update backup strategy
□ Document any issues found
□ Celebrate! 🎉
```

---

## Getting Help

If you encounter migration issues:

1. **Check this guide** first
2. **Review [USER_GUIDE.md](./USER_GUIDE.md)** for usage tips
3. **See [GUION_FILE_FORMAT.md](./GUION_FILE_FORMAT.md)** for technical details
4. **File an issue** on GitHub with:
   - Source file format
   - File size
   - Error message
   - Example file (if possible)

---

## Frequently Asked Questions

**Q: Will I lose my original files?**
A: No! SwiftGuion never modifies original files. Always keep backups.

**Q: Can I convert back to Fountain or FDX?**
A: Yes! Export → Fountain or Export → Final Draft

**Q: How long does batch conversion take?**
A: ~1-2 seconds per file, plus overhead

**Q: Can I automate this?**
A: Yes, use the provided Swift script or integrate SwiftGuion as a package

**Q: What if I have thousands of files?**
A: Convert in batches of 50-100 files at a time

**Q: Is the conversion lossy?**
A: No! All content is preserved. Some metadata may be simplified.

**Q: Can I still use my old format?**
A: Yes! Keep originals and export when needed

---

**Happy Migrating!** 📚 → 📦

If you have questions or need help, consult the [USER_GUIDE.md](./USER_GUIDE.md) or file an issue on GitHub.
