---
name: figma
description: "Translate a Figma design into accurate, production-ready UI code. Use when the user says /figma followed by a design file path, screenshot, or URL."
argument-hint: "<figma-design-path-screenshot-or-url>"
user-invocable: true
---

# Figma-to-Code Workflow

Translate a Figma design into production-ready UI code by invoking the **analyst** (Anna), **architect** (Indrek), and **developer** (Madis) agents sequentially with human approval gates. No existing issue or requirements document is needed — the design IS the specification.

## Steps

### Step 1: EXTRACT DESIGN SPEC

1. Load project config from `_bmad/config/config.yaml`
2. Read the Figma design input ($ARGUMENTS) — accepts a screenshot image path, exported design file, or Figma URL
3. If a URL is provided, fetch the page or prompt the user for an exported screenshot
4. Invoke the **analyst** agent with the design to extract a visual specification:
   - Component inventory (buttons, forms, cards, navigation, modals, etc.)
   - Layout structure (grid, flex, spacing, responsive breakpoints)
   - Visual tokens (colors, typography, border radii, shadows, spacing scale)
   - Interactive states (hover, focus, active, disabled, loading, error)
   - Content inventory (text content, images, icons, placeholder data)
5. Save output to `_bmad-output/figma-<slug>/design-spec.md`

**GATE**: Show the extracted design specification. Ask the user:
- **[C] Continue** → proceed to component design
- **[E] Edit** → provide corrections or missing details, analyst re-runs
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

### Step 2: PLAN COMPONENTS

1. Invoke the **architect** agent with the design specification from Step 1 and the original design
2. The architect produces a component architecture:
   - Component hierarchy and file structure
   - Props and interfaces for each component
   - Styling approach (following project conventions from `.claude/rules/`)
   - Responsive behavior plan (breakpoints, layout shifts)
   - Accessibility requirements per component (ARIA roles, keyboard navigation, contrast)
3. Save output to `_bmad-output/figma-<slug>/component-architecture.md`

**GATE**: Show the component architecture. Ask the user:
- **[C] Continue** → proceed to implementation
- **[E] Edit** → provide feedback, architect re-runs
- **[S] Stop** → abort workflow

**HALT**: Wait for user selection before proceeding.

### Step 3: IMPLEMENT

1. Invoke the **developer** agent with the component architecture, design specification, and original design
2. Developer creates a feature branch in a worktree
3. Implements each component following the architecture plan:
   - Builds from smallest components (atoms) to largest (pages/layouts)
   - Matches the design's visual tokens precisely (colors, spacing, typography, radii)
   - Implements responsive breakpoints as specified
   - Adds accessibility attributes (ARIA labels, roles, keyboard handlers)
   - Validates each file with the project's linter
4. Commits and pushes to origin after each logical component unit

**GATE**: Show implementation summary with file list and diff stats. Ask the user:
- **[C] Continue** → implementation complete
- **[E] Edit** → provide visual feedback, developer adjusts
- **[S] Stop** → abort (branch preserved on origin)

**HALT**: Wait for user selection before proceeding.

## Completion

Inform user:
- Implementation branch and commit list
- Component files created with file paths
- To verify accessibility: `/code-review`
- To run full review pipeline: `/pre-pr`
- To create PR directly: use `gh pr create`
