# Step 2 of 4: INVESTIGATE

**Agent**: Indrek (architect) — model: opus
**Goal**: Identify the root cause through code tracing, reproduction, and available debugging tools.

## Execution

1. Read the triage from `_bmad-output/<issue>-<slug>/triage.md`
2. Invoke the **architect** agent with the triage as input
3. The architect conducts investigation in this order:

### Core Investigation (always)
1. **Reproduce**: Attempt to trigger the bug using the project's test runner or by running the application
2. **Trace code paths**: Follow execution from the entry point through to the failure using code analysis tools (`find_symbol`, `find_referencing_symbols`, `get_symbols_overview`)
3. **Hypothesis testing**: For each hypothesis from triage, gather evidence to confirm or eliminate it
4. **Narrow root cause**: Identify the exact location (file:line) and mechanism of the bug

### Auto-Bisect Protocol (when `is_regression: true` in STATE.yaml)
1. Identify a known-good reference — the last commit before recent changes in the affected area (from triage git log)
2. Write a minimal reproduction script that exits 0 on success, exits 1 when the bug is present
3. Run: `git bisect start HEAD <good-commit>` then `git bisect run <script>`
4. Report the exact breaking commit with its diff
5. Update STATE.yaml: `bisect_commit: <hash>`
6. Focus remaining investigation on that commit's changes
7. If bisect is inconclusive, fall back to manual investigation

### Container Debugging Protocol (when project config indicates containerized deployment)
1. Check for container configuration (docker-compose files, Dockerfiles)
2. If a debug override file is configured, start services with it for verbose logging
3. Inspect container logs for errors related to the bug
4. Check container health and status
5. Test API endpoints directly against running services
6. Append `docker` to STATE.yaml `debug_tools_used`

### MCP Tool Integration (when MCP servers are available)
Check for available MCP tools and use whichever are relevant:
- **Browser DevTools MCP**: Capture console errors, network failures, screenshots, DOM state — use for frontend and UI bugs
- **Observability MCP** (Datadog, Grafana, etc.): Query error logs, traces, latency metrics — use for production and performance bugs
- **Database MCP**: Inspect data state, run read-only queries, check schema — use for data corruption and query bugs
- Append each tool used to STATE.yaml `debug_tools_used`

4. Update STATE.yaml: set `root_cause`, `hypotheses_tested`, `reproduction_confirmed`, add `architect` to `agents_completed`
5. Save output to `_bmad-output/<issue>-<slug>/investigation.md`:
   ```markdown
   ---
   type: investigation
   issue: <number>
   inputDocuments:
     - _bmad-output/<issue>-<slug>/triage.md
   date: <today>
   ---
   # Investigation: <title>
   ## Root Cause
   <Exact location, mechanism, and evidence>
   ## Evidence
   | Source | Finding |
   |--------|---------|
   | Code trace | <file:line — what's wrong> |
   | Git bisect | <commit hash — what introduced it> |
   | Container logs | <relevant entries> |
   | MCP tools | <findings> |
   ## Hypotheses Tested
   | # | Hypothesis | Result | Evidence |
   |---|-----------|--------|----------|
   ## Suggested Fix
   <Minimal change description with file:line targets>
   ## Regression Test Approach
   <How to write a test that catches this specific bug>
   ## Architectural Concerns
   <If the bug reveals deeper design issues, describe them here. Otherwise: "None — targeted fix is sufficient.">
   ```

## Gate

Present the investigation report. Display:
- Root cause with evidence
- Bisect result (if regression)
- Debug tools used and their findings
- Suggested fix approach
- Architectural concerns (if any)

**Menu**:
- **[C] Continue** → proceed to Step 3: FIX
- **[E] Edit** → provide more context or request deeper investigation
- **[O] Orchestrate** → escalate to `/orchestrate` (only if architectural concerns were flagged)
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

## State Updates

| Choice | STATE.yaml Update |
|--------|-------------------|
| [C] Continue | `state: fixing`, `stage: fix`, `started: <now>` |
| [E] Edit | no change, re-run architect with additional context |
| [O] Orchestrate | `state: cancelled`, `cancelled_reason: "Escalated to /orchestrate"` |
| [S] Stop | `state: cancelled`, `finished: <now>`, `cancelled_reason: "User stopped at investigate"` |

## On Orchestrate

Transfer to `/orchestrate` with the triage and investigation documents as prior context. The orchestrate pipeline starts at ANALYZE with these documents pre-loaded — the analyst can use them instead of starting from scratch.

## Next Step

On **Continue**: Read and follow `step-03-fix.md`
