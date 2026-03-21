---
name: debug
description: "Investigation-first bug resolution: triage → investigate → fix → verify → PR. Use when the user says /debug followed by an issue number, error description, or log output."
argument-hint: "<issue-number-or-error-description>"
user-invocable: true
---

# Debug — Investigation-First Bug Resolution

Resolve bugs through structured investigation before attempting fixes. Reproduces the issue,
diagnoses root cause using code tracing, git bisect, container logs, and available MCP tools,
then applies a minimal targeted fix with a regression test.

Follow the instructions in [workflow.md](workflow.md).
