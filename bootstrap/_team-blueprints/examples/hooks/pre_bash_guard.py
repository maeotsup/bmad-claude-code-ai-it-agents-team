"""
PreToolUse hook: Block dangerous bash commands.
Reads JSON from stdin, checks tool_input.command against blocked patterns.
Exit 0 = allow, Exit 2 = block (stderr message fed back to Claude).
"""

import json
import re
import sys


# Universal blocked patterns — apply to every project.
# The generator adds project-specific patterns from _bmad/config/config.yaml.
BLOCKED_PATTERNS = [
    (r"\brm\s+-rf\s+[./]", "Blocked: rm -rf on project/root directory"),
    (r"\brm\s+-rf\s+\*", "Blocked: rm -rf with wildcard"),
    (r"\bgit\s+push\s+--force\s+.*\b(master|main)\b", "Blocked: force push to master/main"),
    (r"\bgit\s+reset\s+--hard\b", "Blocked: git reset --hard (requires explicit user instruction)"),
    (r"\bgit\s+clean\s+-fd\b", "Blocked: git clean -fd removes untracked files"),
    # Project-specific patterns are added below by the generator:
    # (r"\bpattern\b", "Blocked: reason"),
]


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)

    tool_input = data.get("tool_input", {})
    command = tool_input.get("command", "")

    if not command:
        sys.exit(0)

    for pattern, message in BLOCKED_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            print(message, file=sys.stderr)
            sys.exit(2)

    sys.exit(0)


if __name__ == "__main__":
    main()
