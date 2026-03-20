"""
PostToolUse hook: Run the project's linter on edited files.
Async (non-blocking), informational only. Always exits 0.

The LINT_COMMAND and FILE_EXTENSIONS are set by the generator based on the
project's detected tech stack. Examples:
  Python:     ruff check {file} --select E,F,W --quiet
  TypeScript: npx eslint {file} --quiet
  C#:         dotnet format {file} --verify-no-changes
"""

import json
import subprocess
import sys

# Set by the generator based on detected stack.
# The command must accept a file path as the last argument.
LINT_COMMAND = []  # e.g., ["ruff", "check", "--select", "E,F,W", "--quiet"]
FILE_EXTENSIONS = []  # e.g., [".py"] or [".ts", ".tsx"]


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    if not LINT_COMMAND or not FILE_EXTENSIONS:
        sys.exit(0)  # Not configured — skip silently

    tool_input = data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not file_path or not any(file_path.endswith(ext) for ext in FILE_EXTENSIONS):
        sys.exit(0)

    try:
        result = subprocess.run(
            LINT_COMMAND + [file_path],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.stdout.strip():
            print(f"Lint warnings in {file_path}:")
            print(result.stdout.strip())
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass  # Linter not available or timed out — skip silently

    sys.exit(0)


if __name__ == "__main__":
    main()
