# 08 — Decisions (staff-app)

System-wide ADRs and open decisions: `field-api/docs/08-decisions.md` (notably ADR-007 sync protocol, ADR-009 background location, ADR-012 receipt numbers, ADR-014 tiles).

### ADR-M01 Flutter, Android first · fixed
- **Reason:** fixed decision; one codebase keeps iOS possible; good performance on low-end Android with Skia/Impeller.
- **Alternatives rejected:** native Kotlin (best background control but slower to build UI, no iOS path); React Native (weaker offline DB/background story for this case).

### ADR-M02 drift (SQLite) + SQLCipher for the local database · accepted
- **Reason:** relational queries (filters, joins, FTS5 search), reactive streams, typed migrations with schema tests, encryption.
- **Alternatives rejected:** Isar (maintenance uncertainty), Hive (no queries/joins, weak for 2,000+ rows with filters), ObjectBox (good speed, less SQL flexibility, licence considerations for sync), sqflite raw (no type safety).

### ADR-M03 Riverpod 2 + go_router · accepted
- **Reason:** compile-safe DI and state, testable without widgets, good with streams from drift; go_router for deep links from notifications.
- **Alternatives rejected:** Bloc (more boilerplate; fine but heavier for AI-generated code consistency), GetX (global magic, hard to test), Provider (superseded by Riverpod).

### ADR-M04 API client: generated Dart client from openapi.yaml · accepted
- **Reason:** contract owned by field-api; generation avoids drift.
- **Alternative kept:** hand-written freezed models validated by fixture tests if generator output is poor for some schemas (`oneOf`/nullable). Decision per schema documented in `packages/field_api_client/README.md`.

### ADR-M05 flutter_map for OSM tiles · accepted
- **Reason:** Leaflet-like API, TileProvider-agnostic, tile caching plugin, no Google dependency.
- **Alternatives rejected:** google_maps_flutter (only if OD-19 proves necessary), maplibre_gl (vector tiles, heavier native dependency — reconsider with PMTiles vector in P4).

### ADR-M06 Local notifications for promise reminders · accepted
- **Reason:** must work offline at 09:00 on the promised date; FCM only as backup.

### ADR-M07 Hold-to-confirm for money submission · accepted
- **Reason:** prevents accidental double taps and pocket taps; gives a deliberate moment while the customer watches.
- **Alternative rejected:** confirmation dialog (users tap through dialogs automatically).

### ADR-M08 UI never calls the network directly · accepted
- **Reason:** offline-first guarantee; all writes go through local DB + outbox; reads from DB streams.
- **Exception:** explicitly online-only actions (handover decision, on-demand balance refresh, password change) via use cases that show "internet required".

### Amendments made during the build (2026-11-15)
- **ADR-M02 amended:** encryption uses SQLite3MultipleCiphers (`sqlite3` package build hook `source: sqlite3mc`, `PRAGMA key`) instead of the separate SQLCipher plugin. Same at-rest protection; one native library; key = random 256-bit, stored in Android Keystore (`flutter_secure_storage`).
- **ADR-M03 amended:** Riverpod 3 (current stable) without code generation; `StateProvider` from `legacy.dart` only for simple UI state. go_router 18 with a stage-driven redirect (`lib/app/router.dart` `redirectFor`, unit-tested).
- **ADR-M04 interim:** until field-api publishes a stable generated Dart client, models are hand-written in `lib/core/api/api_models.dart` (only the fields the app reads) and every call goes through `FieldApi`. Replace with the generated package when available; do not mix.
- **ADR-M09 Dhaka time as fixed UTC+6:** Bangladesh has no DST; `core/time/clock.dart` uses a fixed offset instead of the tz database for business dates (the tz database is used only for scheduling local notifications).
- **ADR-M10 Demo mode:** `APP_ENV=demo` (the default build) runs entirely in memory against `FakeFieldApi` (a dio adapter implementing the contract routes the app uses) with 36 Barishal sample customers. Prod builds refuse demo mode at start-up. Used for UI review before field-api is deployed and for tests.
- **Location plugin:** decided 2026-11-15 (OD-M06): free now, paid possible later via admin setting. See ADR-M11.
- **ADR-M11 Switchable tracking provider · accepted (2026-11-15):** tracking goes through `TrackingProvider` (`lib/core/location/tracking/`). `FreeTrackingProvider` (geolocator with an Android foreground service) ships now; `PaidTrackingProvider` is a stub reporting `isAvailable = false`. The server setting `location.trackingProvider` (`free` | `paid`) is read at runtime and the tracker switches without an app update **if the installed APK contains the paid SDK**. A paid SDK cannot be downloaded at runtime: enabling it needs (1) buying the licence for app id `bd.howlader.staff_app`, (2) adding the plugin and implementing `PaidTrackingProvider`, (3) the licence key as a CI secret (`LOCATION_LICENSE_KEY`, never in the repo), (4) shipping that APK. After that the admin setting switches freely. Until then `paid` falls back to free, shown on the Me tab and in the heartbeat.
- **Attendance photo · decided by owner (2026-11-16):** a front-camera photo is required at work-in, break start, break end and work-out by default; which events need it is the server setting `attendance.selfieEvents`. Amends field-api OD-12 (optional at work-in, off by default). Implemented with a `held` outbox state so attendance works offline and stays in order.
- **ADR-M12 No background location permission · accepted (2026-11-15):** tracking is a visible foreground service started while the app is open (work-in), so `ACCESS_BACKGROUND_LOCATION` is not requested ("While using the app" is enough). Trade-off: after a phone reboot tracking restarts only when the staff opens the app.

## Open decisions (app)
| ID | Question | Default |
|---|---|---|
| OD-M01 | Distribution: Google Play closed track vs. direct APK | Play closed testing track (in-app updates, integrity API) |
| OD-M02 | Heading font for Bangla | Noto Sans Bengali (Hind Siliguri optional) |
| OD-M03 | Crash reporting | Firebase Crashlytics (already using Firebase for FCM), PII scrubbed |
| OD-M04 | Certificate pinning | Off at launch (rotation risk); revisit after 3 months |
| OD-M05 | Allow managers to use the app | Yes, same app, role-based UI |
| OD-M06 | Background location plugin (free geolocator + own foreground service vs. paid licence) | **Decided:** free now; paid switchable from admin settings once a build includes it (ADR-M11) |
