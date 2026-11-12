---
name: LivaRava Frontend Rules
description: "Use when updating, upgrading, auditing, or reviewing frontend dependencies in package.json (npm/yarn), lockfiles, Next.js, React, Node engine versions, or when refactoring a LivaRava frontend project."
applyTo: "**/package.json, **/yarn.lock, **/package-lock.json, **/pnpm-lock.yaml, **/eslint.config.*, **/.eslintrc*, **/jsconfig.json, **/tsconfig.json, **/components/common/*Wrapper.js"
---
# Frontend Package Updates

Related instructions: `next.instructions.md` for `next.config.js`, module aliases and dev origins; `ports.instructions.md` for ports, `basePath` and local hosts; `docker.instructions.md` and `makefile.instructions.md` for running the tooling, since Node is not installed on the dev host.

- If dependencies in `package.json` can be safely updated to the latest versions, do it. Do not leave them outdated by default.
- Use the project's own package manager (detect it from the lockfile: `yarn.lock` → yarn, `package-lock.json` → npm, `pnpm-lock.yaml` → pnpm). Never mix managers and always keep the lockfile in sync with `package.json`.
- Check each update against the project's runtime (the `engines.node` field and the Docker base image), framework (Next.js, React), and peer-dependency constraints.
- Apply minor and patch updates freely. Migrate breaking major versions only when the change can be validated (build, lint, tests, and a representative page check). Do not apply risky major upgrades blindly.
- Keep packages pinned only for a concrete reason, and report each pinned package with that reason.
- Remove dependencies that are no longer used (for example `styled-components` after migrating to SCSS) and update the lockfile. Verify with a literal search across the whole repository (excluding `node_modules`, `.next`, `.git`, the lockfile and static `.html` snapshots), not only in component folders: a package can be referenced from `pages/_app.js`, a `.scss` import or a config file.
- Never remove `typescript`, even when the project contains zero `.ts`/`.tsx` files - see "ESLint and TypeScript" below.
- Run the install without relaxing lockfile checks, then rerun lint, tests, and build after updating.
- A green build is not proof the project is clean. `next build` ignores config files that the editor's TypeScript service still reports as errors, so also check the editor diagnostics (VS Code Problems panel) for `jsconfig.json` / `tsconfig.json` / `next.config.js` after an update.
- Prefer running these commands in the project's Docker environment when Node is not available on the host, so they match the real runtime.
- Report which packages were updated, which were skipped, and why.

# Reference Baseline

