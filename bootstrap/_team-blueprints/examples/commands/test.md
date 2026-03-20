Run the project's test suite and report results.

## Prerequisites

- Test dependencies are installed (see CLAUDE.md for setup instructions)

## Steps

1. Execute the test command specified in `CLAUDE.md` or `_bmad/config/config.yaml`
2. Report results clearly: total tests, passed, failed, skipped
3. For any failures:
   - Show the failure message and file location
   - Analyze the error and suggest a likely cause (test bug vs implementation bug)
4. If all tests pass, confirm success and suggest next steps

## On Failure

- If the test runner is not found, suggest the install command from `CLAUDE.md`
- If tests fail due to missing fixtures or setup, check `CLAUDE.md` for environment prerequisites
- If a single test fails repeatedly, investigate whether it's a flaky test or a real regression
