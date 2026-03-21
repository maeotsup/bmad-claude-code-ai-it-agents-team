---
name: resume
description: "Resume an async workflow after client feedback on a GitHub issue. Use when the user says /resume followed by an issue number."
argument-hint: "<issue-number>"
user-invocable: true
---

# Resume — Continue After Client Feedback

Check a GitHub issue for client feedback on a `/propose` plan, then continue
the pipeline based on the client's response.

## Steps

### Step 1: CHECK FEEDBACK

1. Load project config from `_bmad/config/config.yaml`
2. Find STATE.yaml in `_bmad-output/` for the given issue number
3. Verify state is `awaiting_review` — if not, inform user of current state
4. Fetch latest comments: `gh issue view $ARGUMENTS --json comments`
5. Find comments posted after the proposal comment
6. Classify the client response:
   - **Approved**: Comment contains an approval signal from config (`LGTM`, `Approved`, `Looks good`, etc.) — case-insensitive
   - **Changes requested**: Comment contains feedback, questions, or change requests
   - **No response yet**: No new comments since the proposal

If **no response yet**: inform user and exit. No state change.

If **changes requested**:
- Present the client's feedback to the user
- **GATE**:
  - **[R] Revise** → re-run analyst/architect with client feedback, then re-post via `/propose`
  - **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

If **approved**:
- Remove label: `gh issue edit <number> --remove-label "awaiting-client-review"`
- Present the approval to the user
- **GATE**:
  - **[C] Continue** → proceed to implementation
  - **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

### Step 2: IMPLEMENT (on approval)

Continue the pipeline from the IMPLEMENT stage. This follows the same flow as `/implement`:

1. Invoke the **developer** (Madis) agent with the existing architecture plan
2. Developer creates feature branch, implements, validates, pushes
3. Update STATE.yaml: `state: in_progress`, `stage: implement`

**GATE**: Show implementation summary.
- **[C] Continue** → proceed to testing
- **[E] Edit** → provide feedback
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

### Step 3: TEST

1. Invoke the **tester** (Katrin) agent on the developer's branch
2. Write tests, run test suite, diagnose failures

**GATE**: Show test results.
- **[C] Continue** → proceed to PR
- **[F] Fix** → loop back to developer (max 2 retries)
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

### Step 4: PR + NOTIFY CLIENT

1. Invoke the **release** (Meelis) agent to create the PR
2. Post a follow-up comment on the original issue:
   ```
   ## Implementation Complete

   PR: <URL>
   <brief summary of what was implemented>

   ---
   *Ready for final review. The PR addresses the approved plan above.*
   ```
3. Post via `gh issue comment <number> --body "<formatted>"`
4. Update STATE.yaml: `state: finished`, `stage: done`, `pr: <number>`

## Completion

Report to the user:
- PR: <URL>
- Follow-up comment posted to issue #<N>
- Client notified of implementation
- Suggest: "Run `/pre-pr` for full review pipeline before merge."
