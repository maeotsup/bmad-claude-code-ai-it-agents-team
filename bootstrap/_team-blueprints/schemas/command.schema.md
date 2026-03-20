# Command Definition Schema

Commands are slash commands (`/build`, `/test`, `/lint`, `/security`) that define
how Claude executes common project operations. Each command describes the BEHAVIOR
Claude should exhibit — the actual CLI commands come from `CLAUDE.md` and `_bmad/config/config.yaml`.

## File Naming

- File name: `{command-name}.md` (lowercase — e.g., `build.md`, `test.md`)
- One command per file
- Located in `.claude/commands/`

## Frontmatter

Commands do not use YAML frontmatter. The file is plain markdown.
The first line is a one-sentence description of what the command does.

## Section Order (strict)

### 1. Description (required, 1 line)

First line of the file. One sentence describing what this command does.
Format: `{Verb} the {target} {purpose}.`

Example: `Run the project's test suite and report results.`

### 2. Prerequisites (optional, bulleted list)

```markdown
## Prerequisites
- {condition that must be true before running}
```

Only include if the command has real prerequisites (e.g., app must be running,
dependencies must be installed). Omit the section entirely if there are none.

### 3. Steps (required, numbered list)

```markdown
## Steps
1. {action with specific instruction}
2. {action}
```

**Rules**:
- Each step is one clear action
- Reference commands from `CLAUDE.md` rather than hardcoding CLI commands
- Include what to report after execution (counts, status, file sizes, etc.)
- 3-6 steps typical
- Final step should suggest a follow-up action or next command

### 4. On Failure (required, bulleted list)

```markdown
## On Failure
- If {failure condition}, then {recovery action}
```

**Rules**:
- Cover the 2-3 most common failure modes
- Each bullet: condition → action
- Actions should be: suggest install, show the error, recommend a different command
- Never silently swallow errors

## Constraints on the Overall File

| Constraint | Value |
|------------|-------|
| Target length | 15–35 lines |
| Hard maximum | 50 lines |
| Hardcoded CLI commands | NONE — reference CLAUDE.md or config |
| Emojis | NONE |

## Validation Checklist

- [ ] First line is a single-sentence description starting with a verb
- [ ] Steps section has 3-6 numbered items
- [ ] On Failure section covers at least 2 failure modes
- [ ] No hardcoded technology-specific commands (no `pytest`, `npm test`, `dotnet test`)
- [ ] Steps reference `CLAUDE.md` or project config for actual command syntax
- [ ] Total line count within 15–50 range
