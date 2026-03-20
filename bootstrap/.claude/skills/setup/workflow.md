# Setup Workflow

**Goal**: Configure the AI development team for this project by detecting (or learning about)
the tech stack and generating all `.claude/` configuration files tailored to the codebase.

**Your Role**: Interviewer and generator. You analyze the project, confirm findings with the
user, generate all configuration, validate it, and clean up the bootstrap scaffolding.

## Workflow Architecture

- Three stages: DETECT → GENERATE → VERIFY
- Human confirmation between detect and generate
- Blueprint files in `_team-blueprints/` provide schemas, examples, and stack knowledge
- All generated files follow the schemas exactly
- Bootstrap scaffolding is cleaned up after successful generation

## Blueprint Locations

```
_team-blueprints/
├── schemas/          # Structural contracts for each file type
│   ├── agent.schema.md
│   ├── command.schema.md
│   ├── rule.schema.md
│   ├── skill.schema.md
│   └── hook.schema.md
├── examples/         # Golden reference implementations
│   ├── agents/       # 8 generalized agent definitions
│   ├── commands/     # 4 command templates
│   ├── rules/        # Safety + language template
│   ├── skills/       # Full orchestrate pipeline + 7 simpler skills
│   └── hooks/        # Pre-bash guard + post-edit lint
└── stacks/           # Per-language and per-framework knowledge
    ├── python.md, typescript.md, javascript.md, csharp.md
    ├── react.md, nextjs.md, angular.md, vue.md
    ├── express.md, fastapi.md, django.md
    ├── dotnet-webapi.md, blazor.md, razor-pages.md
    └── (more can be added)
```

## STAGE 1: DETECT

Read and follow: [steps/step-01-detect.md](steps/step-01-detect.md)

## STAGE 2: GENERATE

Read and follow: [steps/step-02-generate.md](steps/step-02-generate.md)

## STAGE 3: VERIFY

Read and follow: [steps/step-03-verify.md](steps/step-03-verify.md)
