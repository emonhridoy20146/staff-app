# Changelog — staff-app

## [0.6.0] — 2026-11-16
### Added
- Contract pinned to field-api 1.9.1 (co-work 1.9.0; bootstrap of today's working state 1.9.1, handled by the existing generic pull path).
- Co-work (FR-CW-001…005, owner request 2026-11-16), module flag `module.cowork`, permission `cowork.use`:
  - Ask colleagues of the same branch to work together today (`/cowork`): colleague list from `GET /cowork/colleagues` with "on duty", "not on duty", "in another group" and "in this group"; pick up to the free seats (`cowork.maxMembers` counts everyone, including me); optional note. Online only (ADR-M08 exception, like handovers): a partner must see the answer at once. One idempotency key per send, reused on retry.
  - Invitations arrive on pull (entity `cowork_session`) and show on Today with Accept / Reject; errors say what happened (no internet, already in another group, group ended, limit reached).
  - Today shows my group: members with a tick or "waiting", today's co-work visit count, Ask more, Leave (with a confirmation). When off duty and in no group, Today offers "Work with a colleague". Me tab entry with the invitation count.
  - Visits: when I have at least one accepted partner and am on duty, the visit screen shows a "Co-work visit" switch (on by default) naming the partners. The visit then carries `coWorkSessionId`; this works offline because the session is stored on the phone. The server decides who took part (members accepted at check-in) and its `coWork.participantIds` replace our estimate on pull; a claim the server cannot confirm comes back as a single visit.
  - Partners' joint visits arrive on pull and count for me. The customer timeline marks joint visits with a "Co-work" chip, "with …" names and "recorded by …" for a partner's record.
  - Today's visit metric counts my visits plus joint visits I took part in, with a "N co-work" line; others' visits on my customers no longer count (bug fix). Target credit (`cowork.visitCredit`) and money are server-side: collections always belong to the recorder only.
- Database schema 4: table `cowork_sessions`; `visits.user_id`, `visits.co_work_session_id`, `visits.co_work_participant_ids_json`. Migration tests from schema 1, 2 and 3.
- `VisitService` (provider) behind `recordVisit`, so visit saving is testable without widgets.
- Tests: co-work flow tests (invitation, offline answer refused, joint visit offline then sent, idempotent request, member limit, partner visit credit, leave ends a group of two, work-out leaves, already in a group); screenshots 18–21.

## [0.5.0] — 2026-11-16
### Added
- Map filters and list view (FR-M-024, owner request 2026-11-16). The map has multi-select filter chips (due today, overdue, promised today, tagged, likely bad), each with its count; a customer shows when it matches any selected filter, and a clear chip resets them. A Map/List toggle switches to a list of the same filtered customers, nearest first with distance from the last GPS fix; customers without a pin go last. Both work fully offline from the local database; only map tiles need the network. The choice of filters and view is kept while the app is open.
- Tests: filter and distance-order flow test; screenshots `16-map-filtered`, `17-map-list`; `07-map` updated.

## [0.4.0] — 2026-11-16
### Added
- Contract pinned to field-api 1.8.0.
- Attendance photo (FR-ATT-001, owner request 2026-11-16): work-in, break start, break end and work-out open the front camera, and nothing is recorded without the photo (camera only, no gallery). Server settings (contract 1.8.0, resolved per branch): `attendance.selfieRequired` is the master switch (default on) and `attendance.selfieEvents` lists the events (default all four). The server never rejects an event without a photo; it flags the day `no_selfie`, so the app enforces the camera step. The photo is watermarked (time, event, staff code, GPS) and uploaded as media kind `selfie`.
- Outbox state `held`: a mutation saved on the phone but not sent until its photo is confirmed, then released with `selfieMediaId`. Duty status changes on the phone right away. Each attendance event depends on the previous one of the day, so the server always receives them in order. Held items count as unsynced (sign-out guard, sync centre).
### Changed
- OD-12 amended by the owner: the selfie is no longer optional at work-in only. See `08-decisions.md`.

## [0.3.0] — 2026-11-16
### Added
- Pin correction (FR-CUS-008): staff can set or correct a customer's map location. Open it from customer detail ("Set location" when there is no pin, "Correct location" under More) or from the map's "N without location" chip. The phone's GPS fix is checked as the server does (accuracy ≤ 30 m, no mock location, inside Bangladesh), a camera photo is required (kind `location_proof`), and a note is optional. Saved offline: the proposal waits on the phone until its photo is uploaded, then the `location_proposal` mutation is sent with `photoMediaId`. The pin itself changes only after a manager approves it and the customer syncs back. Customer detail shows "waiting for manager approval" until then.
- Proposal status from the server (contract 1.7.0): `location_proposal` arrives on `/sync/pull` when created and when a manager decides. A rejection shows on customer detail with the manager's reason and a tap to send a new one; an approval clears the line (the new pin arrives as a customer change).
- Database schema 3: `location_proposals.decision_reason`, with migration tests from schema 1 and 2.
### Changed
- Contract pinned to field-api `openapi.yaml` 1.7.0.
### Not done
- `GET /location-proposals/mine` (for a reinstalled phone) is not called yet; bootstrap does not snapshot proposals, so after a reinstall older proposals show only when the server next changes them.

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
- Android `compileSdk` 37 (needed by `flutter_local_notifications` and `androidx.core` 1.19; the CI APK build failed on 36). `targetSdk` unchanged. CI builds with JDK 21 (Android lint crashed on 17).
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
