# Configuration File Schemas

Structural contracts for the generated configuration files:
`_bmad/config/config.yaml`, `.claude/settings.json`, `.claude/settings.local.json`, and `CLAUDE.md`.

---

## config.yaml

Located at `_bmad/config/config.yaml`. Project metadata used by agents and workflows.

### Required Fields

```yaml
project_name: {string}          # Human-readable project name
description: {string}           # One-line description

user_name: {string}             # From git config user.name

languages: [{list}]             # e.g., [Python, TypeScript]
frameworks: [{list}]            # e.g., [FastAPI, React]
package_manager: {string}       # e.g., pip, npm, dotnet
database: {string or "none"}    # e.g., PostgreSQL, SQLite, none
deployment: {string or "none"}  # e.g., Docker, Vercel, none

artifacts_dir: _bmad-output
project_docs: docs

models:
  thinking: opus
  execution: sonnet

forbidden_files: [{list}]       # Glob patterns for files agents must never modify
forbidden_commands: [{list}]    # Shell commands agents must never run

branch_patterns:
  feature: "feat/{issue}-{description}"
  bugfix: "fix/{issue}-{description}"
  hotfix: "hotfix/{issue}-{description}"
```

---

## settings.json

Located at `.claude/settings.json`. Hook wiring — connects hook scripts to tool events.

### Required Structure

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

### Rules
- `PreToolUse` hooks: synchronous (no `async` field), exit 2 to block
- `PostToolUse` hooks: `"async": true` always, exit 0 always
- `matcher`: regex against tool name (`Bash`, `Write|Edit`)
- `command`: path to hook script relative to project root

---

## settings.local.json

Located at `.claude/settings.local.json`. Permission whitelist and MCP server config.

### Required Structure

```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(gh issue view:*)"
    ]
  }
}
```

### Rules
- Include universal git permissions (add, commit, push)
- Include stack-specific tool permissions from stack knowledge files
- Add MCP server configuration if MCP servers are available:
  ```json
  {
    "enableAllProjectMcpServers": true
  }
  ```
- Keep the list intentional and minimal — do not add overly broad permissions
- Never add permissions for destructive operations (force push, reset --hard)

---

## CLAUDE.md

Located at project root. Project-specific technical reference loaded into every conversation.

### Required Sections (in order)

1. **Title** — `# {Project Name}` + one-line description
2. **Tech Stack** — Languages, frameworks, database, deployment
3. **Key Files** — Table of important files and their purposes
4. **Running Locally** — Dev server, build, and Docker commands
5. **Running Tests** — Test command with filtering options
6. **Conventions** — Summary of key conventions (not duplicating rules files)
7. **Custom Slash Commands** — Tables for tool commands and SDLC pipeline commands
8. **SDLC Agents** — Team roster table
9. **SDLC Artifacts** — Artifact directory paths

### Rules
- Keep under 200 lines — this is loaded into every conversation context
- Concrete commands, not vague descriptions
- Key Files table: only list the most important 10-20 files
- Conventions: brief summary pointing to `.claude/rules/` for details
- Must replace the bootstrap CLAUDE.md completely
