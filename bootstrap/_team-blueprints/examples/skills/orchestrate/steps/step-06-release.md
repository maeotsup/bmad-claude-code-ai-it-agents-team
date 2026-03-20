# Step 6 of 6: RELEASE

**Agent**: Meelis (release) — model: sonnet
**Goal**: Run final verification, handle merge conflicts, and create the PR.

## Execution

1. Invoke the **release** agent on the implementation branch
2. The release agent:
   - Runs the project's full verification suite (test, lint, security)
   - Checks for merge conflicts with the main branch
   - If conflicts found: STOP and report to user
   - Ensures all commits are pushed to origin
   - Creates PR via `gh pr create` with full template:
     - Summary linking to the GitHub issue
     - File change table
     - Test plan checklist
     - Security and code review notes
     - Accessibility review notes
     - `Closes #<issue>`
3. Update STATE.yaml: add `release` to `agents_completed`

## Gate

Present the PR. Display:
- PR URL
- PR title and summary
- Verification results
- Any warnings

**Menu**:
- **[D] Done** → workflow complete
- **[E] Edit** → modify PR description
- **[S] Stop** → close PR and abort

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [D] Done | `state: finished`, `stage: done`, `pr: <number>`, `finished: <now>` |
| [E] Edit | no change, modify PR |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at release"` |

## Completion

On **Done**, update STATE.yaml and report:
- Pipeline complete for issue #<N>
- PR: <URL>
- Branch: <branch-name>
- Feature artifacts in `_bmad-output/<issue>-<slug>/`
- Agents involved: Anna → Indrek → Madis → Katrin → Priit + Liisa + Marika → Meelis
- Total retries: <N>
