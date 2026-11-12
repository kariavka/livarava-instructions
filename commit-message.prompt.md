---
name: LivaRava Commit Message
description: "Use when generating a git commit message for any LivaRava repository under the shared commit standard."
argument-hint: "Describe staged changes briefly"
agent: "agent"
---
Generate a git commit message using the rules from [commit.instructions.md](./commit.instructions.md).

Requirements:
- Return only the commit message text, with no markdown fences and no extra commentary.
- Write in English and in past tense.
- Start with exactly one indicator: `[-]`, `[*]`, or `[+]`.
- Start with the required verb by indicator:
  - `[-] Fixed ...` or `[-] Removed ...`
  - `[*] Refactored ...`, `[*] Updated ...` or `[*] Enhanced ...`
  - `[+] Added ...`
- Write the summary paragraph as 2-3 short sentences.
- End that summary paragraph with: `Bumped version to <version>.` only when the staged changes include an actual version bump.
- Add a detailed `- ` list only when the commit has multiple meaningful changes.
- Mention changed or added tests and measured results when relevant.

Input to use:
- User-provided summary of staged changes: `${input:Describe staged changes briefly}`
