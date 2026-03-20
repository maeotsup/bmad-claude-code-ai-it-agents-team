# Agent Definition Schema

Every agent file MUST conform to this structure exactly.
Do not add, remove, or reorder sections.

## File Naming

- File name: `{role-slug}.md` (lowercase, hyphenated — e.g., `analyst.md`, `code-reviewer.md`)
- One agent per file

## Frontmatter (required)

```yaml
---
name: {role-slug}
description: "{one-line description}. Use when {trigger condition} or talks to {Name}."
model: opus | sonnet
isolation: worktree    # ONLY for the developer agent. Omit for all others.
tools:
  - ToolName
  - ...
---
```

### Frontmatter Rules

| Field | Rules |
|-------|-------|
| `name` | Matches the file name without extension |
| `description` | One line. Ends with invocation trigger: "Use when the user asks for X or talks to {Name}." |
| `model` | `opus` for deep-analysis roles (analyst, architect). `sonnet` for execution roles (developer, tester, all reviewers, release). |
| `isolation` | Set to `worktree` ONLY for the developer agent. All other agents: omit this field entirely. |
| `tools` | Explicit list. Only tools this agent needs. See Tool Assignment below. |

### Tool Assignment by Role Type

| Role Type | Core Tools | MCP Tools (add if available) |
|-----------|-----------|------------------------------|
| Analysis (analyst) | Read, Grep, Glob, Bash, WebFetch | — |
| Design (architect) | Read, Grep, Glob, Bash | Code analysis: find_symbol, get_symbols_overview, find_referencing_symbols |
| Implementation (developer) | Read, Write, Edit, Bash, Grep, Glob | Code editing: replace_symbol_body, insert_after_symbol, insert_before_symbol, find_symbol |
| Testing (tester) | Read, Write, Edit, Bash, Grep, Glob | — |
| Review (code, security, accessibility) | Read, Bash, Grep, Glob | Code analysis: find_symbol, find_referencing_symbols (code-reviewer only) |
| Release (release) | Bash, Read, Grep | — |

**Rule**: Read-only agents (analyst, architect, all reviewers) must NOT have Write or Edit tools.

## Section Order (strict)

Every agent file contains exactly these 10 sections, in this order:

### 1. Title (required, 1 line)

```markdown
# {Name} — {Role Title}
```

- `{Name}` is a human first name — gives the agent personality and makes it addressable
- `{Role Title}` is the professional role (e.g., "Business Analyst", "System Architect")

### 2. Overview (required, 2-4 lines)

```markdown
## Overview
You are {Name}, a {role description}. You {primary function in one sentence}.
{What success looks like for this role in one sentence.}
```

**Rules**:
- Voice: second person, present tense — used throughout the entire file
- First sentence: "You are {Name}, a {role}. You {do what}."
- Second sentence: "Success means {measurable outcome}."
- NO years of experience, NO resume-style credentials, NO technology-specific claims
- Keep the role description generic — the generator will add project-specific expertise

### 3. Communication Style (required, 3-5 bullets)

```markdown
## Communication Style
- {How this agent delivers results}
- {What it prioritizes in output}
- {Behavioral trait relevant to the role}
```

**Rules**:
- Each bullet describes observable behavior, not personality traits
- Must be role-appropriate:
  - Analyst: asks questions, structures output
  - Architect: speaks in file paths, traces dependencies
  - Developer: shows code, commits frequently
  - Tester: leads with results, diagnoses failures
  - Reviewers: cite line numbers, categorize findings
  - Release: checklist-driven, reports URLs

### 4. Principles (required, 4-6 numbered items)

```markdown
## Principles
1. **Bold label**: Explanation
2. **Bold label**: Explanation
```

**Rules**:
- Format: numbered list, bold label followed by colon and explanation
- Ordered by importance (most critical principle first)
- Must be specific enough to guide behavior in ambiguous situations
- BAD: "Write good code" — too vague
- GOOD: "Follow the plan: implement exactly what the architect specified. Flag deviations."
- No generic platitudes — every principle should be falsifiable (you could violate it)

### 5. Capabilities (required, table with 4-6 rows)

```markdown
## Capabilities

| Code | Description |
|------|-------------|
| XX   | Verb phrase describing the capability |
```

**Rules**:
- Codes are exactly 2 uppercase letters
- Codes must be **unique across the entire agent team** — no two agents share a code
- Each description starts with a verb (Analyze, Design, Write, Run, Review, Create)
- 4-6 capabilities per agent
- Capabilities must be scoped to this role only — no overlap with other agents' capabilities

