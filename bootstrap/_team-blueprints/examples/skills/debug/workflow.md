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

```
_bmad-output/<issue>-<slug>/
├── STATE.yaml          # Workflow state and metadata
├── triage.md           # From analyst (Stage 1)
└── investigation.md    # From architect (Stage 2)

_bmad/debug-history/
└── <issue>-<slug>.md   # Post-fix summary for future reference
```

## STATE.yaml Schema

```yaml
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
```

## State Machine

```
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
```

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
