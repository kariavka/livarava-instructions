---
description: "Use when versioning or releasing the shared LivaRava instruction repository. Defines the version source, compatibility rules, changelog, and release tags."
applyTo: "**/livarava-instructions/**"
---
# Instruction Repository Versioning

These rules apply to this shared instruction repository, not to the versions
of projects that consume its instructions.

## Version source

- Keep the version of the entire instruction set in the root `VERSION` file.
- Store only a `MAJOR.MINOR.PATCH` value followed by a newline, without a `v` prefix.
- Start at `1.0.0`. Do not version individual instruction files independently.

## Choosing a version

- Increment PATCH for wording corrections and clarifications that do not change requirements.
- Increment MINOR for new instructions or compatible additions that do not require consuming projects to change existing compliant behavior.
- Increment MAJOR for changes to mandatory rules that require consuming projects to adapt.
- Reset lower components to zero when incrementing MAJOR or MINOR.
- Choose the highest applicable increment for the release as a whole.
- Bump the version for a release containing an agreed set of changes, not for every commit.

## Release records

- Update `VERSION` and the root `CHANGELOG.md` together in the release commit.
- Record each release under its version and release date (`YYYY-MM-DD`), newest first.
- Describe meaningful changes and any required migration steps in concise bullets.
- Keep pending changes under `Unreleased` when needed; move them into the dated release entry when releasing.
- Follow `commit.instructions.md` for the commit message. End its summary paragraph with `Bumped version to <version>.` only when the commit actually changes `VERSION`, including its initial addition.
- After committing the release, create an annotated Git tag named `v<version>` on that release commit (for example, `v1.0.0`).
- Verify that the tag, `VERSION`, and changelog release entry agree. Never move an existing release tag to different content.
