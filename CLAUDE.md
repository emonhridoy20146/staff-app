# CLAUDE.md — staff-app

Rules for AI coding agents. Read fully before changing anything.

## 1. What this repo is
The field staff app of the Howlader Field Operations System. Flutter (Dart 3), Android APK first, **offline-first**. Talks only to field-api `/api/v1` (+ FCM, map tiles, presigned storage URLs).

Read first: `docs/01-system-analysis.md`, `docs/02-requirements.md`, `docs/03-design-guide.md`, `docs/04-architecture.md` (§5 sync engine), `docs/06-data-model.md`, then field-api `docs/02-requirements.md` (master catalog) and `docs/openapi.yaml`.

## 2. Hard boundaries
1. **Offline-first:** UI reads from the local DB and writes through use cases into the local DB + outbox. Widgets and controllers never call dio/the API directly (lint-enforced). Only documented online-only actions are exceptions (ADR-M08).
2. **Idempotency:** a mutation's UUIDv7 is generated once at save time and never regenerated on retry, edit or app restart.
3. **Never delete unsynced data** (outbox `pending/failed`, collections, media queue) — not on logout, error, migration or "cleanup". Failed money items stay visible in Problems.
4. **Money:** poisha integers; format only via `core/format`; show "pending in ERP" until posted; never present field-calculated balance as official.
5. **Camera only** for photos — never add a gallery/file picker.
6. **Location:** only while on duty (duty_guard); always visible to the user (notification + chip); never collect location in background when off duty, for any feature.
7. **Features:** `lib/features/<name>/`; import another feature only through its public barrel; prefer extension points (customer actions, Today cards). `lib/app/features.dart` is the only feature list.
8. **Permissions & flags:** check keys from the server snapshot via `Can`/`PermissionService`; keys must exist in the master catalog (`tool/check_permissions.dart`). Hidden ≠ secure; handle 403.
9. **Contract:** generated client from the pinned field-api `openapi.yaml`; never hand-edit `packages/field_api_client`. Missing endpoint → it must be added to field-api first.
10. **Design tokens:** use `core/theme` tokens and `StatusColors`; no raw colours or ad-hoc sizes; targets ≥ 48 dp; body ≥ 16 sp. Token changes must match `admin-web/docs/03-design-guide.md §2`.
11. **Strings:** all user-visible text in `app_bn.arb` + `app_en.arb` (`tool/check_l10n.dart`); Bangla default.
12. **Time:** use `core/time/clock.dart` (server-offset aware, Dhaka); no `DateTime.now()` in domain/application code.
13. **Secrets:** none in the repo; `--dart-define-from-file` with `.env` files that are git-ignored; `.env.example` names only; signing keys only in CI secrets. The one committed config, `config/live.env`, holds public values only (URL, env, mode; ADR-M16) and `test/core/live_config_test.dart` guards it.
14. Microfinance: reserved — do not build.

## 3. Workflow for every change
1. Find/add FR-ID (master for shared behaviour; FR-M for app-only).
2. Domain rule → unit tests first; then data (DAO, repository, sync handler) → application (use case) → presentation.
3. DB change: bump drift `schemaVersion`, add migration step, dump schema, add migration test from every released version.
4. Tests: unit, widget/golden (bn/en, light/dark, font scale 1.3), integration journey if a flow changed.
5. **Update docs with every change:** `docs/CHANGELOG.md` always; `docs/09-progress.md`; `docs/08-decisions.md` if a decision was made; design guide if a component/pattern changed; data model if tables changed.
6. Run `make check` (`flutter analyze`, custom lints, `flutter test`, l10n and permission checks) before finishing; `make e2e` for flow changes.

## 4. Feature-add checklist
- [ ] `make new-feature name=<name>` (template), folder = manifest `name`.
- [ ] Manifest: flag key, permissions, routes, nav entries, sync handlers (pull entity + push mutation types), migrations, extension points.
- [ ] Register in `lib/app/features.dart`.
- [ ] Local tables in `docs/06-data-model.md`; drift migration + schema test.
- [ ] Mutation types exist in field-api `SyncMutation.entity` enum (contract first).
- [ ] Offline behaviour defined: what works offline, what needs network and how it is shown.
- [ ] l10n bn/en; tokens only; 48 dp targets; TalkBack labels.
- [ ] Tests: unit, widget/golden, Patrol journey; manual checklist lines added to `docs/07-test-plan.md §3` if device-specific.
- [ ] Docs updated; no other feature's `src/` edited.

## 5. Testing rules
- No real network in unit/widget tests; integration tests against staging + mock-erp only.
- Freeze clock for date logic; test Dhaka midnight boundary.
- Never skip or weaken a test to pass CI.
