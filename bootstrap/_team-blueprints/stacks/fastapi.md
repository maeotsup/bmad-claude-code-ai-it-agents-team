# FastAPI — Framework Knowledge

**Applies to**: Python projects with `fastapi` in requirements
**Type**: Backend API framework

## Detection Signals

- `fastapi` in requirements.txt, pyproject.toml, or Pipfile
- `from fastapi import FastAPI` in source files
- `uvicorn` in requirements (ASGI server)
- `app = FastAPI()` pattern

## Run

| Action | Command |
|--------|---------|
| Dev | `uvicorn app:app --reload --host 0.0.0.0 --port 8000` |
| Production | `uvicorn app:app --workers 4` or via Docker |
| Docs | Auto-generated at `/docs` (Swagger) and `/redoc` |

## Additional Rules (extend Python rules)

### Routes
- Path operations: `@app.get()`, `@app.post()`, etc.
- Use path parameters for resource IDs: `/users/{user_id}`
- Use query parameters for filters: `/users?active=true&role=admin`
- Group routes with `APIRouter` — one router per resource/domain
- Return Pydantic models (response_model) for type-safe, documented responses

### Pydantic Models
- Request bodies: define as Pydantic `BaseModel` subclasses
- Response models: separate from request models (don't expose internal fields)
- Use `Field()` for validation: min/max length, regex, default values
- Pydantic v2 preferred (better performance, `model_validator`)

### Dependency Injection
- Use `Depends()` for shared logic: database sessions, auth, pagination
- Dependencies can be nested and cached per-request
- Use `yield` dependencies for setup/teardown (DB connections, file handles)

### Async
- FastAPI supports both `async def` and `def` route handlers
- Use `async def` when doing I/O (database, HTTP calls, file operations)
- Use `def` (sync) for CPU-bound operations — FastAPI runs these in a thread pool
- Never mix `asyncio.run()` inside an async handler

### Templates (if using Jinja2)
- `Jinja2Templates` for server-side rendered pages
- Templates in `templates/` directory
- Static files via `StaticFiles` mount
- Autoescaping is ON by default — do not use `|safe` with user content

### Security
- OAuth2 with `OAuth2PasswordBearer` for token auth
- Use `Depends()` for auth checks on protected routes
- Validate all inputs via Pydantic (automatic from type annotations)
- CORS: configure `CORSMiddleware` with explicit origins
- Never expose internal error details — use `HTTPException` with safe messages

### Testing
- Use `httpx.AsyncClient` with `ASGITransport` for async endpoint tests
- Test database: separate test DB or in-memory SQLite
- Override dependencies with `app.dependency_overrides` for mocking
- Test both happy paths and error cases (400, 401, 404, 422)

### Database
- SQLAlchemy (async with `asyncpg`) or raw `sqlite3`/`aiosqlite`
- Connection per-request via `Depends()` with `yield`
- Alembic for migrations (SQLAlchemy), or manual `init_db()` for SQLite
