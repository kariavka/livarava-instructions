---
name: LivaRava Assistant Rules
description: "Use when creating, reviewing, or changing an Assistant or chat interface, chat persistence, message rendering, or AI workflow in any LivaRava client. Keeps Assistant naming, layout, visual components, history ownership, and privacy behavior consistent across products."
applyTo: "**/components/**/*Assistant*.{js,jsx,ts,tsx}, **/components/**/*Chat*.{js,jsx,ts,tsx}, **/components/chat/**/*.{js,jsx,ts,tsx}, **/styles/**/*.{css,scss}, **/livarava/ai/chat/**/*.py"
---
# LivaRava Assistant

Use these rules for every user-facing LivaRava assistant and chat experience.
Treat `livarava-mail/components/assistant/Assistant.js` together with
`livarava-mail/styles/assistant.scss` as the visual reference for the panel
shell, spacing, surfaces, context line, introductory state, conversation area,
and composer. Treat the shared `components/chat` message components as the
reference for message rendering and interaction behavior. Copy or reuse this
shared component bundle instead of independently restyling chat behavior.

## Shared component architecture

- Split every integration into a reusable presentation component and a thin
  product controller. The reusable Assistant owns the dialog, header, context
  badges, introduction, message list, message actions, loading state, composer,
  keyboard interaction, and Toast placement.
- The product controller owns authentication identifiers, domain scope, API
  calls, chat restoration and creation, request cancellation, response mapping,
  and product-specific introductory copy. For Mail this controller is
  `components/mail/MailAssistant.js`.
- A shared presentation component must not import product API modules, Redux
  slices, mail/lead/domain models, or product styles. Pass all domain data and
  behavior through props and callbacks.
- Use a small portable contract. Context items have `{ id, text, title?,
  truncate? }`; messages have `{ role, content }`; product controllers provide
  lifecycle flags and `onOpenChange`, `onStart`, `onSend`, `onRetry`, and error
  callbacks.
- Keep shared files together under `components/assistant`, shared message
  renderers under `components/chat`, and all durable Assistant presentation in
  `styles/assistant.scss`. Import that stylesheet once from the application
  entry point. Do not put reusable Assistant styles in `mail.scss`,
  `business.scss`, or page-local styles.
- Treat `Assistant.js`, its shared Toast, `ChatMessageItem`, `ChatMessageBody`,
  and `assistant.scss` as one versioned copy unit when moving the experience to
  another LivaRava project. Preserve the public prop contract and class names so
  fixes can be copied between projects without a redesign.
- Keep product-specific variations declarative through props. Add a narrowly
  namespaced product override only when a real product requirement cannot be
  represented by the shared contract; do not fork the shared component for
  cosmetic differences.
- The portable implementation assumes React, Bootstrap, Next Image, and the
  shared Font Awesome setup. If a target project lacks one of these dependencies,
  adapt it behind the same component contract rather than leaking product logic
  into the presentation layer.

## Naming

- Use **Assistant** for the global entry point and panel title.
- Use a product-specific name such as **Mail Assistant** only on an introductory
  screen where the product context helps explain the feature.
- Do not use **AI Chat**, **AI Assistant**, **You**, or **Assistant** as redundant
  visible labels above individual message bubbles. Message alignment and styling
  already communicate the speaker.
- Accessible labels may still describe the control or speaker where needed by a
  screen reader.

## Global entry point and panel

- Present Assistant as a global floating action button at the bottom-right of
  the client, independent of the current page, view, folder, or empty state.
- Keep the entry point available while the client is usable. When the panel is
  open, its own close control replaces the need for a second overlapping button.
- Open Assistant as a right-side panel that occupies the full viewport height.
- On desktop the panel must occupy at least one third of the viewport width and
  must not be narrower than 520 px. Cap it at the viewport width.
- On narrow screens use the full available width.
- Close the panel with its close button, the Escape key, or a click on the
  backdrop outside the panel.
- Preserve the underlying client state when opening and closing Assistant.

## Before a chat starts

- Follow the introductory pattern used by LivaRava Mail.
- Show the Assistant image, product-specific title, a short explanation, a
  compact **What you can do** list, and a primary **Start Chat** button.
