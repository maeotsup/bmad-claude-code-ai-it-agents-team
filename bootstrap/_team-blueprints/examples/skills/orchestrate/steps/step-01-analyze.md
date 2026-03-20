# Step 1 of 6: ANALYZE

**Agent**: Anna (analyst) — model: opus
**Goal**: Produce structured requirements from the GitHub issue or description.

## Execution

1. Create feature folder: `_bmad-output/<issue>-<slug>/`
   - `<slug>` = lowercase, hyphenated version of issue title (e.g., `4-rbac`)
2. Create initial STATE.yaml:
   ```yaml
   issue: <number>
   title: <issue title>
   state: planning
   stage: analyze
   branch: null
   pr: null
   created: <ISO timestamp>
   started: null
   finished: null
   retries: 0
   cancelled_reason: null
   agents_completed: []
   ```
3. Invoke the **analyst** agent with the input (issue number, description, or Figma design). If a Figma design is attached or referenced, the analyst extracts visual specifications as structured requirements.
4. The analyst produces a structured requirements document
5. Save output to `_bmad-output/<issue>-<slug>/requirements.md`
6. Update STATE.yaml: add `analyst` to `agents_completed`

## Gate

Present the requirements to the user. Display:
- Summary
- Affected areas
- Acceptance criteria
- Open questions (if any)

**Menu**:
- **[C] Continue** → proceed to Step 2: DESIGN
- **[E] Edit** → user provides feedback, re-run analyst with adjustments
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `stage: design` |
| [E] Edit | no change, re-run analyst |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at analyze"` |

## Next Step

On **Continue**: Read and follow `step-02-design.md`
