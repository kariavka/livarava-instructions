---
name: LivaRava Header Rules
description: "Use when creating, changing, or refactoring a site Header, main navigation menu, user/account menu, guest sign-in button, header search, or header menu data loading in LivaRava projects (livarava-www, livarava-mail, and similar)."
applyTo: "**/components/**/header/**, **/components/input/InputAutocomplete.js, **/redux/actions/autocomplete.js, **/redux/reducers/autocomplete.js, **/styles/header.scss, **/lib/Navigation.js"
---
# Header Guidelines

Header is one composed component with three independent children. Each child owns its own data and state; all Header styling is centralized in `styles/header.scss`. `Header.js` composes the components and coordinates which panel is open.

- Header (`Header.js`)
  - HeaderSearch (`HeaderSearch.js`)
  - HeaderMainMenu (`HeaderMainMenu.js`)
  - HeaderUserMenu (`HeaderUserMenu.js`)

## 1. Header (shared rules)

### Reference and scope
- `livarava-www` is the canonical and highest-priority reference for Header behavior and implementation, especially search. Reuse its components, data flow and interaction patterns first; adapt only what is project-specific (routes, data, branding).
- `livarava-mail` and other projects are secondary references only. When their Header or search behavior differs from `livarava-www`, follow `livarava-www` unless the user explicitly requests a project-specific change.
- Do not replace or redesign canonical `livarava-www` behavior to match a generic recommendation or another project's implementation. Treat any such change as a behavior change that requires an explicit request.
- Keep the Header, its menus and its search as separate components with one responsibility per file. Do not add Dynamic/Static/View variants or other extra layers for the same menu.

### Files and structure
Header components live together in `components/common/header/`. Keep exactly these names across projects:

| File | Responsibility |
|------|----------------|
| `Header.js` | Composes the Header: brand, site title, toggles, account area. Owns the open/closed state of the search and services panels and the shared dismissal effect. |
| `HeaderSearch.js` | Search panel with autocomplete and `Create <query>`. |
| `HeaderMainMenu.js` | Main (services) menu panel: API load, JSON validation, static fallback, rendering. |
| `HeaderUserMenu.js` | Account dropdown (avatar trigger and panel) for all screen widths. |

- `Header.js` also holds the small presentational toggle buttons (`ServicesToggle`, `HeaderSearchToggle`) as local components; extract them only if they grow or are reused elsewhere.
- The avatar is the shared `components/common/avatar/Avatar.js`; never duplicate avatar rendering in the Header.
- The Footer (`components/common/footer/`) and the page wrapper (`MainWrapper.js`) stay outside the header folder. `MainWrapper.js` renders `<Header />`.
- Shared helpers live outside components: `lib/Api.js` (endpoints) and `lib/Navigation.js` (JSON validation).

### Layout and responsiveness
- One markup for all widths. Do not build separate desktop and mobile versions: no `navbar-expand-lg`, Bootstrap collapse, burger toggler, duplicated mobile account list, `matchMedia` effects or `!important` overrides. Adapt with CSS only.
- Search, services and account are toggle buttons with a dropdown panel; only one panel is open at a time.
- Single row inside `.container-fluid.d-flex.flex-nowrap.gap-2`: brand logo, site title (`text-truncate me-auto`), search toggle, services toggle, then `HeaderUserMenu` (authenticated) or the project's guest actions. Keep existing project-specific actions such as Request Demo unless explicitly asked to remove them; do not add a separate Sign Up button when registration is reachable from the sign-in page.
- For guest action buttons, use standard Bootstrap classes/utilities (`btn`, `btn-sm`, `text-nowrap`, `d-inline-flex`, `align-items-center`, `justify-content-center`) in markup. Do not add custom CSS rules for button centering or sizing in `header.scss`.
- The brand logo (`navbar-brand`) links to the host root as a plain `<a href='/'>`: not `Config.BASE_URL`, not the project's `basePath`, not `Link`. The site title next to it is the only element that links to the sub-project home (through `Link`).
- The Header is `position: fixed` with height `--header-height`. Add a page offset only where the page actually needs one; do not keep unused offset styles or classes.
- The search and services panels are full-width blocks under the Header (`position: absolute; top: 100%; left: 0; width: 100%`).
- At mobile widths, panels (including the account panel) expand to the full viewport width using CSS, without introducing a second markup tree. Verify there is no horizontal overflow.

