# LivaRava shared assistant instructions

Canonical location: `/home/smart/livarava-instructions/`.

- Topic rules are stored in `*.instructions.md`; preserve their front matter.
- VS Code loads this directory through `chat.instructionsFilesLocations` in
  `/home/smart/.vscode-server/data/User/settings.json`.
- VS Code Source Control commit-message generation explicitly loads
  `commit.instructions.md` through
  `github.copilot.chat.commitMessageGeneration.instructions` in the shared
  remote user settings and project workspace settings.
- `/home/smart/.vscode-server/data/User/prompts` is a compatibility symlink here.
- `/home/smart/.codex/AGENTS.md` links to this directory's `AGENTS.md`.
- Project references should point directly to `/home/smart/livarava-instructions/`.

Edit these canonical files rather than making independent copies in editor
configuration directories. Keep topic guidance in its matching instruction file.

`/home/smart/instructions` is a compatibility symlink to this repository root.

## Versioning

The current instruction set version is stored in [VERSION](./VERSION).
Release history is recorded in [CHANGELOG.md](./CHANGELOG.md).
Follow [versioning.instructions.md](./versioning.instructions.md) when preparing
releases. Release commits are tagged as `v<version>` (starting with `v1.0.0`).
