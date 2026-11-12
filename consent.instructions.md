---
name: LivaRava Consent Rules
description: "Use when implementing or changing consent collection, the consent banner or preferences dialog, consent state and withdrawal, or any consent-gated third-party script, embed or tag in a LivaRava frontend. Defines the standard Consent component."
applyTo: "**/lib/Consent.js, **/components/consent/**, **/styles/consent.scss, **/pages/_app.js, **/pages/_document.js, **/lib/Google.js, **/locales/**"
---

# LivaRava Consent Rules

Consent manages **permission** for the optional processing that
`privacy.instructions.md` defines, and hands storage to the `Cookie` component
of `cookie.instructions.md`. It decides; `Cookie` persists and cleans up.

LivaRava operates **its own first-party consent implementation**. Do not add an
external CMP service, SDK, hosted banner or consent library, and do not restore
one that was removed.

## 1) The `Consent` component

The standard name is `Consent`. One implementation per project, in
`lib/Consent.js`, framework-independent:

- No React, no Redux, no DOM in `lib/Consent.js`. The UI lives in
  `components/consent/` and subscribes to it. (`lib` holds data utilities;
  anything that renders belongs in `components`.)
- It is the single source of truth. A component that needs to know about
  consent asks `Consent`, never a cookie directly and never its own copy of the
  state.

```js
Consent.CATEGORIES          // frozen category list, in display order
Consent.VERSION             // integer; raising it re-asks everyone
Consent.get()               // the stored decision record, or null
Consent.has(category)       // boolean; false unless that category is granted
Consent.isDecided()         // a valid, current-version record exists
Consent.set(categories)     // persist a decision, notify subscribers
Consent.acceptAll()
Consent.rejectAll()
Consent.withdraw()          // clear the decision, purge storage, re-ask
Consent.subscribe(listener) // returns an unsubscribe function
Consent.open() / Consent.close()   // the preferences UI
```

Rules for the API:

- **Deny by default.** `has()` returns `false` when nothing is stored, when the
  record is from an older `VERSION`, when it has expired, during server
  rendering, and whenever anything is unparseable. There is no "unknown" state
  that behaves like a grant.
- `has()` must be safe to call anywhere, including before hydration, and must
  never throw.
- `set()` records the whole decision at once, so a half-saved state cannot be
  read. It notifies subscribers after the record is persisted, not before.
- `withdraw()` is not the same as `rejectAll()`: it clears the record, calls
  `Cookie.purge()` for every optional category, and leaves the visitor in the
  undecided state so the banner appears again.

## 2) Categories

Exactly four, in this order, with these keys:

| Key | Label | Consent | Contains |
|---|---|---|---|
| `necessary` | Necessary | always on, cannot be switched off | Session and authentication storage, CSRF, the consent record itself, load balancing |
| `preferences` | Preferences | opt-in | Locale and interface choices that outlive the session |
| `statistics` | Statistics | opt-in | Google Analytics 4, Microsoft Clarity, any audience measurement |
| `marketing` | Marketing | opt-in | Advertising, remarketing, third-party embeds such as video players and maps |

- Do not rename, merge, split or alias these keys. A fifth category is a
  product decision, not a local one.
- Do not create a category to make something load earlier. If a purpose is
  genuinely necessary for the service the visitor requested, it needs no
  consent and belongs in `necessary`; everything else is opt-in.

## 3) The decision record

```js
{ version: 1, at: '2026-10-27T10:15:00.000Z', locale: 'de',
  method: 'accept_all' | 'reject_all' | 'save',
  categories: { necessary: true, preferences: false, statistics: true, marketing: false } }
```

- Persisted by `Cookie` under the canonical consent cookie name, as a
  `necessary` cookie. Nothing else writes or parses it.
- It holds no identifier: no user id, no IP, no fingerprint, no page URL.
- Ask again when `VERSION` was raised, when the record is older than the
  consent lifetime in `cookie.instructions.md`, or when the set of purposes
  changed. A category added later starts denied for everyone who already
  decided, whatever their previous answer was.
