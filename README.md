# BMAD Claude Code AI IT Agents Team

A portable bootstrap kit that sets up an AI development team in any project using Claude Code. Inspired by [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD) agents and [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) patterns.

## What This Does

Copies a small bootstrap folder into your project, then run `/setup` in Claude Code. It detects your tech stack (or asks about it for new projects) and generates a complete SDLC pipeline — 8 specialized AI agents, workflow skills, safety guardrails, and project-specific commands — all tailored to your codebase.

After setup, work through GitHub issues using `/orchestrate #123` and the full team handles analysis → design → implementation → testing → review → PR creation, with human approval gates at every stage.

## Quick Start

```bash
# Clone this repo
git clone https://github.com/maeotsup/bmad-claude-code-ai-it-agents-team /tmp/team-bootstrap

# Copy bootstrap into your project
cp -r /tmp/team-bootstrap/bootstrap/* /path/to/your-project/
cp -r /tmp/team-bootstrap/bootstrap/.claude /path/to/your-project/

# Open your project in Claude Code, then run:
#   /setup
```

### Windows (PowerShell)

```powershell
git clone https://github.com/maeotsup/bmad-claude-code-ai-it-agents-team $env:TEMP\team-bootstrap

Copy-Item -Recurse "$env:TEMP\team-bootstrap\bootstrap\*" "C:\path\to\your-project\"
Copy-Item -Recurse "$env:TEMP\team-bootstrap\bootstrap\.claude" "C:\path\to\your-project\"
```

## Two Modes

### Existing Project (has source files)

`/setup` detects your stack automatically:

```
/setup
  ├── Scans for: package.json, tsconfig.json, *.csproj, requirements.txt, pyproject.toml, ...
  ├── Identifies: languages, frameworks, test runners, linters, build tools
  ├── Presents findings for your confirmation
  ├── Generates all configuration tailored to your stack
  └── Cleanup: removes bootstrap scaffolding, replaces CLAUDE.md
```

### New / Empty Project

`/setup` interviews you:

```
/setup
  ├── Detects empty project
  ├── Asks: What are you building? What languages/frameworks?
  ├── Asks: Frontend, backend, or both? Database? Deployment target?
  ├── Summarizes understanding, you confirm
  ├── Generates all configuration based on your answers
  └── Suggests: "Create a GitHub issue for your first feature and run /orchestrate #1"
```

## What You Get After Setup

```
your-project/
├── CLAUDE.md                          # Project-specific technical reference
├── .claude/
│   ├── agents/                        # 8 AI team members
│   │   ├── analyst.md                 # Anna — requirements engineering
│   │   ├── architect.md               # Indrek — system design
│   │   ├── developer.md               # Madis — implementation (worktree isolated)
│   │   ├── tester.md                  # Katrin — test automation
│   │   ├── code-reviewer.md           # Liisa — code quality
│   │   ├── security-reviewer.md       # Priit — security audit
│   │   ├── accessibility.md           # Marika — WCAG 2.1 AA (web projects only)
│   │   └── release.md                 # Meelis — PR creation
│   ├── commands/                      # Stack-specific tool commands
│   │   ├── build.md                   # /build — build the project
│   │   ├── test.md                    # /test — run test suite
│   │   ├── lint.md                    # /lint — run linter
│   │   └── security.md               # /security — run security scan
│   ├── rules/                         # Always-active coding guidelines
│   │   ├── safety.md                  # Universal safety guardrails
│   │   ├── {language}.md              # Language-specific conventions
│   │   ├── {framework}.md             # Framework-specific conventions
│   │   └── testing.md                 # Test patterns and conventions
│   ├── skills/                        # SDLC workflow definitions
│   │   ├── orchestrate/               # Full pipeline (analyze → PR)
│   │   ├── plan/                      # Requirements + design only
│   │   ├── implement/                 # Execute an architect plan
│   │   ├── tdd/                       # Red → green → refactor
│   │   ├── code-review/               # Review current changes
│   │   ├── verify/                    # Test + lint + security
│   │   ├── pre-pr/                    # Review pipeline + PR creation
│   │   ├── issue/                     # Quick issue triage
│   │   └── figma/                     # Figma design → production code
│   ├── hooks/                         # Safety and quality automation
│   │   ├── pre_bash_guard.py          # Block dangerous commands
│   │   └── post_edit_lint.py          # Auto-lint on file save
│   ├── settings.json                  # Hook wiring
│   └── settings.local.json            # Permission whitelist
├── _bmad/
│   └── config/
│       └── config.yaml                # Project metadata and model routing
└── _bmad-output/                      # Pipeline artifacts (per-issue subdirectories)
```

