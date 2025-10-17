# Requirements: ElementType Enum Conversion

**Date:** 2025-10-17
**Version:** 1.0
**Status:** Draft

## Executive Summary

Convert the current string-based `elementType` property in `GuionElement` and `GuionElementProtocol` to a strongly-typed enum to improve type safety, enable better pattern matching, and prevent runtime errors from typos in element type strings.

## Background

### Current Implementation

Currently, `GuionElement` uses a `String` property for `elementType`:

```swift
public protocol GuionElementProtocol {
    var elementType: String { get set }
    // ... other properties
}

public struct GuionElement: GuionElementProtocol {
    public var elementType: String
    // ... other properties
}
```

### Problems with Current Approach

1. **Type Safety**: String values can contain typos (e.g., "Dialouge" instead of "Dialogue")
2. **No Compile-Time Validation**: Invalid element types are only caught at runtime
3. **Poor Discoverability**: Developers must search code to find valid element types
4. **Limited Pattern Matching**: String comparisons are verbose and error-prone
5. **Refactoring Risk**: Renaming element types requires string searches across codebase

## Requirements

### 1. Element Type Enum Definition

Create a new `ElementType` enum that represents all screenplay element types:

**Required Element Types** (from FountainParser.swift analysis):
- Scene Heading
- Action
- Character
- Dialogue
- Parenthetical
- Transition
- Section Heading (with levels)
- Synopsis
- Comment
- Boneyard
- Lyrics
- Page Break

**New/Enhanced Element Types** (per Fountain.io specification):
- Outline elements (represented by Section Heading with levels 1-6)
- Outline Summary (represented by Synopsis, lines starting with "=")

### 2. Enum Design Requirements

The enum must:

1. **Support Associated Values** for types that have additional data:
   - `sectionHeading(level: Int)` - For outline levels based on number of "#" characters

2. **Provide String Representation** for backward compatibility:
   - Implement `CustomStringConvertible`
   - Provide `rawValue` or similar for serialization

3. **Support Pattern Matching**:
   ```swift
   switch element.elementType {
   case .sceneHeading:
       // Handle scene heading
   case .sectionHeading(let level):
       // Handle section with specific level
   case .dialogue:
       // Handle dialogue
   default:
       // Handle other types
   }
   ```

4. **Maintain Backward Compatibility**:
   - Provide initializer from String for parsing existing files
   - Provide string representation for export/serialization
   - Ensure FDX export still works

### 3. Protocol Updates

Update `GuionElementProtocol` to use the enum:

```swift
public protocol GuionElementProtocol {
    var elementType: ElementType { get set }
    // ... other properties remain unchanged
}
```

**Note**: The `sectionDepth` property should be deprecated in favor of the enum's associated value, but maintained temporarily for backward compatibility.

### 4. Parser Updates

Update `FountainParser` to use the enum:

**Current code (line 258-260)**:
```swift
var element = GuionElement(type: "Section Heading", text: text)
element.sectionDepth = depth
```

**Should become**:
```swift
var element = GuionElement(type: .sectionHeading(level: depth), text: text)
```

### 5. Outline Support

Enhance outline element support per Fountain.io specification:

**Outline Elements (Section Headings)**:
- `#` = Level 1 (Title/Script name)
- `##` = Level 2 (Act)
- `###` = Level 3 (Sequence)
- `####` = Level 4 (Scene Group)
- `#####` = Level 5 (Sub-scene)
- `######` = Level 6 (Beat)

**Outline Summary**:
- Lines starting with `=` are outline summaries/synopses
- Currently parsed as "Synopsis" - this is correct per Fountain spec
- Should be accessible via `.synopsis` case

### 6. Migration Strategy

**Phase 1: Create Enum (Additive)**
- Define `ElementType` enum
- Add alongside existing `String`-based property
- All new code uses enum

**Phase 2: Update Protocol (Breaking)**
- Change `GuionElementProtocol.elementType` to use enum
- Update `GuionElement` struct
- Update all parsers and writers

**Phase 3: Update Callsites**
- Update all code that checks element types
- Replace string comparisons with pattern matching
- Update tests

**Phase 4: Cleanup**
- Remove temporary compatibility layers
- Remove deprecation warnings

## Test Requirements

### Unit Tests Required

1. **Enum Tests**:
   - Test all enum cases can be created
   - Test string representation matches expected values
   - Test initializer from string works for all valid types
   - Test invalid strings return appropriate default or error

2. **Section Heading Level Tests**:
   - Test parsing `#` through `######` correctly sets levels 1-6
   - Test level extraction from associated value
   - Test level > 6 is handled appropriately

3. **Pattern Matching Tests**:
   - Test switch statements work with all cases
   - Test associated value extraction
   - Test equality comparisons

4. **Backward Compatibility Tests**:
   - Test existing Fountain files parse correctly
   - Test FDX export produces identical output
   - Test serialization/deserialization maintains types

5. **Parser Integration Tests**:
   - Test FountainParser creates correct enum values
   - Test bigfish.fountain parses without errors
   - Test all element types are created correctly

### Test Files to Update

- `GuionElementTests.swift` - Update to use enum
- `FountainParserTests.swift` - Add enum validation
- `OutlineExtensionTests.swift` - Test level handling
- Create new `ElementTypeEnumTests.swift` for enum-specific tests

## Implementation Order

1. ✅ **Write Requirements** (this document)
2. **Write Tests** - Test-driven development approach
   - Create `ElementTypeEnumTests.swift`
   - Update existing tests to expect enum usage
3. **Implement Enum** - Create `ElementType.swift`
   - Define enum with all cases
   - Add string conversion
   - Add initializers
4. **Update Protocol** - Modify `GuionElement.swift`
   - Update protocol definition
   - Update struct implementation
5. **Update Parser** - Modify `FountainParser.swift`
   - Use enum cases instead of strings
6. **Update Writers** - Modify export code
   - `FountainWriter.swift`
   - `FDXDocumentWriter.swift`
7. **Update All Callsites**
   - Search for `elementType ==` patterns
   - Replace with pattern matching
8. **Run Tests** - Verify all tests pass

## Success Criteria

1. All existing tests pass with enum implementation
2. No string-based element type comparisons remain in codebase
3. Fountain files parse identically before and after change
4. FDX export produces identical output
5. Pattern matching improves code readability
6. No runtime errors from invalid element types
7. Section heading levels 1-6 are properly represented
8. Outline summaries (Synopsis) are properly parsed

## References

- Fountain.io Specification: https://fountain.io/syntax
- Current Implementation: `Sources/SwiftGuion/FileFormat/GuionElement.swift:64-116`
- Parser Implementation: `Sources/SwiftGuion/ImportExport/FountainParser.swift:249-264`
- Section Heading Support: `FountainParser.swift:258` (sectionDepth tracking)
- Synopsis Support: `FountainParser.swift:229-237`

## Notes

- The current implementation already tracks `sectionDepth` correctly
- Synopsis parsing for "=" lines already exists
- This change is primarily about type safety and code quality
- No change to Fountain specification compliance needed
