---
name: hotfix
description: "Emergency fast-track fix: skip investigation, apply fix → verify → PR. Use when the user says /hotfix followed by an issue number or fix description."
argument-hint: "<issue-number-or-fix-description>"
user-invocable: true
---

# Hotfix — Emergency Fast-Track Fix

Apply an urgent fix when the root cause is already known. Skips triage and investigation
for maximum speed. Creates a `hotfix/` branch, applies the fix with a regression test,
runs verification, and creates a PR.

Use `/debug` instead when the root cause is unknown and investigation is needed.

## Steps

### Step 1: FIX

1. Load project config from `_bmad/config/config.yaml`
2. Parse input: `$ARGUMENTS` — issue number or fix description
3. If number: fetch issue via `gh issue view <N> --json title,body,labels,comments`
4. Invoke the **developer** (Madis) agent in a worktree
5. The developer:
   - Creates `hotfix/<issue>-<slug>` branch (using configured hotfix branch pattern)
   - Applies the minimal fix based on the user's description or issue
   - Writes a regression test that catches the specific bug
   - Runs the project's test suite
   - Validates with the project's linter
   - Commits with `fix(<scope>): <description>`
   - Pushes to origin

**GATE**: Show the fix diff, regression test, and test results.
- **[C] Continue** → proceed to verification
- **[E] Edit** → user provides feedback, developer adjusts
- **[S] Stop** → abort (branch preserved on origin)

**HALT**: Wait for user selection before proceeding.

### Step 2: VERIFY

1. Run the combined verification suite: test + lint + security (same as `/verify`)
2. Report consolidated results

**GATE**: Show verification results.
- **[C] Continue** → proceed to PR creation
- **[F] Fix** → loop back to Step 1 (max 2 retries)
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

### Step 3: RELEASE

1. Invoke the **release** (Meelis) agent
2. Check for merge conflicts with the main branch
3. Create PR via `gh pr create` with hotfix template:
   - Hotfix summary
   - Files changed
   - Regression test added
   - `Fixes #<issue>` (if issue number provided)
4. Report PR URL

## Completion

- PR URL: <link>
- Branch: `hotfix/<issue>-<slug>`
- All commits pushed to origin
- Suggest: "Run `/code-review` for a full code review if the fix touches critical code."
