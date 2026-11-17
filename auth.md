---
description: "Use when implementing or changing authentication, authorization, signin/signout, SSO callback flows, session restore, token storage, or auth-related API handling across LivaRava projects."
name: "LivaRava Auth Standard"
applyTo: "**/*.{js,jsx,ts,tsx}"
---

# LivaRava Authentication Standard

Use this as the required baseline for `www`, `mail`, `business`, `community`, `sites`, and `blog`.

## 1) Single session source of truth

- Persist the authenticated token in `localStorage.session`.
- In-memory auth state (`Auth.token`, redux state) is runtime cache only.
- `me` cache is profile/UI data only, not proof of valid authentication.

## 2) Required SSO callback flow

When handling `/auth` callback:

1. Read `token` from query.
2. Read `redirect` from query and keep only a safe internal path.
3. Validate token through `/me` with current project `SITE_ID`.
4. On success, persist auth data (`session` + `me`) through shared helpers/store.
5. Redirect to the safe path from `redirect`, with app default fallback.







- Public/landing pages may bootstrap from cached `me` for UI.
- Protected pages must verify a real token/session before allowing access.
- On verification failure, clear local auth data and route to signin with redirect back.





1. Read token from `localStorage.session`.
2. Clear local `session` and `me` immediately.
3. Optionally call API signout/revoke (`/signout/`) when the app supports it.
4. Keep user signed out locally even if remote revoke fails.
5. Redirect to requested safe `redirect` path, otherwise app-specific default.

## 5) Error semantics across projects

- Treat invalid/expired token as global session failure: clear `session`.
- Treat site access mismatch/denied as project-specific access issue; do not silently fake authenticated UI.
- Surface auth errors explicitly; do not hide failures behind success-shaped fallbacks.

## 6) Implementation consistency rules

- Keep signin URL construction consistent: `site`, `next`, and safe `redirect`.
- Keep auth header usage consistent for API calls (`X-LivaRava-Token`, `X-LivaRava-Site`).
- Reuse shared helpers for auth flows instead of duplicating divergent logic.
