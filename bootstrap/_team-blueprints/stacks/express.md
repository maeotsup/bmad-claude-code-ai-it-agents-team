# Express — Framework Knowledge

**Applies to**: JavaScript or TypeScript projects with `express` in dependencies
**Type**: Backend HTTP framework

## Detection Signals

- `express` in package.json dependencies
- `app.listen()` or `express()` in entry file
- Middleware pattern: `app.use()`, `router.get()`, etc.

## Additional Rules (extend JS/TS rules)

### Project Structure
- `routes/` or `controllers/` for route handlers
- `middleware/` for middleware functions
- `models/` or `services/` for business logic
- Entry point: `app.js`/`app.ts` (Express setup) + `server.js`/`server.ts` (listen)

### Routes
- Use `express.Router()` for modular route definitions
- Group routes by resource: `/api/users`, `/api/posts`
- Validate request body/params at route level (using Joi, Zod, or express-validator)
- Return consistent JSON structure: `{ data, error, message }`

### Middleware
- Error middleware must have 4 params: `(err, req, res, next)`
- Order matters: auth middleware before route handlers
- Use `express.json()` for body parsing (built-in since Express 4.16)
- CORS: `cors()` middleware configured for specific origins, not `*` in production

### Error Handling
- Centralized error handler as the last middleware
- Async route handlers: wrap in `try/catch` or use `express-async-errors`
- Never send raw error objects to clients — use status codes + generic messages
- Log errors with request context (method, path, user)

### Security
- Use `helmet` middleware for HTTP security headers
- Rate limiting with `express-rate-limit`
- Never trust `req.body` or `req.params` without validation
- Use parameterized queries for all database operations
- Store secrets in environment variables, not code
- HTTPS in production (terminate at reverse proxy or use `https` module)

### Testing
- Supertest (`supertest`) for HTTP endpoint testing
- Test middleware independently with mock `req`, `res`, `next`
- Integration tests: start server, make requests, assert responses
- Mock external services (databases, APIs) at the service layer

### Database Patterns
- Connection pooling for SQL databases (pg-pool, mysql2/promise)
- Mongoose for MongoDB ODM
- Prisma or Knex.js for SQL query building
- Close connections gracefully on server shutdown (`SIGTERM`)
