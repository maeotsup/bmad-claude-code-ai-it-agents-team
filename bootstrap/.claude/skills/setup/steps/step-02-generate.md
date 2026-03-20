# Step 2 of 3: GENERATE

**Goal**: Generate all `.claude/` configuration files tailored to the confirmed Stack Profile.
Follow the generation protocol for each file type to ensure consistency.

**Input**: Confirmed Stack Profile from Step 1.

## Generation Protocol

For EVERY file you generate, follow this exact process:

### Step A: Read the Schema
Read the schema from `_team-blueprints/schemas/{type}.schema.md` for the file type
you are about to generate. This is your structural contract — follow it exactly.

### Step B: Study the Golden Example
Read the golden example from `_team-blueprints/examples/{type}/` to calibrate
tone, depth, and style. Match the example's quality and approach.

### Step C: Read the Stack Knowledge
Read the relevant `_team-blueprints/stacks/{language}.md` and `_team-blueprints/stacks/{framework}.md`
files for this project's detected stack. Extract specific tools, commands, conventions, and patterns.

### Step D: Generate
Write the file following the schema EXACTLY:
- Every required section present, in the specified order
- Stack-specific content woven in from Step C
- Line count within the schema's limits
- No placeholder text left behind — every section has real content

### Step E: Self-Validate
Before moving to the next file, verify:
- All required sections present and in correct order?
- Frontmatter fields correct and complete?
- No leftover template markers or TODOs?
- Line count within limits?
- Tools listed are real and available in this project?

---

## Generation Order

Generate files in this exact order. Each group can be generated in parallel within the group,
but groups must be sequential (later groups may reference earlier files).

### Group 1: Project Configuration

**1.1 — `_bmad/config/config.yaml`**

Read schema from `_team-blueprints/schemas/config.schema.md` (if available) or use this structure:

```yaml
# {Project Name} — BMAD Project Configuration
project_name: {from Stack Profile or directory name}
description: {brief description from detection/interview}

# User
user_name: {detect from git config user.name, or ask}

# Tech Stack
languages: [{detected languages}]
frameworks: [{detected frameworks}]
package_manager: {detected package manager}
database: {detected or "none"}
deployment: {detected or "none"}

# Paths
artifacts_dir: _bmad-output
project_docs: docs

# Model Routing
models:
  thinking: opus     # analyst, architect — deep reasoning
  execution: sonnet  # developer, tester, reviewers — fast execution

# Safety
forbidden_files: [{stack-specific patterns, e.g., "*.db", "models/", ".env"}]
forbidden_commands: [{stack-specific, e.g., "git push --force origin master"}]

# Branch Naming
branch_patterns:
  feature: "feat/{issue}-{description}"
  bugfix: "fix/{issue}-{description}"
  hotfix: "hotfix/{issue}-{description}"
```

Create directories: `_bmad/config/`, `_bmad-output/`.

### Group 2: Rules and Commands

**2.1 — `.claude/rules/safety.md`**
- Read: `schemas/rule.schema.md` + `examples/rules/safety.md`
- Start with the universal safety rules from the example
- Add project-specific forbidden actions from the config (e.g., dangerous commands for this stack)

**2.2 — `.claude/rules/{language}.md`** (one per detected language)
- Read: `schemas/rule.schema.md` + `examples/rules/language-template.md` + `stacks/{language}.md`
- Generate language-specific conventions using the stack knowledge file

**2.3 — `.claude/rules/{framework}.md`** (one per detected framework)
- Read: `schemas/rule.schema.md` + `stacks/{framework}.md`
- Generate framework-specific conventions

**2.4 — `.claude/rules/testing.md`**
- Read: `schemas/rule.schema.md` + stack knowledge for the project's test runner
- Generate test patterns and conventions

**2.5 — `.claude/commands/build.md`**
- Read: `schemas/command.schema.md` + `examples/commands/build.md` + stack knowledge
- Generate with the ACTUAL build command for this project (from Stack Profile)

**2.6 — `.claude/commands/test.md`**
- Read: `schemas/command.schema.md` + `examples/commands/test.md` + stack knowledge
- Generate with the ACTUAL test command

**2.7 — `.claude/commands/lint.md`**
- Read: `schemas/command.schema.md` + `examples/commands/lint.md` + stack knowledge
- Generate with the ACTUAL lint command

**2.8 — `.claude/commands/security.md`**
- Read: `schemas/command.schema.md` + `examples/commands/security.md` + stack knowledge
- Generate with the ACTUAL security scan command (or recommend one if none detected)

### Group 3: Agents

Generate all 8 agents. For each:
- Read: `schemas/agent.schema.md` + `examples/agents/{role}.md` + stack knowledge
- Follow the schema's 10-section structure exactly
- Customize: add stack-specific tools, domain knowledge, and conventions
- MCP tools: add available MCP tools to relevant agents' tool lists
- For web projects: include the accessibility agent. For non-web: still generate it
  but note in its description that it activates only when UI files are changed.

