---
name: LivaRava Cookie Rules
description: "Use when reading, writing or deleting cookies, localStorage, sessionStorage or IndexedDB in a LivaRava frontend, when classifying or declaring a cookie, or when cleaning up storage after a consent withdrawal. Defines the standard Cookie component."
applyTo: "**/lib/Cookie.js, **/lib/Storage.js, **/lib/Consent.js, **/components/consent/**, **/pages/_app.js, **/pages/api/**"
---

# LivaRava Cookie Rules

Cookie enforces **browser storage**. It asks `Consent`
(`consent.instructions.md`) whether an optional category is granted and refuses
the write when it is not; which purposes exist at all is decided by
`privacy.instructions.md`.

Cookie never shows UI, never decides lawfulness, and never asks the visitor
anything.

## 1) The `Cookie` component

The standard name is `Cookie`, in `lib/Cookie.js`, with no dependencies:

```js
Cookie.REGISTRY                 // name -> { category, purpose, maxAge, provider }
Cookie.get(name)                // string | null
Cookie.set(name, value, options)// false when consent is missing or the name is unregistered
Cookie.remove(name)
Cookie.list()                   // readable cookies, registered or not
Cookie.purge(category)          // delete everything belonging to a category
```

- `document.cookie` is read and written **only** here. No component, page or
  other library parses it, and no project adds a third-party cookie library —
  `js-cookie`, `react-cookie`, `universal-cookie`, `cookie` and equivalents are
  out. Remove them where they are only wrapping what `Cookie` does.
- Every write names its category. A write with no category is a bug, not a
  default to `necessary`.
- `set()` returns `false` instead of throwing when it refuses, so a caller can
  carry on without a cookie. Callers must work without their cookie.
- Keep it safe on the server: reading `document` must not break SSR, and
  nothing optional is ever written during server rendering.

## 2) Registry and classification

`Cookie.REGISTRY` is the single source of truth and the input to the published
cookie declaration. A cookie that is not in the registry is not set.

Each entry records: name, category (the four keys from
`consent.instructions.md`), purpose in plain language, maximum age, and who
sets it (LivaRava, or the third party).

- Classify by what the cookie **does**, not by who benefits. A cookie that
  measures usage is `statistics` even when the product also needs the number.
- Third-party cookies set by a gated script are registered too, by their real
  names, so the declaration and the cleanup both know about them. Registering
  them does not mean LivaRava sets them.
- Names are `snake_case` with an `lr_` prefix (`lr_consent`, `lr_locale`), so a
  LivaRava cookie is recognisable among third-party ones. Never put personal
  data, a token or an identifier in a cookie **name**.

## 3) Attributes

Defaults for a LivaRava cookie on this host:

| Attribute | Value | Note |
|---|---|---|
| Host | `www.livarava.com` | host-only; **do not set `Domain=`** |
| `Path` | `/` | so every path-mounted subproject shares one decision |
| `Secure` | always | including when developing against a local HTTPS host |
| `SameSite` | `Lax` | the default for anything read on normal navigation |
| `HttpOnly` | wherever the value is not needed by script | a script-readable cookie is a decision, not an oversight |

- `Path: /` with no `Domain` is what makes one consent decision cover `/`,
  `/blog/`, `/business/`, `/community/`, `/events/`, `/sites/` and `/mail/`.
  Never narrow an app-wide cookie to a subproject path.
- **Do not use a cross-domain cookie unnecessarily.** `Domain=.livarava.com`
  would extend storage to every subdomain including `id.livarava.com`; it is
  allowed only when a specific requirement needs it, and then the reason is
  recorded in the registry entry. The consequence of the host-only default is
  that other hosts do not see the decision and must collect their own — state
  that rather than widening the scope quietly.
- `SameSite=Strict` for anything whose use in a cross-site navigation would be
  a state change. `SameSite=None` requires `Secure`, a written reason, and
  never carries personal data.
- Never set a cookie from a URL parameter value without validating it, and
  never reflect a cookie value into HTML.

## 4) Expiry

- Give every cookie the shortest life that works. No `Expires` means a session
  cookie, which is the right default for necessary state.
