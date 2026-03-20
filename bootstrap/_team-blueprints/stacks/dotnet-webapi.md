# ASP.NET Web API — Framework Knowledge

**Applies to**: C# projects with `Microsoft.AspNetCore` SDK
**Type**: Backend API framework

## Detection Signals

- `<Project Sdk="Microsoft.NET.Sdk.Web">` in .csproj
- `Program.cs` with `WebApplication.CreateBuilder()` (minimal API) or `CreateHostBuilder()`
- `Controllers/` directory with `*Controller.cs` files (controller-based)
- `app.MapGet()` / `app.MapPost()` patterns (minimal API)
- `appsettings.json` configuration file

## Run

| Action | Command |
|--------|---------|
| Dev | `dotnet run` or `dotnet watch run` (hot reload) |
| Build | `dotnet build` |
| Publish | `dotnet publish -c Release` |
| Migrations | `dotnet ef migrations add <Name>` → `dotnet ef database update` |

## Additional Rules (extend C# rules)

### API Style: Minimal API vs Controllers

**Minimal API** (.NET 6+, preferred for new simple APIs):
```csharp
app.MapGet("/api/users/{id}", async (int id, IUserService svc) => await svc.GetAsync(id));
```

**Controllers** (preferred for complex APIs):
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase { }
```

Choose one style per project; don't mix unless migrating.

### Routing
- RESTful routes: `GET /api/resources`, `POST /api/resources`, `GET /api/resources/{id}`
- Use `[Route]` attributes on controllers (attribute routing)
- Return `IActionResult` or `ActionResult<T>` for flexible responses
- Use `TypedResults` (minimal API) for compile-time-safe responses

### Request Validation
- Data annotations: `[Required]`, `[StringLength]`, `[Range]` on model properties
- FluentValidation for complex validation rules
- `[ApiController]` attribute enables automatic model validation (returns 400 on invalid)
- Validate at the boundary — services trust their inputs are pre-validated

### Response Patterns
- Success: `Ok(data)`, `Created(uri, data)`, `NoContent()`
- Client errors: `BadRequest(details)`, `NotFound()`, `Unauthorized()`
- Use `ProblemDetails` (RFC 7807) for error responses — built-in from .NET 7
- Never return raw exception details

### Authentication / Authorization
- JWT Bearer: `AddAuthentication().AddJwtBearer()`
- `[Authorize]` attribute on controllers or endpoints
- Policy-based authorization for role/claim checks
- Always validate tokens server-side; never trust client claims

### Middleware Pipeline
- Order matters: Exception handler → HTTPS redirect → Auth → CORS → Endpoints
- Custom middleware for cross-cutting concerns (logging, timing, tenant resolution)
- Use `app.UseExceptionHandler()` for global error handling

### Configuration
- `appsettings.json` + `appsettings.{Environment}.json` for environment-specific config
- Bind to strongly-typed options classes via `IOptions<T>`
- User secrets for local development: `dotnet user-secrets set "Key" "Value"`
- Never store secrets in `appsettings.json` — use environment variables or Key Vault

### Testing
- Integration tests with `WebApplicationFactory<Program>` (in-memory test server)
- Unit tests: mock `IService` interfaces with Moq or NSubstitute
- Test controllers by calling action methods with mocked dependencies
- Test middleware and filters independently
- Use `HttpClient` from `WebApplicationFactory` for full HTTP pipeline tests

### Database (Entity Framework Core)
- `DbContext` registered as scoped service
- Code-first migrations: `dotnet ef migrations add` → `dotnet ef database update`
- Use `async` methods: `ToListAsync()`, `FirstOrDefaultAsync()`, `SaveChangesAsync()`
- Repository/Unit of Work patterns optional — EF Core's `DbContext` already implements both
- Always use `CancellationToken` in async DB calls

### Security
- Enable HTTPS redirect: `app.UseHttpsRedirection()`
- CORS: configure specific origins, not `AllowAnyOrigin()` in production
- Anti-forgery for MVC forms (automatic with `[ValidateAntiForgeryToken]`)
- Rate limiting: `app.UseRateLimiter()` (.NET 7+)
- SQL injection: EF Core parameterizes automatically; if using raw SQL, use `FromSqlInterpolated()`
