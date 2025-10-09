# BOT GUIDE

A condensed orientation for automated agents interacting with SwiftGuion.

## Project Snapshot

- **Purpose:** Parse Fountain screenplays into SwiftData-ready models without touching the source files. 【F:README.md†L5-L39】
- **Language/Platform:** Swift package targeting macOS 15+, distributed as the `SwiftGuion` library. 【F:Package.swift†L7-L29】
- **Key Entry Point:** `FountainScript` – handles loading, parsing, content access, and export utilities. Start here for most automation tasks. 【F:Sources/SwiftGuion/FountainScript.swift†L30-L195】

## Repository Layout

- `Sources/SwiftGuion/` – library sources (parsers, models, exporters). 【F:Package.swift†L23-L29】
- `Tests/SwiftGuionTests/` – unit tests plus fixture bundles (`test.fountain`, `.textbundle`, `.highland`). 【F:Package.swift†L30-L37】
- `Examples/` – reference macOS document-based app showing full integration. 【F:README.md†L51-L69】

## Common Workflows

1. **Parse content:** instantiate `FountainScript` from a file, string, Highland archive, or TextBundle. 【F:Sources/SwiftGuion/FountainScript.swift†L44-L195】【F:Sources/SwiftGuion/FountainScript+Highland.swift†L31-L123】【F:Sources/SwiftGuion/FountainScript+TextBundle.swift†L32-L179】
2. **Inspect results:** iterate `script.elements`/`script.titlePage`, or derive character/outline data via the extension helpers. 【F:Sources/SwiftGuion/FountainScript.swift†L35-L140】【F:Sources/SwiftGuion/FountainScript+Characters.swift†L30-L154】【F:Sources/SwiftGuion/FountainScript+Outline.swift†L30-L273】
3. **Export:** use `write(...)`, `writeToTextBundle`, or `writeToHighland` to regenerate assets. 【F:Sources/SwiftGuion/FountainScript.swift†L88-L108】【F:Sources/SwiftGuion/FountainScript+TextBundle.swift†L84-L179】【F:Sources/SwiftGuion/FountainScript+Highland.swift†L81-L123】

## Testing Checklist

Run SwiftPM tests after modifications:

```bash
swift test
```

The suite exercises Fountain, TextBundle, and Highland workflows using the bundled fixtures. 【F:Package.swift†L30-L37】

## Additional Notes

- All parsers are non-mutating; cached content is available for re-parsing without touching the source document. 【F:Sources/SwiftGuion/FountainScript.swift†L35-L143】
- When packaging TextBundles/Highland archives, character and outline JSON resources can be generated automatically from the parsed guión data. 【F:Sources/SwiftGuion/FountainScript+TextBundle.swift†L120-L179】【F:Sources/SwiftGuion/FountainScript+Highland.swift†L81-L123】
