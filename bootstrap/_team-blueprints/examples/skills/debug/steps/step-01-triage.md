# Step 1 of 4: TRIAGE

**Agent**: Anna (analyst) — model: opus
**Goal**: Classify the bug, check debug history for recurring patterns, and detect potential regressions.

## Execution

1. Create feature folder: `_bmad-output/<issue>-<slug>/`
   - `<slug>` = lowercase, hyphenated summary (e.g., `42-login-timeout`)
2. Create initial STATE.yaml (see schema in workflow.md) with `workflow: debug`, `state: triaging`, `stage: triage`
3. Invoke the **analyst** agent with the bug report (`$ARGUMENTS`)
4. The analyst:
   - Reads the bug report, error description, or log output
   - **Checks debug history**: Read `_bmad/debug-history/` for prior bugs in the same component or area
     - If recurring: flag the pattern and surface prior root causes and fixes
   - Classifies severity: CRITICAL / HIGH / MEDIUM / LOW
   - Identifies affected area (components, files, endpoints)
   - Formulates reproduction steps (from report or by inference)
   - **Checks git history** on affected files: `git log --oneline -20 -- <affected-paths>`
     - If recent changes exist in affected area: flag as potential regression
   - Generates 2-5 initial hypotheses ranked by likelihood
5. Save output to `_bmad-output/<issue>-<slug>/triage.md`:
   ```markdown
   ---
   type: triage
   issue: <number>
   date: <today>
   severity: <level>
   is_regression: true|false
   ---
   # Triage: <title>
   ## Summary
   ## Severity
   ## Affected Area
   ## Reproduction Steps
   ## Debug History
   <Prior bugs in same area, or "No prior bugs recorded in this area.">
   ## Regression Check
   <Recent commits in affected files, or "No recent changes in affected files.">
   ## Initial Hypotheses
   1. <hypothesis> — likelihood: HIGH/MEDIUM/LOW
   ```
6. Update STATE.yaml: set `severity`, `is_regression`, add `analyst` to `agents_completed`

## Gate

Present the triage to the user. Display:
- Summary and severity
- Affected area
- Debug history matches (if any)
- Regression flag (if applicable)
- Initial hypotheses

**Menu**:
- **[C] Continue** → proceed to Step 2: INVESTIGATE
- **[E] Edit** → user provides additional context, re-run analyst
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `state: investigating`, `stage: investigate` |
| [E] Edit | no change, re-run analyst |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at triage"` |

## Next Step

On **Continue**: Read and follow `step-02-investigate.md`
