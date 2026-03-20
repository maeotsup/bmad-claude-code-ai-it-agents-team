---
name: tdd
description: "Test-driven development: write failing tests first, then implement until they pass. Use when the user says /tdd followed by a requirement."
argument-hint: "<requirement-description>"
user-invocable: true
---

# TDD Workflow (Red → Green → Refactor)

Write failing tests first, then implement until tests pass. Uses the **tester** (Katrin) and **developer** (Madis) agents in alternating cycles.

## Steps

### Step 1: RED — Write Failing Tests

1. Invoke the **tester** agent with the requirement ($ARGUMENTS)
2. Tester writes test functions that define the expected behavior
3. Tester runs the project's test suite — tests should **fail** (confirming they test something new)
4. If tests pass immediately, they're not testing new behavior — tester rewrites them

**GATE**: Show the failing tests. Ask the user:
- **[C] Continue** → proceed to implementation
- **[E] Edit** → adjust test expectations
- **[S] Stop** → abort

**HALT**: Wait for user selection before proceeding.

### Step 2: GREEN — Implement Until Tests Pass

1. Invoke the **developer** agent with the failing tests as the specification
2. Developer implements the minimum code to make tests pass
3. Developer runs the test suite after each change
4. Loop until all tests pass (max 5 iterations)

**GATE**: Show test results. If all pass:
- **[C] Continue** → proceed to refactor
- **[S] Stop** → done without refactoring

**HALT**: Wait for user selection before proceeding.

### Step 3: REFACTOR (optional)

1. Review implementation for code quality and adherence to project conventions
2. Clean up without changing behavior
3. Run tests again to confirm they still pass

## Completion

- All tests pass
- Code is clean and follows conventions from `.claude/rules/`
- Commits pushed to origin