- The cookie is the browser's copy of the decision, not proof of it. A
  controller-side record (GDPR Art. 7(1)) needs an API v2 resource that does
  not exist yet; do not invent an endpoint, and do not claim the record is
  legally sufficient while it is only local.

## 4) Consent-aware activation

This is the part that actually protects the visitor; the dialog is only how
they answer.

- **Nothing optional may touch the network or the device before consent.** No
  script tag, no iframe, no preconnect, no web font, no pixel, no beacon.
  Removing a consent-aware gate is a data-protection regression, not a cleanup.
- Optional tags are mounted from one place per project, gated on
  `Consent.has(...)`, and never rendered unconditionally in `pages/_app.js`.
- `strategy="beforeInteractive"` is reserved for code that neither requests nor
  stores anything — in practice only the denied-by-default consent signals
  below. A gated tag is `afterInteractive`, mounted after the decision is read.
- Activation is immediate on grant and does not require a reload. Revocation
  cannot unload a script that already ran, so after a withdrawal purge storage
  (`Cookie.purge`), stop sending further events, and reload the page.
- Server rendering must not depend on consent. Render the page the same way for
  everyone and resolve consent on the client, so no cached HTML carries one
  visitor's decision to another.

### Vendor signals that must be sent

Blocking the tag is necessary but not always sufficient; several vendors
require their own signal as well.

- **Google (Consent Mode v2):** set the defaults `ad_storage`,
  `ad_user_data`, `ad_personalization` and `analytics_storage` to `denied`
  before any Google tag loads, then send an update when the decision changes.
  The defaults snippet makes no request and stores nothing, so it is the one
  thing allowed to run before consent.
- **Microsoft Clarity:** the tag records sessions, so it is not loaded at all
  before `statistics`, and its own consent call is sent on grant.
- Any further vendor: see question 6 of section 8 in
  `privacy.instructions.md`.

### Google advertising and certification

LivaRava runs its **own, non-certified** first-party consent implementation,
and every service LivaRava needs is activated once the visitor grants the
matching category — Google advertising included. That is the product decision
of 2026-10-27. Implement it; do not re-open it in code comments or review.

What the decision does and does not mean:

- **GDPR and TDDDG are satisfied by the implementation, not by a certificate.**
  Prior consent, granular categories, a refusal as easy as acceptance, and
  withdrawal at any time are what the law asks for, and `Consent` provides
  them. There is no legal requirement to buy a vendor.
- **Google's certified-CMP requirement is a contract with Google, not a
  statute.** Google requires a Google-certified CMP integrated with IAB TCF
  v2.2 for ads served to EEA, UK and Swiss users through AdSense, Ad Manager
  or AdMob. Running without one risks serving being limited to
  non-personalised ads, lower EEA/UK revenue, or action against the publisher
  account. That exposure is commercial and was accepted knowingly.
- **Send Google Consent Mode v2 either way.** Google reads those signals with
  or without a TCF string, and they are what actually keeps a visitor who
  refused from being tracked. They are not optional because certification was
  skipped.
- **Never fake certification.** Do not register a `__tcfapi` shim, do not
  synthesise a TC string, and do not describe `Consent` as certified in UI
  copy, documentation or a commit message. A forged TCF signal misleads every
  downstream vendor and breaches Google's policy more seriously than having no
  CMP at all.
- Revisit only if Google restricts the account, or if the user asks for IAB
  Europe registration and Google certification.

**Ads run non-personalised**, everywhere, decided 2026-10-27. That is the
outcome an uncertified publisher gets in the EEA, UK and Switzerland anyway,
and serving one mode worldwide keeps the implementation free of
geolocation — LivaRava does not need to detect a visitor's region in order to
decide what to serve them.

- Set `requestNonPersonalizedAds = 1` on the `adsbygoogle` array before the
  first slot is pushed, in addition to the consent signals below.
- Consent Mode v2 then maps as: `ad_storage` and `ad_user_data` follow the
  `marketing` decision, while **`ad_personalization` stays `denied`
  permanently** while LivaRava is uncertified. Granting it would ask Google for
  personalised serving that cannot lawfully be delivered here.
