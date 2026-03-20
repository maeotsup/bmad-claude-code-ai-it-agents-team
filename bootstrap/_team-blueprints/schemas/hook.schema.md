# Hook Definition Schema

Hooks are Python scripts that Claude Code executes automatically before or after tool use.
They enforce safety guardrails and automated checks without requiring manual invocation.

## Hook Types

| Type | Trigger | Purpose | Exit Codes |
|------|---------|---------|------------|
| **PreToolUse** | Before a tool runs | Block dangerous commands | 0=allow, 2=block |
| **PostToolUse** | After a tool runs | Run automated checks (lint, format) | 0=always (informational) |

## File Naming

- File name: `{trigger}_{purpose}.py` (e.g., `pre_bash_guard.py`, `post_edit_lint.py`)
- Located in `.claude/hooks/`

## Hook Contract

All hooks receive JSON on stdin with tool invocation context:

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "git push --force origin main"
  }
}
```

### PreToolUse Hooks

- **Purpose**: Block dangerous or forbidden commands before execution
- **Exit 0**: Allow the command to proceed
- **Exit 2**: Block the command; stderr message is shown to Claude as the reason
- **Pattern**: Read stdin JSON → extract command → check against blocked patterns → exit

### PostToolUse Hooks

- **Purpose**: Run automated checks after file modifications (lint, format)
- **Must be async** (non-blocking): Set `"async": true` in settings.json
- **Always exit 0**: These are informational only; never block
- **Pattern**: Read stdin JSON → extract file path → run check if applicable → print results → exit 0

## Required Structure (Python)

```python
"""
{Hook type} hook: {What it does}.
{How it works — 1 sentence}.
Exit codes: {what each exit code means}.
"""

import json
import sys


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        sys.exit(0)  # On parse failure, allow (fail-open for pre) or ignore (post)

    tool_input = data.get("tool_input", {})
    # ... extract relevant field (command, file_path, etc.)

    # ... check logic ...

    sys.exit(0)


if __name__ == "__main__":
    main()
```

**Rules**:
- Always handle JSON parse errors gracefully (exit 0)
- PreToolUse: blocked patterns should be configurable (list of tuples)
- PostToolUse: only check relevant file types (e.g., `.py`, `.ts`, `.cs`)
- Use `re` module for pattern matching in PreToolUse guards
- Print block reason to stderr (PreToolUse) or check results to stdout (PostToolUse)
- No external dependencies beyond Python stdlib + the project's existing tools

## settings.json Wiring

Hooks are registered in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/pre_bash_guard.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/post_edit_lint.py",
            "async": true
          }
        ]
      }
    ]
  }
}
```

| Field | Rules |
|-------|-------|
| `matcher` | Tool name regex. `Bash` for pre-bash guard. `Write\|Edit` for post-edit hooks. |
| `type` | Always `"command"` |
| `command` | Path to the hook script |
| `async` | `true` for PostToolUse hooks (non-blocking). Omit for PreToolUse. |

## Constraints

| Constraint | Value |
|------------|-------|
| Target length | 30–60 lines per hook |
| Dependencies | Python stdlib only (json, re, sys, subprocess) |
| PreToolUse exit codes | 0 = allow, 2 = block |
| PostToolUse exit codes | Always 0 |
| Blocked patterns | Configurable list, not hardcoded logic |

## Validation Checklist

- [ ] Hook has a docstring explaining purpose and exit codes
- [ ] JSON parse errors handled gracefully (exit 0)
- [ ] PreToolUse: blocked patterns are in a configurable list
- [ ] PreToolUse: block reason printed to stderr
- [ ] PostToolUse: marked async in settings.json
- [ ] PostToolUse: always exits 0
- [ ] No external dependencies beyond stdlib + project tools
- [ ] settings.json wiring matches the hook file path
