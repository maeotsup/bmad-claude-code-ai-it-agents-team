# Step 4 of 6: TEST

**Agent**: Katrin (tester) — model: sonnet
**Goal**: Write tests for the implementation and run the full test suite.

## Execution

1. Invoke the **tester** agent on the developer's branch
2. The tester:
   - Reads the implementation changes (git diff)
   - Reads existing test patterns in the project
   - Writes tests for new functionality
   - Runs the project's configured test command
   - Diagnoses any failures (test bug vs implementation bug)
   - Pushes test commits to the same branch on origin
3. Update STATE.yaml: add `tester` to `agents_completed`
4. Report test results

## Gate

Present test results. Display:
- Total: X passed, Y failed, Z skipped
- New tests added
- Failure details (if any) with diagnosis

**Menu**:
- **[C] Continue** → proceed to Step 5: REVIEW (all tests pass)
- **[F] Fix** → implementation bugs found, loop back to Step 3 for fixes
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `state: review`, `stage: review` |
| [F] Fix | `state: in_progress`, `stage: implement`, `retries: +1` |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at test"` |

## On Fix

Return to `step-03-implement.md` with the test failure details as context.
Increment retry counter in STATE.yaml.

Check retry count:
- If `retries < 3`: Continue with sonnet
- If `retries == 3`: Escalate to opus for final attempt
- If `retries > 3`: STOP and notify user (see escalation rules in workflow.md)

## Next Step

On **Continue**: Read and follow `step-05-review.md`
