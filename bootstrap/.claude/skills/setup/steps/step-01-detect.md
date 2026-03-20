# Step 1 of 3: DETECT

**Goal**: Determine the project's tech stack, or interview the user for new/empty projects.
Output a confirmed Stack Profile that drives generation in Step 2.

## Determine Mode

First, check whether this is an existing project or a new/empty one:

1. List files in the project root (excluding `.git/`, `_team-blueprints/`, `.claude/`)
2. If meaningful source files exist → **Existing Project Mode**
3. If the directory is empty or only has boilerplate (README, LICENSE, .gitignore) → **New Project Mode**

---

## EXISTING PROJECT MODE

### Scan for Detection Signals

Check for these files and patterns. For each detected signal, read the corresponding
stack knowledge file from `_team-blueprints/stacks/` to understand the stack.

#### Languages

| Check | If Found | Stack File |
|-------|----------|------------|
| `*.py`, `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py` | Python | `stacks/python.md` |
| `tsconfig.json` | TypeScript | `stacks/typescript.md` |
| `package.json` WITHOUT `tsconfig.json` | JavaScript | `stacks/javascript.md` |
| `*.csproj`, `*.sln` | C# | `stacks/csharp.md` |

#### Frameworks

| Check | If Found | Stack File |
|-------|----------|------------|
| `react` in package.json dependencies | React | `stacks/react.md` |
| `next` in package.json dependencies, `next.config.*` | Next.js | `stacks/nextjs.md` |
| `@angular/core` in package.json, `angular.json` | Angular | `stacks/angular.md` |
| `vue` in package.json dependencies, `*.vue` files | Vue | `stacks/vue.md` |
| `express` in package.json dependencies | Express | `stacks/express.md` |
| `fastapi` in requirements | FastAPI | `stacks/fastapi.md` |
| `django` in requirements, `manage.py` | Django | `stacks/django.md` |
| `Sdk="Microsoft.NET.Sdk.Web"` in .csproj | ASP.NET Web API | `stacks/dotnet-webapi.md` |
| `Microsoft.AspNetCore.Components` in .csproj, `*.razor` | Blazor | `stacks/blazor.md` |
| `Pages/*.cshtml` paired with `*.cshtml.cs`, `AddRazorPages()` | Razor Pages | `stacks/razor-pages.md` |

#### Build / Test / Lint Tools

| Check | Identifies |
|-------|-----------|
| `package.json` → `"scripts"` → `"build"`, `"test"`, `"lint"` | npm scripts (read actual commands) |
| `Dockerfile`, `docker-compose.yml` | Docker build available |
| `Makefile` | Make targets available |
| `.github/workflows/*.yml` | CI/CD pipeline (read for tool hints) |

#### Existing Configuration

| Check | Meaning |
|-------|---------|
| `CLAUDE.md` already exists (not the bootstrap one) | Project has existing Claude Code config — preserve and extend |
| `.claude/` already exists | Partial setup present — offer to merge or overwrite |
| `.editorconfig` | Code style preferences to respect |
| `.eslintrc*`, `biome.json`, `ruff.toml`, `.pylintrc` | Linter already configured |

### Assemble Stack Profile

Compile findings into a Stack Profile:

```
## Stack Profile

**Languages**: [detected languages]
**Frameworks**: [detected frameworks]
**Build**: [build command or "none detected"]
**Test**: [test runner and command]
**Lint**: [linter and command]
**Security**: [security scanner or "recommend: {tool}"]
**Package Manager**: [npm/yarn/pnpm/pip/poetry/dotnet/etc.]
**Container**: [Docker if detected, else "none"]
**CI/CD**: [GitHub Actions / other if detected]
**MCP Servers**: [Serena if available, Playwright if web project, etc.]

### Detected File Structure
- [key directories and entry points found]

### Notes
- [anything unusual: mixed stacks, monorepo, custom patterns]
```

### Present to User

Display the Stack Profile and ask:

**"Here's what I detected. Does this look right? Anything I should add or change?"**

**GATE**:
- **[C] Continue** → proceed to Step 2: GENERATE with this profile
- **[E] Edit** → user provides corrections, update the profile
- **[S] Stop** → abort setup

**HALT**: Wait for user selection before proceeding.

---

## NEW PROJECT MODE

### Interview the User

Ask these questions sequentially. After each answer, decide if you have enough information
to proceed or if you need to ask more. Adapt follow-up questions based on answers.

#### Required Questions

1. **"What are you building?"**
   - App type: web app, API, CLI tool, desktop app, mobile, library, etc.
   - Domain: what does it do? (brief — for CLAUDE.md context)

2. **"What languages and frameworks will you use?"**
   - If the user isn't sure, suggest based on app type:
     - Web app → React/Next.js + Express/FastAPI
     - API → FastAPI / Express / ASP.NET Web API
     - Full-stack C# → Blazor / Razor Pages + ASP.NET
   - Confirm: frontend, backend, or both?

3. **"What database?"** (if applicable)
   - PostgreSQL, MySQL, SQLite, MongoDB, SQL Server, none, etc.
   - ORM preference if relevant

4. **"What package manager do you prefer?"**
   - npm/yarn/pnpm/bun (JS/TS), pip/poetry/uv (Python), dotnet (C#)

#### Optional Questions (ask if relevant)

5. **"Any specific testing framework preference?"**
   - Or: "I'll use [default for your stack] — ok?"

6. **"Any deployment target?"**
   - Docker, Vercel, AWS, Azure, Coolify, bare metal, etc.

7. **"Any MCP servers you use?"**
   - Serena (code analysis), Playwright (browser testing), GitHub, etc.

8. **"Any specific conventions or constraints I should know about?"**
   - Code style, naming conventions, team standards, etc.

### Assemble Stack Profile

Same format as Existing Project Mode, but assembled from interview answers.
For unspecified choices, use sensible defaults from the stack knowledge files.

### Present to User

Display the Stack Profile assembled from the interview:

**"Here's my understanding of your project. Ready to generate the configuration?"**

**GATE**:
- **[C] Continue** → proceed to Step 2: GENERATE
- **[E] Edit** → user provides corrections
- **[S] Stop** → abort setup

**HALT**: Wait for user selection before proceeding.

---

## Next Step

On **Continue** (either mode): Read and follow `step-02-generate.md`, passing the confirmed Stack Profile.
