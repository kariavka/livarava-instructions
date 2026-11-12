---
name: LivaRava Privacy Rules
description: "Use when writing or changing any frontend code that collects, stores, sends or displays personal data, loads a third-party service, or touches the published Privacy Policy. Defines the data-protection rules the Consent and Cookie systems enforce."
applyTo: "**/*.{js,jsx,ts,tsx}"
---

# LivaRava Privacy Rules

This is the top of a three-file system. Privacy defines **what** may be
processed and on what basis; `consent.instructions.md` manages **permission**
for the optional part; `cookie.instructions.md` enforces **browser storage**.

| File | Owns | Never owns |
|---|---|---|
| `privacy.instructions.md` | Purposes, legal bases, disclosure, retention, third-party review | Permission state, storage mechanics |
| `consent.instructions.md` | The `Consent` component: categories, decisions, withdrawal, consent-aware activation | Which processing is lawful, cookie attributes |
| `cookie.instructions.md` | The `Cookie` component: classification, attributes, expiry, deletion | Whether a purpose exists, consent UI |

Each file states a rule once. When a rule belongs to another file, reference it
rather than restating it.

## 1) Authoritative source

The published LivaRava Privacy Policy, **effective October 26, 2026**, is the
authoritative description of what LivaRava processes. It is a CMS page served
through `pages/[[...path]].js` at `/en/privacy/`, not a file in any repository.

- Read the live policy before adding a processing purpose, a third-party
  service or a new cookie. Do not work from memory of it.
- Code may process **less** than the policy describes. Code may never process
  **more**, and may never claim more: a consent dialog, a form disclaimer or a
  marketing page must not promise a guarantee the implementation does not keep.
- **Do not rewrite the published Privacy Policy as part of another task.** A
  policy change is an explicit, separately reviewed request.
- When implementation and policy disagree, report it (see section 9) and leave
  both as they are until the user decides which one is wrong.

## 2) Scope

These rules apply to every frontend served under `https://www.livarava.com/`,
whatever the framework or mount path: `/`, `/blog/`, `/business/`,
`/community/`, `/events/`, `/sites/`, `/mail/`, and any subproject added later.
One visitor on that host has one privacy and consent state across all of them.

`id.livarava.com` and `accounts.livarava.com` are a **different host**. They are
in scope for these privacy rules and out of scope for a host-scoped
`www.livarava.com` cookie; see the domain section of
`cookie.instructions.md` before assuming a shared decision.

## 3) Legal framework

- **GDPR** applies to visitors in the EEA. LivaRava Platform LLC is established
  in the United States and offers services to EEA users, so Art. 3(2) applies.
- **TDDDG § 25** (Germany) governs storing or reading information on a
  visitor's device. It requires prior consent for anything that is not strictly
  necessary to deliver the requested service, and it applies regardless of
  whether the stored data is personal data. Technical necessity is the only
  exemption; "legitimate interest" is not one for device storage.
- German-language pages are served from this host, so German requirements are
  not hypothetical. Treat `de` as a first-class locale in every privacy,
  consent and cookie surface.

## 4) Legal bases

Align every processing purpose with the basis the policy names (policy § 9):

| Purpose | Basis | Consent needed |
|---|---|---|
| Accounts, authentication, requested operations, integrations, AI-assisted functionality | Contract | No |
| Security, abuse prevention, service reliability | Legitimate interests | No |
| Statutory obligations | Legal obligation | No |
| Statistics, advertising, non-essential embeds, optional device storage | Consent | **Yes** |

- Do not invent a legal basis in code comments or UI copy.
- Do not describe a consent-based purpose as "necessary" in order to load it
  earlier. Necessity is about the service the visitor asked for, not about
  business value.

## 5) Data minimisation in the frontend

- Send a third party only what its declared purpose needs, and never personal
  data it does not need to receive.
- Keep personal data out of places that are logged, shared or replayed:
  URL paths and query strings, `utm_*` parameters, analytics event names and
  labels, page titles, error messages, console output, and `data-*` attributes
  in CMS HTML.
- Never use an email address, a phone number, a user id or a session token as a
  campaign value, a cookie name, an analytics dimension or an element id.
- Session recording and heatmap tools receive whole pages. Where such a tool is
  enabled, exclude form fields, authenticated views and any element rendering
  user content from capture; masking is not optional.
- Browser storage of personal data is governed by `cookie.instructions.md`.
  Nothing beyond what `auth.instructions.md` requires may be kept there.

## 6) Transparency

A processing purpose exists for the visitor only if it is disclosed.

- A new third-party service, cookie, or device-storage key ships only once it
  is in the cookie registry (`cookie.instructions.md`) **and** in the published
  policy.
