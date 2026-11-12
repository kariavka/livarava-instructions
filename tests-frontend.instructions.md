---
name: Frontend Tests Standard
description: "Use when writing, naming or reviewing a frontend test suite, including the .test.mjs file naming in tests/ and the runner globs that refer to it."
applyTo: "**/tests/*.test.mjs, **/components/**/*.js, **/lib/**/*.js"
---
# Frontend test suites

Read `tests.instructions.md` first; it carries the rules that hold in every
language, including the test-first workflow and what has to be covered. This
file adds what is specific to the ESM suites of the frontends.

Commands:

```bash
npm test     # inside the repository
make test    # on this host, which runs it in the container
```

Node is not installed on this host, so a suite is run through the project's
`make` target rather than directly.

## 1) Location and file naming

Unit and integration suites live in `tests/`, one file per primary module
under test, named:

```
<SourceBaseName>.test.mjs
```

- `SourceBaseName` matches the basename of the file under test **exactly**,
  including its casing. The source file is the authority: do not force a suite
  name to start upper or lower case against it.
- In the LivaRava frontends that authority is uppercase throughout, because
  every file under `components/` and `lib/` is PascalCase, helper modules
  included — `lib/Api.js` and `components/mail/MailChatConfig.js` show it. A
  lowercase source file there is an outlier to rename, not a casing to mirror
  in a suite name.
- The extension is `.mjs` and nothing else, so that the module format is
  explicit.

Examples:

| Source | Suite |
|---|---|
| `lib/Api.js` | `tests/Api.test.mjs` |
| `lib/JsonApi.js` | `tests/JsonApi.test.mjs` |
| `components/chat/ChatMessageBody.js` | `tests/ChatMessageBody.test.mjs` |
| `components/mail/MailActions.js` | `tests/MailActions.test.mjs` |

When renaming a suite, update every test-runner glob and explicit path that
refers to its old name or extension in the same change.

Setup, resolver, fixture and other support modules keep names that say what
they are for. This naming rule covers suites, not the files that serve them.

## 2) Runner and structure

The runner is the built-in Node test runner, `node --test`. The imports are:

```js
import { test, describe, beforeEach, afterEach } from 'node:test'
import assert from 'node:assert/strict'
```

One `describe` per logical block of the module or API under test, and one
`test` per scenario. Test names are short statements of the behaviour that is
guaranteed, not of the function that is called.

## 3) React and Next components

Test the behaviour and the output, never the internals.

- Render on the server with `react-dom/server` and `renderToStaticMarkup`
  wherever that is enough to see the output under test.
- Reach for `jsdom` only where a DOM API is genuinely required, and only in
  the suite that requires it.

## 4) API adapters

An adapter suite covers the status codes, the shape of the response it returns
to its callers, and the way it reports an invalid or failed response.

## 5) Stability

- Mocks are local to the suite and are cleared in `afterEach`, completely.
- No timing workarounds: no `setTimeout` to let something settle, no duplicated
  handlers to catch a race.