### Links
- Header links that target the host root or a different project (main menu, account base links, brand logo) are plain `<a href>` with host-relative paths: no `Config.BASE_URL`, no project `basePath`, no `Link`.
- Use `Link` for the site title and routes owned by the current Next.js project, including its internal auth routes (`Log Out`, `Sign in`). Verify each destination against the actual project routes before choosing the element; do not infer link type only from its label.
- Account link objects use `{ label, href, icon, hostPath }`. Render `hostPath: true` as a plain `<a>` and current-project routes as `Link`. Keep the base account paths `/dashboard/`, `/profile/`, `/billing/`, and `/settings/` host-relative; keep `/signout/` as an internal `Link`. Project-specific links are a separate group between base links and Log Out.

### Styles
- All Header styles are in the project's single `styles/header.scss`. Keep them as close to identical to the canonical `livarava-www` styles as possible. Do not create per-component Header stylesheets or put Header rules in `globals.scss`, `livarava.scss`, or project/subproject stylesheets. Avoid `styled-components` and large inline styles.
- `header.scss` is imported once from `pages/_app.js`, after `globals.scss` and `livarava.scss` and before `footer.scss`. Do not override Header styles later in another stylesheet; intentional visual differences require an explicit reason and should remain in `header.scss`.
- Class names are project-neutral with the `header-*` prefix; the root is `.header`:
  - Layout: `.header`, `.header-navbar`
  - Brand: `.header-site-title`
  - Actions: `.header-action-trigger`, `.header-guest-actions`
  - Shared panel base: `.header-menu-panel`
  - Services: `.header-services`, `.header-services-heading`, `.header-services-link`
  - Search: `.header-search`, `.header-search-content`, `.autocomplete-root`, `.autocomplete-results`, `.header-search-option`, `.header-search-option-content`, `.header-search-error`
  - Account: `.header-account-panel`, `.header-account-name`, `.header-account-details`, `.header-account-fullname`, `.header-account-email`, `.header-account-link`, `.header-account-divider`, `.header-avatar`, `.header-avatar-trigger`
- Every class listed here must be used in the code. Remove a class that is no longer used from both `header.scss` and this list; do not keep dead styles.
- Use Bootstrap utilities (`gap-2`, `ms-auto`, `d-flex`, `text-truncate` and similar) for simple layout in markup; put everything else in `header.scss`.

### Dismissing panels
Every panel and dropdown in the Header closes on a click anywhere outside it **and** on `Escape` - the services menu, the search panel and the account menu, with no exceptions. A panel that can only be closed by clicking its own toggle again is a bug, not a style choice.

- Beware the two-level trap that produced this bug in `livarava-www`: `InputAutocomplete` closes its own results list on an outside click, which makes the search panel *look* handled while the panel itself stays open. Closing the results list and closing the panel are separate behaviours; verify the panel, not the list.
- The services and search panels share one effect in `Header.js`, since only one of them is open at a time. Toggles are matched with `data-header-toggle` and panels with `data-header-panel` instead of refs:

```jsx
useEffect(() => {
  if (!isSearchOpen && !isServicesOpen) return;

  const closePanels = () => {
    setSearchOpen(false);
    setServicesOpen(false);
  };

  const handleOutsideClick = event => {
    if (event.target.closest('[data-header-panel]')) return;
    if (event.target.closest('[data-header-toggle]')) return;
    closePanels();
  };

  const handleEscape = event => {
    if (event.key === 'Escape') closePanels();
  };

  document.addEventListener('click', handleOutsideClick);
  document.addEventListener('keydown', handleEscape);
  return () => {
    document.removeEventListener('click', handleOutsideClick);
    document.removeEventListener('keydown', handleEscape);
  };
}, [isSearchOpen, isServicesOpen]);
```
- Excluding `[data-header-toggle]` from the outside-click handler keeps a toggle click from closing and immediately reopening the panel. Do not solve that with `stopPropagation`, which breaks the other panels' handlers.
- `HeaderUserMenu.js` owns its own effect, because its trigger and panel both live inside that component: it keys off `triggerRef` and `menuRef` and handles `Escape` as well.
- Register the listeners only while something is open (`if (!isOpen) return`) and remove them in the effect cleanup. A listener left on `document` after the panel closes is a leak and will fight the next panel.
- Clicking a link inside a panel closes it too: the services menu through `onClose` on each link, the account menu through `onClick={() => setOpen(false)}`.
- Opening one panel closes the others: `toggleSearch` closes services, `toggleServices` closes search, and `HeaderUserMenu`'s `onOpen` closes both.