- The goal is for every LivaRava frontend project to always use the newest stable packages. Never settle for "good enough" versions; keep pulling projects up.
- `livarava-www` is the current version reference (verified by lint + production build + Docker image build on 2026-10-19). `livarava-mail` remains the reference for dependency *footprint* (smallest honest dependency list). Before updating any project, compare its `package.json` and resolved lockfile with `livarava-www` and align to the same or newer versions. If a project turns out newer, keep it and record the new numbers in this file.
- `livarava-community` was pulled onto the baseline on 2026-10-20, from next 12.0.10 / react 17.0.2: 23 dependencies (was 41) and 3 devDependencies (was 7), lint running for the first time at 0 errors / 81 warnings, and 84 static pages in the production build. It had no lockfile at all - `/yarn.lock` and `/package-lock.json` were both in `.gitignore` while the Dockerfile ran `yarn install --pure-lockfile` - so check for that before trusting any project's "resolved" versions.
- `redux-bees` declares `react` and `react-redux` as plain `dependencies` with the range `*`, not as peers, so yarn installs a second copy of each whenever the project's own React does not satisfy hoisting. On React 17 that meant a nested React 19 in `livarava-community`; bumping the project to `^19.3.1` deduped it to a single entry. `livarava-www` still carries `node_modules/redux-bees/node_modules/react` at 19.1.0 alongside 19.3.1 - worth deduping there too.
- `livarava-sites` was migrated to the `fetch` API v2 client on 2026-10-26 (104 call sites in 54 files, `redux-bees` gone): `yarn lint` went from 60 errors / 63 warnings to **0 errors / 117 warnings** - the warning count rose only because the four React Compiler rules were demoted from `error` to `warn` (51 `set-state-in-effect`, 6 `immutability`) - plus 23 passing tests and a production build of 32 routes, 14 of them prerendered. Its `yarn.lock` was in `.gitignore` while the Dockerfile ran `COPY package.json yarn.lock ./` with `--frozen-lockfile`, so a clean clone could not build at all; the ignore entry was removed. Check for that before trusting any project's resolved versions - `livarava-community` had the same defect.
- `livarava-mail` got `typescript` `^5.9.3` and a flat-config `lint` script on 2026-10-23, as part of the API v2 JSON:API migration, so its `yarn lint` runs for the first time: 0 errors, 9 warnings. Its `lint` script was still `next lint`, which Next 16 removed, and `build` now pins `NODE_ENV=production`. The `redux-bees` → `fetch` adapter recipe below was applied there too, so `redux-bees` is gone (13 dependencies, 4 devDependencies).
- Pending: `livarava-mail` is still behind `livarava-www` on `next` (16.3.8 resolved vs 16.4.2) and `@fortawesome/*` (6.7.2 vs 7.3.1). Bump it next; that is deliberately a separate change from the API migration.
- Baseline stack, as resolved in `livarava-www` on 2026-10-19: `next` 16.4.2, `react` / `react-dom` 19.3.1, `sass` 1.105.2, `bootstrap` 5.3.8, `@reduxjs/toolkit` 2.13.0, `react-redux` 9.3.0, `redux` 5.0.1, `@fortawesome/fontawesome-svg-core` and the icon packs 7.3.1 with `@fortawesome/react-fontawesome` 3.5.0, `eslint` 9.39.5 with `eslint-config-next` 16.4.2, `typescript` 5.9.3, Node `24.x` in `engines`.
- Keep `eslint-config-next` on the same major as `next`. This is not cosmetic: it pulls `@next/eslint-plugin-next` of the matching major and the whole `typescript-eslint` chain with it.
- Keep `@fortawesome/*` packages mutually compatible. `react-fontawesome` 3.5.0 declares `@fortawesome/fontawesome-svg-core: ~6 || ~7`, so core and icon packs move together to 7.x while the React wrapper stays 3.x.
- Before a major FontAwesome bump, prove no icon name disappeared instead of trusting the changelog: collect every `fa*` identifier imported from `@fortawesome/*` across the source, then import each pack in Node and assert the name is an export. The 6 -> 7 move in `livarava-www` passed this for all 77 icons across 50 files, including FA5-era aliases (`faTimes`, `faSearch`, `faSlidersH`, `faGlobeEurope`, `faExclamationTriangle`, `faExternalLinkAlt`).
- Compare the resolved versions in the lockfile, not only the ranges in `package.json`; ranges like `^16.2.4` can hide an older locked version.
- Keep dependency lists minimal like `livarava-mail`: add a package only when it is actually used, and prefer platform or existing-stack solutions (SCSS and Bootstrap instead of `styled-components`/Tailwind; native `Intl`/`Date` instead of `moment`; native `fetch` instead of extra HTTP libraries) over new dependencies.
- Treat legacy packages as candidates for removal or replacement: `moment`, `moment-timezone`, `lodash`, `redux-thunk` (already included in Redux Toolkit), `styled-components`, and unused `react-router-dom` in Next.js projects. Verify usage before removing.
- When a package update changes the baseline, record the new versions here.

# ESLint and TypeScript

- Keep `typescript` in `devDependencies` of every frontend project, including JS-only ones with zero `.ts`/`.tsx` files. `eslint-config-next` 16 depends on `typescript-eslint` 8, which `require()`s `typescript` the moment the flat config loads; without it `yarn lint` dies with `Cannot find module 'typescript'`. The npm metadata is misleading here: `peerDependenciesMeta.typescript.optional` is `true`, so this looks like a safe removal and is not one.
- Version ceilings that follow from that chain, both of them deliberate and not "outdated":
  - `typescript` stays on `^5.9.3`. `typescript-eslint` 8 declares `typescript >=4.8.4 <6.1.0`, so TypeScript 7.x is out of range.
  - `eslint` stays on `9.x`. `typescript-eslint` 8 does not support ESLint 10, even though `eslint-config-next` advertises the looser peer `eslint >=9.0.0`.
  - Record both as pinned-with-a-reason in the update report rather than silently leaving them behind.
- `eslint-config-next` 16 requires ESLint flat config. Migrating a project means all of: add `eslint.config.mjs`, delete `.eslintrc.json`, and drop the `ESLINT_USE_FLAT_CONFIG=false` workaround from the `lint` script. The canonical file, carrying project rule overrides in the middle block:

```js
import { defineConfig, globalIgnores } from 'eslint/config'
import nextVitals from 'eslint-config-next/core-web-vitals'

export default defineConfig([
  ...nextVitals,
  { rules: { '@next/next/no-html-link-for-pages': 'off' } },
  globalIgnores(['.next/**', 'out/**', 'build/**', 'next-env.d.ts'])
])
```

