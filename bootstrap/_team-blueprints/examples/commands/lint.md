Run the project's linter and report code quality issues.

## Steps

1. Execute the lint command specified in `CLAUDE.md` or `_bmad/config/config.yaml`
2. Report all issues found, grouped by severity or rule category
3. If issues are found, ask the user whether to attempt auto-fix (if the linter supports it)
4. After auto-fix, re-run the linter to confirm issues are resolved

## On Failure

- If the linter is not found, suggest the install command from `CLAUDE.md`
- If the linter reports configuration errors, check for a config file (e.g., linter config in project root)
