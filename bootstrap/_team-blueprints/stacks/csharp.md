# C# — Stack Knowledge

## Detection Signals

| Signal | Pattern |
|--------|---------|
| Primary | `*.csproj`, `*.sln` |
| Files | `*.cs` in project directories |
| SDK | `<Project Sdk="Microsoft.NET.Sdk...">` in .csproj |
| Global config | `global.json` (SDK version), `Directory.Build.props` |
| NuGet | `*.nupkg`, `nuget.config`, `<PackageReference>` in .csproj |

## Build

| Tool | Command | Detection |
|------|---------|-----------|
| dotnet CLI | `dotnet build` | Any `*.csproj` or `*.sln` |
| dotnet publish | `dotnet publish -c Release` | Production build |
| Docker | `docker compose build` | `Dockerfile` present |

**Note**: For solutions with multiple projects, `dotnet build` at solution root builds all.

## Test

| Runner | Command | Detection |
|--------|---------|-----------|
| dotnet test | `dotnet test --verbosity normal` | Test projects with `<IsTestProject>true</IsTestProject>` |
| xUnit | `dotnet test` | `xunit` NuGet reference in test .csproj |
| NUnit | `dotnet test` | `NUnit` NuGet reference in test .csproj |
| MSTest | `dotnet test` | `MSTest.TestFramework` NuGet reference |

### Run patterns
- Single project: `dotnet test tests/MyProject.Tests/`
- Filter: `dotnet test --filter "FullyQualifiedName~ClassName"`
- Category: `dotnet test --filter "Category=Integration"`

All three frameworks use `dotnet test` as the command — the framework only affects test authoring patterns.

## Lint

| Tool | Command | Detection | Auto-fix |
|------|---------|-----------|----------|
| dotnet format | `dotnet format --verify-no-changes` | Any .NET 6+ project | `dotnet format` |
| Roslyn analyzers | Built into `dotnet build` | `<TreatWarningsAsErrors>` in .csproj | Some via `dotnet format` |
| StyleCop | Build warnings | `StyleCop.Analyzers` NuGet reference | N/A |
| SonarAnalyzer | Build warnings | `SonarAnalyzer.CSharp` NuGet reference | N/A |

**Preferred**: `dotnet format` (built-in) + Roslyn analyzers via `.editorconfig`

## Security

| Tool | Command | Detection |
|------|---------|-----------|
| dotnet list vulnerable | `dotnet list package --vulnerable --include-transitive` | Any .NET project |
| Security Code Scan | Build warnings | `SecurityCodeScan.VS2019` NuGet reference |
| Snyk | `snyk test --file=MyProject.sln` | Any .NET solution |

**Note**: `dotnet list package --vulnerable` is built-in from .NET 7+ and requires no additional tools.

## Code Conventions

### Style
- C# 10+ features: file-scoped namespaces, global usings, record types
- Follow `.editorconfig` if present (standard for .NET projects)
- PascalCase for public members, methods, properties, classes
- camelCase with `_` prefix for private fields (e.g., `_logger`)
- One class per file; file name matches class name
- Use `var` when the type is obvious from the right side
- Prefer primary constructors (C# 12+) for simple DI

### Async Patterns
- Suffix async methods with `Async` (e.g., `GetUserAsync`)
- Always use `async/await`, never `.Result` or `.Wait()` (deadlock risk)
- Use `CancellationToken` in all async API methods
- Return `Task` or `ValueTask`, not `void` (except event handlers)

### Dependency Injection
- Register services in `Program.cs` or `Startup.cs`
- Use constructor injection, not service locator
- Scoped for per-request services, Singleton for stateless services
- Interface-based abstractions for testability

### Error Handling
- Catch specific exceptions, not bare `catch (Exception)`
- Use `ProblemDetails` for API error responses (RFC 7807)
- Global exception middleware for unhandled errors
- Log with structured logging (ILogger with message templates)
- Never expose stack traces in production

### Database Patterns
- Use Entity Framework Core or Dapper (most common)
- Migrations: `dotnet ef migrations add <Name>` → `dotnet ef database update`
- Always use parameterized queries (EF Core does this automatically)
- Use `DbContext` scoping (one per request via DI)

## Hook Configuration

### pre_bash_guard — Additional Patterns
```python
(r"\bdotnet\s+ef\s+database\s+drop\b", "Blocked: dropping database"),
(r"\bdotnet\s+ef\s+migrations\s+remove\b", "Blocked: removing migration without review"),
```

### post_edit_lint
```python
LINT_COMMAND = ["dotnet", "format", "--verify-no-changes", "--include"]
FILE_EXTENSIONS = [".cs"]
```

**Note**: `dotnet format` works on the whole project by default. For single-file lint, use:
`dotnet format --include {file} --verify-no-changes`

## Permission Whitelist
```json
[
  "Bash(dotnet test:*)",
  "Bash(dotnet build:*)",
  "Bash(dotnet format:*)",
  "Bash(dotnet run:*)",
  "Bash(dotnet list package:*)",
  "Bash(dotnet ef:*)"
]
```

## Common Frameworks

| Framework | Type | Detection |
|-----------|------|-----------|
| ASP.NET Web API | Backend API | `Microsoft.AspNetCore` SDK, controllers or minimal API |
| ASP.NET MVC | Full-stack | Razor views (`.cshtml`) + controllers |
| Blazor | Frontend | `Microsoft.AspNetCore.Components` reference |
| MAUI | Desktop/mobile | `Microsoft.Maui` reference |
| Worker Service | Background | `Microsoft.Extensions.Hosting` without web SDK |
