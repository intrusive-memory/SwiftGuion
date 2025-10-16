# SwiftGuion Xcode Template: Implementation Methodology

## Table of Contents
1. [Project Overview](#project-overview)
2. [Definition of Done](#definition-of-done)
3. [Development Phases](#development-phases)
4. [Implementation Strategy](#implementation-strategy)
5. [Testing & Validation](#testing--validation)
6. [Acceptance Criteria](#acceptance-criteria)
7. [Risk Management](#risk-management)

---

## Project Overview

**Goal**: Create an Xcode project template that generates fully functional SwiftGuion-based screenplay editing applications.

**Timeline Estimate**: 4-6 weeks (detailed breakdown in phases below)

**Key Deliverables**:
1. Xcode template bundle (`.xctemplate`)
2. Installation script
3. Template documentation
4. Working sample projects from template
5. Test suite for template validation

---

## Definition of Done

### Primary "Done" Criteria

The template is considered **DONE** when:

#### 1. **Functional Completeness** ✅
- [ ] Template generates on first attempt without errors
- [ ] Generated project builds successfully (iOS and macOS)
- [ ] Generated project runs on simulator/device
- [ ] All 7 Success Criteria from requirements are met (see below)

#### 2. **Feature Completeness** ✅
- [ ] Document handling works (new, open, save, close)
- [ ] Import works (.fountain, .fdx, .highland)
- [ ] Export works (.fountain, .fdx)
- [ ] Scene browser displays correctly
- [ ] Navigation works (tap scene → jumps to scene)
- [ ] SwiftData persistence works
- [ ] Value-based mode works (if selected)

#### 3. **Quality Standards** ✅
- [ ] Code passes SwiftLint (if configured)
- [ ] All generated code has documentation comments
- [ ] No compiler warnings on first build
- [ ] No runtime crashes in basic workflows
- [ ] Memory leaks tested and fixed

#### 4. **User Experience** ✅
- [ ] Template appears in Xcode's new project wizard
- [ ] Template options are clear and functional
- [ ] Installation takes < 1 minute
- [ ] README is clear and accurate
- [ ] Sample content demonstrates key features

#### 5. **Testing** ✅
- [ ] Template tested on macOS 14.0+ with Xcode 17+
- [ ] Generated project tested on iOS 26+ simulator
- [ ] Generated project tested on macOS 26+
- [ ] Edge cases tested (large files, empty files, corrupt files)
- [ ] All automated tests pass

#### 6. **Documentation** ✅
- [ ] Template usage guide complete
- [ ] Code documentation complete
- [ ] Installation instructions tested
- [ ] Troubleshooting section included
- [ ] Customization guide provided

### Secondary "Done" Criteria (Nice to Have)

- [ ] Template tested with Xcode beta
- [ ] Performance benchmarks documented
- [ ] Video tutorial created
- [ ] Community feedback incorporated
- [ ] Example customizations provided

---

## Development Phases

### **Phase 0: Foundation (Week 1)**
**Goal**: Set up infrastructure and validate approach

#### Tasks:
1. **Research Xcode Templates**
   - [ ] Study existing Xcode template structure
   - [ ] Review Apple documentation on templates
   - [ ] Examine other template examples
   - [ ] Document template macros and variables

2. **Create Template Skeleton**
   - [ ] Create `Templates/` directory
   - [ ] Create `SwiftGuion Document App.xctemplate/` structure
   - [ ] Create basic `TemplateInfo.plist`
   - [ ] Test template appears in Xcode

3. **Validate Approach**
   - [ ] Generate minimal project from template
   - [ ] Verify Xcode recognizes template
   - [ ] Test variable substitution works
   - [ ] Document any Xcode quirks/limitations

**Deliverable**: Working template skeleton that generates a minimal "Hello World" project

**Definition of Phase 0 Done**:
- Template shows up in Xcode File → New → Project
- Generates a buildable empty project
- Variable substitution works (product name, org identifier, etc.)

---

### **Phase 1: Core Document Handling (Week 2)**
**Goal**: Implement document infrastructure

#### Tasks:
1. **Document Types & UTTypes**
   - [ ] Create UTType extensions for .guion, .fountain, .fdx, .highland
   - [ ] Add Info.plist document type declarations
   - [ ] Create export type declarations
   - [ ] Test document type registration

2. **SwiftData Mode**
   - [ ] Create GuionDocumentModel template
   - [ ] Create GuionElementModel template
   - [ ] Implement DocumentGroup setup
   - [ ] Add model container configuration
   - [ ] Test save/load with SwiftData

3. **Value Mode**
   - [ ] Create FileDocument conformance
   - [ ] Implement read/write methods
   - [ ] Add DocumentGroup(newDocument:) setup
   - [ ] Test save/load with value types

4. **Import/Export**
   - [ ] Implement Fountain import
   - [ ] Implement FDX import
   - [ ] Implement Highland import
   - [ ] Implement Fountain export
   - [ ] Implement FDX export
   - [ ] Add error handling for all formats

**Deliverable**: Template generates project with working document handling

**Definition of Phase 1 Done**:
- Can create new .guion document
- Can open .fountain file
- Can save changes
- Can export to .fountain
- Changes persist after restart
- No data loss in save/load cycle

---

### **Phase 2: User Interface (Week 3-4)**
**Goal**: Build complete UI for both platforms

#### Tasks:
1. **iOS UI**
   - [ ] Create ContentView with NavigationSplitView
   - [ ] Implement SceneBrowserView
   - [ ] Create scene cards
   - [ ] Add chapter sections
   - [ ] Add scene group sections
   - [ ] Implement editor view
   - [ ] Add toolbar with export button
   - [ ] Test on iPhone and iPad

2. **macOS UI**
   - [ ] Create document window layout
   - [ ] Implement three-column layout
   - [ ] Add menu bar items (File, View, Format)
   - [ ] Create toolbar
   - [ ] Add outline navigator
   - [ ] Test on macOS

3. **Shared Components**
   - [ ] Create SceneCard component
   - [ ] Create ChapterSection component
   - [ ] Create SceneGroupSection component
   - [ ] Add location badges
   - [ ] Add scene number display
   - [ ] Style components for both platforms

4. **Navigation**
   - [ ] Implement scene tap → jump to scene
   - [ ] Add collapsible sections
   - [ ] Implement outline filtering
   - [ ] Test navigation flow

**Deliverable**: Template with complete, working UI on both platforms

**Definition of Phase 2 Done**:
- Scene browser displays hierarchy correctly
- Can navigate to scenes by tapping/clicking
- Chapters and scene groups collapse/expand
- UI adapts to iPhone/iPad/Mac appropriately
- Export button works
- Outline navigator works

---

### **Phase 3: Features & Polish (Week 5)**
**Goal**: Add essential features and polish

#### Tasks:
1. **Editor Features**
   - [ ] Add basic syntax highlighting
   - [ ] Implement element type detection
   - [ ] Add scene number display
   - [ ] Create format toolbar
   - [ ] Add character autocomplete (basic)
   - [ ] Test editing workflows

2. **Scene Browser Features**
   - [ ] Display scene summaries (if available)
   - [ ] Add location badges (INT/EXT, time of day)
   - [ ] Show scene numbers
   - [ ] Add search/filter (optional)

3. **App Icon & Assets**
   - [ ] Create template icon (512x512)
   - [ ] Create @2x version (1024x1024)
   - [ ] Add default app icon
   - [ ] Add accent color
   - [ ] Test icon display in Xcode

4. **Sample Content**
   - [ ] Create sample screenplay
   - [ ] Test conditional inclusion
   - [ ] Verify sample loads correctly
   - [ ] Add TODO comments in sample

**Deliverable**: Feature-complete template

**Definition of Phase 3 Done**:
- Basic editing works
- Scene browser shows all metadata
- Sample content loads and displays
- Template icon shows in Xcode
- App runs smoothly on both platforms

---

### **Phase 4: Testing & Documentation (Week 6)**
**Goal**: Ensure quality and usability

#### Tasks:
1. **Template Testing**
   - [ ] Test on clean Xcode installation
   - [ ] Test all template options (iOS, macOS, multiplatform)
   - [ ] Test SwiftData vs Value mode
   - [ ] Test with/without sample content
   - [ ] Generate 10+ projects and verify each builds

2. **Generated Project Testing**
   - [ ] Import 5+ different .fountain files
   - [ ] Test large files (>10k lines)
   - [ ] Test empty files
   - [ ] Test malformed files
   - [ ] Test export roundtrip (import → export → import)
   - [ ] Test SwiftData persistence
   - [ ] Test memory usage with large files
   - [ ] Test on iOS simulator (iPhone, iPad)
   - [ ] Test on macOS (Intel and Apple Silicon if possible)

3. **Documentation**
   - [ ] Write installation guide
   - [ ] Document template options
   - [ ] Create customization guide
   - [ ] Add troubleshooting section
   - [ ] Write code documentation comments
   - [ ] Create README template
   - [ ] Add inline TODO markers
   - [ ] Document common modifications

4. **Installation Script**
   - [ ] Create install-template.sh
   - [ ] Test installation process
   - [ ] Add error handling
   - [ ] Test on multiple macOS versions
   - [ ] Add uninstall script

**Deliverable**: Production-ready template with complete documentation

**Definition of Phase 4 Done**:
- All tests pass
- Documentation is complete and accurate
- Installation tested on 3+ machines
- Known issues documented
- Template ready for public use

---

## Implementation Strategy

### **Incremental Development Approach**

1. **Start Simple, Iterate**
   - Begin with minimal viable template
   - Add features incrementally
   - Test after each addition
   - Don't try to do everything at once

2. **Platform-Specific First, Then Unify**
   - Build iOS version completely first
   - Then build macOS version
   - Extract shared code
   - Test multiplatform option last

3. **Use Existing Code as Reference**
   - Leverage `Examples/GuionViewer/` as starting point
   - Copy working UI components
   - Adapt to template format
   - Don't reinvent working solutions

4. **Test Continuously**
   - Test template generation after each change
   - Keep a test project to validate
   - Run generated project frequently
   - Catch issues early

### **File Organization Strategy**

```
SwiftGuion Document App.xctemplate/
├── TemplateInfo.plist                    # Template configuration
├── TemplateIcon.png                      # 512x512 icon
├── TemplateIcon@2x.png                   # 1024x1024 icon
├── ___PACKAGENAME___.xcodeproj/          # Xcode project template
│   └── project.pbxproj                   # Project file with macros
├── ___PACKAGENAME___/
│   ├── ___PACKAGENAME___App.swift        # App entry point
│   ├── Models/
│   │   ├── GuionDocument.swift
│   │   └── GuionDocumentModel.swift:SwiftData  # Conditional
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── iOS/
│   │   │   └── iOS-specific views
│   │   └── macOS/
│   │       └── macOS-specific views
│   ├── Components/                       # Shared components
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   └── SampleScreenplay.fountain:IncludeSample
│   └── ___PACKAGENAME___.entitlements
└── install-template.sh                   # Installation script
```

**Template Macros to Use**:
- `___PACKAGENAME___` → Product name
- `___PACKAGENAMEASIDENTIFIER___` → Bundle ID safe name
- `___ORGANIZATIONNAME___` → Organization name
- `___FULLUSERNAME___` → Developer name
- `___DATE___` → Current date
- `___YEAR___` → Current year

**Conditional Files**:
- Use `:SwiftData` suffix for SwiftData-only files
- Use `:Value` suffix for value-mode files
- Use `:IncludeSample` for sample content

---

## Testing & Validation

### **Automated Tests**

Create a test script that:

```bash
#!/bin/bash
# test-template.sh

echo "🧪 Testing SwiftGuion Template..."

# Test 1: Template installs
./install-template.sh
if [ ! -d "$HOME/Library/Developer/Xcode/Templates/Project Templates/Application/SwiftGuion Document App.xctemplate" ]; then
    echo "❌ Template installation failed"
    exit 1
fi

# Test 2: Generate project (iOS, SwiftData, with sample)
mkdir -p /tmp/template-test
cd /tmp/template-test
xcodegen generate # Or manual Xcode project creation

# Test 3: Build project
xcodebuild -scheme TestApp -destination 'platform=iOS Simulator,name=iPhone 15' build
if [ $? -ne 0 ]; then
    echo "❌ iOS build failed"
    exit 1
fi

# Test 4: Build macOS
xcodebuild -scheme TestApp -destination 'platform=macOS' build
if [ $? -ne 0 ]; then
    echo "❌ macOS build failed"
    exit 1
fi

echo "✅ All template tests passed"
```

### **Manual Test Checklist**

Use this checklist for each template test:

#### Template Generation
- [ ] Template appears in Xcode
- [ ] All options display correctly
- [ ] Platform selection works
- [ ] Document type selection works
- [ ] Sample content option works
- [ ] Project generates without errors

#### First Build
- [ ] Project opens in Xcode
- [ ] No red compiler errors
- [ ] No warnings (or only expected ones)
- [ ] Build succeeds on first try (iOS)
- [ ] Build succeeds on first try (macOS)

#### Basic Functionality
- [ ] App launches on simulator
- [ ] Can create new document
- [ ] Can open .fountain file
- [ ] Scene browser appears
- [ ] Scenes display in browser
- [ ] Can tap scene to navigate
- [ ] Can export to .fountain
- [ ] Exported file is valid

#### Edge Cases
- [ ] Empty document doesn't crash
- [ ] Large file (10k+ lines) loads
- [ ] Malformed .fountain handled gracefully
- [ ] Missing scenes don't crash browser
- [ ] Rapid scene navigation doesn't crash

---

## Acceptance Criteria

### **7 Success Criteria (from Requirements)**

The template must enable developers to:

1. ✅ **Install in < 1 minute**
   - Download repo
   - Run install script
   - Restart Xcode
   - Template available

2. ✅ **Create project with zero configuration**
   - File → New → Project
   - Select template
   - Fill in standard fields
   - Click Create
   - Project ready

3. ✅ **Build and run immediately**
   - Open generated project
   - Press Cmd+R
   - App launches
   - No errors

4. ✅ **Open .fountain file and see formatted content**
   - File → Open
   - Select .fountain
   - Content displays
   - Formatting correct

5. ✅ **Navigate scenes using browser**
   - See scene list
   - Tap/click scene
   - Jump to scene
   - Browser updates

6. ✅ **Export to .fountain successfully**
   - File → Export
   - Select Fountain
   - Choose location
   - File exports
   - File is valid

7. ✅ **Understand customization through comments**
   - Read inline comments
   - Find TODO markers
   - Understand structure
   - Can modify easily

### **Additional Quality Criteria**

- **Performance**: Large files (10k lines) load in < 2 seconds
- **Memory**: Peak memory < 200MB for typical screenplay
- **Startup**: App launches in < 1 second on modern hardware
- **Reliability**: No crashes in 100 basic operations
- **Compatibility**: Works on macOS 14.0+ with Xcode 17+

---

## Risk Management

### **Identified Risks & Mitigation**

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Xcode template format changes | Low | High | Test with Xcode beta, maintain version compatibility matrix |
| SwiftData API changes | Medium | High | Use stable APIs only, test with each Xcode release |
| Template doesn't appear in Xcode | Medium | High | Validate TemplateInfo.plist structure, test installation early |
| Generated project won't build | Medium | Critical | Test continuously, maintain reference projects |
| Performance issues with large files | Medium | Medium | Profile early, implement lazy loading |
| Platform-specific UI bugs | Medium | Medium | Test on both platforms regularly |
| Documentation out of sync | Low | Medium | Update docs with each code change |

### **Fallback Plans**

If blocked on template implementation:

1. **Plan A**: Xcode project template
2. **Plan B**: Swift Package Manager template (simpler but less integrated)
3. **Plan C**: Xcode project + manual setup guide
4. **Plan D**: Example project with detailed customization guide

---

## Milestones & Checkpoints

### **Week 1 Checkpoint**
**Question**: Does a minimal template generate a buildable project?
- If YES → Continue to Phase 1
- If NO → Revisit template structure, study Xcode docs

### **Week 2 Checkpoint**
**Question**: Does generated project handle documents correctly?
- If YES → Continue to Phase 2
- If NO → Debug document handling, review FileDocument/SwiftData

### **Week 3-4 Checkpoint**
**Question**: Does UI display and navigate correctly?
- If YES → Continue to Phase 3
- If NO → Simplify UI, focus on core navigation

### **Week 5 Checkpoint**
**Question**: Do all features work as expected?
- If YES → Continue to Phase 4
- If NO → Prioritize critical features, defer nice-to-haves

### **Week 6 Checkpoint**
**Question**: Does template pass all tests?
- If YES → Release template
- If NO → Fix critical issues, document known limitations

---

## Maintenance & Updates

### **Post-Release Tasks**

1. **Monitor Issues**
   - Watch for bug reports
   - Track feature requests
   - Monitor SwiftGuion API changes

2. **Regular Updates**
   - Test with new Xcode releases
   - Update for new SwiftGuion versions
   - Refresh sample content periodically

3. **Community Feedback**
   - Collect user feedback
   - Incorporate improvements
   - Share examples of customizations

### **Version Compatibility Matrix**

Maintain this table:

| Template Version | SwiftGuion Version | Xcode Version | iOS Version | macOS Version |
|------------------|--------------------| --------------|-------------|---------------|
| 1.0.0 | 2.1.0+ | 17.0+ | 26.0+ | 26.0+ |

---

## Summary: Definition of "DONE"

**The template is DONE when:**

✅ A developer can install it in under 1 minute
✅ Generated projects build on first try (iOS + macOS)
✅ Basic document workflows work (new, open, save, export)
✅ Scene browser displays and navigates correctly
✅ All 12 template tests pass (see section 12 of requirements)
✅ Documentation is complete and tested
✅ Installation script works reliably

**The template is EXCELLENT when:**

🌟 Generated projects have zero compiler warnings
🌟 Performance is smooth even with large files
🌟 Error messages are helpful and actionable
🌟 Code is clean, commented, and easy to customize
🌟 Sample content demonstrates best practices
🌟 Users can get started without reading docs

**Release Checklist:**

Before tagging v1.0:
- [ ] All phases complete
- [ ] All acceptance criteria met
- [ ] Tested on 3+ machines
- [ ] Documentation reviewed
- [ ] Known issues documented
- [ ] Installation tested end-to-end
- [ ] Generated project runs on real device (iOS + macOS)
- [ ] Performance acceptable
- [ ] No critical bugs

**Ship it!** 🚀
