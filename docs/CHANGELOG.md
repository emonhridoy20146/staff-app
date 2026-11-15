# Changelog — staff-app

## [0.2.0] — 2026-11-15
### Added
- Phase 2 location tracking (FR-M-011, FR-LOC-*): runs only while on duty (work-in to work-out, breaks included) and at most 3 h after the shift end; visible foreground notification plus a Me-tab status card; adaptive sampling by speed (still / walking / bicycle / vehicle) from `location.sampling` and the server's `nextSampling`; phone-side filters (accuracy, future time, duplicates, over 120 km/h); queue capped at 20,000 points (oldest stationary points dropped first); uploads in batches of 500 every 2 min or at 100 points, rows deleted only after the server confirms; heartbeat every 15 min.
- Switchable tracking provider (ADR-M11): free (geolocator foreground service) now; a paid SDK slot behind the same interface. The admin setting `location.trackingProvider` picks the provider at runtime; if `paid` is chosen but this build does not include it, the app uses free and says so (Me tab and heartbeat).
- Visit suggestion on Today after 5 min within 60 m of a customer pin not visited today ("Record visit" / "Not now").
- Call logging (FR-M-014): after a call the app asks how it went and records a `contact_attempt` offline (phone index only, never the number); shown on the customer timeline.
- Database schema 2: `contact_attempts` table and a `location_queue (t)` index, with a v1 → v2 migration test.
### Changed
- Contract pinned to field-api `openapi.yaml` 1.5.0 (adopted 1.2.0: `geo: null` + `geoUnavailableReason` replaces the 0/0/99999 stop-gap; `contact_attempt` mutation entity; location ingest and heartbeat). 1.5.0: heartbeat declares `trackingProvider` / `trackingProviderFallback`; a push result `rejected` with `retryable: true` now stays queued with backoff instead of going to Problems.
- Location primer text: "While using the app" is enough; the app does not request background location (ADR-M12).
- Today: a hidden extension card no longer leaves an empty gap.
- Demo and test builds use a fake tracker (no real GPS stream).
- Android `compileSdk` 37 (needed by `flutter_local_notifications` and `androidx.core` 1.19; the CI APK build failed on 36). `targetSdk` unchanged.
### Not done / known gaps
- Server location module (ingest, heartbeat) is not built yet in field-api; until then those calls fail quietly and points stay queued on the phone.
- No battery level in the heartbeat: `battery_plus` conflicts with `connectivity_plus` 7.3.2 (dbus version); revisit when either updates.
- Free provider limits: no activity recognition (speed is used), no restart after a phone reboot (tracking resumes when the app is opened while on duty), more exposed to OEM battery savers.
- Note editing (PATCH /notes/{id}, 1.3.0) not built yet.
- Nothing in this release is verified on a real phone yet (see `07-test-plan.md §3`).

## [0.1.0] — 2026-11-15
### Added
- Flutter project (Dart 3.14, Flutter 3.50), Material 3 theme from design tokens with bundled Inter, Noto Sans Bengali and JetBrains Mono; light, dark and high-contrast; Bangla default with English.
- Core: encrypted drift database (sqlite3mc), dio client with auth refresh (single flight) and 426 version gate, Dhaka clock with server offset, money / Bangla digits / amount in words, permission and flag snapshot, feature manifests with extension points.
- Offline sync engine: outbox (UUIDv7 once at save), batches, backoff with jitter, dependsOn, conflict and rejection handling, pull cursor with 410 re-bootstrap, sync centre.
- Features: auth (login, password change, PIN, app lock, lock-out after 5 PINs keeping data), onboarding (consent, permission primer, bootstrap), Today, customers (list, filters, search, detail, plans, schedule, timeline), map, collections (3-step flow, hold to confirm, receipt blocks with offline fallback, receipt image share), cash (meter, deposits), visits with camera photo and media queue, notes, promises with 09:00 local reminder, tags with reason, incoming handovers (online-only decision), attendance, Me and settings, sign-out blocked while anything is unsent.
- Demo mode with a fake field-api and 36 Barishal sample customers.
- Tests: 30 unit and flow tests (formatting, Dhaka dates, collection and attendance rules, router gates, offline sync including replay, conflict, rejection, 410, 426, photo de-duplication, sign-out guard) and 12 screen screenshots.
### Contract gaps found (reported to field-api, contract not changed)
- `SyncChange.data` has no per-entity schema; the app assumes the resource schemas (customer → CustomerDetail, etc.).
- `GeoFix` is required on collection / visit / attendance but there is no way to say "no fix"; without a fix the app sends lat 0, lng 0, accuracyM 99999 plus the `no_location` flag as a stop-gap; the contract should allow `geo: null`.
- `CustomerListItem` lacks `installmentPoisha`, `overduePoisha`, `areaName` used by Today and the list.
- No `contact_attempt` mutation entity for FR-M-014 (call logging).

## [0.0.0] — 2026-11-15
### Added
- Initial specification: role analysis, requirements subset + app-only FR-M-001…023, Material 3 design guide with shared design tokens v1.0, architecture (features, manifest, extension points, offline sync engine, folder tree), local SQLite data model, test plan with manual device checklist, ADR-M01…M08, roadmap.
- Contract baseline: field-api `openapi.yaml` 1.0.0-spec.
