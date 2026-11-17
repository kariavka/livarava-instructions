---
description: "Use when creating, reviewing, or refactoring LivaRava data models, fields, or the JSON:API serialization of them. Defines universal snake_case naming, the snake_case attribute rule for API v2 resources, plus profiles for Neo4j Abstract/Neuron and relational PostgreSQL/MySQL models."
applyTo: "**/livarava/**/*.py"
---
# LivaRava Data Model Field Naming Conventions

This instruction defines a shared naming baseline for LivaRava data-model
fields, followed by storage-specific rules for Neo4j models inheriting
`Abstract` or `Neuron`, and models backed by PostgreSQL or MySQL.

Use the shared baseline for every new model field. Apply a storage-specific
section only when the model uses that storage and those mechanisms.

## Scope

Applies to new and changed model fields in:

- Neo4j models inheriting `Abstract` or `Neuron`;
- relational models and schema fields backed by PostgreSQL or MySQL;
- model fields exposed through APIs or serialization.

These rules govern field names, not every identifier in the codebase. Do not
apply relationship-map rules to models that do not define relationship maps.

## 1) Shared baseline

1. Use `snake_case` for every new model field and relationship key.
2. Use one canonical name per concept; do not add parallel synonyms.
3. Choose names that describe the value's meaning and follow the conventions
   below.
4. Preserve an existing database, framework, or public API name when changing
   it would break compatibility. Map it to a canonical internal name where
   practical, and document the exception.

### 1.1 Identity and references

- Use `id` for a model's primary identifier and `uid` for a public stable ID
  when the model has one.
- Name internal references for the referenced entity, such as `user_id` or
  `calendar_id`. These are not external-system IDs.
- Name genuinely external IDs `<provider>_id` or
  `external_<entity>_id`; do not use these forms for internal relationships.

### 1.2 Dates and timestamps

- Timestamp (date+time): `*_at` (preferred), UTC-compatible value.
  - Examples: `created_at`, `updated_at`, `published_at`, `started_at`.
- Date-only: `*_date`.
  - Examples: `start_date`, `end_date`, `birth_date`.
- Legacy names like `startdate`, `enddate`, `dateofbirth` are deprecated for
  new code.
- Exception, the Neo4j `Abstract` timestamp family. `Abstract` defines the bare
  `created`, `updated` and `modified`, and every subclass serializes them under
  those names. A new timestamp that belongs to that family - one the framework
  maintains about the node itself, such as `synced` for the last write from an
  integration - keeps the bare form, so that one model never serves two
  spellings of the same idea. Every other new timestamp on those models uses
  `*_at`, as `work_start_at`, `generated_at` and `expires_at` already do.

### 1.3 Booleans

- Prefer `is_*`, `has_*`, `can_*` prefixes.
  - Examples: `is_featured`, `has_access`, `can_delete`.
- Avoid introducing new `*_on` flags.
  - Keep existing `*_on` only for backward compatibility.

### 1.4 Counters, aggregates, URLs, and media

- Count fields end with `_count`.
  - Examples: `comment_count`, `subscriber_count`.
- Totals/sums use explicit names like `total_amount`, `sum_amount`.
- URL fields end with `_url`.
  - Examples: `image_url`, `payment_url`, `source_url`.
- MIME/type fields use `_mime`, `_type`.
- Dimensions use `_width`, `_height`, `_size`.

### 1.5 Money

- Pair monetary value with currency:
  - `amount` + `currency`
  - or `<domain>_amount` + `<domain>_currency`.

### 1.6 Enum-like fields

- Field name is a noun: `status`, `type`, `role`.
- Constants use upper snake case with a descriptive prefix:
  `STATUS_CREATED`, `TYPE_EVENT`, `ROLE_ADMIN`.
- Stored values should be lowercase snake-case strings unless external
  constraints require otherwise.

## 2) Neo4j models (`Abstract` / `Neuron`)

Apply this section to models inheriting `Abstract` or `Neuron` and to the
framework structures they define.

- `attributes` keys must match their corresponding class attribute names
  1:1.
- `relationships` keys must match the relationship attribute names 1:1.
- A to-one relationship key is a singular noun (`author`, `project`,
  `invoice`, `site`).
- To-many calculated collections that are not relationship-map fields use
  plural nouns (`members`, `posts`, `subscriptions`).
- For role-specific user relationships, use `<entity>_<role>` where it
  describes the relationship (`project_admin`, `product_member`,
  `site_editor`).
- Each `relationships` map entry uses a JSON:API plural resource `type`, a
  Neo4j relationship constant from `Rels` as `rel`, and an optional `map` for
  derived attribute mapping.