- Non-personalised **still stores on the device** — frequency capping and fraud
  prevention — so it stays behind `marketing` consent exactly like personalised
  serving. "Non-personalised" is not a synonym for "consent-free".
- Turning personalisation on later for non-EEA visitors would require
  region detection and a second ad configuration. Treat that as a new decision,
  not an optimisation.
- **Auto ads are enabled on the AdSense account** (stated by the user on
  2026-10-27). Google then places ads by itself, wherever it decides, as soon
  as the loader runs — our explicit `<ins>` slots stop being the placement
  control, and no frontend change restricts it. Two consequences: the loader
  itself is the only consent gate that matters, so it must never load before
  `marketing`; and the pages the loader is allowed on are a decision, since
  Auto ads would otherwise appear on authenticated views and inside CMS
  landing pages. Restrict them in the AdSense console, or mount the loader
  only on the page types that may carry ads.

## 5) Collecting the decision

- Show the banner only when `Consent.isDecided()` is false.
- **Accept and reject must be equally easy**: same level, same prominence,
  same number of clicks. No "Accept all" button next to a "Settings" link that
  hides the refusal.
- No pre-ticked boxes, no sliders defaulting to on, no "legitimate interest"
  toggles that start granted.
- Nothing implies consent: not scrolling, not continuing to browse, not
  closing the banner, not pressing Escape. An undecided visitor stays
  undecided, which means denied.
- No cookie wall. The banner must not block reading the page, and content must
  not be withheld to force a decision.
- A permanent entry point to the preferences is reachable from every page — the
  footer at minimum — and `Consent.open()` is callable from CMS markup, so a
  policy page can place its own button without shipping JavaScript. In
  `livarava-www` that goes through the page component registry
  (`components/page/PageComponents.js`), not an inline script.
- Blocked third-party embeds show a placeholder naming the provider and the
  category, with a control that grants it. Never silently show an empty space.

## 6) UI and accessibility

- The preferences dialog uses `role="dialog"` with `aria-modal="true"`, an
  accessible name, focus moved into it on open and restored to the trigger on
  close, Escape to dismiss **without granting**, and no focus escaping behind
  it.
- The banner is reachable and operable by keyboard alone, in a sensible tab
  order, with visible focus.
- Switches are real form controls with labels, not clickable `div`s, and each
  category names its purpose in plain language with its retention.
- WCAG 2.1 AA contrast, touch targets of at least 44px, usable at 320px width,
  and no layout shift when the banner appears.
- Styling follows `style.instructions.md`: Bootstrap plus a single owned
  stylesheet (`styles/consent.scss`), imported once from the app entry point.
  No `styled-components`, no inline style blocks, no `!important`.
- Hydration: the banner renders nothing on the server and mounts after the
  decision is read, so markup matches and no banner flashes for a visitor who
  already decided.

## 7) Localisation

- Every string comes from the project's locale files under a `consent` key.
  Never hardcode consent copy in a component.
- `en`, `uk` and `de` are all required, in real translations. German is not
  optional here: TDDDG applies to the German-language audience on this host.
- The policy and cookie-declaration links point to the locale's own pages.
- Category labels and purpose descriptions are legal copy. Do not improvise
  them to fit a layout; shorten the layout.

## 8) Checklist

- [ ] `Consent` is first-party, has no external CMP, and lives in `lib/`.
- [ ] Default is denied, including during SSR and on unparseable state.
- [ ] Exactly the four canonical categories, unaliased.
- [ ] No optional tag, embed or font loads before its category is granted.
- [ ] Google Consent Mode defaults are denied and updated on change.
- [ ] Google ad tags load only after `marketing`, request non-personalised
      ads, keep `ad_personalization` denied, and nothing claims certification.
- [ ] Reject is as prominent as accept; nothing is pre-ticked; no cookie wall.
- [ ] Withdrawal clears the record, purges storage through `Cookie`, re-asks.
- [ ] Dialog semantics, keyboard, focus and 320px width verified.
- [ ] Copy exists in `en`, `uk` and `de`, from locale files.
