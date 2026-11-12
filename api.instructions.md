---
name: LivaRava API Rules
description: "Use when creating, refactoring, or aligning API clients in LivaRava frontend projects, including endpoint registries, request/response handling, authentication, API call sites, and redux-bees migrations."
applyTo: "**/lib/Api.js, **/package.json, **/yarn.lock, **/package-lock.json, **/pnpm-lock.yaml"
---
# API Guidelines

This file covers the **frontend API client** only - `lib/Api.js` in the
`livarava-*` Next.js projects - as its `applyTo` says. It does not govern the
server side.

The backend JSON:API contract served by the `livarava` monolith under
`/api/v2/` lives elsewhere: resource type, attribute and error-code casing is
in `conventions.instructions.md` (section 4), and the per-surface contracts
are checked into the repository next to the code they describe
(`livarava/apis/api_v2/BRIDGE.md`, `livarava/apis/api_v2/CALENDAR.md`).

When a client here disagrees with the server contract, the server contract
wins and the client is corrected.

## API client and `redux-bees`

- `redux-bees` is legacy and is being removed from all LivaRava projects. Never add it to a new project or use it for new endpoints. When touching an API client that still depends on it, prefer migrating that client and its callers to the project's native `fetch`-based API layer.
- Keep API endpoint definitions centralized in `lib/Api.js`. Use named endpoint methods with explicit HTTP methods and paths; encode path parameters and serialize query parameters safely.
- Order endpoint groups in `lib/Api.js` with `Api` first, followed by `Autocomplete`. Sort all remaining groups alphabetically between them, and keep `Uploads` as the final group.
- Keep the `lib/Api.js` implementation structure aligned across `livarava-www`, `livarava-business`, and `livarava-mail`: imports and constants; the endpoint registry; `ApiError`; response, URL, and header helpers; response parsing; the shared request function; GET-read deduplication; the endpoint method factory; the generated `Api` object; optional project-specific API methods; and the default export.
- Store every endpoint as `{ method, path }`. Generated methods take one request object: `{ params, body, signal, cache }`. Put path and query values in `params`, write payloads in `body`, and pass an optional `AbortSignal` as `signal`. Do not keep redux-bees positional signatures or add project-specific argument adapters.
- Keep the shared request, response, validation, and method-generation logic structurally consistent across the three clients. Preserve product-specific endpoints and behavior through the endpoint registry, authentication in `buildHeaders`, and clearly separated project-specific methods after the generated API object.
- Return `{ status, headers, body }` consistently; represent an empty 204 response with `body: null` and reject failures with `ApiError` carrying the status, headers, body, and parse cause where applicable.
- Coalesce only identical, uncancelled `GET` reads, and clear the pending entry after either success or failure. Never deduplicate mutations or reads with a caller-provided `signal`.
- Do not copy an API client mechanically between projects. Preserve each project's API contract, including its API base URL, site identifier, authentication source/header, content type, endpoint paths, and response format.
- Resolve authentication at request time. Preserve the correct anonymous/API-key behavior where required; never expose credentials in URLs or logs.
- Serialize JSON request bodies explicitly. Handle `FormData`, binary responses, and other non-JSON bodies with the appropriate content type and response parser rather than stringifying them as JSON.
- Return a consistent response shape and surface HTTP, network, and parse errors explicitly. Handle empty successful responses (such as HTTP 204), non-JSON error bodies, and cancellation without converting failures into success-shaped values or swallowing errors.
- Encode dynamic path segments, use safe query serialization, and support `AbortSignal` where callers need cancellation. Do not deduplicate mutation requests. Deduplicate only safe, identical reads when there is a demonstrated need.
- Validate required endpoint parameters before making requests. Do not return promises that remain pending forever for missing parameters; guard the call at the caller or reject it with a useful error.
- Keep Redux optional. API methods should be ordinary promise-returning functions; use the existing Redux Toolkit patterns only where application state needs to be shared. Do not introduce generated `redux-bees` actions or reducers.

## Migration guidance

- When refactoring a `redux-bees` `Api.js`, use the shared structure in the current `livarava-www/lib/Api.js`, `livarava-business/lib/Api.js`, and `livarava-mail/lib/Api.js` as the implementation standard; align the structure and request contract rather than copying one project's endpoints or authentication.
- Start by mapping every endpoint's name, HTTP method, path, required path parameters, query parameters, request/response format, and auth requirements. Search all callers and generated action/reducer usage before changing the API.
- Replace `buildApi` with named promise-returning methods backed by the shared `{ method, path }` endpoint registry and request helper. Keep endpoint paths and methods explicit; resolve and encode required path parameters from `params`, and serialize remaining values as query parameters.
- Update every caller and test to the shared request-object contract (`{ params, body, signal, cache }`); remove redux-bees callbacks and generated actions/reducers that are no longer needed, while retaining Redux only for application state that must be shared.
- Keep authentication and serialization project-specific. Select headers and tokens at request time, serialize JSON only for JSON bodies, and handle binary or multipart requests through the appropriate request path.
- Migrate incrementally: inventory `redux-bees` imports and generated API usage, replace the client, adapt affected callers to its explicit argument and error contract, then remove the dependency only after no imports remain.
- Preserve the product's API contract, but do not retain redux-bees compatibility quirks such as positional arguments or never-settling missing-parameter requests. Update callers and tests together.
- For binary downloads, keep a dedicated fetch path when needed: validate inputs, encode path segments, send the correct authentication/site headers, parse error responses, and return the binary body (for example, a `Blob`).
- Validate migrations with focused tests for URL/path/query construction, auth headers, JSON and binary bodies, success and error statuses, 204 responses, malformed response bodies, and cancellation where supported. Run lint, tests, and build; verify there are no remaining `redux-bees` imports before uninstalling it and updating the project's lockfile.

## Project-specific behavior

- Keep each product's endpoint set, API URL, site identifier, auth source/header, and domain-specific response handling intact while matching the shared `lib/Api.js` structure.
- Keep multipart upload and attachment conversion helpers below the generated `Api` object. Use `FormData` without manually setting its `Content-Type`, and preserve the caller-facing response contract.
- Keep the three clients native `fetch` implementations. Do not reintroduce `redux-bees` to preserve old call signatures or to make one project's behavior resemble another's.
