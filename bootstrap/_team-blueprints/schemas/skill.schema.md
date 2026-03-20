# Skill Definition Schema

Skills are multi-step workflows invoked via slash commands (e.g., `/orchestrate`, `/plan`).
They coordinate agents, manage state, and present human approval gates.

## Skill Types

| Type | Structure | Description |
|------|-----------|-------------|
| **Complex** | `SKILL.md` + `workflow.md` + `steps/` | Multi-stage pipeline with state machine (e.g., orchestrate) |
| **Simple** | `SKILL.md` only | Self-contained workflow with 2-4 steps (e.g., plan, verify) |

## Directory Structure

```
.claude/skills/
├── orchestrate/              # Complex skill
│   ├── SKILL.md              # Entry point with frontmatter
│   ├── workflow.md           # State machine and architecture
│   └── steps/
│       ├── step-01-analyze.md
│       ├── step-02-design.md
│       └── ...
├── plan/                     # Simple skill
│   └── SKILL.md
└── verify/                   # Simple skill
    └── SKILL.md
```

## SKILL.md — Entry Point (required for all skills)

### Frontmatter (required)

```yaml
---
name: {skill-name}
description: "{what this skill does}. Use when the user says /{name} {arguments}."
argument-hint: "<argument-description>"   # Omit if no arguments needed
user-invocable: true
---
```

| Field | Rules |
|-------|-------|
| `name` | Matches directory name |
| `description` | One line. Starts with verb. Ends with invocation trigger. |
| `argument-hint` | Optional. Shows in help. Example: `"<issue-number-or-description>"` |
| `user-invocable` | Always `true` for skills the user calls directly |

### Body

For **complex skills**: Brief description + link to workflow.md
```markdown
# {Name} — {Subtitle}

{2-3 sentence description of what this skill does end-to-end.}

Follow the instructions in [workflow.md](workflow.md).
```

For **simple skills**: Full workflow inline (see Simple Skill Structure below)

## workflow.md — State Machine (complex skills only)

### Required Sections

1. **Frontmatter**: Config paths
2. **Goal Statement**: One sentence describing the end-to-end objective
3. **Role Statement**: "Your Role: Orchestrator" — clarifies Claude's function
4. **Workflow Architecture**: Bullet summary of how stages connect
5. **Artifact Structure**: Directory layout for outputs
6. **STATE.yaml Schema**: Full schema definition
7. **State Machine Diagram**: ASCII art showing state transitions
8. **State Transition Table**: Tabular reference for each stage's transitions
9. **Initialization Steps**: How the workflow starts
10. **Stage References**: One section per stage, linking to step files
11. **Retry and Escalation Rules**: Max retries, model escalation, abort conditions
12. **Safety Rules**: What the orchestrator must never do

### STATE.yaml Schema

Every complex skill tracks state with this schema:

```yaml
issue: <number>
title: <title>
state: planning|in_progress|testing|review|cancelled|finished
stage: <current-stage-name>
branch: <branch-name or null>
pr: <pr-number or null>
created: <ISO timestamp>
started: <ISO timestamp or null>
finished: <ISO timestamp or null>
retries: <count>
cancelled_reason: <string or null>
agents_completed: [<agent-names>]
```

### Retry Logic (standard)

- Maximum 3 retry loops back to implementation
- Retries 1-2: Use `sonnet` model (fast execution)
- Retry 3: Escalate to `opus` model (deep reasoning)
- After retry 3 failure: STOP and notify user with full context

## Step Files — Stage Definitions (complex skills only)

### File Naming

`step-{NN}-{stage-name}.md` (e.g., `step-01-analyze.md`)

### Required Sections

```markdown
# Step {N} of {total}: {STAGE NAME}

**Agent**: {Name} ({role}) — model: {model}
**Goal**: {One sentence describing this step's output}

## Execution
{Numbered steps for what the agent does}

## Gate
{What to present to the user}

**Menu**:
- **[C] Continue** → {next step}
- **[E] Edit** → {re-run with feedback}
- **[F] Fix** → {loop back, if applicable}
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

## State Updates
{Table mapping each menu choice to STATE.yaml changes}

## Next Step
On **Continue**: Read and follow `step-{NN+1}-{next}.md`
```

### Gate Menu Options

| Option | When Available | Meaning |
|--------|---------------|---------|
| **[C] Continue** | Always | Approve and proceed to next stage |
| **[E] Edit** | Analysis/design stages | Provide feedback, re-run the same agent |
| **[F] Fix** | Test/review stages | Loop back to implementation with findings |
| **[S] Stop** | Always | Abort the workflow cleanly |
| **[D] Done** | Final stage only | Mark workflow complete |

**CRITICAL**: Every gate includes `**HALT**: Wait for user selection before proceeding.`
This prevents auto-advancement without human approval.

## Simple Skill Structure

Simple skills put everything in a single SKILL.md:

```markdown
---
name: {name}
description: "{description}"
argument-hint: "{args}"    # if needed
user-invocable: true
---

# {Name} Workflow

{2-3 sentence description}

## Steps

### Step 1: {NAME}
{What to do}

**GATE**: {What to show the user and menu options}

### Step 2: {NAME}
{What to do}

## Completion
{What to report when done}
```

### Rules for Simple Skills

- 2-4 steps typical
- Each step has an optional gate (not all steps need user approval)
- Reference agents by name (the agent file defines their behavior)
- Reference project commands generically ("the project's test command")
- End with a Completion section explaining outputs and next steps

## Constraints on Skill Files

| Constraint | Value |
|------------|-------|
| SKILL.md target length | 10-20 lines (complex) or 40-80 lines (simple) |
| workflow.md target length | 80-120 lines |
| Step file target length | 40-70 lines |
| Hardcoded CLI commands | NONE — reference `/command` patterns or agent capabilities |
| Technology references | NONE — skills are stack-agnostic |
| Gate requirement | Every step with user-visible output MUST have a gate with HALT |

## Validation Checklist

- [ ] SKILL.md has valid frontmatter (name, description, user-invocable: true)
- [ ] Complex skills: workflow.md exists with all required sections
- [ ] Complex skills: step files follow `step-{NN}-{name}.md` naming
- [ ] Every gate has a HALT instruction
- [ ] Gate menus use the standard [C]/[E]/[F]/[S]/[D] options
- [ ] STATE.yaml schema is complete with all required fields
- [ ] Retry logic follows the standard (3 max, sonnet→opus escalation)
- [ ] No hardcoded technology-specific commands
- [ ] Each step references the correct agent by name
- [ ] State transition table covers all menu options for each stage