## Available Commands After Setup

### Tool Commands

| Command | Description |
|---------|-------------|
| `/build` | Build the project |
| `/test` | Run test suite |
| `/lint` | Run linter |
| `/security` | Run security scan |

### SDLC Pipeline Commands

| Command | Description |
|---------|-------------|
| `/orchestrate <issue>` | Full pipeline: analyze → design → implement → test → review → PR |
| `/plan <issue>` | Requirements analysis + architecture design (no code) |
| `/implement` | Execute an existing architect plan |
| `/tdd <requirement>` | Test-driven development: red → green → refactor |
| `/code-review` | Review current changes (quality + security + accessibility) |
| `/verify` | Combined test + lint + security scan |
| `/pre-pr` | Full review pipeline + PR creation |
| `/issue <number>` | Quick triage of a GitHub issue |
| `/figma <design>` | Translate a Figma design (screenshot/file/URL) into production-ready code |

## The Team

| Agent | Name | Model | Role |
|-------|------|-------|------|
| analyst | Anna | opus | Requirements analysis, issue triage |
| architect | Indrek | opus | System design, codebase tracing |
| developer | Madis | sonnet | Implementation (worktree isolated) |
| tester | Katrin | sonnet | Test writing and execution |
| code-reviewer | Liisa | sonnet | Code quality and architecture review |
| security-reviewer | Priit | sonnet | Security audit (OWASP, CWE) |
| accessibility | Marika | sonnet | WCAG 2.1 AA compliance (web projects) |
| release | Meelis | sonnet | Verification and PR creation |

## Supported Stacks

**Languages**: Python, TypeScript, JavaScript, C#

**Frameworks**:
- Frontend: React, Next.js, Angular, Vue, Blazor
- Backend: FastAPI, Django, Express, ASP.NET Web API
- Full-stack: Next.js, Razor Pages, Blazor

More stacks can be added by creating a new file in `_team-blueprints/stacks/`.

## Customizing the Output

The generated agents, skills, commands, rules, and hooks are **working examples** — functional but intentionally minimalistic. They are meant as a solid starting point, not a final product. You are encouraged to customize, extend, or rewrite any of them to fit your team's workflows, conventions, and quality standards.

## Architecture

The bootstrap works in three layers:

1. **Schemas** (`_team-blueprints/schemas/`) — Structural contracts that enforce consistency. Define exactly what sections each file type must contain, in what order, with what constraints.

2. **Golden Examples** (`_team-blueprints/examples/`) — Complete, working reference files that demonstrate the right tone, depth, and style. The generator reads these as calibration references.

3. **Stack Knowledge** (`_team-blueprints/stacks/`) — Per-language and per-framework files containing detection signals, tool commands, conventions, and hook configuration. The generator combines these with schemas and examples to produce project-specific output.

The `/setup` skill orchestrates the process: detect/interview → read schemas + examples + stack knowledge → generate → self-validate → cleanup.

## How Generation Works

Claude Code is the template engine. No Handlebars, no Jinja2, no code generation scripts. The `/setup` skill instructs Claude to:

1. **Read the schema** for the file type being generated (structural contract)
2. **Study the golden example** for that file type (tone and depth calibration)
3. **Read the stack knowledge** for the detected languages/frameworks (specific content)
4. **Generate** the file following the schema exactly
5. **Self-validate** against the schema before moving to the next file

This handles edge cases that rigid templates cannot — mixed stacks, unusual project structures, custom conventions.

## Contributing

To add support for a new language or framework:

1. Create `bootstrap/_team-blueprints/stacks/{name}.md` following the existing format
2. Include: detection signals, build/test/lint/security commands, conventions, hook config
3. The `/setup` skill will automatically pick it up during detection

## License

MIT
