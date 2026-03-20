# Razor Pages — Framework Knowledge

**Applies to**: C# projects using ASP.NET Core Razor Pages for server-rendered web UI
**Type**: Full-stack server-rendered framework (page-based, simpler than MVC)

## Detection Signals

- `*.cshtml` page files paired with `*.cshtml.cs` page models
- `Pages/` directory structure (not `Views/` + `Controllers/`)
- `builder.Services.AddRazorPages()` in Program.cs
- `app.MapRazorPages()` in middleware pipeline
- `_ViewStart.cshtml` and `_Layout.cshtml` in Pages/Shared/

## Distinguishing from MVC

| Signal | Razor Pages | MVC |
|--------|-------------|-----|
| File pairs | `Page.cshtml` + `Page.cshtml.cs` | `View.cshtml` (no code-behind) |
| Directory | `Pages/` | `Views/` + `Controllers/` |
| Routing | File-based: `Pages/Users/Index.cshtml` → `/Users` | Controller-based: `UsersController.Index()` → `/Users` |
| Registration | `AddRazorPages()` | `AddControllersWithViews()` |

## Build / Run

| Action | Command |
|--------|---------|
| Dev | `dotnet watch run` (hot reload for Razor pages) |
| Build | `dotnet build` |
| Publish | `dotnet publish -c Release` |
| Test | `dotnet test` |

## Additional Rules (extend C# rules)

### Page Structure
- Each page is a pair: `MyPage.cshtml` (markup) + `MyPage.cshtml.cs` (PageModel)
- PageModel contains handlers: `OnGet()`, `OnPostAsync()`, `OnPutAsync()`
- Use `[BindProperty]` for form data binding on POST
- Use `[BindProperty(SupportsGet = true)]` only when query string binding is needed
- Keep PageModel logic thin — delegate to services for business logic

### Routing
- Convention-based: file path maps to URL (`Pages/Products/Details.cshtml` → `/Products/Details`)
- Route parameters: `@page "{id:int}"` in .cshtml directive
- Custom routes: `@page "/custom/path/{id}"` overrides convention
- Areas: `Pages/Admin/` with `@page` directives for admin sections

### Razor Syntax
- `@{ }` for C# code blocks
- `@Model.Property` for rendering model values (auto-HTML-encoded)
- `@Html.Raw()` only with sanitized content — never with user input
- Tag Helpers: `<a asp-page="/Products/Details" asp-route-id="@item.Id">`
- Partial views: `<partial name="_ProductCard" model="@item" />`
- View components for complex reusable UI logic

### Forms and Validation
- `<form method="post">` with automatic anti-forgery token
- `[BindProperty]` on PageModel properties for model binding
- Data annotations: `[Required]`, `[StringLength]`, `[EmailAddress]` on model properties
- Client-side validation: include `_ValidationScriptsPartial.cshtml`
- Server-side: check `ModelState.IsValid` in `OnPost` handlers
- Return `Page()` on validation failure to redisplay with errors

### Layouts and Partials
- `_Layout.cshtml` in `Pages/Shared/` for site-wide layout
- `@RenderBody()` for page content, `@RenderSection("Scripts", required: false)` for page scripts
- `_ViewImports.cshtml` for shared `@using` and `@addTagHelper` directives
- `_ViewStart.cshtml` sets default layout: `@{ Layout = "_Layout"; }`

### Tag Helpers
- `asp-page` for page links: `<a asp-page="/Users/Details" asp-route-id="5">`
- `asp-for` for form inputs: `<input asp-for="Email" />` (generates name, id, validation attributes)
- `asp-validation-for` for validation messages: `<span asp-validation-for="Email"></span>`
- `asp-append-version="true"` on static file links for cache busting
- Custom Tag Helpers for reusable UI patterns

### Security
- Anti-forgery tokens: automatic in `<form method="post">` with Tag Helpers
- `[ValidateAntiForgeryToken]` is implicit for Razor Pages POST handlers
- `[Authorize]` attribute on PageModel class or in conventions: `options.Conventions.AuthorizePage("/Admin")`
- Never render user input with `@Html.Raw()` — use `@Model.Value` (auto-encoded)
- HTTPS: `app.UseHttpsRedirection()` in middleware pipeline
- Cookie auth: `AddAuthentication().AddCookie()` with `[Authorize]` on protected pages

### Testing
- Integration tests: `WebApplicationFactory<Program>` with `HttpClient` for full page requests
- Test page handlers: instantiate PageModel, set dependencies, call `OnGetAsync()`, assert results
- Use `AngleSharp` to parse and assert HTML responses in integration tests
- Test anti-forgery: extract token from form, include in POST requests
- Test authorization: verify redirect to login for unauthenticated requests

### Accessibility
- Razor Pages render standard HTML — all WCAG rules apply
- Use Tag Helpers (`asp-for`) — they generate proper `id` and `name` attributes for label association
- Add `<label asp-for="Field">` for every form input
- Use semantic HTML: `<nav>`, `<main>`, `<article>`, `<section>`
- Include `lang` attribute on `<html>` element in `_Layout.cshtml`
- Heading hierarchy: one `<h1>` per page, sequential `<h2>` → `<h3>`
