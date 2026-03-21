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

```markdown
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
```

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
