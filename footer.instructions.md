---
name: LivaRava Footer Rules
description: "Use when creating, changing, or refactoring a site Footer, footer navigation menu, footer links, or footer menu data loading in LivaRava projects (livarava-www, livarava-mail, and similar)."
applyTo: "**/components/**/footer/**, **/styles/footer.scss, **/lib/Navigation.js"
---
# Footer Guidelines

- Use `livarava-www` and `livarava-mail` as the reference base. Reuse their Footer components and styles before writing new ones.
- If a Footer is outdated, always follow the current link structure and grouping in `livarava-www`, adapting URLs and data only as the target project requires.
- Footer styles live in `footer.scss`; use the universal `.footer` class and project-neutral names. Do not leave Footer rules in `globals.scss`, `livarava.scss`, or project stylesheets.
- Avoid `styled-components` and large inline styles.

## Footer menu

- Use a dedicated `FooterMenu` component that tries to load the live menu from API v2 `/navigations/17032626/` (the same ID for all frontend projects) and falls back to a current static menu when loading fails or the JSON is invalid. Remove legacy standalone link files (for example `footerLinks.js`) once unused.
- Static fallback menu (for API failure/invalid JSON) must match the canonical structure exactly:
  - `Products`: `/en/neuronet/`, `/en/community/`, `/en/business/`, `/en/sites/`, `/en/mail/`
  - `Services`: `/en/services-marketing/`, `/en/services-advertisement/`, `/en/guest-posting/`, `/en/services-development/`
  - `Media`: `/trends/`, `/finance/`, `/crypto/`, `/technology/`, `/games/`, `/medicine/`, `/health/`
  - `Company`: `/en/about/`, `/events/`, `/en/contacts/`
  - `Resources`: `/blog/`, `/en/portfolio/`, `/en/livarava-helper/`, `/en/subscribe/`
  - `Legal`: `/en/terms/`, `/en/ethics/`, `/en/privacy/`, `/en/public-offer/`, `/en/impressum/`
- Header menu and Footer menu are different menus with independent data. Do not share link data; share only the JSON validation helper.
- Read the `json` attribute; never render the legacy HTML `description` attribute.
- JSON contract: `{ "sections": [{ "id", "title", "links": [{ "id", "label", "href" }] }] }`, with unique ids, non-empty sections and links, and host-relative `href` values.
- Prefix host-relative links with the main site base URL when the project is not served from the main site.

## Layout

- In `livarava-www`, place the language selector in its own full-width row above the Footer menu, separated from the menu by a horizontal rule. Keep it horizontally stretched and compact in height, with a clear label and the current language selected.
- The language selector is specific to `livarava-www`. Do not add it to `livarava-mail` or other projects unless explicitly requested for that project.
- Menu sections go in the top block; the logo, social links, and version/copyright go in the bottom block. Separate these blocks with a horizontal rule.
- Keep the large menu line spacing scoped to the menu block (`.footer-menu`); the rest of the Footer uses a normal line height.
- Keep responsive Footer layout and durable presentation rules in `footer.scss`.
- Show the Footer by default. Hide it only on pages that need the full screen (for example a mail client) by passing an explicit `hideFooter` prop to the page wrapper, not by checking authentication.
