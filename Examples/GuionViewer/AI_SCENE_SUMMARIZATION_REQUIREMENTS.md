# AI Scene Summarization Requirements

**Feature:** Automatic scene summarization using Foundation Models (Apple Intelligence)

**Version:** 1.0
**Created:** 2025-10-14
**Status:** Requirements Draft

---

## Overview

Add AI-powered scene summarization to GuionViewer that automatically generates concise summaries of screenplay scenes using Apple's Foundation Models. Summaries should be generated when document parsing completes and displayed in the collapsed (undisclosed) scene view.

**Note:**
- ✅ The `GuionElementModel` SwiftData model already has a `summary: String?` field (GuionDocumentModel.swift:236)
- ✅ `SceneSummarizer` class exists with `summarizeScene()` method (SceneSummarizer.swift:172)
- ✅ Foundation Models integration scaffolding exists (iOS 26+/macOS 26+ support)
- ⚠️ **TODO:** Actual Foundation Models API calls need implementation (SceneSummarizer.swift:88-94)
- ✅ Fallback extractive summarization already implemented

---

## Functional Requirements

### FR-1: Scene Summary Data Model

**Requirement:** Use existing `summary` field on `GuionElementModel` SwiftData model.

**Details:**
- ✅ **Already implemented:** `summary: String?` property exists on `GuionElementModel` (GuionDocumentModel.swift:236)
- Summary is stored in SwiftData persistence layer
- Summary updates will automatically trigger SwiftUI view updates
- Default value is `nil` (not yet generated)

**Implementation:**
- Update the `summary` property on `GuionElementModel` instances for Scene Heading elements
- Use `@MainActor` to ensure UI updates happen on main thread
- SwiftData will handle persistence and change notifications

---

### FR-2: Summarization Trigger

**Requirement:** Trigger summarization when document parsing completes.

**Details:**
- ✅ **CLARIFIED:** Summarization occurs when the entire document parsing is complete
- NOT triggered per-scene as they scroll into view
- One-time batch operation for all Scene Heading elements in the document
- Triggered in the document opening/import flow

**Implementation:**
- Hook into document parsing completion event
- Iterate through all `GuionElementModel` instances where `elementType == "Scene Heading"`
- For each scene heading, generate summary on background thread
- Update `summary` field on main thread when complete

---

### FR-3: Foundation Models Integration

**Requirement:** Use Apple's Foundation Models framework to generate scene summaries.

**Details:**
- Use `Foundation.Models` API (available in iOS 18.2+, macOS 15.2+)
- Execute summarization on background thread (non-main actor)
- Send generated summary back to main actor for UI update
- Handle model availability checks (device capability, OS version)

**Technical Notes:**
```swift
// Pseudocode
Task.detached {
    let summary = await FoundationModel.summarize(sceneContent)
    await MainActor.run {
        sceneData.summary = summary
    }
}
```

**Questions:**
- Which specific Foundation Model API should we use? (e.g., `TextGeneration`, `Summarization`)
- What's the maximum input token/character limit?
- Should we truncate very long scenes before summarization?
- What happens on devices without Apple Intelligence support?

---

### FR-4: Summarization Prompt

**Requirement:** Define the prompt/instruction for the summarization task.

**Details:**
- Create concise 1-2 sentence summaries
- Focus on key actions, characters, and plot points
- Maintain screenplay terminology where appropriate

**Questions:**
- ⚠️ **NEEDS CLARIFICATION:** What's the exact prompt format?
  - Example: "Summarize this screenplay scene in 1-2 sentences, focusing on key actions and character interactions:"
- Should summaries include character names explicitly?
- Should summaries note scene location/time or assume that's already visible?
- What tone should summaries use? (Professional, casual, technical?)

---

### FR-5: Background Threading

**Requirement:** Perform all AI summarization on background threads to prevent UI blocking.

**Details:**
- Use `Task.detached` or similar for off-main-thread execution
- Queue multiple summarization requests efficiently
- Implement concurrency limiting (e.g., max 3 simultaneous summarizations)
- Handle cancellation when views disappear

**Technical Constraints:**
- Foundation Models API must be called from non-MainActor context
- UI updates must return to MainActor
- Should work with Swift concurrency (async/await)

**Questions:**
- Should we use an actor-based queue manager?
- What's the maximum concurrent summarization limit?
- How do we prioritize visible scenes over off-screen scenes?

---

### FR-6: Main Actor Updates

**Requirement:** Update `GuionElementModel.summary` field on main thread after background processing.

