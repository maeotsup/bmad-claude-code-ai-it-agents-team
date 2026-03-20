# TypeScript — Stack Knowledge

## Detection Signals

| Signal | Pattern |
|--------|---------|
| Primary | `tsconfig.json` |
| Files | `*.ts`, `*.tsx` in `src/` or project root |
| Package manager | `package.json` with `typescript` in devDependencies |
| Lock files | `package-lock.json` (npm), `yarn.lock` (yarn), `pnpm-lock.yaml` (pnpm), `bun.lockb` (bun) |

## Build

| Tool | Command | Detection |
|------|---------|-----------|
| tsc | `npx tsc --build` | `tsconfig.json` with no bundler config |
| Vite | `npx vite build` | `vite.config.ts` |
| Next.js | `npx next build` | `next.config.ts` or `next.config.js` |
| esbuild | `npx esbuild src/index.ts --bundle --outdir=dist` | `esbuild` in devDependencies |
| Webpack | `npx webpack` | `webpack.config.ts` or `webpack.config.js` |
| Docker | `docker compose build` | `Dockerfile` present |

**Note**: Check `"scripts"` in `package.json` — most projects define `"build"` there.

## Test

| Runner | Command | Detection |
|--------|---------|-----------|
| Vitest | `npx vitest run` | `vitest.config.ts` or `vitest` in devDependencies |
| Jest | `npx jest` | `jest.config.ts`, `jest.config.js`, or `"jest"` in package.json |
| Playwright | `npx playwright test` | `playwright.config.ts` |
| Mocha | `npx mocha` | `.mocharc.yml` or `mocha` in devDependencies |

**Note**: Check `"scripts"` in `package.json` — most projects define `"test"` there.

### Run patterns
- Single file: `npx vitest run src/module.test.ts`
- Watch mode: `npx vitest` (default is watch)
- Coverage: `npx vitest run --coverage`

## Lint

| Tool | Command | Detection | Auto-fix |
|------|---------|-----------|----------|
| ESLint | `npx eslint .` | `eslint.config.ts`, `.eslintrc.*`, `"eslintConfig"` in package.json | `npx eslint . --fix` |
| Biome | `npx biome check .` | `biome.json` | `npx biome check . --apply` |
| Prettier (formatter) | `npx prettier --check .` | `.prettierrc`, `"prettier"` in package.json | `npx prettier --write .` |
| TypeScript strict | `npx tsc --noEmit` | `tsconfig.json` with `"strict": true` | N/A |

**Preferred**: ESLint (v9 flat config) + Prettier, or Biome (all-in-one)

## Security

| Tool | Command | Detection |
|------|---------|-----------|
| npm audit | `npm audit --audit-level=high` | `package-lock.json` |
| yarn audit | `yarn audit --level high` | `yarn.lock` |
| pnpm audit | `pnpm audit --audit-level high` | `pnpm-lock.yaml` |
| Snyk | `npx snyk test` | Any JS/TS project |

## Code Conventions

### Style
- Strict mode: `"strict": true` in tsconfig.json
- Prefer `const` over `let`; never use `var`
- Explicit return types on exported functions
- Use `interface` for object shapes, `type` for unions and intersections
- Named exports preferred over default exports
- Imports ordered: node builtins → third-party → project modules → relative

### Async Patterns
- Use `async/await` over raw Promises
- Always handle errors in async functions (try/catch or `.catch()`)
- Never fire-and-forget promises without error handling
- Use `Promise.all()` for independent concurrent operations

### Error Handling
- Use typed error classes or error codes, not string matching
- API responses should have consistent error shape: `{ error: string, details?: unknown }`
- Never expose stack traces in production responses
- Log errors with request context (path, method, user ID)

## Hook Configuration

### pre_bash_guard — Additional Patterns
```python
(r"\bnpx?\s+.*--unsafe-perm", "Blocked: npm with unsafe permissions"),
(r"\brm\s+-rf\s+node_modules", "Blocked: use package manager to manage node_modules"),
```

### post_edit_lint
```python
LINT_COMMAND = ["npx", "eslint", "--quiet"]  # Adjust if project uses Biome
FILE_EXTENSIONS = [".ts", ".tsx"]
```

## Permission Whitelist
```json
[
  "Bash(npx vitest:*)",
  "Bash(npx jest:*)",
  "Bash(npx eslint:*)",
  "Bash(npx biome:*)",
  "Bash(npx tsc:*)",
  "Bash(npm audit:*)",
  "Bash(npm install:*)",
  "Bash(npm run:*)"
]
```

## Common Frameworks

| Framework | Type | Detection |
|-----------|------|-----------|
| React | Frontend | `react` in dependencies |
| Next.js | Full-stack | `next` in dependencies, `next.config.*` |
| Angular | Frontend | `@angular/core` in dependencies, `angular.json` |
| Vue | Frontend | `vue` in dependencies |
| Express | Backend | `express` in dependencies |
| NestJS | Backend | `@nestjs/core` in dependencies |
| Fastify | Backend | `fastify` in dependencies |
