Run a security scan on the project codebase.

## Steps

1. Execute the security scan command specified in `CLAUDE.md` or `_bmad/config/config.yaml`
2. Report findings grouped by severity: CRITICAL → HIGH → MEDIUM → LOW
3. For HIGH and CRITICAL findings, explain the vulnerability and suggest a concrete fix
4. Ignore findings in test files and vendored/third-party code
5. Report the total count per severity level

## On Failure

- If no security scanner is configured, recommend one appropriate for the project's language (see `CLAUDE.md` for tech stack)
- If the scanner fails to run, check that it is installed and the project path is correct
