---
name: verify
description: "Run the combined test + lint + security validation suite. Use when the user says /verify."
user-invocable: true
---

# Verify — Combined Validation Suite

Run the project's test suite, linter, and security scanner in sequence and report consolidated results.

## Steps

### 1. Tests

Execute the project's configured test command (the `/test` command).
Record: passed, failed, skipped, errors.

### 2. Lint

Execute the project's configured lint command (the `/lint` command).
Record: warnings, errors.

### 3. Security

Execute the project's configured security scan command (the `/security` command).
Record: critical, high, medium, low findings.

## Output

```
## Verification Results

| Check    | Status    | Details                      |
|----------|-----------|------------------------------|
| Tests    | PASS/FAIL | X passed, Y failed           |
| Lint     | PASS/FAIL | X warnings, Y errors         |
| Security | PASS/FAIL | X high, Y medium             |

**Overall**: PASS / FAIL
```

If all pass: "Ready for PR creation. Run `/pre-pr` to create PR with full review."
If any fail: Show details and suggest fixes.