- The visitor must be able to reach, from every page: the Privacy Policy, the
  cookie declaration, and the consent preferences. The first two are CMS pages;
  the third belongs to `Consent`.
- The cookie declaration must describe what is actually set, generated from the
  registry rather than written by hand, so it cannot drift from the code.

## 7) Retention, security, transfers

- The frontend keeps personal data only for as long as the view needs it.
  Anything that outlives the tab is a declared cookie or storage key with an
  expiry, or it does not exist.
- Never place credentials, tokens or keys in a URL, a log line, an analytics
  payload or a cookie readable by script where `httpOnly` is possible.
- Third-party processing happens largely in the United States (OpenAI, Google,
  Microsoft, PayPal). That is disclosed in policy § 10; adding a provider in a
  further jurisdiction requires the disclosure to be updated first.

## 8) Third-party services

Before adding or re-enabling any third-party script, embed, font, pixel or
iframe, answer all of these in the change itself:

1. Which purpose does it serve, and which legal basis?
2. Which consent category gates it (`consent.instructions.md`)?
3. What does it store on the device, under which names and for how long
   (`cookie.instructions.md`)?
4. What personal data does it receive, and where is it processed?
5. Is it disclosed in the published policy and the cookie declaration?
6. Does it have a vendor-specific consent signal that must be sent
   (for example Google Consent Mode, or a provider's own consent call)?

An unanswered question blocks the change. Self-hosting an asset is preferred to
gating it.

### OpenAI API

- Send only what the requested operation needs; connected-service data goes out
  only when that operation requires it, with the user's consent.
- API data is not used to train generalised models; do not add a feature that
  depends on it being used that way.
- Conversation history and context are Platform records with their own
  retention. Do not duplicate them into browser storage.

### Google API data

- Google user data (Calendar, events, Search Console) is accessed only within
  the permissions the user granted, and is used only to provide the requested
  integration.
- It is never used for advertising, never sold, and never passed to an
  unauthorised third party. Keep it out of analytics and ad payloads entirely.
- Use and transfer of Google API data follows the Google API Services User Data
  Policy including the **Limited Use** requirements. Disconnecting an account
  must stop further access.

## 9) Reporting inconsistencies

When frontend behaviour and the published policy do not match, report it to the
user as a separate, dated finding: what the code does, what the policy says,
and which of the two you believe should change. Do not edit the policy, and do
not quietly change the code to match a policy the user has not reviewed.

### Open findings (2026-10-27, `livarava-www`)

1. The policy has **no cookies or tracking section at all** — no cookie
   declaration, and no mention of Google Analytics 4, Microsoft Clarity, Google
   AdSense or the consent banner, although all four ran on the live site. GDPR
   Art. 13 and TDDDG § 25 both require this disclosure.
2. **Microsoft Clarity** records sessions, including pointer movement and input
   behaviour. Policy § 1 discloses "IP addresses, browser and device
   information, authentication records, and diagnostic logs", which does not
   cover session replay.
3. **Advertising is undisclosed.** AdSense served ads on neuron pages; the
   policy describes no advertising purpose and names no ad partner. The
   statement "we do not sell personal data" needs checking against what ad
   partners receive. The mode was decided on 2026-10-27 — non-personalised
   AdSense behind `marketing` consent — so the policy needs an advertising
   purpose that names Google, says the serving is non-personalised, and says
   that nothing is stored for it before consent.
4. **The PayPal SDK loads on every page**, not only where a payment button is
   rendered, so a third party receives a request from visitors who never go
   near a payment.
5. Policy § 8 grants a right to **withdraw consent**, which, after the
   third-party CMP was removed, has no mechanism until `Consent` exists.
6. No **record of consent** is kept anywhere: no API v2 resource, no field on
   the user. Demonstrating consent (GDPR Art. 7(1)) currently rests on a
   browser cookie that the visitor can delete.
7. The policy names **no EU representative** (GDPR Art. 27) while the
   controller is established in Delaware and targets EEA users.

Keep this list current: remove an item when it is resolved, and say in which
commit.

## 10) Checklist

- [ ] The live policy was read, not recalled, and the change stays inside it.
- [ ] Every purpose has a basis from section 4, and consent-based purposes are
      gated by `Consent`.
- [ ] No personal data in URLs, campaign parameters, analytics labels or logs.
- [ ] New third parties answered all six questions in section 8.
- [ ] Device storage is declared in the cookie registry and the declaration.
- [ ] Policy/implementation mismatches were reported, not papered over.
- [ ] The policy itself was left unchanged unless the task was explicitly that.
