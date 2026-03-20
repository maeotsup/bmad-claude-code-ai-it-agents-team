# Next.js — Framework Knowledge

**Applies to**: TypeScript (or JavaScript) projects with `next` in dependencies
**Type**: Full-stack React framework

## Detection Signals

- `next` in package.json dependencies
- `next.config.ts` or `next.config.js` or `next.config.mjs`
- `app/` directory (App Router) or `pages/` directory (Pages Router)

## Build / Run

| Action | Command |
|--------|---------|
| Dev | `npx next dev` |
| Build | `npx next build` |
| Start | `npx next start` |
| Lint | `npx next lint` (built-in ESLint config) |

## Additional Rules (extend TypeScript + React rules)

### App Router (preferred for new projects)
- Pages in `app/` directory as `page.tsx` files
- Layouts as `layout.tsx` — shared UI without re-rendering
- Loading states as `loading.tsx`, errors as `error.tsx`
- Server Components by default — add `"use client"` only when needed
- Route handlers in `app/api/*/route.ts` (not pages/api)

### Pages Router (legacy)
- Pages in `pages/` directory
- API routes in `pages/api/`
- `getServerSideProps` / `getStaticProps` for data fetching

### Data Fetching
- Server Components: `async` component functions with direct `fetch()`
- Client Components: `useEffect` + state, or SWR/React Query
- Server Actions: `"use server"` functions for form submissions and mutations
- Always validate and sanitize inputs in Server Actions

### Rendering Strategy
- Static (SSG): Default for pages without dynamic data
- Dynamic (SSR): Use when data changes per request
- ISR: `revalidate` option for semi-static pages
- Client: `"use client"` for interactive components

### Environment Variables
- `NEXT_PUBLIC_*` prefix for client-exposed variables
- Server-only env vars have no prefix and are NEVER accessible in client code
- Use `.env.local` for local overrides (gitignored)

### Testing
- `next/jest` for Jest configuration
- Or Vitest with `@vitejs/plugin-react`
- Playwright for E2E testing of full pages

### Security
- Never expose server-only secrets via `NEXT_PUBLIC_*` variables
- Validate all inputs in Server Actions and Route Handlers
- Use `headers()` and `cookies()` from `next/headers` for auth checks
- Middleware (`middleware.ts`) for auth guards and redirects
