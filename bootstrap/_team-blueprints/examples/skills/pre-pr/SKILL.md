---
name: pre-pr
description: "Full pre-PR pipeline: test → parallel review → PR creation. Use when the user says /pre-pr."
user-invocable: true
---

# Pre-PR Pipeline

Run the full review pipeline on current changes and create a PR. This is a shortcut that runs the TEST → REVIEW → RELEASE stages from `/orchestrate` on existing changes.

## Steps

### Step 1: TEST

1. Invoke the **tester** (Katrin) agent
2. Write tests for recent changes (if not already tested)
3. Run the project's full test suite
4. Report results

**GATE**: Show test results → [C] Continue / [F] Fix / [S] Stop

**HALT**: Wait for user selection before proceeding.

### Step 2: PARALLEL REVIEW

Launch in parallel:
1. **Security** (Priit): security scan + manual review
2. **Code Review** (Liisa): linter + architecture + style review
3. **Accessibility** (Marika): template + WCAG audit (if UI files changed)

Present all three reports together.

**GATE**: Show combined review → [C] Continue / [F] Fix / [S] Stop

**HALT**: Wait for user selection before proceeding.

### Step 3: RELEASE

1. Invoke the **release** (Meelis) agent
2. Run final verification
3. Check merge conflicts with the main branch
4. Create PR with full template

## Completion

Report the PR URL to the user.
