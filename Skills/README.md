# SwiftGuion AI Skills

This directory contains AI assistant skills for working with the SwiftGuion library. These skills help AI coding assistants (Claude Code, GitHub Copilot, Cursor, etc.) provide better support for screenplay parsing, SwiftData integration, and screenplay analysis tasks.

## What Are AI Skills?

AI skills are structured documentation and prompts that help AI assistants understand:

- **Domain-specific concepts** (screenplay parsing, SwiftData integration)
- **Common workflows** (import/export pipelines)
- **Best practices** (error handling, performance optimization)
- **Code patterns** (ready-to-use examples)

By providing this context, AI assistants can generate better code, catch common mistakes, and follow established patterns.

## Available Skills

### 📝 Screenplay SwiftData Import/Export

**Directory**: `screenplay-swiftdata/`

**Purpose**: Helps AI assistants work with SwiftGuion for importing screenplay files (Fountain, FDX, Highland) into SwiftData and exporting them back to screenplay formats.

**Capabilities**:
- Parse screenplay files with progress reporting
- Convert to SwiftData models with proper chapter indexing
- Export SwiftData back to screenplay formats
- Extract character, location, and outline analysis
- Build SwiftUI screenplay viewing apps
- Handle large files efficiently

**When to use**: Any time you're working with screenplay import/export, SwiftData integration, or building screenplay editing/production tools.

**Files**:
- `screenplay-swiftdata.md` - Comprehensive AI prompt with all patterns and workflows
- `examples.md` - Copy-paste code examples for common tasks
- `README.md` - Skill overview and usage guide

## How to Use These Skills

### With Claude Code

1. **Reference in conversation**: Point Claude to this directory when working on SwiftGuion tasks

```
"Help me import a screenplay file using the SwiftGuion library.
See the Skills/screenplay-swiftdata/ directory for guidance."
```

2. **Ask for specific workflows**:

```
"Use the screenplay import workflow from the skill to create
an import function with progress reporting."
```

3. **Request examples**:

```
"Show me the character analysis example from the SwiftGuion skill."
```

### With GitHub Copilot

1. **Open skill files** in your editor alongside your code
2. **Add comments** referencing the skill:

```swift
// Import screenplay using the pattern from Skills/screenplay-swiftdata/
// See examples.md for reference
func importScreenplay(from url: URL) async throws {
    // Copilot will suggest code based on the skill
}
```

3. **Use in workspace**:
- Keep skill files open in tabs
- Copilot will use them as context for suggestions

### With Cursor

1. **Add to context**: Use `@Skills/screenplay-swiftdata` in Cursor chat
2. **Reference specific sections**: Point Cursor to specific workflows or examples
3. **Use for code generation**: Ask Cursor to generate code following skill patterns

### With Other AI Assistants

1. **Copy relevant sections** from skill files
2. **Paste into your prompt** when asking for help
3. **Reference examples** for the AI to adapt

## Skill Structure

Each skill typically contains:

```
skill-name/
├── skill-name.md       # Main AI prompt with comprehensive guidance
├── examples.md         # Practical code examples
├── README.md          # Skill overview and usage guide
└── [other files]      # Additional resources, tests, etc.
```

### Main Skill File (`*.md`)

The primary AI assistant prompt containing:
- Core capabilities
- Architecture overview
- Complete workflows
- API reference
- Error handling patterns
- Performance tips
- Common pitfalls

**Use this** when you need comprehensive understanding.

### Examples File (`examples.md`)

Ready-to-use code snippets for:
- Common tasks
- Complete implementations
- Integration patterns
- Testing examples

**Use this** when you need working code to adapt.

### README File

Human-readable overview with:
- Quick start guide
- Key concepts
- Use cases
- Integration points
- Troubleshooting

**Use this** for project planning and understanding.

## Creating New Skills

To add a new skill to this directory:

### 1. Create Skill Directory

```bash
mkdir Skills/my-skill-name
```

### 2. Create Main Skill Prompt

`Skills/my-skill-name/my-skill-name.md`:

```markdown
# My Skill Name

You are an AI assistant specialized in [domain]. Your expertise includes [capabilities].

## Core Capabilities

[List capabilities]

## Architecture

[Explain key concepts]

## Workflows

[Provide complete workflows]

## Common Pitfalls

[Document gotchas]

## When to Use This Skill

[When to invoke]
```

### 3. Add Examples

`Skills/my-skill-name/examples.md`:

```markdown
# My Skill Examples

## Example 1: [Task Name]

[Code example with explanation]

## Example 2: [Another Task]

[More code examples]
```

### 4. Write README

`Skills/my-skill-name/README.md`:

```markdown
# My Skill Name

## Overview

[What this skill does]

## Quick Start

[How to use]

## Key Concepts

[Important ideas]

## Resources

[Links and references]
```

### 5. Update This File

