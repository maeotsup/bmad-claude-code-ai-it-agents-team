---
main_config: '_bmad/config/config.yaml'
artifacts_dir: '_bmad-output'
---

# Orchestrate Workflow

**Goal**: Take a GitHub issue or requirement from analysis through to a merge-ready PR.
**Your Role**: Orchestrator. You invoke agents sequentially, present results at gates, and manage retries and escalations.

## Workflow Architecture

- Each stage invokes a specific agent from `.claude/agents/`
- Stages are sequential except the PARALLEL REVIEW stage
- Human gates between each stage (menu-gated progression)
- State tracked via STATE.yaml in `_bmad-output/<issue>-<slug>/`
- Maximum 3 retries on implementation, then escalation to opus

## Artifact Structure

```
_bmad-output/<issue>-<slug>/
├── STATE.yaml       # Workflow state and metadata
├── requirements.md  # From analyst (Stage 1)
├── architecture.md  # From architect (Stage 2)
└── review-notes.md  # Optional: combined review feedback
```

## STATE.yaml Schema

```yaml
issue: <number>
title: <title>
state: planning|in_progress|testing|review|cancelled|finished
stage: analyze|design|implement|test|review|release|done
branch: <branch-name or null>
pr: <pr-number or null>
created: <ISO timestamp>
started: <ISO timestamp or null>
finished: <ISO timestamp or null>
retries: 0
cancelled_reason: null
agents_completed: []
```

## State Machine

```
                    ┌─────────────────────────────────────────────┐
                    │              [F] Fix (retries++)            │
                    ▼                                             │
┌─────────┐    ┌───────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│ planning│───▶│in_progress│───▶│ testing │───▶│ review  │───▶│finished │
└─────────┘    └───────────┘    └─────────┘    └─────────┘    └─────────┘
     │              │                │              │
     │ [S]          │ [S]            │ [S]          │ [S]
     ▼              ▼                ▼              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              cancelled                                   │
└─────────────────────────────────────────────────────────────────────────┘
```

## State Transitions

| Stage | Entry State | [C] Continue | [F] Fix | [S] Stop |
|-------|-------------|--------------|---------|----------|
| Analyze | `planning` | → Design | — | `cancelled` |
| Design | `planning` | `in_progress` | — | `cancelled` |
| Implement | `in_progress` | `testing` | — | `cancelled` |
| Test | `testing` | `review` | `in_progress` +retry | `cancelled` |
| Review | `review` | → Release | `in_progress` +retry | `cancelled` |
| Release | `review` | `finished` | — | `cancelled` |

## Initialization

1. Load config from `_bmad/config/config.yaml`
2. Parse input: `$ARGUMENTS` — issue number or text description
3. If number: verify issue exists via `gh issue view <N>`
4. Create feature folder and initial STATE.yaml

## STAGE 1: ANALYZE

Read and follow: [steps/step-01-analyze.md](steps/step-01-analyze.md)

## STAGE 2: DESIGN

Read and follow: [steps/step-02-design.md](steps/step-02-design.md)

## STAGE 3: IMPLEMENT

Read and follow: [steps/step-03-implement.md](steps/step-03-implement.md)

## STAGE 4: TEST

Read and follow: [steps/step-04-test.md](steps/step-04-test.md)

## STAGE 5: PARALLEL REVIEW

Read and follow: [steps/step-05-review.md](steps/step-05-review.md)

## STAGE 6: RELEASE

Read and follow: [steps/step-06-release.md](steps/step-06-release.md)

## Retry and Escalation Rules

- Maximum 3 retry loops back to IMPLEMENT across all review stages
- Retries 1-2: Use sonnet model (fast execution)
- Retry 3: Escalate to opus model (deep reasoning)
- After retry 3 failure: STOP and notify user with:
  - Full error context and what was tried across all attempts
  - Which review(s) failed and their specific findings
  - Current state of the feature branch (all commits pushed to origin)
  - STATE.yaml updated: `state: cancelled`, `cancelled_reason: "Max retries exceeded"`
  - User decides: fix manually, provide guidance, or close issue

## Safety Rules

- Each stage must complete within its scope — no scope creep between stages
- If any gate is rejected with [S] Stop, update STATE.yaml and abort cleanly
- Never push to the main/master branch directly
- Never execute commands listed under `forbidden_commands` in project config
- Always update STATE.yaml on every gate decision