### Accessibility
- Every icon-only button has `aria-label` (and `title` where useful); decorative icons have `aria-hidden='true'`.
- Toggles carry `aria-controls` (the panel `id`) and `aria-expanded`.
- Toggle buttons must show a persistent visual "expanded" state while their panel is open (driven by `aria-expanded='true'`), so users can immediately see which panel is active.

### Verification
- Check manually at 320, 576, 768, 992 and 1280px: the layout does not shift when resizing, panels close on outside click, `Escape` and link click, and only one panel is open at a time.

## 2. HeaderSearch

- The `livarava-www` search is the source of truth. Implement and validate search behavior there first; other projects adopt that behavior and may adapt only project-specific routes or presentation.
- The behavior is composed across `HeaderSearch.js`, `components/input/InputAutocomplete.js`, the autocomplete Redux action, and the callbacks in `Header.js`. Keep these responsibilities connected; do not move or replace the search flow unnecessarily.
- `HeaderSearch.js` is the panel wrapper: it returns `null` when closed, renders `.header-search` with `data-header-panel` and the shared project-neutral ID `headerSearchPanel`, and passes `onClose`, `onSelect`, and `onCreate` to `InputAutocomplete`. The search toggle's `aria-controls` must match this ID.
- Query the existing autocomplete API through the canonical Redux/API flow. Normalize the query by trimming it and collapsing repeated whitespace; do not request until it has at least 3 characters. Debounce typing by about 500 ms, cancel the pending timer when the query changes or the panel closes, request up to 5 results, and sort by `-created`. Suppress duplicate requests for the same normalized query. Submitting explicitly may run the current query immediately.
- A newer query, clear, close, or unmount invalidates earlier work. Ensure an older response or error cannot overwrite results for the current query. Abort an in-flight request only if the API client can do so without breaking its request deduplication or other callers; otherwise ignore stale completions through request IDs/generation checks.
- Focus the search input when the panel opens. Implement the accessible combobox/listbox pattern: input with `role='combobox'`, `aria-expanded`, `aria-controls`, and `aria-activedescendant`; results with `role='listbox'` and selectable `role='option'` entries. Arrow keys move the active option, Enter activates it, and Escape closes the panel. Keep focus in the input while changing the active descendant; do not intercept Space in the text input.
- Do not show the minimum-query prompt just because an empty search input received focus; show it only after the user enters a non-empty query shorter than the minimum.
- Search results list and rows have no margins or outer padding. Keep row corners square, but keep the results container rounded with `overflow: hidden`, so the active-row background follows the same rounded outer shape as the account menu panel. The highlighted row spans the full list width; use horizontal/vertical padding inside each row for readable content spacing. Pointer and keyboard navigation must use the same active option and the same `.active` styling. Avoid generic `.d-flex` inside active options because a global `.active .d-flex` rule adds a second background; use a Header-specific content class styled only in `header.scss`. Use one shared gray highlight on the row only. Use a pointer cursor for actionable options, and ensure two options are never highlighted at once.
- Preserve the `Typing...`, `Searching...`, error (`role='alert'`), `Nothing found.`, and `Create <query>` states. The create action is keyboard-selectable, is disabled while creating, and surfaces failures inline.
- Preserve the canonical selection and creation callbacks in `Header.js`: selecting a result navigates through the existing Next router helper; creating a neuron parses the query, opens an existing neuron when returned, or creates a public neuron and navigates to it. Do not switch to `window.location.assign`, add a separate API flow, or change route semantics unless explicitly requested.
- That router rule assumes `/neuron/<id>` is a route of the project doing the navigating, which is true of `livarava-www` and nothing else. In a sub-project with a `basePath`, `router.push('/neuron/7')` resolves to `/<basePath>/neuron/7`, which does not exist, so the canonical flow silently 404s. There the neuron page is another project's route on the host root, which the "Links" rule already covers: navigate host-relative (`window.location.assign('/neuron/7')`), and keep the parse/create sequence and its error handling unchanged. `livarava-sites` does this since 2026-10-26; `livarava-business` and `livarava-community` still push `/neuron/<id>` through their own router and need the same correction.
- Reset the query, results, active option, errors, and pending timer when the panel closes. Opening search closes the services menu and vice versa; only one panel is open at a time. The panel closes on outside click and `Escape`. Closing the autocomplete results list is not the same as closing the search panel; see "Dismissing panels".
- Search is available to guests and authenticated users alike.

## 3. HeaderMainMenu

