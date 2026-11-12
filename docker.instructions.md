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
- Keep `EXPOSE`, the start command, and the compose port mapping consistent with the project's dev port as listed in the ports instructions (`ports.instructions.md`), which is the ports document for all LivaRava projects.
- After a dependency or Node version update, rebuild the image and verify the app starts and responds before finishing. Verify the version that is actually running, for example from the dev server banner, not just that the build succeeded.
- Beware the anonymous volume trap when verifying: `docker compose up --build` recreates the container but **reuses** the existing anonymous `node_modules` volume, so a rebuilt image can still run the previous dependency tree. After changing dependencies use `docker compose up --build --renew-anon-volumes`, or switch the service to a named volume so the reuse is explicit.
- The Docker environment is the reference runtime for installing, linting, testing, and building when Node is not available on the host.

# Compose

- Mount the project, and keep the generated directories out of the host bind mount with their own volumes: `- /app/node_modules` and `- /app/.next`. Without the `.next` volume the dev server writes a root-owned `.next` into the checkout, which then blocks host tooling.
- Do not leave a dead top-level `volumes: node_modules:` declaration when the service uses an anonymous volume (`- /app/node_modules`). Either drop the declaration or reference it properly as `node_modules:/app/node_modules`. Most LivaRava projects currently carry the unused declaration.
- Do not add `CHOKIDAR_USEPOLLING`. It is a webpack-era setting that Turbopack does not read, so it only looks like file watching is configured. If hot reload is broken, the cause is almost always a missing `allowedDevOrigins` (see the Next.js instructions), not file watching.
- `:cached` on a bind mount is a macOS/osxfs option and a no-op on the Linux dev host. Harmless, but do not add it to anything new.
