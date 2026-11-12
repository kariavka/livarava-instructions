---
name: LivaRava Commit Rules
description: "Use when writing a git commit message for any LivaRava project. Defines the type indicator, the summary paragraph, the detailed change list and the version bump."
applyTo: "**"
---
# Commit Messages

Every commit message starts with a type indicator, then one short paragraph
describing the main changes, and then a detailed list when there were many of
them. Write in English and in the past tense, describing what the commit did.

`applyTo` is `**` because a commit message is not a file. This is the one
instruction file that governs an action rather than a path, so it applies to
every project in the repository set.

## VS Code Source Control integration

- Always use this standard when writing or generating commit messages, including
  the Generate Commit Message action in VS Code Source Control.
- Configure `github.copilot.chat.commitMessageGeneration.instructions` with
  `{ "file": "/home/smart/livarava-instructions/commit.instructions.md" }` in the array.
  Keep this entry in the shared remote user settings at
  `/home/smart/.vscode-server/data/User/settings.json` and in each LivaRava
  project's `.vscode/settings.json`. Preserve other instruction entries.
- `chat.instructionsFilesLocations` and the `commit-message.prompt.md` prompt
  alone do not configure the Source Control generator; its dedicated setting
  must explicitly reference this canonical file.
- When creating or configuring a LivaRava project, verify that its workspace
  settings do not override the shared commit instructions without this entry.
- Keep the rules here as the single source of truth; do not copy them into
  editor settings. On another host, configure the path to its canonical copy.
- AI-generated messages still require review against the staged changes and
  this standard before committing.

## 1) Type indicator

The message begins with exactly one indicator, followed by a space:

| Indicator | Use for |
|-----------|---------|
| `[-]` | Something was removed, or a bug was fixed |
| `[*]` | Something was refactored or updated |
| `[+]` | A new function, module or feature was added |

- One indicator per commit. When a commit does more than one of these, use the
  indicator of the change its summary paragraph leads with.
- The first verb is mandatory by indicator:
  - `[-]` must start with `Fixed` or `Removed`
  - `[*]` must start with `Refactored`, `Updated` or `Enhanced`
  - `[+]` must start with `Added`
- Nothing precedes the indicator - no scope, no branch name, no ticket.
- Merge commits keep git's own `Merge branch '<branch>'` subject and carry no
  indicator.

## 2) Line breaks

- Do not hard-wrap the message. One paragraph is one line, and one list item is
  one line, however long it runs; the editor and `git log` wrap it for the
  reader. Existing commits in the history are wrapped at about 79 columns - do
  not copy that.
- Use a blank line only between the summary paragraph, the detailed list and
  any closing paragraph.

## 3) Summary paragraph

- One short paragraph follows the indicator, always, even for a one-line
  change.
- It says what changed and why, not which files were touched: `git show --stat`
  already lists the files.
- Lead with the change itself, in the past tense: `Removed the
  WHATSAPP_AI_MODEL override from the WhatsApp assistant, so both AI stages
  name the default model in code.`
- Keep it laconic: **two or three short sentences, and no more**, which is what
  a reader needs in order to decide whether this commit concerns them. Detail
  belongs in the list below, not in this paragraph - name the change and its
  one governing rule, and leave the types, limits, error codes and file names
  to the items.
- Three sentences that each run three clauses long is not a laconic paragraph.
  Count the sentences and then shorten each one: a summary a reader has to
  parse twice has already failed, however few full stops it contains. When a
  qualification feels necessary in the summary, that is the signal it belongs
  to an item.
- End the paragraph with the version bump only when this commit actually bumps
  the project version: `Bumped version to 6.43.13.`

## 4) Detailed list

- When the commit carries many changes, follow the summary paragraph with a
  blank line and then the detail: a context paragraph where the reason needs
  one, and a list of `- ` items, one item per change.
- Each item is a full statement of what changed, and of why where that is not
  obvious from the change itself.
- Do not repeat in the list what the summary paragraph already said, and do not
  split one change across two items.
- A commit with a single change needs no list. The summary paragraph is enough.

## 5) What else belongs in the message

- Name the tests a commit added or changed, and give measured results as
  numbers where the commit claims one.
- Record what the commit deliberately did **not** do when a reader would
  otherwise assume it did, for example a credential that still needs rotating
  or a caller that still needs fixing.
- Do not paste file listings, diffs, command output or lint logs.