- Explain what context the Assistant has and what the user must provide.
- Do not render the message composer until the chat has been started or an
  existing chat has been restored.
- Hide the introductory content as soon as an existing or newly created chat is
  active.

## Chat window visual contract

- Match the LivaRava Mail shell: a borderless right-edge dialog with no outer
  margin or padding, `100dvh` height, a single restrained shadow, and a
  translucent black backdrop around `rgba(0, 0, 0, 0.35)`.
- Build the panel as one full-height flex column with three stable regions:
  a non-scrolling header, one independently scrolling conversation area, and a
  non-scrolling composer at the bottom.
- Keep the header compact and separated by a bottom border. Place the Assistant
  wand icon and `Assistant` title on the left and the standard icon-only close
  button on the right. Use the Mail proportions: normal `p-3` header spacing and
  an `h5`-sized title without extra bottom margin.
- When the active chat scope benefits from visible context, show compact badges
  below the panel title and separate them from the title with a subtle line that
  spans the complete panel width. Keep the badges aligned to the header's inner
  content padding. Give the badge area identical top and bottom padding and do
  not use vertical margins that make this spacing asymmetrical. Use balanced
  spacing of about `0.5rem` around that divider so
  the title and context remain related without appearing crowded. In Mail, show
  only the selected mailbox name
  and selected message subject, without labels, sender details, separators, or
  empty-state text. Update the badges immediately when either selection changes,
  never truncate the mailbox name, truncate only a message subject that is too
  long to fit, and omit a badge when its context is absent. Use a
  restrained outline treatment with transparent background and neutral border
  and text colors; context badges must not compete with primary actions. Keep a
  small amount of breathing room below the title/context group before the
  header divider.
- In Business, show the context as **Business → selected project → active section →
  selected object**, in that order. Business is the product root and is always
  present; append the project name when selected, then the active section
  (for example **Leads**), then the name of the current lead, product, invoice,
  property, advertisement, or other selected object. A section is a context
  level even when no individual object is selected. Do not display the word
  **Scope** or a **Scope:** prefix in the interface.
  Accumulate the active hierarchy, not a history of visited records. Leaving
  an object removes that level while retaining the product and selected
  project. Ignore stale Redux records whose IDs do not match the active route.
  Keep the global entry point available without a selected project, allow a
  general conversation, and keep the panel open across page navigation while
  updating its context. Displaying a record in the context hierarchy does not grant the model
  access: send only resource types supported by the server's context contract.
- Visual context is not model context. Do not automatically add the displayed
  mailbox or message data to Chat requests unless that exact payload has been
  separately disclosed and approved.
- Do not wrap the complete chat in another card or add stacked decorative
  borders, rounded panel corners, or ornamental header treatments.
- Keep one visible divider below the complete header area, including its context
  badges, so the title and context remain clearly separated from chat content.
- Use the Mail surface hierarchy: the header and composer use the normal body
  surface, while the independently scrolling conversation uses Bootstrap's
  light neutral surface with compact `p-2` padding and a small consistent gap.
  Render Assistant response text directly on that surface. Use a restrained
  light-gray user bubble (`#dddddd`) with small padding and rounded corners.
- Limit a message content block to approximately 92% of the available chat
  width so alignment remains visible and long content stays readable.
- Keep conversation spacing compact and consistent with the Business reference:
  small message margins, `0.875rem` message text, and `1.45` line height.
- Keep the composer on the normal solid surface with a single top border and
  `p-3` spacing. Follow the Mail control layout: a full-width textarea above a
  full-width primary Send button with a small gap. Start the textarea at about
  three rows; it may grow within a reasonable limit, after which it should
  scroll internally. Include the send icon when the product already uses the
  shared Font Awesome icon set.
- The conversation area must own vertical scrolling. Opening the panel,
  restoring history, or receiving a response should reveal the latest message
  without scrolling the underlying page.
- The introductory state should be centered inside the scrolling middle region
  and use the same panel shell as the active chat so the window does not jump
  when chat starts. Use the Mail proportions: an 80 px Assistant image, an
  `h6`-sized product title, short muted copy with a readable maximum width around
  28rem, a light bordered capabilities block, and a compact primary Start Chat
  button. Keep the capabilities heading subtle, uppercase, about 10 px, with
  modest letter spacing.
