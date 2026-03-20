Build the project and report results.

## Prerequisites

- Build tooling is installed (see CLAUDE.md for setup instructions)

## Steps

1. Execute the build command specified in `CLAUDE.md` or `_bmad/config/config.yaml`
2. Report build success or failure with relevant output
3. If successful, report build artifacts (image size, bundle size, output directory)
4. If the project uses containers, ask the user if they want to start the built image

## On Failure

- If the build tool is not found, suggest the install command from `CLAUDE.md`
- If the build fails with dependency errors, suggest running the project's install/restore command first
- If the build fails with code errors, show the first error and suggest a fix
