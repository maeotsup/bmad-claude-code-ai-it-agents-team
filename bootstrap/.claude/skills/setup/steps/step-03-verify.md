# Step 3 of 3: VERIFY

**Goal**: Validate all generated files, run a smoke test, and present the final summary to the user.

## Verification Checklist

Read each generated file and verify against its schema. Report any issues found.

### Agents (8 files)

For each file in `.claude/agents/*.md`:
- [ ] Frontmatter has: name, description, model, tools (and isolation for developer only)
- [ ] All 10 sections present in order: Title, Overview, Communication Style, Principles, Capabilities, Activation Protocol, Working Protocol, Output Format, Constraints, Escalation
- [ ] Capability codes are unique across all 8 agents (no duplicates)
- [ ] Tools listed match the agent's role type
- [ ] Stack-specific knowledge is woven in (not generic placeholders)
- [ ] No leftover template markers or TODOs

### Commands (4 files)

For each file in `.claude/commands/*.md` (build, test, lint, security):
- [ ] Contains actual CLI commands for this project's stack (not generic "run the linter")
- [ ] Has Steps section with 3-6 numbered items
- [ ] Has On Failure section with at least 2 recovery actions

### Rules (3-5 files)

For each file in `.claude/rules/*.md`:
- [ ] `safety.md` contains both universal and project-specific rules
- [ ] Language rules match the detected language(s)
- [ ] Framework rules match the detected framework(s)
- [ ] `testing.md` references the actual test runner and patterns

### Skills (8 directories)

- [ ] `skills/orchestrate/` has: SKILL.md, workflow.md, steps/step-01 through step-06
- [ ] All other skills have SKILL.md with valid frontmatter
- [ ] `skills/setup/` has been removed (cleanup from Step 2)

### Hooks (2 files)

- [ ] `hooks/pre_bash_guard.py` has stack-specific blocked patterns
- [ ] `hooks/post_edit_lint.py` has correct LINT_COMMAND and FILE_EXTENSIONS for this stack
- [ ] Both are valid Python that will execute without import errors

### Settings (2 files)

- [ ] `settings.json` has correct hook wiring (paths match actual hook files)
- [ ] `settings.local.json` has stack-appropriate permission whitelist

### Configuration

- [ ] `_bmad/config/config.yaml` has correct project metadata
- [ ] `_bmad-output/` directory exists
- [ ] `CLAUDE.md` has been replaced with project-specific content (not the bootstrap placeholder)

### Cleanup

- [ ] `_team-blueprints/` directory has been removed
- [ ] `.claude/skills/setup/` has been removed
- [ ] `.claude/commands/setup.md` has been removed

---

## Smoke Test

Run quick validation commands to confirm the setup works:

1. If a linter is configured, run it on an existing file to verify the command works
2. If tests are configured, run the test suite to verify the command works
3. Check that `gh issue list` works (GitHub CLI available)

Report results — failures here are informational, not blockers.

---

## Present Summary

Display the final summary to the user:

```
## Setup Complete

### Project: {project name}
**Stack**: {languages} + {frameworks}

### Generated Files
- 8 agents in `.claude/agents/`
- {N} commands in `.claude/commands/`
- {N} rules in `.claude/rules/`
- 8 skills in `.claude/skills/`
- 2 hooks in `.claude/hooks/`
- Settings: `.claude/settings.json`, `.claude/settings.local.json`
- Config: `_bmad/config/config.yaml`
- Reference: `CLAUDE.md`

### Verification
- Agents: {PASS/issues found}
- Commands: {PASS/issues found}
- Rules: {PASS/issues found}
- Skills: {PASS/issues found}
- Hooks: {PASS/issues found}
- Settings: {PASS/issues found}
- Smoke test: {results}

### Next Steps
1. Review the generated `CLAUDE.md` — add any project details I may have missed
2. Review `.claude/rules/` — adjust conventions to match your team's preferences
3. Create a GitHub issue for your first feature
4. Run `/orchestrate #1` to see the full SDLC pipeline in action

### Available Commands
/orchestrate, /plan, /implement, /tdd, /code-review, /verify, /pre-pr, /issue
/build, /test, /lint, /security
```

**GATE**:
- **[D] Done** → setup complete
- **[E] Edit** → user wants to adjust generated files (assist with specific changes)

**HALT**: Wait for user selection before proceeding.