- Place Toasts above the panel content, centered at the top of the viewport, and
  ensure the dialog does not clip them.
- Keep durable presentation in the owning stylesheet and use shared
  `.chat-*` / `.assistant-*` classes. Avoid duplicating these rules as inline
  styles across products.
- Preserve the desktop width contract: at least one third of the viewport and
  at least 520 px, capped at the viewport width. At mobile breakpoints, use the
  full viewport width and retain access to the close button and composer.

## Active chat presentation

- Reuse `ChatMessageItem` and `ChatMessageBody` behavior from LivaRava Business.
- Align user messages to the right and Assistant responses to the left.
- Do not add speaker headings to message bubbles.
- Render Assistant responses directly on the chat surface. Do not add a separate
  background, border, rounded bubble, or container padding around Assistant
  response text. A contrasting bubble may remain for user messages.
- Use a compact `0.875rem` font size with approximately `1.45` line height for
  message content in every Assistant. Keep the composer, buttons, panel title,
  and introductory screen at their normal component sizes unless a product has
  a specific accessibility requirement.
- Render Assistant message content as Markdown with a maintained parser and
  safe defaults: bold and italic emphasis, paragraphs, lists, links, quotes,
  responsive tables, and fenced code blocks. Preserve line breaks so labels
  such as **Priority:**, **Action:**, **Reason:**, and **Next:** remain readable.
- Use Markdown within response content when it improves readability, including
  bold emphasis for key recommendations and labels. If the API requires JSON,
  keep the envelope valid and put Markdown only inside the content string.
- Keep user messages literal. Copy the original message content, preserving its
  Markdown source. Do not execute raw HTML or allow unsafe link protocols.
- Use `livarava-mail/components/chat/ChatMessageBody.js` as the Markdown
  rendering reference and preserve the shared responsive table presentation.
- Provide the shared copy, retry, like, and dislike controls where applicable.
- Keep message actions visually quiet and reveal them on hover, while ensuring
  the latest applicable actions remain discoverable.
- Use the shared Assistant ready/loading image and animation.
- Keep the composer fixed below the scrollable history and support
  Ctrl/Cmd+Enter to send.
- Display failures through the project's standard error Toast, visually distinct
  from informational Toasts. Keep actionable errors visible until dismissed.

## Chat ownership and continuity

- A chat ID must have a server-side owner and scope. React state, Redux,
  `sessionStorage`, and `localStorage` are caches, never the source of truth.
- Restore an existing chat and its messages before showing the introductory
  screen or creating a new chat.
- Use an idempotent server-side get-or-create operation when available. Prevent
  double-clicks and concurrent requests from creating duplicate chats.
- Prefer a durable relationship from the domain resource to Chat, as Business
  uses `Lead.relationships.chat`. If the scoped resource lives outside Neo4j,
  use a dedicated server-side binding table or endpoint.
- For Mail, scope history to the authenticated user and selected connected
  mailbox. Switching mailboxes must switch to that mailbox's chat and history.
- An internal mail-account ID may be used as a temporary scope key because it
  does not disclose the mailbox address. It survives reloads while the same
  connection exists, but does not survive disconnect/reconnect. For durable
  continuity, resolve a stable mailbox binding on the server.
- Do not identify a mailbox chat by title matching alone.
- Keep one active chat per scope unless the product explicitly supports a chat
  list or **New Chat** action. Archive older chats rather than silently replacing
  their binding.
- Load history from the Chat API when the active scope changes. Cancel stale
  requests so a previous scope cannot overwrite the current one.

## Workflow and API contract

- Give each product Assistant a stable workflow identifier and keep its system
  instructions on the server when possible, following `lead_assistant` in
  LivaRava Business. The workflows that already exist are listed below; reuse
  one before defining another.
- Chat creation must include the authenticated author relationship.
- APIs that return a model response as structured data must explicitly require
  the exact JSON envelope expected by the server, including non-empty `role` and
  `content` fields where that is the current Chat contract.
