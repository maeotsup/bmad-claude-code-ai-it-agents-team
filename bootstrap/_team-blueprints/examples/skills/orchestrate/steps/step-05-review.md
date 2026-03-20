# Step 5 of 6: PARALLEL REVIEW

**Agents**: Priit (security), Liisa (code review), Marika (accessibility) — model: sonnet
**Goal**: Run three independent reviews in parallel against the implementation branch.

## Execution

Launch all three review agents **in parallel** (they are all read-only):

### Security Review (Priit)
- Run the project's configured security scanner on changed files
- Manual security checklist review
- Produce security report with PASS/FAIL verdict

### Code Review (Liisa)
- Run the project's configured linter on changed files
- Architecture adherence check
- Style and pattern review
- Produce code review report with APPROVE/REQUEST_CHANGES/COMMENT verdict

### Accessibility Review (Marika)
- Only if UI/template files were changed
- Template audit for WCAG 2.1 AA compliance
- Produce accessibility report with PASS/FAIL verdict
- If no UI files changed, skip with "Not applicable"

Update STATE.yaml: add `security-reviewer`, `code-reviewer`, `accessibility` to `agents_completed`

## Gate

Present all three reports together. Display:
- **Security**: PASS/FAIL with findings count
- **Code Review**: APPROVE/REQUEST_CHANGES/COMMENT
- **Accessibility**: PASS/FAIL with violation count (or "Skipped — no UI changes")

**Menu**:
- **[C] Continue** → all reviews passed, proceed to Step 6: RELEASE
- **[F] Fix** → issues found, loop back to Step 3 with combined findings
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `stage: release` (state remains `review`) |
| [F] Fix | `state: in_progress`, `stage: implement`, `retries: +1` |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at review"` |

## On Fix

Provide the developer with ALL findings from all three reviews combined.
Increment retry counter in STATE.yaml.

Check retry count:
- If `retries < 3`: Continue with sonnet
- If `retries == 3`: Escalate to opus for final attempt
- If `retries > 3`: STOP and notify user:
  - Full error context and what was tried across all attempts
  - Which review(s) failed and specific findings
  - Branch name (all commits on origin)
  - Set `state: cancelled`, `cancelled_reason: "Max retries exceeded"`

## Next Step

On **Continue**: Read and follow `step-06-release.md`
