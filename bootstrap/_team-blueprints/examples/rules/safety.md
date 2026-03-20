# Safety Guardrails

## Forbidden Actions

- **Never** push directly to the main/master branch. Always use feature branches and pull requests.
- **Never** use `git push --force` to main/master.
- **Never** run `git reset --hard` without explicit user instruction.
- **Never** run `git clean -fd` without explicit user instruction.
- **Never** hardcode secrets, passwords, API keys, or connection strings in source code.
- **Never** commit files containing credentials (`.env`, `*.pem`, `credentials.*`).

## Required Before PR

- All tests pass (run the `/test` command)
- No lint errors (run the `/lint` command)
- No HIGH or CRITICAL security findings (run the `/security` command)
- Build succeeds (run the `/build` command, if applicable)

## Data Safety

- All database queries must use parameterized statements. Never construct queries with string concatenation from user input.
- Validate and sanitize all external input at API boundaries.
- Never write to directories outside the project root.
- Respect `.gitignore` patterns — do not commit ignored files.

## File Safety

- Never modify or delete files in protected directories (listed in `_bmad/config/config.yaml` under `forbidden_files`)
- Never execute commands listed under `forbidden_commands` in the project config
- When in doubt about a destructive operation, ask the user first
