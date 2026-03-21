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
