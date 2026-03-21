# Debug & Hotfix Skills — Portable Template

> Copy this document into any BMAD-enabled project as a reference, or extract the individual
> file sections into `.claude/skills/debug/` and `.claude/skills/hotfix/`.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [/debug Skill](#debug-skill)
  - [SKILL.md](#debug--skillmd)
  - [workflow.md](#debug--workflowmd)
  - [step-01-triage.md](#debug--step-01-triagemd)
  - [step-02-investigate.md](#debug--step-02-investigatemd)
  - [step-03-fix.md](#debug--step-03-fixmd)
  - [step-04-verify.md](#debug--step-04-verifymd)
- [/hotfix Skill](#hotfix-skill)
  - [SKILL.md](#hotfix--skillmd)
- [Config Changes](#config-changes)
- [Setup Checklist](#setup-checklist)

---

## Overview

Two complementary workflows for bug resolution:

| Skill | When to Use | Pipeline | Stages |
|-------|------------|----------|--------|
| `/debug` | Root cause unknown — needs investigation | TRIAGE → INVESTIGATE → FIX → VERIFY → PR | 4 + PR |
| `/hotfix` | Root cause known — need to ship fast | FIX → VERIFY → PR | 3 |

Both reuse existing BMAD agents (no new agents needed):

| Stage | Agent | Role in Debug Context |
|-------|-------|-----------------------|
| Triage | Anna (analyst) | Bug classification, debug history lookup, regression detection |
| Investigate | Indrek (architect) | Code tracing, auto-bisect, MCP tools, container debugging |
| Fix | Madis (developer) | Minimal targeted fix + regression test in worktree |
| Verify | Katrin (tester) | Test suite, reproduction check, debug history save |
| PR | Meelis (release) | Final verification + PR creation |

Key features:
- **Debug history** — persistent memory of past bugs for recurring pattern detection
- **Auto-bisect** — `git bisect` with AI-generated scripts for regressions
- **MCP integration** — Browser DevTools, observability, database tools when available
- **Container debugging** — log inspection, health checks, endpoint testing
- **Escalation** — `/debug` can escalate to `/orchestrate` if architectural changes are needed
- **No parallel review** — skipped for speed; suggests `/code-review` in completion

---

## Prerequisites

- BMAD framework installed and `/setup` completed
- All 8 standard agents in `.claude/agents/`
- `_bmad/config/config.yaml` with branch patterns for `bugfix` and `hotfix`
- `gh` CLI authenticated for GitHub operations

---

## /debug Skill

### Directory Structure

```
.claude/skills/debug/
├── SKILL.md
├── workflow.md
└── steps/
    ├── step-01-triage.md
    ├── step-02-investigate.md
    ├── step-03-fix.md
    └── step-04-verify.md
```

---

### debug / SKILL.md

```markdown
---
name: debug
description: "Investigation-first bug resolution: triage → investigate → fix → verify → PR. Use when the user says /debug followed by an issue number, error description, or log output."
argument-hint: "<issue-number-or-error-description>"
user-invocable: true
---

# Debug — Investigation-First Bug Resolution

Resolve bugs through structured investigation before attempting fixes. Reproduces the issue,
diagnoses root cause using code tracing, git bisect, container logs, and available MCP tools,
then applies a minimal targeted fix with a regression test.

Follow the instructions in [workflow.md](workflow.md).
```

---

### debug / workflow.md

```markdown
---
main_config: '_bmad/config/config.yaml'
artifacts_dir: '_bmad-output'
debug_history_dir: '_bmad/debug-history'
---

# Debug Workflow

**Goal**: Resolve a bug through structured investigation, minimal fix, and verified regression test — then create a merge-ready PR.
**Your Role**: Orchestrator. You invoke agents sequentially, present results at gates, and manage retries and escalations.

## Workflow Architecture

- Investigation-first: understand before fixing
- 4 stages + PR creation, each with a human gate
- Reuses existing agents with debugging-specific instructions
- Auto-bisect for regressions, MCP tools and container logs when available
- Debug history for recurring pattern detection
- Escalation to `/orchestrate` if architectural changes are needed

## Artifact Structure

    _bmad-output/<issue>-<slug>/
    ├── STATE.yaml          # Workflow state and metadata
    ├── triage.md           # From analyst (Stage 1)
    └── investigation.md    # From architect (Stage 2)

    _bmad/debug-history/
    └── <issue>-<slug>.md   # Post-fix summary for future reference

## STATE.yaml Schema

    issue: <number>
    title: <title>
    workflow: debug
    state: triaging|investigating|fixing|verifying|cancelled|finished
    stage: triage|investigate|fix|verify|done
    severity: critical|high|medium|low|null
    branch: <branch-name or null>
    pr: <pr-number or null>
    root_cause: <brief description or null>
    is_regression: true|false|null
    bisect_commit: <commit hash or null>
    hypotheses_tested: 0
    reproduction_confirmed: true|false
    debug_tools_used: []
    created: <ISO timestamp>
    started: <ISO timestamp or null>
    finished: <ISO timestamp or null>
    retries: 0
    cancelled_reason: null
    agents_completed: []

## State Machine

                        ┌────────────────────────────────┐
                        │         [F] Fix (retries++)     │
                        ▼                                  │
    ┌─────────┐    ┌─────────────┐    ┌─────┐    ┌────────┐
    │ TRIAGE  │───▶│ INVESTIGATE │───▶│ FIX │───▶│ VERIFY │──▶ PR
    └─────────┘    └─────────────┘    └─────┘    └────────┘
         │              │                │            │
         │ [S]          │ [S]           │ [S]        │ [S]
         ▼              ▼               ▼            ▼
                            cancelled

## State Transitions

| Stage | Entry State | [C] Continue | [F] Fix | [S] Stop |
|-------|-------------|--------------|---------|----------|
| Triage | `triaging` | → Investigate | — | `cancelled` |
| Investigate | `investigating` | `fixing` | — | `cancelled` |
| Fix | `fixing` | `verifying` | — | `cancelled` |
| Verify | `verifying` | → PR + `finished` | `fixing` +retry | `cancelled` |

## Initialization

1. Load config from `_bmad/config/config.yaml`
2. Parse input: `$ARGUMENTS` — issue number, error description, or log output
3. If number: fetch issue via `gh issue view <N> --json title,body,labels,comments`
4. Create feature folder and initial STATE.yaml with `workflow: debug`

## STAGE 1: TRIAGE

Read and follow: [steps/step-01-triage.md](steps/step-01-triage.md)

## STAGE 2: INVESTIGATE

Read and follow: [steps/step-02-investigate.md](steps/step-02-investigate.md)

## STAGE 3: FIX

Read and follow: [steps/step-03-fix.md](steps/step-03-fix.md)

## STAGE 4: VERIFY

Read and follow: [steps/step-04-verify.md](steps/step-04-verify.md)

## Retry and Escalation Rules

- Maximum 3 retry loops back to FIX from VERIFY
- Retries 1-2: Use sonnet model (fast iteration)
- Retry 3: Escalate to opus model (deep reasoning)
- After retry 3 failure: STOP and notify user with:
  - Full error context and what was tried across all attempts
  - Root cause from investigation and each fix attempt
  - Current state of the branch (all commits pushed to origin)
  - STATE.yaml updated: `state: cancelled`, `cancelled_reason: "Max retries exceeded"`
  - User decides: fix manually, provide guidance, or escalate to `/orchestrate`

## Escalation to /orchestrate

If the INVESTIGATE stage reveals that the bug requires **architectural changes** (not just a targeted fix):
- The architect flags this in the investigation report
- Present the user with an additional gate option: **[O] Orchestrate** → escalate to `/orchestrate` with the investigation findings as context
- On escalation: set `state: cancelled`, `cancelled_reason: "Escalated to /orchestrate"`, and start `/orchestrate` with the triage and investigation documents as input

## Safety Rules

- Each stage must complete within its scope — no scope creep between stages
- If any gate is rejected with [S] Stop, update STATE.yaml and abort cleanly
- Never push to the main/master branch directly
- Never execute commands listed under `forbidden_commands` in project config
- Always update STATE.yaml on every gate decision
- Debug history entries are kept indefinitely — never prune automatically
```

---

### debug / step-01-triage.md

```markdown
# Step 1 of 4: TRIAGE

**Agent**: Anna (analyst) — model: opus
**Goal**: Classify the bug, check debug history for recurring patterns, and detect potential regressions.

## Execution

1. Create feature folder: `_bmad-output/<issue>-<slug>/`
   - `<slug>` = lowercase, hyphenated summary (e.g., `42-login-timeout`)
2. Create initial STATE.yaml (see schema in workflow.md) with `workflow: debug`, `state: triaging`, `stage: triage`
3. Invoke the **analyst** agent with the bug report (`$ARGUMENTS`)
4. The analyst:
   - Reads the bug report, error description, or log output
   - **Checks debug history**: Read `_bmad/debug-history/` for prior bugs in the same component or area
     - If recurring: flag the pattern and surface prior root causes and fixes
   - Classifies severity: CRITICAL / HIGH / MEDIUM / LOW
   - Identifies affected area (components, files, endpoints)
   - Formulates reproduction steps (from report or by inference)
   - **Checks git history** on affected files: `git log --oneline -20 -- <affected-paths>`
     - If recent changes exist in affected area: flag as potential regression
   - Generates 2-5 initial hypotheses ranked by likelihood
5. Save output to `_bmad-output/<issue>-<slug>/triage.md`:

   ---
   type: triage
   issue: <number>
   date: <today>
   severity: <level>
   is_regression: true|false
   ---
   # Triage: <title>
   ## Summary
   ## Severity
   ## Affected Area
   ## Reproduction Steps
   ## Debug History
   <Prior bugs in same area, or "No prior bugs recorded in this area.">
   ## Regression Check
   <Recent commits in affected files, or "No recent changes in affected files.">
   ## Initial Hypotheses
   1. <hypothesis> — likelihood: HIGH/MEDIUM/LOW

6. Update STATE.yaml: set `severity`, `is_regression`, add `analyst` to `agents_completed`

## Gate

Present the triage to the user. Display:
- Summary and severity
- Affected area
- Debug history matches (if any)
- Regression flag (if applicable)
- Initial hypotheses

**Menu**:
- **[C] Continue** → proceed to Step 2: INVESTIGATE
- **[E] Edit** → user provides additional context, re-run analyst
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `state: investigating`, `stage: investigate` |
| [E] Edit | no change, re-run analyst |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at triage"` |

## Next Step

On **Continue**: Read and follow `step-02-investigate.md`
```

---

### debug / step-02-investigate.md

```markdown
# Step 2 of 4: INVESTIGATE

**Agent**: Indrek (architect) — model: opus
**Goal**: Identify the root cause through code tracing, reproduction, and available debugging tools.

## Execution

1. Read the triage from `_bmad-output/<issue>-<slug>/triage.md`
2. Invoke the **architect** agent with the triage as input
3. The architect conducts investigation in this order:

### Core Investigation (always)
1. **Reproduce**: Attempt to trigger the bug using the project's test runner or by running the application
2. **Trace code paths**: Follow execution from the entry point through to the failure using code analysis tools (`find_symbol`, `find_referencing_symbols`, `get_symbols_overview`)
3. **Hypothesis testing**: For each hypothesis from triage, gather evidence to confirm or eliminate it
4. **Narrow root cause**: Identify the exact location (file:line) and mechanism of the bug

### Auto-Bisect Protocol (when `is_regression: true` in STATE.yaml)
1. Identify a known-good reference — the last commit before recent changes in the affected area (from triage git log)
2. Write a minimal reproduction script that exits 0 on success, exits 1 when the bug is present
3. Run: `git bisect start HEAD <good-commit>` then `git bisect run <script>`
4. Report the exact breaking commit with its diff
5. Update STATE.yaml: `bisect_commit: <hash>`
6. Focus remaining investigation on that commit's changes
7. If bisect is inconclusive, fall back to manual investigation

### Container Debugging Protocol (when project config indicates containerized deployment)
1. Check for container configuration (docker-compose files, Dockerfiles)
2. If a debug override file is configured, start services with it for verbose logging
3. Inspect container logs for errors related to the bug
4. Check container health and status
5. Test API endpoints directly against running services
6. Append `docker` to STATE.yaml `debug_tools_used`

### MCP Tool Integration (when MCP servers are available)
Check for available MCP tools and use whichever are relevant:
- **Browser DevTools MCP**: Capture console errors, network failures, screenshots, DOM state — use for frontend and UI bugs
- **Observability MCP** (Datadog, Grafana, etc.): Query error logs, traces, latency metrics — use for production and performance bugs
- **Database MCP**: Inspect data state, run read-only queries, check schema — use for data corruption and query bugs
- Append each tool used to STATE.yaml `debug_tools_used`

4. Update STATE.yaml: set `root_cause`, `hypotheses_tested`, `reproduction_confirmed`, add `architect` to `agents_completed`
5. Save output to `_bmad-output/<issue>-<slug>/investigation.md`:

   ---
   type: investigation
   issue: <number>
   inputDocuments:
     - _bmad-output/<issue>-<slug>/triage.md
   date: <today>
   ---
   # Investigation: <title>
   ## Root Cause
   <Exact location, mechanism, and evidence>
   ## Evidence
   | Source | Finding |
   |--------|---------|
   | Code trace | <file:line — what's wrong> |
   | Git bisect | <commit hash — what introduced it> |
   | Container logs | <relevant entries> |
   | MCP tools | <findings> |
   ## Hypotheses Tested
   | # | Hypothesis | Result | Evidence |
   |---|-----------|--------|----------|
   ## Suggested Fix
   <Minimal change description with file:line targets>
   ## Regression Test Approach
   <How to write a test that catches this specific bug>
   ## Architectural Concerns
   <If the bug reveals deeper design issues, describe them here. Otherwise: "None — targeted fix is sufficient.">

## Gate

Present the investigation report. Display:
- Root cause with evidence
- Bisect result (if regression)
- Debug tools used and their findings
- Suggested fix approach
- Architectural concerns (if any)

**Menu**:
- **[C] Continue** → proceed to Step 3: FIX
- **[E] Edit** → provide more context or request deeper investigation
- **[O] Orchestrate** → escalate to `/orchestrate` (only if architectural concerns were flagged)
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `state: fixing`, `stage: fix`, `started: <now>` |
| [E] Edit | no change, re-run architect with additional context |
| [O] Orchestrate | `state: cancelled`, `cancelled_reason: "Escalated to /orchestrate"` |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at investigate"` |

## On Orchestrate

Transfer to `/orchestrate` with the triage and investigation documents as prior context. The orchestrate pipeline starts at ANALYZE with these documents pre-loaded — the analyst can use them instead of starting from scratch.

## Next Step

On **Continue**: Read and follow `step-03-fix.md`
```

---

### debug / step-03-fix.md

```markdown
# Step 3 of 4: FIX

**Agent**: Madis (developer) — model: sonnet, isolation: worktree
**Goal**: Apply a minimal targeted fix with a regression test.

## Execution

1. Read the investigation from `_bmad-output/<issue>-<slug>/investigation.md`
2. Check if this is a retry:
   - If coming from VERIFY with [F] Fix, STATE.yaml already has `retries` incremented
   - Read the verification failure details as additional context
3. Invoke the **developer** agent with the investigation report
4. The developer:
   - Creates `fix/<issue>-<slug>` branch in worktree (using configured bugfix branch pattern)
   - Applies **minimal targeted fix** — change only what's necessary to resolve the root cause
   - Writes a **regression test** following the red-green approach:
     - Test must fail without the fix (confirms it catches the bug)
     - Test must pass with the fix (confirms the fix works)
     - Test targets the root cause specifically, not just the symptom
   - Runs the project's configured test suite — ensure no new failures
   - If containers are available and were used during investigation: verify fix works in the containerized environment
   - Validates with the project's linter
   - Commits with `fix(<scope>): <description>`
   - Pushes to origin
5. Update STATE.yaml:
   - Set `branch: <branch-name>` (if not already set)
   - Add `developer` to `agents_completed` (if not already present)
6. Developer reports: files changed, branch name, regression test added

## Gate

Present the fix summary. Display:
- Branch name
- Git diff summary (files changed, insertions, deletions)
- Regression test name and what it verifies
- Test suite results
- Linter results

**Menu**:
- **[C] Continue** → proceed to Step 4: VERIFY
- **[E] Edit** → user provides feedback, developer adjusts the fix
- **[S] Stop** → abort (branch preserved on origin for manual review)

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `state: verifying`, `stage: verify` |
| [E] Edit | no change, developer continues |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at fix"` |

## Retry Tracking

This step may be revisited from Step 4 (VERIFY):
- Retry 1-2: Use sonnet model
- Retry 3 (escalation): Use opus model
- After retry 3 failure: STOP and notify user (see escalation rules in workflow.md)

## Next Step

On **Continue**: Read and follow `step-04-verify.md`
```

---

### debug / step-04-verify.md

```markdown
# Step 4 of 4: VERIFY

**Agent**: Katrin (tester) — model: sonnet
**Goal**: Verify the fix resolves the bug, run regressions, and save to debug history.

## Execution

1. Invoke the **tester** agent on the developer's fix branch
2. The tester:
   - Runs the project's configured test suite including the new regression test
   - Verifies the original reproduction steps no longer trigger the bug
   - Checks for side effects in related functionality
   - Pushes any additional test commits to the same branch on origin
3. Update STATE.yaml: add `tester` to `agents_completed`
4. Report verification results

## Gate

Present verification results. Display:
- Test results: X passed, Y failed, Z skipped
- Regression test: PASS / FAIL
- Reproduction check: bug resolved / still present
- Side effects: none found / concerns

**Menu**:
- **[D] Done** → create PR and save to debug history
- **[F] Fix** → verification failed, loop back to Step 3 for another fix attempt
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [D] Done | `state: finished`, `stage: done`, `finished: <now>` |
| [F] Fix | `state: fixing`, `stage: fix`, `retries: +1` |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at verify"` |

## On Fix

Return to `step-03-fix.md` with the verification failure details as context.
Increment retry counter in STATE.yaml.

Check retry count:
- If `retries < 3`: Continue with sonnet
- If `retries == 3`: Escalate to opus for final attempt
- If `retries > 3`: STOP and notify user (see escalation rules in workflow.md)

## On Done

### 1. Save to Debug History

Write `_bmad/debug-history/<issue>-<slug>.md`:

    ---
    issue: <number>
    date: <today>
    component: <affected component or module>
    severity: <level>
    category: <regression|logic-error|data-corruption|config|dependency|race-condition|other>
    root_cause: <one-line summary>
    fix_commit: <commit hash>
    ---
    # Bug: <title>
    ## Root Cause
    <one-line summary from investigation>
    ## Fix
    <file:line — what was changed and why>
    ## Regression Test
    <test file : test name>
    ## Pattern Notes
    <anything useful for future debugging in this area, or "None">

If 3+ bugs in the same component exist in debug history, append a warning:
> "Recurring bug pattern detected in `<component>`. Consider structural review or dedicated integration tests."

### 2. Create PR

Invoke the **release** (Meelis) agent to:
- Run final verification suite (test + lint + security)
- Check for merge conflicts with the main branch
- Create PR via `gh pr create` with bug-fix template:
  - Root cause summary (from investigation)
  - Fix description with files changed
  - Regression test added
  - `Fixes #<issue>`
- Update STATE.yaml: `pr: <number>`, add `release` to `agents_completed`

### 3. Completion

Report to the user:
- Pipeline complete for bug #<N>
- PR: <URL>
- Branch: <branch-name>
- Root cause: <summary>
- Debug history saved to `_bmad/debug-history/<issue>-<slug>.md`
- Agents involved: Anna → Indrek → Madis → Katrin → Meelis
- Total retries: <N>
- Suggest: "Run `/code-review` for a full code review if the fix is non-trivial."
```

---

## /hotfix Skill

### Directory Structure

```
.claude/skills/hotfix/
└── SKILL.md
```

---

### hotfix / SKILL.md

```markdown
---
name: hotfix
description: "Emergency fast-track fix: skip investigation, apply fix → verify → PR. Use when the user says /hotfix followed by an issue number or fix description."
argument-hint: "<issue-number-or-fix-description>"
user-invocable: true
---

# Hotfix — Emergency Fast-Track Fix

Apply an urgent fix when the root cause is already known. Skips triage and investigation
for maximum speed. Creates a `hotfix/` branch, applies the fix with a regression test,
runs verification, and creates a PR.

Use `/debug` instead when the root cause is unknown and investigation is needed.

## Steps

### Step 1: FIX

1. Load project config from `_bmad/config/config.yaml`
2. Parse input: `$ARGUMENTS` — issue number or fix description
3. If number: fetch issue via `gh issue view <N> --json title,body,labels,comments`
4. Invoke the **developer** (Madis) agent in a worktree
5. The developer:
   - Creates `hotfix/<issue>-<slug>` branch (using configured hotfix branch pattern)
   - Applies the minimal fix based on the user's description or issue
   - Writes a regression test that catches the specific bug
   - Runs the project's test suite
   - Validates with the project's linter
   - Commits with `fix(<scope>): <description>`
   - Pushes to origin

**GATE**: Show the fix diff, regression test, and test results.
- **[C] Continue** → proceed to verification
- **[E] Edit** → user provides feedback, developer adjusts
- **[S] Stop** → abort (branch preserved on origin)

**HALT**: Wait for user selection before proceeding.

### Step 2: VERIFY

1. Run the combined verification suite: test + lint + security (same as `/verify`)
2. Report consolidated results

**GATE**: Show verification results.
- **[C] Continue** → proceed to PR creation
- **[F] Fix** → loop back to Step 1 (max 2 retries)
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

### Step 3: RELEASE

1. Invoke the **release** (Meelis) agent
2. Check for merge conflicts with the main branch
3. Create PR via `gh pr create` with hotfix template:
   - Hotfix summary
   - Files changed
   - Regression test added
   - `Fixes #<issue>` (if issue number provided)
4. Report PR URL

## Completion

- PR URL: <link>
- Branch: `hotfix/<issue>-<slug>`
- All commits pushed to origin
- Suggest: "Run `/code-review` for a full code review if the fix touches critical code."
```

---

## Config Changes

Add these optional sections to `_bmad/config/config.yaml`:

```yaml
debug:
  history_dir: _bmad/debug-history    # Where debug investigation summaries are stored
  container_debug:                     # Container debugging support (auto-detected from deployment)
    compose_file: ""                   # docker-compose file path (empty = auto-detect)
    debug_overrides: ""                # docker-compose override file with debug/verbose flags
```

Ensure `branch_patterns` includes:

```yaml
branch_patterns:
  feature: "feat/{issue}-{description}"
  bugfix: "fix/{issue}-{description}"
  hotfix: "hotfix/{issue}-{description}"
```

---

## Setup Checklist

When adding these skills to a new project:

- [ ] Copy `skills/debug/` → `.claude/skills/debug/` (6 files)
- [ ] Copy `skills/hotfix/` → `.claude/skills/hotfix/` (1 file)
- [ ] Create `_bmad/debug-history/` directory
- [ ] Add `debug` section to `_bmad/config/config.yaml`
- [ ] Verify `branch_patterns` includes `bugfix` and `hotfix` entries
- [ ] Add `/debug` and `/hotfix` to the CLAUDE.md slash commands table
- [ ] Add container log permissions to `.claude/settings.local.json` (if using Docker)
- [ ] Add `git bisect` permission to `.claude/settings.local.json`: `"Bash(git bisect:*)"`