- A single component (`HeaderMainMenu.js`) that loads the live menu from the API and falls back to a static version when loading fails or the data is invalid. Props: `isOpen`, `onClose`. Returns `null` when closed. The panel root is `.header-services` with `data-header-panel` and the shared project-neutral ID `headerServicesPanel`.
- Header menu and Footer menu are different menus with independent data. Never derive one from the other or share link constants; share only the JSON validation helper (`parseNavigationJson` in `lib/Navigation.js`).
- Load via API v2 `/navigations/17116501/` (the same ID for all frontend projects, `Api.getNavigation`) and read the `json` attribute (`data.attributes.json`). Never render the legacy HTML `description` attribute.
- JSON contract: `{ "sections": [{ "id", "title", "links": [{ "id", "label", "href" }] }] }`. Require non-empty sections and links, unique section ids and unique link ids within each section, and host-relative `href` values (start with `/`, not `//`, no backslash).
- Show the static fallback immediately while the request is pending; keep it in sync with the current CMS menu. If loading fails or the JSON is invalid, keep the fallback and show a short notice (`role='alert'`). Ignore the response if the component unmounted.
- Render links as plain `<a className='header-services-link' href>` with the host-relative `href` from the data (for example `/en/neuronet/`), see "Links". Clicking a link calls `onClose`.
- Layout: sections in columns `col-6 col-lg-2` (two columns on mobile/tablet, six columns on large screens); the panel scrolls (`max-height: calc(100vh - var(--header-height)); overflow-y: auto`).
- Section order: Products (first), Services, Media, Company, Resources, Legal.
- Available to guests and authenticated users alike.

## 4. HeaderUserMenu

### Behaviour
- The account dropdown: an avatar trigger (`.header-avatar-trigger`, `aria-controls='headerAccountMenu'`, `aria-expanded`, `aria-label='Account menu for <name>'`) and a panel (`.header-menu-panel.header-account-panel`). Shown only to authenticated users; guests retain the project's sign-in and other existing actions in `Header.js`.
- There is one dropdown for every screen width; never add a second mobile account list.
- Props: `user`, `groups`, `onOpen`. Links are defined in `Header.js` and passed as `groups`; the `AccountLink` helper is internal to `HeaderUserMenu.js` and not exported.
- The menu is structured in three groups separated by dividers (`.header-account-divider`):
  1. Base part, always present and in this order: `Dashboard`, `Profile` (`/profile/`), `Billing`, `Settings`.
  2. Project part: links specific to the current project or subproject (may be empty). It sits between the dividers and must not replace or reorder the base part.
  3. `Log Out`, always last.
- Keep the base part and `Log Out` identical across all projects; only the project part differs.
- Links marked `hostPath` are plain `<a href>`; `Log Out` uses `Link`.

### Paths
Defined in `Header.js` as link objects `{ label, href, icon, hostPath }`. Paths are host-relative with a trailing slash; never prefix them with `Config.BASE_URL` or the project's `basePath`.

| Item | `href` | Element |
|------|--------|---------|
| Dashboard | `/dashboard/` | `<a>` (`hostPath: true`) |
| Profile | `/profile/` | `<a>` (`hostPath: true`) |
| Billing | `/billing/` | `<a>` (`hostPath: true`) |
| Settings | `/settings/` | `<a>` (`hostPath: true`) |
| Log Out | `/signout/` | `Link` (no `hostPath`) |

- Base part paths are identical in every project. Project-part links that point to another project or to the host root also need `hostPath: true`; only links inside the current sub-project may use `Link`.

### Name block
- `.header-account-name` is a media object: reuse the shared `Avatar` component at 40px on the left, full name on the right with the email below in smaller text (`.header-account-fullname`, `.header-account-email`). The shared Avatar's initials fallback is preferred to a second avatar implementation.
- Both lines are truncated with an ellipsis and carry a `title`. Do not show the email twice when it already is the name.
- Fallback name order: `fullname`, `firstname`, `email`, `Account`.

### Panel layout
- `.header-account-panel`: `position: absolute; top: 100%; right: 12px; min-width: 15rem; max-width: calc(100vw - 24px)`.
- No inner padding on the panel (`padding: 0; overflow: hidden`). Items span the full panel width with `padding: 0.75rem 1rem` and no item border radius; the divider has `margin: 0`.
- Below 576px the panel is full screen width and square: `left: 0; right: 0; width: auto; max-width: none`, no side borders, `border-radius: 0`.
