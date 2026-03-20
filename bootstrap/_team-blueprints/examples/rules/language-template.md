# {Language} Conventions

<!-- This is a TEMPLATE showing the structure for language-specific rule files.
     The generator fills in concrete rules based on the detected language/framework.
     Section names and organization pattern should be preserved. -->

## Code Style

- {Version requirement, e.g., "Python 3.11+" or "Node 20+ with ES modules"}
- {Linter and formatter configuration, e.g., line length, quote style}
- {Naming conventions: functions, variables, classes, files}
- {Import ordering convention}
- {Documentation requirements for public APIs}

## Database Patterns

- {Connection lifecycle pattern, e.g., "Always close connections in finally blocks"}
- {Query safety: parameterized queries, ORM usage patterns}
- {Migration strategy: how schema changes are applied}
- {Index requirements for queried columns}

## Error Handling

- {Exception/error handling philosophy: specific vs generic catches}
- {Logging requirements: what context to include}
- {HTTP/API error response conventions: status codes, response format}
- {Never swallow errors silently}

## Imports and Dependencies

- {Import ordering: stdlib → third-party → project}
- {Circular dependency policy}
- {Dependency addition policy: require approval, version pinning}
