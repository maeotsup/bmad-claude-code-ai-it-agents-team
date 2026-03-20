# Blazor — Framework Knowledge

**Applies to**: C# projects with `Microsoft.AspNetCore.Components` references
**Type**: Frontend framework (runs in browser via WebAssembly or on server via SignalR)

## Detection Signals

- `Microsoft.AspNetCore.Components` or `Microsoft.AspNetCore.Components.WebAssembly` in .csproj
- `*.razor` component files
- `_Imports.razor` with `@using Microsoft.AspNetCore.Components`
- `App.razor` root component
- `wwwroot/` with `index.html` (WASM) or `_Host.cshtml` (Server)

## Hosting Models

| Model | Detection | Trade-offs |
|-------|-----------|------------|
| **Blazor WebAssembly** | `Microsoft.AspNetCore.Components.WebAssembly.Server` or standalone WASM project | Runs in browser, larger initial download, offline-capable |
| **Blazor Server** | `AddServerSideBlazor()` in Program.cs, `_Host.cshtml` | Runs on server via SignalR, thin client, requires constant connection |
| **Blazor United / Web App** (.NET 8+) | `AddRazorComponents().AddInteractiveServerComponents()` | Hybrid: static SSR + interactive islands, preferred for new projects |

## Build / Run

| Action | Command |
|--------|---------|
| Dev | `dotnet watch run` (hot reload for Razor components) |
| Build | `dotnet build` |
| Publish WASM | `dotnet publish -c Release` (outputs to `wwwroot/_framework/`) |
| Test | `dotnet test` (+ bUnit for component tests) |

## Additional Rules (extend C# rules)

### Components
- One component per `.razor` file; file name matches component name in PascalCase
- Component parameters: `[Parameter] public string Title { get; set; }`
- Cascading parameters: `[CascadingParameter]` for theme, auth state, layout data
- Keep components under 150 lines; extract child components and code-behind (`.razor.cs`)
- Use `@code { }` block for simple logic; code-behind partial class for complex components

### Rendering and Lifecycle
- `OnInitializedAsync()` for data loading on first render
- `OnParametersSetAsync()` when parameters change
- `OnAfterRenderAsync(bool firstRender)` for JS interop and DOM access
- `StateHasChanged()` to trigger manual re-render — avoid calling in loops
- `ShouldRender()` override to prevent unnecessary re-renders

### Data Binding
- One-way: `@value` in markup
- Two-way: `@bind-Value` for form inputs
- Event callbacks: `EventCallback<T>` for parent-child communication
- Use `EditForm` with `DataAnnotationsValidator` for form validation

### Render Modes (.NET 8+ Web App)
- `@rendermode InteractiveServer` — server-side interactivity via SignalR
- `@rendermode InteractiveWebAssembly` — client-side via WASM
- `@rendermode InteractiveAuto` — server first, then WASM after download
- Static SSR by default (no `@rendermode`) — fastest, no interactivity
- Choose the least interactive mode that meets the requirement

### State Management
- Component state: fields in `@code` block
- Cascading values for tree-wide state (auth, theme)
- Scoped services for per-circuit state (Blazor Server)
- `ProtectedBrowserStorage` or `localStorage` via JS interop for persistence
- Never store sensitive data in browser storage (WASM)

### JavaScript Interop
- `IJSRuntime.InvokeAsync<T>("functionName", args)` for calling JS from C#
- `[JSInvokable]` attribute for calling C# from JS
- Minimize JS interop — prefer Blazor-native solutions when available
- Dispose `IJSObjectReference` in `IAsyncDisposable.DisposeAsync()`

### Navigation
- `NavigationManager` for programmatic navigation
- `<NavLink>` component for navigation links with active state
- Route parameters: `@page "/users/{Id:int}"`
- Query parameters: `[SupplyParameterFromQuery]` (.NET 8+)

### Testing
- **bUnit** (`bunit`) for component unit testing — the standard Blazor test library
- Test component rendering: `var cut = RenderComponent<MyComponent>(p => p.Add(x => x.Title, "Test"))`
- Test user interaction: `cut.Find("button").Click()`
- Assert markup: `cut.MarkupMatches("<p>Expected</p>")`
- Mock services via bUnit's built-in service registration
- Integration tests: `WebApplicationFactory` for full server-side testing

### Accessibility
- Blazor renders standard HTML — all WCAG rules apply
- Use native HTML elements (`<button>`, `<input>`) over custom interactive divs
- `<InputText>`, `<InputSelect>` components render accessible form elements
- Add `aria-*` attributes directly in Razor markup
- `<ErrorBoundary>` should show accessible error messages, not just crash silently
- `<FocusOnNavigate>` component for managing focus after page navigation

### Security
- `[Authorize]` attribute on pages/components for auth gating
- `AuthorizeView` component for conditional UI: `<Authorized>` / `<NotAuthorized>`
- Never trust client-side validation alone — always validate on the server
- Blazor WASM: all code is downloadable — never embed secrets or sensitive logic
- Blazor Server: SignalR connection is authenticated but circuit state can be tampered with
- Use `AntiforgeryToken` for form submissions
- CORS configuration required when WASM app calls a separate API host
