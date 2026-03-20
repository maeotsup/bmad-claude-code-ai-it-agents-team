# Step 2 of 6: DESIGN

**Agent**: Indrek (architect) — model: opus
**Goal**: Produce an implementation plan with file-level specificity.

## Execution

1. Read the requirements from `_bmad-output/<issue>-<slug>/requirements.md`
2. Invoke the **architect** agent with the requirements (and any Figma design referenced in the requirements or provided as input)
3. The architect:
   - Uses code analysis tools to trace symbol dependencies
   - Identifies files to modify with specific locations
   - Designs schema and API changes
   - Produces test plan and risk assessment
4. Save output to `_bmad-output/<issue>-<slug>/architecture.md`
5. Update STATE.yaml: add `architect` to `agents_completed`

## Gate

Present the architecture to the user. Display:
- Design summary
- Files to modify
- Schema/API changes
- Risk flags
- Estimated complexity

**Menu**:
- **[C] Continue** → proceed to Step 3: IMPLEMENT
- **[E] Edit** → user provides feedback, re-run architect with adjustments
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `state: in_progress`, `stage: implement`, `started: <now>` |
| [E] Edit | no change, re-run architect |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at design"` |

## Next Step

On **Continue**: Read and follow `step-03-implement.md`
