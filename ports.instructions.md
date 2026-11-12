---
name: LivaRava Ports and Local Hosts
description: "Use when choosing or changing a dev port, a Docker compose port mapping, an EXPOSE line, a Next.js basePath, or allowedDevOrigins in LivaRava projects, and when a local project is not reachable through local.livarava.com."
applyTo: "**/Dockerfile, **/Dockerfile.*, **/docker-compose*.yml, **/compose*.yml, **/Makefile, **/next.config.js, **/next.config.mjs, **/next.config.ts"
---
# Ports and Local Hosts

This is the ports document the Docker and Makefile instructions refer to. The source of truth is the local nginx server block for `local.livarava.com` (`/opt/homebrew/etc/nginx/servers/livarava.conf`); keep this table in sync with it.

Checked on the Linux dev host on 2026-10-20: that path does not exist, there is no `/etc/nginx`, no `nginx` binary, and no `*.livarava.com` entry in `/etc/hosts`, so `http://local.community.livarava.com/community/` does not resolve and projects are reached directly on `127.0.0.1:<port>`. The nginx path above is a macOS Homebrew location and describes a different machine. The table below stays authoritative for ports, `basePath` and the `Host` values to put in `allowedDevOrigins`; just include `127.0.0.1` alongside the hostname so the dev server also works without the proxy.

All frontend projects are reached through that one nginx front end, not directly on their port. A project's dev port, its `EXPOSE`, its compose port mapping, its `Makefile` run target and its `basePath` must all agree with this table.

| Port | Path | Project | basePath | `Host` nginx forwards |
|------|------|---------|----------|------------------------|
| 3000 | `/` | `livarava-www` | none | `$host` -> `local.livarava.com` |
| 3001 | `/blog` | `livarava-blog` | `/blog` | `local.blog.livarava.com` (overridden) |
| 3002 | `/business` | `livarava-business` | `/business` | `$host` -> `local.livarava.com` |
| 3003 | `/community` | `livarava-community` | `/community` | `local.community.livarava.com` (overridden) |
| 3004 | `/events` | `livarava-events` | `/events` | upstream default |
| 3005 | `/` on `local.id.livarava.com` and `local.accounts.livarava.com` | `livarava-accounts` | none | `$host` |
| 3006 | `/quiz` | quiz | `/quiz` | upstream default |
| 3007 | `/sites` | `livarava-sites` | `/sites` | upstream default |
| 3008 | `/gift` | gift | `/gift` | upstream default |
| 3009 | `/finance` | finance | `/finance` | upstream default |
| 3010 | `/technology` | technology | `/technology` | upstream default |
| 3011 | `/mail` | `livarava-mail` | `/mail` | upstream default |

Backend, not Next.js projects: `5000` serves `/act`, `/goto`, `/payment`, `/invoice`, `/ticket`; `5001` serves `/api` and `/static`; `5002` serves `/socket.io`.

## Consequences for Next.js config

- Every project is served cross-origin from the dev server's point of view, because the browser's origin is `local.livarava.com` while the dev server listens on a container port. Next 16 blocks dev resources in that situation, so each project needs `allowedDevOrigins` in `next.config.js` or hot reload dies silently. See the Next.js instructions.
- The value must match the `Host` header nginx actually forwards, which is the right-hand column above - not always `local.livarava.com`. `livarava-blog` needs `local.blog.livarava.com`, `livarava-community` needs `local.community.livarava.com`, and `livarava-accounts` needs both `local.id.livarava.com` and `local.accounts.livarava.com`. Where no `proxy_set_header Host` is present, nginx forwards the upstream address, so include `127.0.0.1` alongside the hostname.
- HMR needs the websocket upgrade headers (`proxy_set_header Upgrade $http_upgrade;` and `Connection "upgrade";`) on that location block. If a project's location block lacks them, hot reload will not work no matter what the app config says.
- `/blog` and `/community` are proxied with the path included in `proxy_pass`, so their `basePath` must match the location name exactly.

## Changing a port

- Never pick a port ad hoc: take the next free number from this table, then update, in this order, the nginx location block, `docker-compose.yml` (mapping and `command`), `Dockerfile` (`EXPOSE` and `CMD`), the `Makefile` run target, and `basePath` in `next.config.js`.
- Reload nginx after editing its config, and verify the project answers through `local.livarava.com/<path>`, not only on `127.0.0.1:<port>`.
