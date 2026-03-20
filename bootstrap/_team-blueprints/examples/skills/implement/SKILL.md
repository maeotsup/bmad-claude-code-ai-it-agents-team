---
name: implement
description: "Implement code changes from an existing architect plan. Use when the user says /implement."
user-invocable: true
---

# Implement Workflow

Execute an architect's plan by invoking the **developer** (Madis) agent. The developer works in an isolated git worktree.

## Steps

### Step 1: LOCATE PLAN

1. Check conversation context for an architecture document
2. If not found, check `_bmad-output/` subdirectories for the most recent `architecture.md`
3. If no plan exists, inform user to run `/plan <issue>` first

### Step 2: IMPLEMENT

1. Invoke the **developer** agent with the architecture plan
2. Developer creates a feature branch in a worktree
3. Implements changes step by step following the plan
4. Validates each file with the project's linter
5. Commits and pushes to origin after each logical unit
6. Reports: files changed, branch name, commit hashes

**GATE**: Show git diff summary and branch info. Ask the user:
- **[C] Continue** → proceed to testing
- **[E] Edit** → provide feedback, developer fixes
- **[S] Stop** → abort (branch preserved for manual review)

**HALT**: Wait for user selection before proceeding.

### Step 3: TEST

1. Invoke the **tester** (Katrin) agent on the developer's branch
2. Tester writes tests and runs the project's test suite
3. If tests fail, tester diagnoses whether it's a test or implementation issue
4. Pushes test commits to the same branch

**GATE**: Show test results. Ask the user:
- **[C] Continue** → implementation complete
- **[F] Fix** → loop back to developer to fix failures (max 2 retries)
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

## Completion

Inform user:
- Implementation branch: `feat/<issue>-<description>` (or configured pattern)
- All commits pushed to origin
- To run full review pipeline: `/pre-pr`
- To create PR directly: use `gh pr create`
