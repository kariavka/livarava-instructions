---
name: LivaRava Docker Rules
description: "Use when creating, editing, or updating a Dockerfile, docker-compose.yml, .dockerignore, container base images, Node image versions, or Docker-based dev/build workflows in LivaRava projects."
applyTo: "**/Dockerfile, **/Dockerfile.*, **/docker-compose*.yml, **/compose*.yml, **/.dockerignore"
---
# Docker Guidelines

- Keep the Node base image in sync with the `engines.node` field in `package.json`. When the project upgrades Node, update both together. If a newer supported Node release is safe for the project, prefer it.
- Use a slim image (for example `node:<major>-alpine`) and pin the major version explicitly, never `latest`.
- Do not reinstall what the base image already ships. `node:24-alpine` already contains yarn 1.22.22 at `/usr/local/bin/yarn`, so a line like `RUN apk add --no-cache yarn git` is a wasted layer; it is present in most LivaRava projects and should be removed. Install `git` only when the lockfile actually resolves a dependency from a git URL - grep the lockfile for `git+` before deciding.
- Copy `package.json` and the lockfile first, then install dependencies, then copy the rest of the source so dependency layers stay cached.
- Install with the lockfile enforced (for example `yarn install --frozen-lockfile --non-interactive`, `npm ci`, or `pnpm install --frozen-lockfile`), matching the project's package manager.
- Keep `.dockerignore` complete: exclude `node_modules`, `.next`, `.git`, and local environment files so they never enter the image.
- Do not bake secrets or credentials into images, Dockerfiles, or compose files. Pass them as environment variables or runtime secrets.
- In LivaRava projects the credentials live in `lib/Config.js`, which is selected by `make local` / `make master` from `lib/Config.local.js` / `lib/Config.master.js`. Those files are tracked by git and land in the image through `COPY . .`, and they carry values such as `SITE_API_KEY`, so an image built from a local checkout ships a live key. Treat that as the concrete thing this rule is about: move the keys to environment variables, or at minimum keep `lib/Config.*.js` out of the image and mount the config at runtime.
- Keep `EXPOSE`, the start command, and the compose port mapping consistent with the project's dev port as listed in the ports instructions (`ports.md`), which is the ports document for all LivaRava projects.
- After a dependency or Node version update, rebuild the image and verify the app starts and responds before finishing. Verify the version that is actually running, for example from the dev server banner, not just that the build succeeded.
- Beware the anonymous volume trap when verifying: `docker compose up --build` recreates the container but **reuses** the existing anonymous `node_modules` volume, so a rebuilt image can still run the previous dependency tree. After changing dependencies use `docker compose up --build --renew-anon-volumes`, or switch the service to a named volume so the reuse is explicit.
- The Docker environment is the reference runtime for installing, linting, testing, and building when Node is not available on the host.

# Compose

- Mount the project, and keep the generated directories out of the host bind mount with their own volumes: `- /app/node_modules` and `- /app/.next`. Without the `.next` volume the dev server writes a root-owned `.next` into the checkout, which then blocks host tooling.
- Do not leave a dead top-level `volumes: node_modules:` declaration when the service uses an anonymous volume (`- /app/node_modules`). Either drop the declaration or reference it properly as `node_modules:/app/node_modules`. Most LivaRava projects currently carry the unused declaration.
- Do not add `CHOKIDAR_USEPOLLING`. It is a webpack-era setting that Turbopack does not read, so it only looks like file watching is configured. If hot reload is broken, the cause is almost always a missing `allowedDevOrigins` (see the Next.js instructions), not file watching.
- `:cached` on a bind mount is a macOS/osxfs option and a no-op on the Linux dev host. Harmless, but do not add it to anything new.

## Disk efficiency and build performance

### Image size optimization

- When a development image grows unexpectedly, inspect image layers first (`docker history`, `docker image inspect`) and remove the biggest avoidable layer inputs.
- Keep generated artifacts and local caches out of images via `.dockerignore` and Dockerfile copy scope; include only files needed for the dev runtime.
- Use multi-stage builds only when measurements show a real benefit for the target project (smaller image and/or faster rebuilds) without harming hot reload.
- Do not force production-only hardening patterns into development containers when they slow iterative workflows.

### Build cache management

- Order layers to maximize cache reuse: base tools -> dependency manifests/lockfiles -> dependency install -> app source.
- Avoid dependency reinstalls unless dependency manifests changed; source-only edits should reuse dependency layers.
- Distinguish storage classes during analysis: images, build cache, writable container layers, and volumes are tracked separately.
- Treat Docker storage totals carefully: shared layers can make per-object sizes appear additive even when bytes are reused.
- Keep the existing automated cache cleanup and disk monitoring flow intact; do not replace it with manual recurring cleanup steps.

### Volume management

- Prefer named volumes when data is expected to survive rebuild cycles and be managed explicitly (for example long-lived `node_modules`/build caches in stable local setups).
- Use anonymous volumes only for short-lived or intentionally disposable data.
- Before recommending any volume cleanup, inspect which containers reference each volume and identify likely stale entries.
- Never remove volumes automatically when they may contain valuable data.
- After dependency updates, ensure dependency volumes are refreshed (`--renew-anon-volumes` for anonymous volumes, or recreate the relevant named volume) so runtime dependencies match rebuilt images.

### Development server safety

- Never stop, restart, or remove active development containers without explicit approval.
- Never run destructive Docker cleanup commands automatically (`prune`, forced volume removal, image mass deletion).
- Inspect concrete targets (container/image/volume) before proposing deletion and describe expected impact.
- Keep Docker as the reference runtime; do not require direct host Node.js installation for standard dev/build/test workflows.

### Optimization workflow

When modifying a project Docker setup:

1. Inspect Dockerfile, compose files, `.dockerignore`, and package manifests.
2. Identify measurable inefficiencies (size, rebuild time, dependency reuse, startup cost).
3. Propose and apply the smallest safe change set.
4. Preserve project-specific behavior (ports, commands, mounts, hot reload flow).
5. Verify startup, dependency correctness, hot reload, and persistent data behavior.
6. Compare build time and disk consumption before and after.
