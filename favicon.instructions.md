---
description: "Use when working with favicon files, head meta tags, manifest icons, or browser-tab branding."
applyTo: "**/*.{html,htm,js,jsx,ts,tsx}"
---

# Favicon implementation (current state, do not improve yet)

## 1) Active implementation
- Use a single external favicon URL:
  - `https://store.livarava.com/d8f6e83e-b2e4-11e8-b344-5254a2021b2b.png`
- Keep tag format exactly:
  - `<link rel='shortcut icon' type='image/png' href='https://store.livarava.com/d8f6e83e-b2e4-11e8-b344-5254a2021b2b.png' />`

## 2) Source of truth in code
- Favicon link must be present in both wrappers:
  - `components/common/MainWrapper.js`
  - `components/common/BasicWrapper.js`
- Keep both wrappers aligned; do not update one without the other.

## 3) Explicitly out of scope for now
- Do not add local favicon assets in `public/` yet.
- Do not add `favicon.ico`, `favicon.svg`, `apple-touch-icon.png`, or `site.webmanifest` yet.
- Do not migrate to multi-size/icon-set strategy yet.

## 4) Change policy
- For routine tasks, preserve current favicon behavior exactly.
- Any favicon modernization (local assets, manifest, extra icon tags, cache busting) must be a separate explicit task.

## 5) Desired future implementation (not active yet)
- Target state (for a separate future task):
  - Local assets in `public/`:
    - `favicon.ico` (16x16, 32x32)
    - `favicon.svg`
    - `favicon-32x32.png`
    - `favicon-16x16.png`
    - `apple-touch-icon.png` (180x180)
    - optional `site.webmanifest` with valid icon entries
  - Extended `<head>` icon tags for modern browsers and Apple devices.
- Until that migration task is explicitly requested, keep the current single external favicon link unchanged.