- `eslint-config-next` 16 also brings `eslint-plugin-react-hooks` 7, whose React Compiler rules fire on long-standing patterns: `set-state-in-effect`, `immutability`, `purity`, `preserve-manual-memoization`. In `livarava-www` that was 87 errors across 55 files on first run, none of them regressions from the upgrade.
- Policy for that wave, so a dependency update never turns into a hostage of a large refactor: demote exactly those four rules to `warn` in `eslint.config.mjs` with a comment stating why and how many findings there were, keep them visible, and promote each rule back to `error` as its files are cleaned up. Do not use `eslint-disable` comments and do not drop the rules entirely.
- `react-hooks` 7 reports the lazy-ref idiom (`if (!ref.current) ref.current = make()`) as an **error** (`react-hooks/refs`: "Cannot access refs during render"), and reading `ref.current` in JSX is a second error. Use a lazy `useState` initialiser instead - `const [store] = useState(makeStore)` - which keeps the same once-per-instance semantics and lints clean.
- Report lint results as "N errors, M warnings" with the pre-existing warning count, so a later run can tell new noise from inherited noise. `livarava-www` baseline after the 2026-10-19 update: 0 errors, 180 warnings (66 `react-hooks/exhaustive-deps`, 21 `@next/next/no-img-element`, the demoted react-hooks findings, and a few `jsx-a11y`). Measured again on 2026-10-23 at **182** warnings on `master`, and **183** after the calendar synchronization settings, whose one new warning is a `@next/next/no-img-element` for a provider icon - the same pattern `SettingsPage.js` already uses. Measure the baseline by stashing the work (`git stash push --include-untracked`) rather than trusting the number recorded here, since it drifts with every commit.

# Favicon

- Every LivaRava frontend uses the same favicon as `livarava-www`, declared in `<Head>` of each page wrapper (`MainWrapper.js`, `BasicWrapper.js`) and of any page that renders its own `<Head>`:

```jsx
<link rel='shortcut icon' type='image/png' href='https://store.livarava.com/d8f6e83e-b2e4-11e8-b344-5254a2021b2b.png' />
```

- Do not add local favicon files to `public/` or use a different icon URL. When `livarava-www` changes its favicon, update all projects together.

# Known breaking migrations

Packages that changed their API in a way that breaks a LivaRava project silently or at build time. Check these before bumping, and search the other projects for the same package afterwards.

| Package | Break | Fix |
|---|---|---|
| `js-yaml` 4 -> 5 | the default export is gone; only named exports remain. Turbopack fails the build with `Export default doesn't exist in target module` | `import { dump } from 'js-yaml'` and call `dump(...)`; the `lineWidth` option is unchanged |
| `react-player` 2 -> 3 | the component was rewritten around media elements; the `url` prop no longer exists | `url=` becomes `src=`, and controls are opt-in via `controls` |
| `uuid` 11 -> 14, `react-dropzone` 14 -> 20 | both are now ESM-only (`"type": "module"`) | no source change needed under Next 16; the existing `import { v4 as uuidv4 }` / `import { useDropzone }` keep working |
| `@fortawesome/*` 6 -> 7 | icon packs may drop FA5-era name aliases | audit every imported `fa*` name against the installed pack, as described above |
| `react-input-mask` 2.0.4 -> React 19 | the package calls `ReactDOM.findDOMNode`, **removed in React 19**, so the input throws at runtime. Unmaintained since 2020, 2.0.4 is still the latest release | replace it. `livarava-community` dropped it for a 6-line `lib/DateMask.js` plus a plain `<input inputMode='numeric' maxLength={10}>`; the `99-99-9999` behaviour and the `e.target.value` contract are preserved, with one less dependency. Note `livarava-www/components/input/InputDate.js` still imports it while `www` does not declare it at all - that file is dead and should be deleted |
| `next-redux-wrapper` 7 -> 8 | `wrapper.withRedux(App)` is legacy. It still renders, prints `/!\ You are using legacy implementation`, and then fails the production build during prerender | in `_app.js`: `const { store, props } = wrapper.useWrappedStore({ Component, pageProps })`, wrap the page in `<Provider store={store}>`, render `props.pageProps`, and `export default MyApp` with no HOC |
| Next 12 -> 13+ | `<Link href><a>…</a></Link>` is gone; `legacyBehavior` is removed in 16 | move the anchor's props onto `Link`, drop `passHref`, delete the `<a>`. `livarava-community`: 34 occurrences in 12 files. Also delete any `ActiveLink`-style helper that does `Children.only` + `cloneElement` on the anchor |
| Next 16 | `next lint` is removed | `"lint": "eslint ."` |
| `lodash` | kept alive by single trivial calls | replace and remove the dependency. `_.escape(x)` fed into `dangerouslySetInnerHTML` is just `{x}` in JSX - React escapes it, and the rendered result is identical |

# Replacing unmaintained packages