**Details:**
- ✅ **CLARIFIED:** Use main thread to update `GuionElementModel.summary` property
- Use `@MainActor` annotation or `await MainActor.run { }` for updates
- SwiftData will automatically trigger SwiftUI view updates when property changes
- No need for manual `@Published` or `objectWillChange` - SwiftData handles this

**Implementation Pattern:**
```swift
@MainActor
func updateSummary(for element: GuionElementModel, summary: String) {
    element.summary = summary
    // SwiftData automatically notifies views
}
```

**Implementation:**
- Locate the correct `GuionElementModel` by `sceneId` property
- Update the `summary` property directly
- SwiftData's observation system handles UI refresh automatically

---

### FR-7: UI Display - Collapsed Scene View

**Requirement:** Display summary in the collapsed (undisclosed/compact) version of the scene view.

**Details:**
- ✅ **CLARIFIED:** "Undisclosed" = collapsed state of `DisclosureGroup` (when `isExpanded = false`)
- Show summary text in the scene label area before scene details are disclosed
- Display in collapsed/compact/preview state

**UI Location:**
- Display in the `DisclosureGroup` label section of `SceneWidget`
- Show below or alongside the scene slugline
- Visible when scene is collapsed (not expanded)

**Styling:**
- Font: System caption or footnote
- Color: Secondary or tertiary (to distinguish from slugline)
- Style: Regular or italic
- Truncation: Use `lineLimit(2)` or similar to prevent overflow

**Visual Hierarchy:**
1. Scene slugline (bold, primary, monospaced)
2. Scene location badge (capsule, secondary) - aligned right
3. Summary (caption, secondary/tertiary) - below slugline

---

### FR-8: Summary Display Formatting

**Requirement:** Format summaries consistently in the UI.

**Details:**
- Font: System body or caption
- Color: Secondary or tertiary
- Style: Italic or regular
- Truncation: Use `lineLimit()` or full text
- Loading state: Show spinner/skeleton

**Questions:**
- Should summaries be truncated with "..." if too long?
- Should there be a max character/line limit for display?
- What's the loading state UI? (spinner, skeleton, placeholder text?)

---

### FR-9: Error Handling

**Requirement:** Handle summarization failures gracefully.

**Details:**
- Network errors (if model requires connection)
- Model unavailable (device/OS limitations)
- Timeout errors (slow processing)
- Content safety/filtering rejections
- Rate limiting

**Fallback Behavior:**
- Don't show summary if generation fails
- Log error for debugging
- Don't retry automatically (avoid infinite loops)
- Optional: Show error indicator (🚫 icon?)

**Questions:**
- Should users see error messages or silently fail?
- Should we cache failed attempts to avoid retries?
- Should there be a manual "retry" option?

---

### FR-10: Performance & Optimization

**Requirement:** Ensure summarization doesn't degrade app performance.

