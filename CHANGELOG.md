# Changelog

## 1.1.0 — 2026-11-16

- Expanded Docker guidance for disk-efficient development workflows: image layer inspection, cache-aware Dockerfile ordering, safe volume lifecycle management, and non-destructive cleanup rules.
- Added an optimization workflow for Docker changes requiring before/after measurement of build performance and storage impact while preserving hot reload and project-specific behavior.

## 1.0.1 — 2026-11-12

- Added `make release` and `make refresh` shortcuts for pushing and pulling the `develop` and `master` branches.
- Documented branch prerequisites, the final branch, and separate handling of release tags.

## 1.0.0 — 2026-11-12

First release of the shared LivaRava instruction set.

- Imported existing instructions for backend and frontend development, APIs, authentication, data conventions, tooling, and testing.
- Included guidance for assistant behavior, UI, localization, analytics, privacy, consent, and cookies.
- Added global agent instructions, commit message rules, and a reusable commit message prompt.
- Established `/home/smart/livarava-instructions/` as the canonical location and updated references to it.
- Documented editor integration and compatibility links, including the `/home/smart/instructions` symlink to the repository root.
- Added version tracking in `VERSION` and rules for release versions, changelog entries, and Git tags.
