# JavaScript — Stack Knowledge

## Detection Signals

| Signal | Pattern |
|--------|---------|
| Primary | `package.json` WITHOUT `tsconfig.json` (otherwise → TypeScript) |
| Files | `*.js`, `*.jsx`, `*.mjs`, `*.cjs` |
| Module type | `"type": "module"` in package.json = ESM; absence = CommonJS |
| Lock files | `package-lock.json` (npm), `yarn.lock` (yarn), `pnpm-lock.yaml` (pnpm), `bun.lockb` (bun) |

**Important**: If both `package.json` and `tsconfig.json` exist, classify as TypeScript.
JavaScript-specific rules apply when there is no TypeScript configuration.

## Build

| Tool | Command | Detection |
|------|---------|-----------|
| Vite | `npx vite build` | `vite.config.js` |
| Webpack | `npx webpack` | `webpack.config.js` |
| Rollup | `npx rollup -c` | `rollup.config.js` |
| esbuild | `npx esbuild src/index.js --bundle --outdir=dist` | `esbuild` in devDependencies |
| Docker | `docker compose build` | `Dockerfile` present |

**Note**: Check `"scripts"` in `package.json` for `"build"`.

## Test

| Runner | Command | Detection |
|--------|---------|-----------|
| Vitest | `npx vitest run` | `vitest.config.js` or `vitest` in devDependencies |
| Jest | `npx jest` | `jest.config.js` or `"jest"` in package.json |
| Mocha | `npx mocha` | `.mocharc.yml` or `mocha` in devDependencies |
| Node test runner | `node --test` | `*.test.js` files without other test framework |

**Note**: Check `"scripts"` in `package.json` for `"test"`.

## Lint

| Tool | Command | Detection | Auto-fix |
|------|---------|-----------|----------|
| ESLint | `npx eslint .` | `eslint.config.js`, `.eslintrc.*` | `npx eslint . --fix` |
| Biome | `npx biome check .` | `biome.json` | `npx biome check . --apply` |
| Prettier | `npx prettier --check .` | `.prettierrc` | `npx prettier --write .` |
| Standard | `npx standard` | `standard` in devDependencies | `npx standard --fix` |

## Security

| Tool | Command |
|------|---------|
| npm audit | `npm audit --audit-level=high` |
| yarn audit | `yarn audit --level high` |
| pnpm audit | `pnpm audit --audit-level high` |
| Snyk | `npx snyk test` |

## Code Conventions

### Style
- Use `const` over `let`; never use `var`
- ESM imports (`import/export`) preferred over CommonJS (`require/module.exports`) in new code
- JSDoc comments on public functions for IDE support (since no TypeScript types)
- Consistent naming: camelCase for variables/functions, PascalCase for classes/components
- Imports ordered: node builtins → third-party → project modules → relative

### Error Handling
- Always validate types at function boundaries (no TypeScript to catch type errors)
- Use `Error` objects, not string throws
- Handle all Promise rejections (`try/catch` with `async/await`, or `.catch()`)
- API responses: consistent error shape `{ error: "message" }`

### Module Patterns
- Check `"type"` field in package.json to determine ESM vs CommonJS
- Don't mix `import` and `require` in the same file
- Use `.mjs` / `.cjs` extensions only when mixing module types is unavoidable

## Hook Configuration

### post_edit_lint
```python
LINT_COMMAND = ["npx", "eslint", "--quiet"]
FILE_EXTENSIONS = [".js", ".jsx", ".mjs"]
```

## Permission Whitelist
```json
[
  "Bash(npx vitest:*)",
  "Bash(npx jest:*)",
  "Bash(npx eslint:*)",
  "Bash(npm audit:*)",
  "Bash(npm install:*)",
  "Bash(npm run:*)"
]
```

## Common Frameworks

| Framework | Type | Detection |
|-----------|------|-----------|
| React | Frontend | `react` in dependencies |
| Vue | Frontend | `vue` in dependencies |
| Express | Backend | `express` in dependencies |
| Fastify | Backend | `fastify` in dependencies |
| Hono | Backend | `hono` in dependencies |