- The consent record (`lr_consent`) lives **180 days**, then the visitor is
  asked again. It is the canonical name `Consent` persists its decision under.
- Nothing persistent exceeds **13 months**. A longer life needs a documented
  reason in the registry, and "convenience" is not one.
- A third party whose default is longer is **configured down** where its tag is
  mounted, not excused in the table. Google Analytics defaults `_ga` to two
  years and takes `cookie_expires`; the registry then states the lifetime the
  visitor is actually given. A registry entry that disagrees with what the
  vendor sets is worse than no entry, because the declaration is generated from
  it.
- Renew a consent record only when the visitor decides again, not on every
  page view: silently extending a decision defeats the re-ask.

## 5) Consent enforcement

- A `necessary` cookie is set whenever it is needed, with no consent check.
  **Technically necessary storage must keep working for a visitor who refuses
  everything** — authentication, the session, CSRF, and the consent record
  itself.
- A `preferences`, `statistics` or `marketing` cookie is set only after
  `Consent.has(category)` is true. No optional cookie is written before a
  decision, and an undecided visitor counts as a refusal.
- Reading is gated too: do not read an optional cookie left over from an
  earlier consent to restore behaviour the visitor has since refused.
- `Cookie` calls `Consent.has()`; `Consent` calls `Cookie` to persist its
  record. Keep that the only edge between them, with the consent record always
  classified `necessary`, so the two cannot deadlock each other.

## 6) Other device storage

`localStorage`, `sessionStorage`, IndexedDB, the Cache API and a service worker
all store information on the device, so TDDDG § 25 treats them exactly like
cookies. The same classification, consent gate and cleanup apply.

- Authentication storage (`localStorage.session` and the `me` cache described
  in `auth.instructions.md`) is `necessary`: it exists to deliver a service the
  visitor asked for.
- Anything else in `localStorage` needs a registry entry and a category, under
  the same `lr_` naming.
- Do not move optional data from a cookie into `localStorage` to avoid the
  consent gate. It is the same obligation with a worse expiry story.

## 7) Deletion and cleanup

`Cookie.purge(category)` must leave nothing behind that can still identify the
visitor for that purpose:

1. Delete every registered cookie in the category, with the same path and
   host attributes they were written with — a mismatched `Path` leaves a second
   copy alive.
2. Delete third-party cookies of that category by their registered names, on
   this host.
3. Delete the matching `localStorage`, `sessionStorage` and IndexedDB entries.
4. Stop the client-side senders for the category, so nothing is written back a
   moment later.
5. Leave `necessary` storage untouched, including the consent record and the
   session.

`Consent.withdraw()` purges every optional category and then reloads, because a
third-party script that is already running cannot be unloaded.

Clearing storage must also be possible for a visitor who deletes cookies in the
browser: the app recovers into the undecided state and asks again, rather than
breaking.

## 8) Server-side cookies

- A cookie may be read on the server (for example in `getServerSideProps` or a
  route handler) to render a page consistently. Read it there as a request
  header; do not reach for `document`.
- Do not **write** an optional cookie from the server: the server does not know
  the decision before the client has made it, and a cached response must never
  carry one visitor's cookie to another.
- A cookie whose value changes the HTML makes the response personal. Keep it
  out of anything cached, or render the consent-dependent part on the client.

## 9) Checklist

- [ ] `document.cookie` is touched only in `lib/Cookie.js`; no cookie library.
- [ ] Every cookie is in `Cookie.REGISTRY` with category, purpose and max age.
- [ ] `lr_` prefix, no personal data in names, nothing sensitive readable by
      script where `HttpOnly` was possible.
- [ ] Host-only, `Path: /`, `Secure`, deliberate `SameSite`; `Domain=` only
      with a recorded reason.
- [ ] Session by default; consent record 180 days; nothing over 13 months.
- [ ] Necessary storage works for a visitor who refuses everything.
- [ ] No optional cookie or storage key written before consent, reads gated too.
- [ ] `purge()` clears cookies, third-party names and other device storage, and
      leaves necessary state alone.
- [ ] Nothing optional is written during server rendering.