Add your skill to the "Available Skills" section above.

## Best Practices for Skills

### For Skill Authors

1. **Be comprehensive**: Cover all common use cases
2. **Provide examples**: Show, don't just tell
3. **Document pitfalls**: Save users from common mistakes
4. **Stay updated**: Keep in sync with library changes
5. **Test examples**: Ensure all code actually works

### For Skill Users (Developers)

1. **Read the README first**: Understand what the skill covers
2. **Use examples as starting points**: Adapt, don't just copy
3. **Reference workflows**: Follow established patterns
4. **Ask specific questions**: Point AI to relevant sections
5. **Contribute improvements**: Share better patterns you discover

### For AI Assistants

1. **Read the main skill file**: Understand domain and capabilities
2. **Follow workflows exactly**: They encode best practices
3. **Use examples as templates**: Adapt for user's specific needs
4. **Warn about pitfalls**: Reference common mistakes section
5. **Stay consistent**: Follow patterns throughout the skill

## Skill Development Workflow

```
1. Identify need
   ↓
2. Study library/domain
   ↓
3. Document architecture
   ↓
4. Create workflows
   ↓
5. Write examples
   ↓
6. Test with AI
   ↓
7. Refine based on usage
   ↓
8. Update as library evolves
```

## Testing Skills

### Manual Testing

1. **Ask AI assistant** to perform task using skill
2. **Verify generated code** compiles and works
3. **Check for completeness** - did it miss anything?
4. **Test edge cases** - what about errors?

### Automated Testing

1. **Extract examples** into unit tests
2. **Run tests** to ensure examples work
3. **Update skill** when tests fail

### Improvement Cycle

1. **Collect issues** from usage
2. **Identify patterns** in mistakes
3. **Update skill** to address issues
4. **Re-test** with AI assistant
5. **Document improvements**

## Integration with SwiftGuion

These skills are designed to work alongside SwiftGuion's existing documentation:

```
SwiftGuion/
├── README.md              # Project overview
├── CLAUDE.md             # Claude Code integration
├── CHANGELOG.md          # Version history
├── Docs/                 # API documentation
├── Examples/             # Example apps
├── Tests/                # Test suite
└── Skills/               # AI assistant skills (this directory)
    └── screenplay-swiftdata/
        ├── screenplay-swiftdata.md    # AI prompt
        ├── examples.md               # Code examples
        └── README.md                 # Usage guide
```

**Relationship**:
- **README.md**: Human-readable project overview
- **CLAUDE.md**: Claude Code-specific instructions
- **Skills/**: Reusable AI assistant skills for any AI tool

## Contributing

### Adding a New Skill

1. Create skill directory: `Skills/new-skill-name/`
2. Write main prompt: `new-skill-name.md`
3. Add examples: `examples.md`
4. Write README: `README.md`
5. Update this file with skill description
6. Test with multiple AI assistants
7. Submit PR with skill

### Improving Existing Skills

1. Identify improvement area
2. Update relevant files
3. Test changes with AI
4. Document changes in skill README
5. Submit PR

### Reporting Issues

If a skill has incorrect information or missing patterns:

1. Open issue describing the problem
2. Include example of what went wrong
3. Suggest improvement if possible
4. Tag with `skill:` label

## Future Skills

Potential skills to add:

- **Screenplay Analysis**: Advanced character/scene/structure analysis
- **FDX Parsing**: Deep dive into Final Draft format specifics
- **Highland Extensions**: Working with Highland-specific features
- **Screenplay Validation**: Format checking and linting
- **Production Breakdown**: Script breakdown for production
- **Collaborative Editing**: Multi-user screenplay editing patterns

## Resources

### SwiftGuion Documentation

- [Main README](../README.md) - Project overview
- [CLAUDE.md](../CLAUDE.md) - Claude Code integration
- [API Docs](../Docs/) - Detailed API documentation
- [Examples](../Examples/) - Example applications

### AI Assistant Documentation

- [Claude Code](https://claude.com/claude-code) - Claude's coding assistant
- [GitHub Copilot](https://github.com/features/copilot) - GitHub's AI pair programmer
- [Cursor](https://cursor.sh/) - AI-first code editor

### Screenplay Formats

- [Fountain Spec](https://fountain.io) - Fountain format specification
- [Final Draft](https://www.finaldraft.com/) - Industry-standard screenwriting software

## License

These skills are part of the SwiftGuion project and are licensed under the MIT License. See [LICENSE](../LICENSE) for details.

## Questions?

- **For skill usage**: See individual skill READMEs
- **For skill development**: See "Creating New Skills" above
- **For SwiftGuion**: See main project documentation
- **For issues**: Open a GitHub issue

---

**Version**: 1.0.0
**Last Updated**: 2025-01-21
**Maintained By**: SwiftGuion Contributors

*Making AI assistants better at working with screenplays.*
