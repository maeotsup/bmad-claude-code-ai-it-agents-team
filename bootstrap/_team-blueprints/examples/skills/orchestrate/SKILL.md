---
name: orchestrate
description: "Full SDLC pipeline: analyze → design → implement → test → review → PR. Use when the user says /orchestrate followed by an issue number or description."
argument-hint: "<issue-number-or-description>"
user-invocable: true
---

# Orchestrate — Full SDLC Pipeline

Run the complete software development lifecycle for a GitHub issue or requirement.
This is the master workflow that coordinates all agents through 6 stages with human
approval gates between each stage.

Follow the instructions in [workflow.md](workflow.md).