Verified replacements, done in `livarava-www` on 2026-10-20 (lint + production build green after each). Apply the same recipe in the other projects; check with a literal search whether the project has the package at all first.

## `next-redux-wrapper` -> nothing

Check first whether the project uses it for anything: if no page calls `wrapper.getServerSideProps` / `getStaticProps` and no reducer handles `HYDRATE`, the wrapper only creates the store and hands it to `Provider`, which `@reduxjs/toolkit` and `react-redux` already do. That was the case in `livarava-www` (4 lines, 2 files).

Keep one thing it did for free - a separate store per server request. A module-level store is shared across requests and leaks one visitor's state into another's response:

```js
// redux/store.js
const makeStore = () => configureStore({ reducer: rootReducer, devTools: process.env.NODE_ENV !== 'production' })

let clientStore
export const getStore = () => {
  if (typeof window === 'undefined') return makeStore()
  if (!clientStore) clientStore = makeStore()
  return clientStore
}
```

```js
// pages/_app.js
const [store] = useState(getStore)
// ...
<Provider store={store}><Component {...pageProps} /></Provider>
```

## `redux-bees` -> a `fetch` adapter that keeps the interface

`redux-bees` (last release 2019) is used only as a declarative HTTP client - its reducers, normalisation and selectors are not wired in. Replace `lib/Api.js` with a `fetch` adapter and keep the endpoint table and the call signatures, so the consuming modules (52 of them in `livarava-www`) need no changes at all. No new dependency: `query-string` is already in the stack for the query string.

Keep the response shape (`{ status, headers, body }`, rejecting with the same object on a non-2xx), the JSON:API headers (`application/vnd.api+json`), `:id` substitution with leftovers becoming query parameters, and the argument conventions: `(params, options)` for GET and DELETE, and `(body)`, `(params, body)` or `(params, body, options)` for POST, PATCH and PUT.

Two behaviours are easy to miss and must be carried over deliberately, because call sites depend on them:

- **A missing required `:id` returns a promise that never settles** (`buildApi` returns `new Promise(() => {})` flagged `.noop`). Components use this to hold off a request until an id is known. Resolving or rejecting instead surfaces errors where there were none.
- **Concurrent identical calls share one promise**, keyed by the endpoint name plus arguments, and the key is cleared when the request settles. Dropping this multiplies API calls wherever several components load the same entity.

Generate the new endpoint table from the old one with a script rather than retyping it: `name: { method: get, path: '/x/:id' }` becomes `name: ['GET', '/x/:id']`.

## `react-phone-input-2` -> nothing yet, deliberately

`react-phone-input-2` (last release 2022-07-01) is unmaintained and **stays in place**. Four replacements were built and reverted in `livarava-www` on 2026-10-20; every one of them built and linted clean, and each was turned down on review. Do not start a fifth attempt without a concrete complaint to fix, and do not re-apply any of these from this file alone:

- **`react-phone-number-input`** 3.4.18 - rejected on review.
- **A hand-written component with a separate country `<select>`** - rejected: the original is one field with the dial code inside it, not a select plus a national-number box.
- **A hand-written component reusing the package's own data and flag sprite** - the approach worked, but the flags were visibly incomplete. Cause worth remembering: the sprite offsets live in `style.css` as 232 rules, and a naive regex misses about 30 of them because the zero offsets in the first row and column are written without `px` (`background-position:-16px 0`) and some selectors are comma-grouped (`fr`, `nl`, `bl`). Parse rule blocks properly, or the field silently loses flags.
- **`react-international-phone`** 4.8.0 - zero dependencies, React 19 peer, `defaultCountry` already lowercase, all 218 of its countries have a working Twemoji flag. Reverted for time, not for a defect. Two things to know if it is ever revisited: it lists 218 countries against react-phone-input-2's 235, and it loads flags from `cdnjs.cloudflare.com` (Twemoji 14.0.2) unless the `flags` prop points somewhere local. It must be themed through its own `--react-international-phone-*` custom properties - its stylesheet is imported after Bootstrap, so adding `form-control` to the input loses on font size, height and border.

What any future attempt has to satisfy, learned from these four:

- One text field showing `+<dial> <masked number>` with a flag dropdown on its left - not a country select beside a separate input.
- Font size, height and border matching the other Bootstrap fields in the same form.
- Flags present for every country in the list, proportionate to the field.
- The existing call-site contract: the component takes a value with or without a leading plus and emits **digits without the plus**, which `LeadButtonForm` prefixes again. Changing this means touching callers.
- Worth cleaning whenever it is finally replaced: nine props the wrapper never uses, `readonly` in lowercase (React ignores it - it is `readOnly`), and a non-DOM `prefix` attribute inside `inputProps`.
