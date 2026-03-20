---
name: plan
description: "Analyze requirements and design implementation plan without writing code. Use when the user says /plan followed by an issue number or description."
argument-hint: "<issue-number-or-description>"
user-invocable: true
---

# Plan Workflow

Analyze a requirement and produce a full implementation plan. This runs the **analyst** (Anna) and **architect** (Indrek) agents sequentially with human approval gates. No code is written.

## Steps

### Step 1: ANALYZE

1. Load project config from `_bmad/config/config.yaml`
2. Invoke the **analyst** agent with the user's input ($ARGUMENTS)
3. The analyst produces a requirements document saved to `_bmad-output/<issue>-<slug>/requirements.md`
4. Present the requirements to the user

**GATE**: Show requirements output. Ask the user:
- **[C] Continue** → proceed to design
- **[E] Edit** → provide feedback, analyst re-runs
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

### Step 2: DESIGN

1. Invoke the **architect** agent with the requirements from Step 1
2. The architect uses code analysis tools to trace dependencies and produces an architecture document
3. Save to `_bmad-output/<issue>-<slug>/architecture.md`
4. Present the design to the user

**GATE**: Show architecture output. Ask the user:
- **[C] Continue** → plan complete
- **[E] Edit** → provide feedback, architect re-runs
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

## Completion

When both steps are approved, inform the user:
- Planning artifacts saved to `_bmad-output/<issue>-<slug>/`
- To implement, run `/implement` in a new conversation
- To run the full pipeline, use `/orchestrate <issue>`
