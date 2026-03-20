---
name: code-review
description: "Review uncommitted or recent changes for code quality, security, and accessibility. Use when the user says /code-review."
user-invocable: true
---

# Code Review — Current Changes

Review the current `git diff` for quality, security, and architecture adherence. Does NOT create a PR — produces review reports only.

## Steps

1. Run `git diff` to identify changed files
2. If no changes, check `git diff --staged`
3. If still no changes, inform the user and exit

### Parallel Review

Launch all three review agents in parallel:

**Code Review** (Liisa):
- Run the project's linter on changed files
- Check architecture adherence and pattern consistency
- Review style and naming
- If a Figma design exists in `_bmad-output/` for the current feature, compare implementation against the design for visual fidelity

**Security Review** (Priit):
- Run the project's security scanner on changed files (if configured)
- Manual security checklist review

**Accessibility Review** (Marika):
- Only if UI/template files are in the diff
- Template audit for WCAG 2.1 AA
- If a Figma design is available, audit the design alongside the implementation for WCAG compliance
- Skip with "Not applicable" if no UI files changed

## Output

Present all reports with combined verdict:
- **APPROVE**: All reviews pass — ready for `/pre-pr`
- **REQUEST_CHANGES**: Issues found — fix before PR
- **COMMENT**: Minor suggestions, can proceed with notes
