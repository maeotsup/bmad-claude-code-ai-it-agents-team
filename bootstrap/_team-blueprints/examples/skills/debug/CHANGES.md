# Debug & Hotfix Workflows — Implementation Summary

## Overview

Added 4 new skills to the BMAD framework introducing investigation-first bug resolution,
emergency hotfix fast-track, and asynchronous client communication via GitHub issue comments.

## New Skills

### `/debug` — Investigation-First Bug Resolution (complex skill)

**Purpose**: Resolve bugs through structured investigation before attempting fixes.
Unlike `/orchestrate` which assumes you know what to build, `/debug` starts by understanding what's broken.

**Pipeline**: TRIAGE → INVESTIGATE → FIX → VERIFY → PR (4 stages + PR creation)

**Key features**:
- **Debug history** — checks `_bmad/debug-history/` for recurring bugs in the same component. After a verified fix, saves a summary for future reference. Flags recurring patterns with structural review warnings. Entries kept indefinitely.
- **Auto-bisect** — when triage detects a regression (recent changes in affected files), the investigation stage runs `git bisect` with an AI-generated reproduction script to find the exact breaking commit.
- **MCP tool integration** — investigation stage detects available MCP servers and uses them: Browser DevTools for frontend bugs, observability tools (Datadog/Grafana) for production issues, database MCP for data corruption bugs.
- **Container debugging** — when the project uses containerized deployment, investigation spins up services with debug flags, inspects container logs, and tests endpoints against running containers.
- **Escalation to `/orchestrate`** — if investigation reveals the bug requires architectural changes (not just a targeted fix), offers `[O] Orchestrate` gate option to escalate with triage and investigation documents as context.
- **Minimal fixes** — targets 2-3 line fixes with regression tests, not speculative rewrites.
- **No parallel review stage** — skipped for speed. Suggests `/code-review` in completion message for non-trivial fixes.

**Files**:
```
skills/debug/
├── SKILL.md
├── workflow.md
└── steps/
    ├── step-01-triage.md
    ├── step-02-investigate.md
    ├── step-03-fix.md
    └── step-04-verify.md
```

**Agents reused** (no new agents created):
| Stage | Agent | Why |
|-------|-------|-----|
| Triage | Anna (analyst) | Already does issue analysis and classification |
| Investigate | Indrek (architect) | Has code-tracing tools, dependency analysis, read-only |
| Fix | Madis (developer) | Has FX capability, worktree isolation |
| Verify | Katrin (tester) | Has DG (diagnose) and RG (red-green) capabilities |
| PR | Meelis (release) | Standard PR creation |

**STATE.yaml extensions** for debug workflow:
```yaml
workflow: debug
severity: critical|high|medium|low|null
root_cause: <string or null>
is_regression: true|false|null
bisect_commit: <commit hash or null>
hypotheses_tested: 0
reproduction_confirmed: true|false
debug_tools_used: []
```

---

### `/hotfix` — Emergency Fast-Track (simple skill)

**Purpose**: Apply urgent fixes when the root cause is already known. Maximum speed, minimum overhead.

**Pipeline**: FIX → VERIFY → PR (3 steps, no triage or investigation)

**Key features**:
- Uses `hotfix/` branch pattern (distinct from `fix/` for regular bugs)
- No document generation — zero overhead
- Max 2 retries on verify failure
- Suggests `/code-review` for critical code in completion

**Files**: `skills/hotfix/SKILL.md`

---

### `/propose` — Async Client Communication (simple skill)

**Purpose**: Post analysis and design as GitHub issue comments for asynchronous client review.
Enables non-technical stakeholders to participate through GitHub.

**Pipeline**: ANALYZE → DESIGN → POST TO ISSUE (3 steps)

**Key features**:
- Runs analyst and architect locally, sanitizes output for client-facing format (business-level, no internal file paths)
- Posts combined proposal as a GitHub issue comment via `gh issue comment`
- Adds `awaiting-client-review` label to the issue
- Requires `async.enabled: true` in config

**Files**: `skills/propose/SKILL.md`

---

### `/resume` — Continue After Client Feedback (simple skill)

**Purpose**: Check GitHub issue for client feedback on a `/propose` plan, then continue or revise.

**Pipeline**: CHECK FEEDBACK → IMPLEMENT → TEST → PR + NOTIFY (4 steps, conditional)

**Key features**:
- Detects approval vs change requests vs no response from issue comments
- Approval signals configurable in `config.yaml` (`LGTM`, `Approved`, `Looks good`)
- On changes requested: offers [R] Revise to re-run analysis with feedback, then re-post
- On approval: continues to implementation, testing, PR creation
- Posts follow-up comment on issue when PR is created, notifying client

**Files**: `skills/resume/SKILL.md`

---

## Modified Files

### `schemas/config.schema.md`

Added two optional sections to the `config.yaml` schema:

```yaml
debug:
  history_dir: _bmad/debug-history
  container_debug:
    compose_file: ""
    debug_overrides: ""

async:
  enabled: false
  comment_prefix: "## "
  approval_signals: ["LGTM", "Approved", "Looks good"]
```

Updated rules for `settings.local.json` to include GitHub CLI and container log permissions.

Updated CLAUDE.md schema section 7 to reference debug/hotfix commands and section 9 to include `_bmad/debug-history/`.

---

## Architecture Decisions

### No new agents
All four skills reuse existing agents with debugging/async-specific instructions in step files. The architect (Indrek) is the investigator — already has the right tools (symbol tracing, dependency analysis) and mindset (read-only, systematic).

### Debug history kept indefinitely
Files are small (~20 lines each), and recurring pattern detection becomes more valuable over time. No automatic pruning.

### Parallel review skipped in `/debug`
Speed matters for bug fixes. Suggest `/code-review` in completion for non-trivial fixes instead of mandating it.

### `/propose` + `/resume` separation
Instead of a `--async` flag on existing skills, two distinct skills provide a clear mental model: propose pauses after posting, resume picks up after feedback. STATE.yaml bridges the gap.

### `[O] Orchestrate` escalation
Available only when the investigation flags architectural concerns. Transfers triage and investigation documents as prior context so the orchestrate pipeline doesn't start from scratch.

---

## Setup Integration Required

When implementing `/setup` support for these features, the setup process should:

1. Create `_bmad/debug-history/` directory
2. Add `debug` section to generated `config.yaml`
3. Auto-detect container configuration for `container_debug`
4. Add `/debug`, `/hotfix`, `/propose`, `/resume` to the CLAUDE.md slash commands table
5. Add container/GitHub CLI permissions to `settings.local.json`
6. Add `async` section to config if user wants client communication workflows

---

## How to Apply to Other Projects

Copy the following files into your project's `.claude/skills/` directory after running `/setup`:

```
skills/debug/       → .claude/skills/debug/
skills/hotfix/      → .claude/skills/hotfix/
skills/propose/     → .claude/skills/propose/
skills/resume/      → .claude/skills/resume/
```

Then add the following to your `_bmad/config/config.yaml`:

```yaml
debug:
  history_dir: _bmad/debug-history
  container_debug:
    compose_file: ""
    debug_overrides: ""
```

Create the debug history directory: `mkdir -p _bmad/debug-history`

And update your `CLAUDE.md` to list the new slash commands.
