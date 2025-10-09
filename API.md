# API Reference

This guide lists the main entry points exposed by the SwiftGuion package so that tools can look up type signatures without opening the sources.

## Core Types

| Type | Role |
| --- | --- |
| `FountainScript` | Primary facade for parsing, inspecting, and exporting Fountain data. |
| `GuionElement` | Represents a single guión element (scene heading, dialogue, etc.). |
| `CharacterInfo` / `CharacterList` | Aggregated character statistics derived from a script. |
| `OutlineElement` / `OutlineTree` | Structural outline abstraction with hierarchical helpers. |
| `FountainWriter` | Recreates Fountain/Highland/TextBundle outputs from a parsed script. |

## FountainScript

`FountainScript` tracks parsed metadata and provides multiple loaders. Key properties and initializers include:

- `init()` – create an empty container.
- `init(file:parser:)` / `loadFile(_:parser:)` – parse a file path (`.fountain`, `.highland`, `.textbundle`).
- `init(string:parser:)` / `loadString(_:parser:)` – parse in-memory Fountain text.
- `init(highlandURL:parser:)` / `loadHighland(_:parser:)` – unpack Highland archives.
- `init(textBundleURL:parser:)` / `loadTextBundle(_:parser:)` – extract TextBundle content.

The class stores `filename`, `elements`, `titlePage`, `suppressSceneNumbers`, and caching needed for re-parsing. It also exposes `getGuionElements`, `getContentUrl`, `getContent`, and writing helpers (`write(toFile:)`, `write(to:)`, `writeToTextBundle`, `writeToHighland`). Parser selection is handled by the `ParserType` enum (`.fast` vs `.regex`). 【F:Sources/SwiftGuion/FountainScript.swift†L30-L195】【F:Sources/SwiftGuion/FountainScript+Highland.swift†L31-L123】【F:Sources/SwiftGuion/FountainScript+TextBundle.swift†L32-L179】

## Guion Elements

`GuionElement` stores the textual payload and metadata needed to reconstruct Fountain markup:

- `elementType`, `elementText`, `isCentered`
- Scene-specific info (`sceneNumber`, `sectionDepth`, `isDualDialogue`)
- `CustomStringConvertible` implementation for debug printing

Instances are created and managed by the parsers but can be constructed manually if necessary. 【F:Sources/SwiftGuion/FountainElement.swift†L18-L45】

## Characters API

`CharacterInfo` tracks per-character statistics with nested `CharacterCounts` (dialogue lines/words) and `CharacterGender` metadata. `CharacterList` is a simple `[String: CharacterInfo]` alias. FountainScript adds:

- `extractCharacters()` – builds the dictionary, populating scenes, line counts, and word counts.
- `writeCharactersJSON(toFile:)` / `writeCharactersJSON(to:)` – export summaries as pretty-printed JSON.
- `firstDialogue(for:)` – find the first spoken line of a character.

These utilities rely on the parsed `GuionElement` sequence; names are normalized (case-insensitive, extension-free). 【F:Sources/SwiftGuion/CharacterInfo.swift†L28-L74】【F:Sources/SwiftGuion/FountainScript+Characters.swift†L30-L154】

## Outline API

`OutlineElement` encodes hierarchy for sections, scenes, and `NOTE:` comments, including parent/child relationships, directive metadata, and helper predicates (`isSceneDirective`, `isChapter`, `isMainTitle`). The companion `OutlineTree` builds a tree of `OutlineTreeNode` objects and offers queries such as `node(for:)`, `allNodes`, and `leafNodes`. FountainScript exposes:

- `extractOutline()` – generates ordered outline entries with auto-added title/root markers.
- `extractOutlineTree()` – convenience wrapper returning an `OutlineTree`.
- `writeOutlineJSON(toFile:)` / `writeOutlineJSON(to:)` – exports a trimmed outline ready for Highland/TextBundle resources.

Parent-child relationships are automatically tracked and exported in JSON-friendly form. 【F:Sources/SwiftGuion/OutlineElement.swift†L28-L268】【F:Sources/SwiftGuion/FountainScript+Outline.swift†L30-L273】

## Writing Output

`FountainWriter` rebuilds title pages and guión bodies from the parsed elements. Notable methods:

- `document(from:)` – produce the full Fountain text (title page + body).
- `body(from:)` – serialize only the guión body, applying Fountain formatting rules for each element type.
- `titlePage(from:)` – render the title page entries back into Fountain front matter.

`FountainScript` wraps these helpers via `stringFromDocument`, `stringFromBody`, and `stringFromTitlePage`, and passes the generated text to the file/bundle writers described above. 【F:Sources/SwiftGuion/FountainWriter.swift†L29-L158】【F:Sources/SwiftGuion/FountainScript.swift†L88-L108】【F:Sources/SwiftGuion/FountainScript+TextBundle.swift†L84-L179】

## Package Layout

SwiftGuion ships as a single SwiftPM library target that depends on the open-source `TextBundle` package (used for TextBundle/Highland support). Tests live under `SwiftGuionTests` with fixture bundles for Fountain, Highland, and TextBundle inputs. 【F:Package.swift†L7-L37】