- Updating Assistant instructions must not create a new chat or discard history.
- Creating the chat and binding it to its owner should be atomic. If the current
  API requires two requests, handle partial failure and clean up or recover the
  unbound chat.
- Restrict chat lookup and item access to the authenticated owner on the server;
  a client-supplied author filter is not an authorization boundary.

## Existing workflows

The workflow catalogue lives in `livarava/ai/chat/workflow.py`, as the
`Workflow` class: a constant per workflow, `Workflow.ALL` listing them and
`Workflow.INSTRUCTIONS` mapping each one to its system instructions. A chat
stores the identifier in its own `workflow` attribute, and
`Chat.prepare_context_messages` prepends those instructions as the first
`system` message, before the chat's own `instructions` attribute and before any
lead or action context. Read that file before adding a workflow, and reuse an
existing one rather than defining a second identifier for the same job.

| Identifier | Purpose | Used by |
|------------|---------|---------|
| `guest_post_chat` | Guides a user through publishing an article step by step, collecting title, image URL and content, then returning the SEO-optimized HTML and a draft status for confirmation | not called |
| `guest_post_process` | Processes submitted guest post data in one pass: title, summary, description, featured image, site, tags, with every supplied link and extra image placed in the content | not called |
| `guest_post_summary` | Writes the 140-160 character plain-text summary of a post | `livarava-www`, the guest post form |
| `guest_post_site` | Picks the most relevant site for a post from a supplied list, or `Uncategorized` | `livarava-www`, the guest post form |
| `guest_post_categories` | Picks one to three categories strictly from a supplied list, or `Uncategorized` | `livarava-www`, the guest post form |
| `guest_post_tags` | Produces three to eight Title Case tags for a post, or `General` | `livarava-www`, the guest post form |
| `lead_assistant` | Acts as a senior sales manager on a lead: discovery, qualification, objections and the next funnel step | `livarava-business`, the project and lead Assistant |
| `mail_assistant` | Acts as an email communication assistant: understands a message's intent, summarizes a thread, drafts a reply, never claims a mailbox action it did not perform | `livarava-mail`; the panel also sends its own `instructions` |
| `page_assistant` | Acts as a senior frontend developer for LivaRava Sites: creates and improves page markup, Bootstrap-first, CMS-ready | `livarava-sites` |

- Every one of these workflows requires a JSON envelope with a non-empty
  `role` and `content`; the guest post ones additionally carry their fields in
  `data`. Keep a new workflow's envelope consistent with them.
- `guest_post_chat` and `guest_post_process` have no caller. Treat them as
  available rather than as dead code, but verify their instructions before
  wiring either one up: `guest_post_chat` spells the envelope key `"data:"`
  with a trailing colon, so a model following it literally returns a member no
  client reads.
- An identifier outside `Workflow.INSTRUCTIONS` is accepted and simply adds no
  system message, which makes `workflow` usable as a scope key. LivaRava Mail
  relies on this: `mailChatWorkflow(accountId)` builds
  `mail_assistant_account_<id>` per mailbox, so `filter[workflow]` finds that
  account's chat, while the instructions travel in the chat's own
  `instructions` attribute. Choose deliberately between the two mechanisms -
  server-side instructions for a workflow shared across users, a scoped
  identifier plus client instructions for a per-account or per-object chat -
  and do not invent a third.
- `livarava/console.py` asks for `Workflow.GUEST_POSTING`, which the class does
  not define. Do not copy that name; it raises `AttributeError`.
- `Workflow.REQUIRED_CONTEXT` declares the resource context roles a workflow
  cannot work without. It is empty today, so every workflow accepts a message
  with no context; add an entry only together with the client that sends it.

## Request resource context

A user message may carry the resources the user is working with, as JSON:API
resource identifiers. The contract is `livarava/apis/api_v2/CHAT.md`, and the
backend side of it is the `Context` class in `livarava/ai/chat/context.py`,
which a route builds with `Context.build(value, user, workflow)` and hands to
`Chat.get_response`. The rules that bind a client:

- Send `context` as an array of `{ type, id, role }`, where `type` is the
  JSON:API resource type and `id` is the id that resource's own endpoint
  serves. Never send an internal neuron or node id; the server resolves the
  Neuronet representation itself.
