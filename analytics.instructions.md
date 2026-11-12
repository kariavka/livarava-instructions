---
description: "Use when implementing or changing analytics, Google Analytics, gtag initialization, tracking IDs, or analytics-related config across LivaRava projects."
name: "LivaRava Analytics Standard"
applyTo: "**/*.{js,jsx,ts,tsx}"
---

# LivaRava Analytics Standard

Use this baseline for analytics integration in `www`, `mail`, `business`, `community`, `sites`, and `blog`.

## 1) Canonical GA identifier symbol

- Use `Config.GOOGLE_GA_TRACKING_ID` as the canonical code-level identifier for Google Analytics tracking ID.
- Do not hardcode GA IDs directly in page components or scripts.

## 2) Environment-driven configuration

- Define the value as:
  - `Config.GOOGLE_GA_TRACKING_ID = process.env.NEXT_PUBLIC_GOOGLE_GA_TRACKING_ID || '<fallback-id>'`
- `NEXT_PUBLIC_GOOGLE_GA_TRACKING_ID` is the primary source per environment.
- A fallback ID is allowed only as a safe default for compatibility.

## 3) Script initialization consistency

- When injecting GA scripts (`gtag.js`), always reference `Config.GOOGLE_GA_TRACKING_ID`.
- Keep initialization consistent:
  - load `https://www.googletagmanager.com/gtag/js?id=${Config.GOOGLE_GA_TRACKING_ID}`
  - call `gtag('config', Config.GOOGLE_GA_TRACKING_ID, ...)`

## 4) Reliability and safety

- If analytics configuration is missing or disabled, fail gracefully without breaking page rendering.
- Keep analytics setup isolated from auth/session logic.
- Reuse shared analytics helpers where available instead of duplicating script bootstrap code.