**3.1** — `.claude/agents/analyst.md` (Anna)
**3.2** — `.claude/agents/architect.md` (Indrek)
**3.3** — `.claude/agents/developer.md` (Madis)
**3.4** — `.claude/agents/tester.md` (Katrin)
**3.5** — `.claude/agents/code-reviewer.md` (Liisa)
**3.6** — `.claude/agents/security-reviewer.md` (Priit)
**3.7** — `.claude/agents/accessibility.md` (Marika)
**3.8** — `.claude/agents/release.md` (Meelis)

### Group 4: Skills

Copy the skill files from `_team-blueprints/examples/skills/` with minimal modification.
Skills are largely stack-agnostic — they reference agents and commands by name, not by
specific tools.

**What to copy as-is** (these are universal):
- `skills/orchestrate/` — entire directory (SKILL.md + workflow.md + steps/)
- `skills/plan/SKILL.md`
- `skills/implement/SKILL.md`
- `skills/tdd/SKILL.md`
- `skills/code-review/SKILL.md`
- `skills/verify/SKILL.md`
- `skills/pre-pr/SKILL.md`
- `skills/issue/SKILL.md`

**Remove** the setup skill directory (`.claude/skills/setup/`) — it's no longer needed after generation.

### Group 5: Hooks and Settings

**5.1 — `.claude/hooks/pre_bash_guard.py`**
- Read: `schemas/hook.schema.md` + `examples/hooks/pre_bash_guard.py` + stack knowledge
- Start with universal blocked patterns from the example
- Add stack-specific patterns from the stack knowledge files
- Add project-specific patterns from `forbidden_commands` in config.yaml

**5.2 — `.claude/hooks/post_edit_lint.py`**
- Read: `schemas/hook.schema.md` + `examples/hooks/post_edit_lint.py` + stack knowledge
- Set `LINT_COMMAND` from the stack knowledge file's hook configuration section
- Set `FILE_EXTENSIONS` from the stack knowledge file

**5.3 — `.claude/settings.json`**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/pre_bash_guard.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/post_edit_lint.py",
            "async": true
          }
        ]
      }
    ]
  }
}
```

**5.4 — `.claude/settings.local.json`**
- Read the Permission Whitelist section from relevant stack knowledge files
- Combine into a clean, intentional permissions list:
```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(gh issue view:*)",
      "{stack-specific permissions from stack knowledge files}"
    ]
  }
}
```
- Add MCP server enablement if applicable:
```json
{
  "enableAllProjectMcpServers": true
}
```

### Group 6: CLAUDE.md

**6.1 — `CLAUDE.md`** (replaces the bootstrap CLAUDE.md)

This is the most project-specific file. Generate it based on the Stack Profile and
everything discovered in Step 1. Structure:

```markdown
# {Project Name}

{Brief description}

## Tech Stack
{Languages, frameworks, database, deployment — from Stack Profile}

## Key Files
| File | Purpose |
|------|---------|
{Key files discovered during detection, or expected structure for new projects}

## Running Locally
{Dev server command, build command, Docker command if applicable}

## Running Tests
{Test command with options for filtering, slow tests, etc.}

## Conventions
{Key conventions from generated rules — summary, not duplication}

## Custom Slash Commands

### Tool Commands
| Command | Description |
|---------|-------------|
| `/build` | {actual build action} |
| `/test` | {actual test action} |
| `/lint` | {actual lint action} |
| `/security` | {actual security scan action} |

### SDLC Pipeline Commands
| Command | Description |
|---------|-------------|
| `/orchestrate <issue>` | Full pipeline: analyze → design → implement → test → review → PR |
| `/plan <issue>` | Requirements analysis + architecture design (no code) |
| `/implement` | Execute an existing architect plan |
| `/tdd <requirement>` | Test-driven development: red → green → refactor |
| `/code-review` | Review current changes (quality + security + accessibility) |
| `/verify` | Combined test + lint + security scan |
| `/pre-pr` | Full review pipeline + PR creation |
| `/issue <number>` | Quick triage of a GitHub issue |

### SDLC Agents
| Agent | Name | Model | Role |
|-------|------|-------|------|
| analyst | Anna | opus | Requirements analysis, issue triage |
| architect | Indrek | opus | System design, codebase tracing |
| developer | Madis | sonnet | Implementation (worktree isolated) |
| tester | Katrin | sonnet | Test writing and execution |
| code-reviewer | Liisa | sonnet | Code quality and architecture review |
| security-reviewer | Priit | sonnet | Security audit (OWASP, CWE) |
| accessibility | Marika | sonnet | WCAG 2.1 AA compliance (web projects) |
| release | Meelis | sonnet | Verification and PR creation |

### SDLC Artifacts
- Artifacts: `_bmad-output/` (per-issue subdirectories)
- Config: `_bmad/config/config.yaml`
```

---

## Cleanup

After all files are generated:

1. **Remove** the `_team-blueprints/` directory — it was only needed for generation
2. **Remove** `.claude/skills/setup/` — the setup skill is no longer needed
3. **Remove** `.claude/commands/setup.md` — the setup command is no longer needed
4. **Keep** everything else generated

---

## Next Step

Read and follow `step-03-verify.md` to validate all generated files.
