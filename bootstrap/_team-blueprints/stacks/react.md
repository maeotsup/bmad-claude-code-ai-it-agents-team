# React — Framework Knowledge

**Applies to**: JavaScript, TypeScript projects with `react` in dependencies
**Type**: Frontend library

## Detection Signals

- `react` and `react-dom` in package.json dependencies
- `*.jsx` or `*.tsx` component files
- Often paired with: Vite, Next.js, Create React App, Remix

## Additional Rules (extend language rules)

### Components
- Functional components only (no class components in new code)
- One component per file; file name matches component name in PascalCase
- Props interfaces/types defined above the component or in a separate types file
- Use `React.FC` sparingly — prefer explicit props typing
- Keep components under 150 lines; extract sub-components when they grow

### State Management
- Local state: `useState` for simple, `useReducer` for complex
- Shared state: Context API for small apps, Zustand/Redux for larger ones
- Side effects: `useEffect` with proper dependency arrays; clean up subscriptions
- Avoid prop drilling beyond 2 levels — use Context or state management

### Hooks
- Custom hooks: prefix with `use`, one concern per hook
- Never call hooks conditionally or inside loops
- Memoize expensive computations: `useMemo` for values, `useCallback` for functions
- Don't over-memoize — only when there's a measured performance issue

### Testing Patterns
- Component tests with React Testing Library (`@testing-library/react`)
- Test behavior (what the user sees), not implementation details
- Use `screen.getByRole`, `getByText`, `getByLabelText` — avoid `getByTestId`
- User events with `@testing-library/user-event`

### Accessibility
- All images need `alt` text
- Interactive elements must be focusable (use native `<button>`, not `<div onClick>`)
- Form inputs require associated `<label>` elements
- Use ARIA attributes only when native HTML semantics are insufficient

## Security Patterns
- Never use `dangerouslySetInnerHTML` with user-provided content
- Sanitize any HTML content with DOMPurify before rendering
- API keys belong in environment variables, not component code