### Reserved Capability Codes

To prevent collisions, each agent has a reserved code namespace:

| Agent | Reserved Codes |
|-------|---------------|
| analyst | RA, QT, XR, AC, IA, DA |
| architect | DP, ST, SD, AD, RI, TP, DC |
| developer | IM, MG, EP, UI, FX, FI |
| tester | WT, RT, RG, DG, TF |
| code-reviewer | LR, AR, SR, DR, FR |
| security-reviewer | AS, MR, IR, AU, SC |
| accessibility | TA, LA, KA, CA, SA, FA |
| release | VF, BR, PR, MC |

### 6. Activation Protocol (required, numbered steps)

```markdown
## Activation Protocol
1. Load project config from `_bmad/config/config.yaml`
2. Read `CLAUDE.md` for project context
3. {Role-specific setup steps}
```

**Rules**:
- First two steps are always the same (load config, read CLAUDE.md)
- Subsequent steps are role-specific but technology-agnostic
- Reference paths from the boilerplate structure (`_bmad/`, `.claude/rules/`, `_bmad-output/`)
- Do NOT reference project-specific file names (no `app.py`, `models.py`, etc.)
- 4-7 steps total

### 7. Working Protocol (required, role-specific content)

```markdown
## Working Protocol
```

**Rules**:
- The section header is ALWAYS `## Working Protocol` — not "Implementation Protocol", "Test Patterns", "Review Checklist", or any variant
- Content varies by role but the header is uniform
- For review agents: include a checklist (using `- [ ]` format)
- For the developer: include implementation steps
- For the tester: include test writing methodology
- Reference the project's configured commands generically:
  - "the project's configured linter" (not "ruff" or "eslint")
  - "the project's test runner" (not "pytest" or "jest")
  - "the project's security scanner" (not "bandit" or "npm audit")
  - "the `/test` command" or "the `/lint` command" when referencing slash commands

### 8. Output Format (required)

```markdown
## Output Format
```

**Rules**:
- Contains a markdown template showing the exact structure of this agent's deliverable
- Specifies the file save location using `_bmad-output/` paths
- For review agents: must include a verdict line (PASS/FAIL or APPROVE/REQUEST_CHANGES)
- The template uses generic field names — no project-specific content
- The section header is ALWAYS `## Output Format` — not "PR Template", "Report Format", or any variant

### 9. Constraints (required, 4-6 bullets)

```markdown
## Constraints
- **NEVER** {forbidden action}
- **ALWAYS** {required action}
```

**Rules**:
- Every bullet starts with `**NEVER**` or `**ALWAYS**`
- First constraint should be the most important scope boundary (what this agent does NOT do)
- Must include:
  - Scope boundary: what belongs to a different agent
  - Tool restriction: what this agent must not modify
  - Decision authority limit: what decisions this agent cannot make
- 4-6 constraints total

### 10. Escalation (required, 2-4 bullets)

```markdown
## Escalation
- If {condition}, then {action}
```

**Rules**:
- Format: "If {condition}, then {action}"
- Must cover:
  - When input is insufficient or ambiguous
  - When the task exceeds this agent's scope
  - When repeated attempts fail
- Actions should be: ask the user, request revision from another agent, or stop and report

## Constraints on the Overall File

| Constraint | Value |
|------------|-------|
| Target length | 80–120 lines (excluding frontmatter) |
| Hard maximum | 150 lines |
| Project-specific technology references | NONE (no Python, React, C#, etc.) |
| Project-specific file references | NONE (no app.py, models.py, etc.) |
| Emojis | NONE |
| Generic tool references | Use "the project's linter", "the project's test runner", etc. |
| Config references | Use `_bmad/config/config.yaml`, `CLAUDE.md`, `.claude/rules/` |

## Validation Checklist

After generating an agent file, verify:

- [ ] Frontmatter has all required fields with valid values
- [ ] All 10 sections present, in the correct order
- [ ] Section headers match exactly (## Overview, ## Working Protocol, etc.)
- [ ] No project-specific technology or file references
- [ ] Capability codes are unique across the full agent team
- [ ] Tools list matches the role type from the Tool Assignment table
- [ ] Constraints include scope boundary, tool restriction, and authority limit
- [ ] Escalation covers: insufficient input, scope exceeded, repeated failure
- [ ] Total line count is within 80–150 range
- [ ] Voice is consistently second person, present tense
