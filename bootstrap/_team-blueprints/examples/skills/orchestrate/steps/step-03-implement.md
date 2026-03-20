# Step 3 of 6: IMPLEMENT

**Agent**: Madis (developer) — model: sonnet, isolation: worktree
**Goal**: Implement the architect's plan in an isolated git worktree.

## Execution

1. Read the architecture from `_bmad-output/<issue>-<slug>/architecture.md`
2. Check if this is a retry:
   - If coming from TEST or REVIEW with [F] Fix, this is a retry
   - STATE.yaml already has `retries` incremented by the referring stage
3. Invoke the **developer** agent with the architecture plan
4. The developer:
   - Creates feature branch in worktree following configured branch pattern
   - Implements changes step by step following the plan
   - Validates each file with the project's linter
   - Commits with conventional messages after each logical unit
   - Pushes each commit to origin
5. Update STATE.yaml:
   - Set `branch: <branch-name>` (if not already set)
   - Add `developer` to `agents_completed` (if not already present)
6. Developer reports: files changed, branch name, commit hashes

## Gate

Present the implementation summary. Display:
- Branch name
- Git diff summary (files changed, insertions, deletions)
- Linter results
- Commit log

**Menu**:
- **[C] Continue** → proceed to Step 4: TEST
- **[E] Edit** → user provides feedback, developer makes additional changes
- **[S] Stop** → abort (branch preserved on origin for manual review)

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `state: testing`, `stage: test` |
| [E] Edit | no change, developer continues |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at implement"` |

## Retry Tracking

This step may be revisited from Step 4 (TEST) or Step 5 (REVIEW):
- Retry 1-2: Use sonnet model
- Retry 3 (escalation): Use opus model
- After retry 3 failure: STOP and notify user (see escalation rules in workflow.md)

## Next Step

On **Continue**: Read and follow `step-04-test.md`