- `role` is `scope` (the mailbox, project or site being worked in),
  `selection` (what is selected right now) or `related`. Keep the array in the
  order that reflects the user's emphasis; the server preserves it.
- The context is **not stored**. Send it on `chat_add_message` and again on
  `chat_get_response`, and resend it on a retry. Historical messages have no
  context, so a reply cannot be re-derived from the chat alone, and changing
  the current selection cannot rewrite what an earlier message meant.
- Where a provider id is unique only inside another resource, send the scope
  too: a `mail-messages` item needs its mail account, as `meta.account` or as a
  `mail-accounts` item of the same context.
- A mail message named as context is read **by the server**. The client sends
  `{ type: "mail-messages", id: "<uid>", role: "selection", meta: { account,
  folder } }` and nothing else; the response route fetches the message and
  gives the model its allowlisted fields. Never put a subject, a body or a
  header into `content` on the user's behalf - the context is the channel for
  message data, and the composer is for the user's own words.
- A mailbox named as context still contributes no fields. Its address stays out
  of the model payload; `direction` on the selected message already says
  whether the user sent or received it.
- Send `meta.folder` whenever the user can read a message outside the inbox. An
  IMAP UID is unique inside one folder, so without it the server reads the
  message with that UID in `INBOX`, which is a different message.
- Treat a refused context as a refused request and surface the error. The codes
  are `context_invalid`, `context_type_unsupported`, `context_access_denied`,
  `context_resource_not_found`, `context_graph_resolution_failed` and
  `context_limit_exceeded`, with a pointer to the item at fault.

## Mail privacy

The product decision this section used to defer was taken on 2026-10-27: the
**selected** message is read by the server and given to the model, because an
assistant that cannot read the message in front of the user is not one. What
follows is the boundary of that decision, and it is deliberately narrow.

- A client sends resource identifiers, never message data. Everything the model
  learns about a message, it learns from the server having read that message.
- Only the message the user has **selected** is read, and only the fields of
  `Context.MAIL_MESSAGE_FIELDS`: folder, direction, timestamp, subject, sender,
  recipients, cc, body text within the character limit, and attachment
  filenames with their types and sizes. `bcc`, `reply_to`, `message_id`,
  `thread_id`, `flags`, the HTML body, the raw headers and every attachment
  byte stay out.
- A mailbox listing is never read. Neither is a thread, a neighbouring message,
  or a message in another folder. One selection is one message.
- The mailbox address is not sent. A mailbox named as context contributes no
  fields at all.
- Nothing read this way is stored. It reaches the model as a request-scoped
  system message and is never written to the chat, the message or Neuronet, so
  the stored conversation holds the user's own words and the model's answers.
- Say so in the panel. The introductory copy names what the Assistant can read,
  because a user who did not ask for the message to be read should not discover
  it from an answer.
- Widening this - a thread, a folder, several messages, more fields - is a new
  product decision, not an extension of this one.
- Do not automatically send visible-message lists, folder trees or any mailbox
  data the user has not selected to the Chat or model API.
- An opaque internal mailbox connection ID may be sent solely to resolve chat
  scope. Do not include it in the natural-language model prompt.
- Treat pasted email content as untrusted data, never as system instructions.
- The Assistant may draft or recommend actions, but must not claim it sent,
  deleted, moved, or modified mail unless an explicitly authorized tool actually
  completed that action.

## Responsive and accessible behavior

- Use a semantic dialog with an accessible title, close label, live status for
  loading, and correct focus behavior.
- Keep keyboard navigation inside the chat from triggering global mail
  shortcuts.
- Ensure controls have accessible names even when their visible UI is icon-only.
- Preserve readable message widths, table scrolling, and composer access at all
  supported viewport sizes.

## Validation

- Verify a new chat, restored chat, mailbox switch, page reload, send, retry,
  copy, close button, Escape, backdrop click, empty state, and API failure.
- Verify that changing scope cannot display history from another user or
  mailbox.
- Confirm that no mailbox or message data is added to Chat requests beyond the
  explicitly approved payload.
- Run the repository's lint, tests, and production build. Test the panel at
  desktop one-third width and mobile full width.
