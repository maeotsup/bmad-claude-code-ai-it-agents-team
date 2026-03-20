# Angular — Framework Knowledge

**Applies to**: TypeScript projects with `@angular/core` in dependencies
**Type**: Frontend framework

## Detection Signals

- `@angular/core` in package.json dependencies
- `angular.json` in project root
- `*.component.ts`, `*.module.ts`, `*.service.ts` file patterns
- `ng` CLI commands in package.json scripts

## Build / Run

| Action | Command |
|--------|---------|
| Dev | `npx ng serve` |
| Build | `npx ng build` |
| Test | `npx ng test` (Karma) or `npx jest` (if configured) |
| Lint | `npx ng lint` |
| E2E | `npx ng e2e` |

## Additional Rules (extend TypeScript rules)

### Project Structure
- Feature modules: group related components, services, and models
- Standalone components (Angular 14+) preferred over NgModules in new code
- One component/service/pipe per file
- File naming: `{name}.{type}.ts` (e.g., `user-list.component.ts`, `auth.service.ts`)

### Components
- Use `standalone: true` for new components (Angular 14+)
- Template-driven forms for simple cases, reactive forms for complex
- `OnPush` change detection for performance-critical components
- Keep templates under 50 lines; extract child components when they grow
- Use `@Input()` / `@Output()` for parent-child communication
- Signals (Angular 16+) for reactive state management

### Services and DI
- `@Injectable({ providedIn: 'root' })` for singleton services
- Use `inject()` function (Angular 14+) instead of constructor injection in new code
- HTTP calls belong in services, never in components
- Use interceptors for auth tokens, error handling, loading states

### RxJS Patterns
- Prefer `async` pipe in templates over manual subscriptions
- Use `takeUntilDestroyed()` (Angular 16+) for cleanup
- Avoid nested subscriptions — use `switchMap`, `mergeMap`, `concatMap`
- Handle errors with `catchError` in pipes, not try/catch

### Testing
- Component tests with `TestBed.configureTestingModule()`
- Service tests: inject and test methods directly
- Use `HttpClientTestingModule` for HTTP service tests
- Jasmine (default) or Jest (configure via `@angular-builders/jest`)

### Routing
- Lazy-load feature modules: `loadChildren` or `loadComponent`
- Route guards for authentication (`canActivate`, `canMatch`)
- Resolvers for pre-fetching route data

### Security
- Never use `[innerHTML]` with unsanitized user content
- Use Angular's built-in `DomSanitizer` when dynamic HTML is unavoidable
- CSRF: Angular's `HttpClient` includes XSRF token headers automatically
- CSP: Configure Content-Security-Policy headers in the server
