---
name: LivaRava Next.js Rules
description: "Use when creating or changing next.config.js, jsconfig.json, module path aliases, dev server flags, image domains, or when upgrading a LivaRava project to a new Next.js major version."
applyTo: "**/next.config.js, **/next.config.mjs, **/next.config.ts, **/jsconfig.json, **/tsconfig.json"
---
# Next.js Guidelines

- Target the Next version recorded in the frontend instructions baseline, and keep `eslint-config-next` on the same major.
- Every project runs behind the local nginx front end, so read the ports instructions before touching ports, `basePath` or dev origins.

## Dev server must be reachable through local.livarava.com

- Every project needs `allowedDevOrigins` in `next.config.js`. The browser's origin is `local.livarava.com` while the dev server listens on a container port, so from Next 16 on, dev resources are cross-origin and blocked by default. Hot reload then dies while the pages still render, which makes it easy to miss:

```
⚠ Blocked cross-origin request to Next.js dev resource /_next/hmr from "local.livarava.com".
```

- The fix is one line, and the value must match the `Host` header nginx forwards for that project (see the ports instructions - it is not always `local.livarava.com`):

```js
allowedDevOrigins: ['local.livarava.com'],
```

- List dev hosts only. `allowedDevOrigins` applies exclusively to `next dev`: it guards dev-only resources such as `/_next/hmr`, which do not exist in a `next build` + `next start` deployment, so the check never runs in production. Adding a production hostname like `www.livarava.com` is a dead entry. `localhost` and `127.0.0.1` are allowed by default and do not need listing either.
- After adding it, restart the dev server and confirm the warning is gone from the container log. A `GET / 200` line is not proof: pages serve fine while HMR is broken.
- Treat a missing `allowedDevOrigins` as a bug in any project upgraded to Next 16, and check it as part of the upgrade rather than waiting for someone to notice that saving a file no longer refreshes the page.

## Config options that changed

- `images.domains` is gone. Use `images.remotePatterns` with an explicit protocol and hostname per entry:

```js
images: {
  remotePatterns: [
    { protocol: 'https', hostname: 'store.livarava.com' }
  ]
}
```

- `--turbo` is a no-op from Next 16 on, because Turbopack is the default (the startup banner prints `(Turbopack)`). Harmless to keep for consistency with the other projects, but do not add it to anything new, and never treat it as the reason something works.
- Do not pass the dev port twice. Keep the port in the Docker `CMD`, the compose `command` and the `Makefile` target, and leave the `package.json` script as plain `next dev` - otherwise the log shows `next dev -p 3000 --turbo -p 3000`, which works only because the last flag wins.
- `i18n` in `next.config.js` still works for Pages Router projects and stays as is.

## Module path aliases (jsconfig.json)

- Aliases live in `jsconfig.json` `compilerOptions.paths`. Do **not** set `baseUrl`: TypeScript reports `Option 'baseUrl' is deprecated and will stop functioning in TypeScript 7.0` as an **error**, which is what makes the file show up red in the editor even while `next build` passes.
- Without `baseUrl`, every target must be relative or TypeScript reports `Non-relative paths are not allowed when 'baseUrl' is not set`. Next's own resolver is more permissive than the editor's, so the build can be green while the file is still red - fix both:

```json
{
    "compilerOptions": {
        "paths": {
            "@components/*": ["./components/*"],
            "@redux/*": ["./redux/*"],
            "@lib/*": ["./lib/*"]
        }
    },
    "include": ["**/*.js", "**/*.jsx"],
    "exclude": ["node_modules", ".next"]
}
```

- Keep `include` honest: list `**/*.ts` / `**/*.tsx` / `next-env.d.ts` only in projects that actually contain TypeScript. Drop alias entries whose target folder does not exist - `livarava-www` carried `@constants/*` pointing at a missing `constants/` folder with zero usages in the source.
- Verify an alias change with a production build, since every aliased import is resolved there (`livarava-www`: 221 alias imports across `@components`, `@lib`, `@redux`).
