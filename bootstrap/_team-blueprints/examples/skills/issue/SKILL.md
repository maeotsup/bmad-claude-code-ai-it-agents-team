---
name: issue
description: "Quick triage of a GitHub issue without running the full pipeline. Use when the user says /issue followed by an issue number."
argument-hint: "<issue-number>"
user-invocable: true
---

# Issue Triage

Quick assessment of a GitHub issue. Runs only the **analyst** (Anna) agent for rapid triage without full planning.

## Steps

1. Invoke the **analyst** agent with the issue number ($ARGUMENTS)
2. The analyst fetches the issue via `gh issue view <number> --json title,body,labels,comments`
3. Produces a quick assessment:
   - **Summary**: What the issue is about
   - **Complexity**: SMALL / MEDIUM / LARGE
   - **Affected Areas**: Which files and components
   - **Dependencies**: What must be done first
   - **Recommendation**: Next step (run `/plan`, implement directly, or needs clarification)
4. Save to `_bmad-output/<issue>-<slug>/triage.md`
5. Present to user

This is a fast, single-agent workflow. For full planning, use `/plan <issue>`.
