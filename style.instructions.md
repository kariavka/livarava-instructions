---
name: LivaRava Style Refactor Rules
description: "Use when auditing, writing, organizing, or refactoring SCSS/CSS in LivaRava projects, including stylesheet ownership cleanup and styled-components migration."
applyTo: "**/*.scss, **/*.css, **/package.json, **/package-lock.json, **/yarn.lock, **/pnpm-lock.yaml"
---
# Style Guidelines

## Scope and intent

- Preserve current visual design and behavior unless the user explicitly asks to change it.
- Adapt to the target project's existing architecture; do not copy another project blindly.
- Avoid unrelated edits and do not overwrite user changes.

## Discovery before edits

- Inventory stylesheets, app entry points, and all style imports.
- Trace major pages/components to map selectors to real usage.
- Identify duplicated selectors/declarations, stale rules, misplaced rules, and durable inline styles that belong in stylesheets.
- Inspect `livarava-www` and `livarava-mail` when available for reusable patterns, components, and style decisions.

## File ownership and structure

- Prefer this ownership model (or equivalent existing structure):
  - `globals.scss`: app-wide global styles and global fixes.
  - `livarava.scss`: project-wide styles.
  - `header.scss`: header-only styles.
  - `footer.scss`: footer-only styles.
  - `mail.scss` or `<subproject>.scss`: subproject/component-specific styles.
- Put each rule in the file that owns it.
- Keep shared styles project-neutral; use project-specific selectors only for truly project-specific behavior.
- Import each stylesheet once from the proper app entry point, in cascade-safe order.
- After moving rules, remove stale/duplicate/conflicting declarations and do not leave copies behind.

## Reuse and migration policy

- Reuse established styles/components from `livarava-www` or `livarava-mail` before inventing new ones.
- Validate compatibility of reused patterns (deps, routing, data assumptions, responsiveness) before adoption.
- If Footer is outdated, align with current footer grouping/link structure from `livarava-www`, adapting URLs/data as needed.

## styled-components and inline styles

- Replace `styled-components` with SCSS ownership-based styles wherever safe.
- Keep `styled-components` only where removal would be unsafe or would materially degrade dynamic styling/theming.
- Move durable presentation inline styles into owning stylesheets when behavior can be preserved.
- If `styled-components` usage drops to zero, remove it from `package.json` and update lockfiles.

## Dependency updates (style-related)

- Review style-related dependency versions when needed.
- Update only compatible versions that fit runtime/framework constraints.
- Do not perform risky blind major upgrades; report packages that must remain pinned and why.

## Validation checklist

- Confirm style ownership is correct and imports are not duplicated.
- Confirm no stale/conflicting declarations remain.
- Verify representative pages/components across relevant breakpoints and touched interactive states.
- Run applicable diagnostics/lint/tests/build for the repository.
- Report changed files, deviations, remaining `styled-components` (if any), and checks not executed.