- Keep relationship and filter names consistent: a relationship key `author`
  corresponds to `filter[author]`, not `filter[user_id]` for the same meaning.

Existing framework or API contracts may require a different name. Do not
rename them silently; use the deprecated-field policy below.

## 3) Relational models (PostgreSQL / MySQL)

Apply this section to models and fields persisted in PostgreSQL or MySQL.

- Use `snake_case` for both model fields and SQL column names. Prefer the same
  name for both; use an explicit mapping when an existing schema or external
  contract requires a different column name.
- Use `id` for a primary key when consistent with the surrounding schema.
- Name a foreign-key field after its referenced entity, such as `user_id` or
  `calendar_id`. Do not name an internal foreign key as an external ID.
- Use the shared date, timestamp, boolean, counter, URL, and enum naming
  rules for columns and model fields.
- If an ORM exposes relationship properties in addition to scalar foreign-key
  fields, name to-one properties in the singular and to-many properties in
  the plural. This does not require a model to define ORM relationships.

Do not rename existing columns or public fields solely to match this section.
Use explicit model-to-column or API mappings and a coordinated migration when
a rename is needed.

## 4) JSON:API serialization

Applies to every resource serialized by LivaRava API v2, including the
Bridge resources and the Calendar resources.

Two different casings meet in one document, and they are not
interchangeable:

- **Resource `type` names are kebab-case and plural**: `calendars`,
  `calendar-events`, `calendar-sync-connections`,
  `google-calendar-connections`, `mail-messages`.
- **Attribute member names and relationship names are `snake_case`**, and
  match the model field and its `to_dict()` key 1:1: `start_at`,
  `is_default`, `all_day`, `recurrence_rule`, `connection_id`,
  `external_calendar_id`, `local_calendar`.

`snake_case` attributes are deliberate and permanent. JSON:API only
*recommends* kebab-case member names, and every API v2 resource has always
served `snake_case`, so a client reading two LivaRava endpoints in one
session sees one convention. Do not "fix" this towards the specification's
recommendation, and do not introduce a second spelling of the same member.

- A task brief, ticket or frontend contract that proposes kebab-case
  attributes does **not** override this rule. Serialize `snake_case` and
  align the client instead; say so when handing the work over, so the
  parallel frontend is corrected rather than the backend.
- Never serialize both spellings of one member as aliases. A duplicated
  member is a public contract that cannot be withdrawn later.
- Error `code` members taken from a domain error keep the domain's own
  `snake_case` code (`validation_failed`, `calendar_not_found`,
  `provider_failed`). Codes owned by the shared transport toolkit stay
  kebab-case, because they mean the same thing on every route
  (`invalid-document`, `type-mismatch`, `unknown-query-parameter`,
  `unsupported-media-type`).
- Query parameter names follow the specification's bracket forms with
  `snake_case` inside them where a field is named: `filter[calendar]`,
  `page[number]`, `fields[calendar-events]` - the bracket contents of
  `fields[...]` are a resource *type*, so they stay kebab-case.
- Members that say how LivaRava *reaches* a resource rather than describing
  it belong in the resource object's `meta`, not in `attributes`. The
  provider coordinates of a `calendars` resource are the reference case. When
  the external address is the substance of the resource rather than incidental
  to it - as it is for `calendar-sync-connections` - it belongs in
  `attributes`.

## 5) Deprecated field policy

When replacing a legacy name:

1. Introduce the canonical name.
2. Keep the old name only as a deprecated compatibility adapter.
3. Mark the old field `# deprecated` where applicable.
4. Preserve read compatibility temporarily; write via the canonical field.
5. Remove the old name only in a planned cleanup or schema migration.

Examples of legacy names not to introduce in new fields:

- `dateofbirth` -> `birth_date`
- `placeofbirth` -> `birth_place`
- `startdate` -> `start_date`
- `enddate` -> `end_date`

## 6) Checklist

- [ ] New model fields use `snake_case` and a single canonical name.
- [ ] Timestamps and dates use `_at` and `_date`; booleans use `is_`, `has_`,
      or `can_`.
- [ ] Counters use `_count`; URLs use `_url`; external IDs are clearly
      distinguished from internal references.
- [ ] Applicable storage-specific rules are followed; non-applicable rules
      are not treated as violations.
- [ ] Existing schema, framework, and API contracts are preserved or changed
      through a documented compatibility plan.
- [ ] Serialized attributes and relationship names are `snake_case` while
      resource `type` names are kebab-case; no member is serialized under two
      spellings.
- [ ] Deprecated names are adapters, not canonical write targets.
