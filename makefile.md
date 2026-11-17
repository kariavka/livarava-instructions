---
name: LivaRava Makefile Rules
description: "Use when creating, editing, or updating a Makefile, make targets, or project task shortcuts for build, run, logs, release, and Docker workflows in LivaRava projects."
applyTo: "**/Makefile, **/*.mk"
---
# Makefile Guidelines

- Use the Makefile as the single entry point for common project tasks: `build`, `up`, `down`, `shell`, `run`, `logs`, `release`, `refresh`. Keep these names consistent across LivaRava projects.
- When dependencies or the package manager change, update the Makefile commands so they use the same package manager as the lockfile (for example `yarn`, `npm`, or `pnpm`).
- Keep the run/dev target consistent with the project's dev port and the Docker compose service name.
- Every project must expose its tooling as targets, not as advice. Node is not installed on the dev host, so without these targets every session reinvents long `docker compose run` incantations - which is exactly what this rule exists to prevent. Required in addition to the targets above:
  - `lint` - run the project's linter inside the container.
  - `test` - run the project's test suite inside the container.
  - `build-app` - run the production build inside the container (distinct from `build`, which builds the image).
  - `update` - upgrade dependencies, then lint, test and build, inside the container.
- Canonical form, with the service name and port taken from the ports instructions:

```makefile
lint:
	docker compose run --rm --no-deps www yarn lint

test:
	docker compose run --rm --no-deps www yarn test

build-app:
	docker compose run --rm --no-deps www yarn build

update:
	docker compose run --rm --no-deps www sh -c 'yarn upgrade && yarn lint && yarn test && yarn build'
```
- Tests need no test dependency. Node 24's own runner plus a resolver hook is enough, and it is what `livarava-www` and `livarava-business` use since 2026-10-23 (`livarava-mail` runs the same runner over `tests/*.test.mjs` without a hook): `"test": "node --disable-warning=MODULE_TYPELESS_PACKAGE_JSON --import ./tests/register.mjs --test tests/*.test.js"`. The hook (`tests/resolve.mjs`, registered from `tests/register.mjs`) adds what Next's bundler does and Node's ESM loader does not, so the tests load the application's own modules instead of a copy adapted to the runner: the `jsconfig.json` aliases, extensionless relative imports, directory imports resolved through the directory's `package.json` (`react-bootstrap/Modal`, whose `main` is preferred over `module` because the package's own ESM build assumes a bundler's CommonJS-default interop), and - in `livarava-www` since 2026-10-23 - JSX under `components/`, compiled with Next's own SWC binding (`next/dist/build/swc`, after `loadBindings()`). That last one is what lets a component be rendered with `react-dom/server` in a test without adding a transform or a testing-library dependency; server rendering runs no effects, so states that follow a settled request stay covered by the model's own suite. Without `--disable-warning` every file prints `MODULE_TYPELESS_PACKAGE_JSON`, because the projects are ESM source in a package without `"type": "module"`.
- Do not call `docker` through `sudo`. The developer account is in the `docker` group, so `sudo` is unnecessary, and it is what makes `node_modules` and `.next` root-owned inside the checkout, after which host tooling and the editor can no longer write there. Existing Makefiles still carry `sudo docker compose`; drop it when touching them.
- **`build-app` must force `NODE_ENV=production`.** The compose service sets `NODE_ENV=development` for the dev server, and `docker compose run` inherits it, so a plain `yarn build` runs `next build` with `NODE_ENV=development`. Next 16 then prerenders with dev-mode module instances and every page that calls `useRouter()` dies with `NextRouter was not mounted` - a context error that reads like an application bug and sends you hunting through `_app.js`, providers and `next.config.js` instead. `livarava-www` hides the trap by pinning it in the script (`"build": "NODE_ENV=production next build"`); do the same in every project, since that one place protects `make`, CI and a manual `docker compose run` alike. Cost of not knowing this, measured on `livarava-community`: about a dozen builds bisecting `_app.js`, the providers, `basePath`, `i18n` and `jsconfig.json`, all of them innocent.
- Mark non-file targets as `.PHONY` and use tabs for recipe indentation.
- Keep targets small and single-purpose. Do not embed secrets, tokens, or credentials in recipes.
- Do not reformat or change unrelated targets, and preserve edits the user already made to the Makefile.
- After changing a target, run it (or its safe equivalent) to confirm it works.