**Details:**
- Lazy loading only (don't pre-generate all summaries)
- Cancel pending requests when views disappear
- Implement request queue/pooling
- Cache generated summaries (in-memory, not persisted)
- Limit concurrent API calls

**Questions:**
- Should summaries be persisted to disk/database?
- How long should in-memory cache last?
- Should there be a "Regenerate All Summaries" option?

---

### FR-11: User Preferences

**Requirement:** Allow users to control summarization behavior.

**Details:**
- Enable/disable auto-summarization
- Optional: Control when summaries trigger (scroll vs expand)
- Optional: Summary length preference (brief, detailed)

**Questions:**
- ⚠️ **NEEDS CLARIFICATION:** Should this feature be opt-in or opt-out?
- Should preferences be per-document or global?
- Should there be a settings screen?

---

## Non-Functional Requirements

### NFR-1: Performance
- Summarization should not block UI thread
- Initial summary generation: < 5 seconds per scene
- UI should remain responsive during summarization

### NFR-2: Privacy
- Scene content sent to on-device models only (no cloud)
- Follow Apple's Foundation Models privacy guidelines
- No scene data should be logged/transmitted externally

### NFR-3: Compatibility
- Minimum OS: macOS 15.2+ (Foundation Models requirement)
- Graceful degradation on older OS versions (hide feature)
- Detect Apple Intelligence availability

### NFR-4: Accessibility
- Summaries should be VoiceOver accessible
- Loading states should announce to assistive tech
- Color contrast should meet WCAG standards

---

## Technical Architecture

### Components to Modify

1. ✅ **GuionElementModel (already exists)**
   - GuionDocumentModel.swift:226-349
   - Already has `summary: String?` property (line 236)
   - Update this field after summarization

2. **SceneWidget.swift**
   - Update collapsed `DisclosureGroup` label to display summary
   - Access summary from underlying `GuionElementModel` via scene ID
   - Show loading indicator if summary is nil during initial load
   - Add summary text below slugline in label area

3. **GuionDocument.swift or GuionViewer.swift**
   - Hook into document parsing completion
   - Trigger summarization for all Scene Heading elements
   - Call `SceneSummarizer.summarizeScene()` (if exists) or Foundation Models API

4. ✅ **SceneSummarizer (already exists!)**
   - SceneSummarizer.swift:57-178
   - Already has `summarizeScene()` method (line 172, marked `@MainActor`)
   - Already has Foundation Models framework integration (iOS 26+)
   - **TODO:** Implement actual Foundation Models API calls (line 88-94, currently placeholder)
   - Already has fallback extractive summarization
   - **What needs to be done:**
     - Complete the Foundation Models API implementation
     - Test on iOS 26+/macOS 26+ device with Apple Intelligence enabled
     - Replace the TODO comment with actual `FoundationModel` API usage

### Data Flow

```
┌─────────────────────────────────────────────────┐
│ User opens document → Parsing completes         │
└───────────────────────┬─────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│ Document parsed → GuionDocumentModel created    │
│ Get all Scene Heading elements                  │
└───────────────────────┬─────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│ For each Scene Heading GuionElementModel:       │
│ Task.detached { summarize(element) }            │
│ [Background Thread - Non-MainActor]             │
└───────────────────────┬─────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│ Foundation Models API generates summary         │
│ (or SceneSummarizer.summarizeScene())           │
└───────────────────────┬─────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│ await MainActor.run {                           │
│   element.summary = generatedSummary            │
│ }                                               │
│ [Main Thread - SwiftData Update]                │
└───────────────────────┬─────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────┐
│ SwiftData notifies observers                    │
│ SwiftUI updates SceneWidget collapsed view      │
└─────────────────────────────────────────────────┘
```

---

## Open Questions & Clarifications Needed

### High Priority

1. ✅ **RESOLVED:** "Undisclosed Version" = collapsed `DisclosureGroup` state

2. ✅ **RESOLVED:** Trigger = when document parsing completes (batch operation for all scenes)

3. ✅ **RESOLVED:** Data Model = use existing `GuionElementModel.summary` field

4. ✅ **RESOLVED:** Main Thread Updates = update `GuionElementModel.summary` directly on main thread

5. **Foundation Models API Implementation** ⚠️
   - ✅ **FOUND:** `SceneSummarizer` exists at SceneSummarizer.swift
   - ✅ Already imports `FoundationModels` framework (line 42)
   - ✅ Has iOS 26+ / macOS 26+ availability checks (line 65, 78)
   - ⚠️ **TODO in code:** Line 88-94 has placeholder for actual Foundation Models API
   - ⚠️ **NEEDS IMPLEMENTATION:** Replace placeholder with actual `FoundationModel` API calls
   - Current fallback: Uses extractive summarization (characters + first action line)

6. **Summarization Prompt** ⚠️
   - Placeholder in code: "Summarize this guión scene in one sentence:\n\n{text}" (line 92)
   - Should this be updated or is it acceptable?
   - Any specific format requirements?
   - Should it be user-configurable?

### Medium Priority

5. **Summary Persistence**
   - Should summaries be saved to disk?
   - Should they be included in .guion file exports?

6. **User Control**
   - Opt-in or opt-out?
   - Global or per-document settings?

7. **Error UX**
   - Show errors to users or silent fail?
   - Retry mechanisms?

### Low Priority

8. **Summary Length**
   - Fixed sentence count or adaptive?
   - Character limit?

9. **Cache Strategy**
   - Cache lifetime?
   - Memory limits?

---

## Success Criteria

- ✅ Summaries generate automatically when scenes become visible
- ✅ UI remains responsive during summarization
- ✅ Summaries display correctly in collapsed scene view
- ✅ No main thread blocking
- ✅ Graceful handling of unavailable models/errors
- ✅ Accessibility features work correctly
- ✅ Privacy preserved (on-device only)

---

## Out of Scope (Future Enhancements)

- Manual summary editing
- Custom summarization prompts per scene
- Export summaries to separate file
- Multi-language support
- Character/location extraction
- Screenplay analysis beyond summarization

---

## Notes

- This feature requires macOS 15.2+ (Foundation Models)
- Will need to test on devices with/without Apple Intelligence
- Consider adding feature flag for gradual rollout
- May need App Store entitlements for Foundation Models usage

