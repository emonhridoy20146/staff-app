# Changelog — staff-app

## [0.10.1] — 2026-11-18
### Added
- Build against the live test server without typing flags (owner request 2026-11-18, ADR-M16): `config/live.env` is committed with public values only (`APP_ENV=staging`, `API_BASE_URL=https://howlader-apps-api.vercel.app/api/v1`, `API_MODE=live`). No token, key or password is in it or anywhere in the app; the app talks only to field-api, never to the ERP.
- Android Studio run configurations in `.run/`: **Live API** (debug), **Live API (release)** and **Demo (no server)**. They appear in the run list after `git pull`.
- `make apk-live` and the README command `flutter build apk --release --dart-define-from-file=config/live.env`; CI uploads a live APK (`staff-app-live-apk`) beside the demo APK.
- Guard test `test/core/live_config_test.dart`: committed `config/*.env` files may hold only `APP_ENV`, `API_BASE_URL` and `API_MODE`, nothing that looks like a secret, an `https` field-api URL ending in `/api/v1` and never the ERP; every `.run` configuration uses a file that exists; Android does not allow cleartext HTTP.
### Changed
- `Env.fromValues` holds the define rules (used by `Env.fromDefines` and the guard test); behaviour is unchanged and a build without defines is still the demo.
- Test fix: the call-record flow test checked that the pushed JSON has no `017` anywhere, which failed whenever the random UUIDv7 `clientId` happened to contain those digits (CI run on PR #10). It now checks that none of the customer's real numbers (last 8 digits) and no phone field are in the payload, which is stricter and not random.
- README: how to run against the live server, and the two admin steps before the first login (staff user with linked ERP employee; minimum app version `0.10.0` while the app is below 1.0.0, because the server default `1.0.0` shows "update required").

## [0.10.0] — 2026-11-18
### Added
- Contract pinned to field-api 1.13.0, the shape of the real Laravel ERP (field-api ADR-033, master FR-ERP-006; field-api PR #10, merge c69ed55). The ERP itself was not changed.
- ERP invoice details on the customer page (FR-M-030): each plan is one ERP invoice and shows its invoice number (`INV-…`), "credit sale" or the installment count, how often installments fall due (monthly, weekly, daily, every N days), "pay by" for a credit sale, any written-off amount, the products with model, quantity and serial numbers, and the plan's own guarantor. A line whose late fee the ERP added shows "incl. late fee". Lines the ERP rolled forward (amount 0) are hidden, with a note saying how many. Returned and cancelled invoices are listed last, muted, with "not collectable".
- Customer header: the ERP's detailed address (when it differs from the address), the ERP "directions" text with a signpost icon, and the ERP risk grade (colour + icon + label; medium and high risk also say so in words).
- Customer timeline: the ERP method name, the collector's name, "advance" and "removed in the ERP" on ERP payments.
- Same-day warning in the collect flow (FR-M-031, open decision OD-27): the ERP takes one payment per installment invoice per day, so when the chosen invoice already has a payment today (an ERP payment on the phone, or a collection recorded on this phone today) the amount and review steps say the office may need to decide on it. The collection is still saved and sent; the server turns it into a conflict instead of dropping it. Credit invoices are not warned about.
- Database schema 7: `customers.detailed_address`, `directions`, `erp_risk_json`; `plans.kind` (default `installment`), `invoice_no`, `sale_date`, `frequency`, `custom_days`, `items_json`, `guarantor_json`, `written_off_poisha`; `schedule_lines.late_fee_poisha`, `rolled`; `erp_payments.method_label`, `collector_name`, `advance`, `discount_poisha`. Migration tests from schema 1 to 6.
- Demo API: invoice numbers, products with model and serial, monthly frequency, ERP receipt numbers (`PAY-YYYYMMDD-NNNNN`), method names and collectors, a late fee on some overdue lines, risk grades, detailed addresses and directions.
### Changed
- The collect flow offers only invoices that can still take money (not returned, cancelled or settled), and names them "invoice number · product".
- ERP payments are linked to their invoice by `erpPlanId` (the 1.13.0 name); `planId` is still read.
- Tests: ERP shape unit tests (same-day rule, collectable invoices, products, risk, guarantor phones, customer pull with rolled lines, late fees and today's paid invoices), migration test from schema 6; screenshots 29-customer-erp, 30-customer-invoice, 31-collect-same-day; 04, 10 and 13 updated.

## [0.9.0] — 2026-11-17
### Added
- Contract pinned to field-api 1.12.0 (leave cancel and filters, holiday ids, my shift, broadcast `ackedAt` and recipients, `broadcast_ack` mutation, contact attempt `target`; field-api PR #9, merge 8a57b85).
- Notices from the office (FR-M-027, master FR-NOT-005, owner request 2026-11-17), flag `module.notifications`: notices arrive with every pull (entity `broadcast`) and are kept on the phone. `/notices` lists them newest first with a read state chip (colour + icon + label: must read, unread, read); `/notices/:id` shows the whole notice in the user's language and a "পড়েছি" (I have read it) button. The tap is saved at once and sent as the `broadcast_ack` mutation with the tap time, so it works offline; until the server confirms it the screen says "read, will be sent". A pull that has not seen the tap yet keeps it. Today shows a banner while a must-read notice is not read; the Me tab shows the unread count.
- Leave, holidays and my shift (FR-M-028, master FR-ATT-008 / FR-SET-002 / FR-SET-003), on the attendance flag: Me → "Leave" lists my requests with status (pending, approved, rejected with the manager's reason, withdrawn) and lets me withdraw a pending one; "Ask for leave" (casual, sick, other; from, to, reason) checks the dates before sending (end before start, more than 31 days, overlap with a pending or approved request) and shows the server's answers (overlap, too long, already decided). "Work calendar" shows this year's holidays for my branch (national or branch only) and my shift (hours, weekly off, late grace). Asking and withdrawing need the network (ADR-M08 exception, see decisions); the last answers are kept and shown offline with their time.
- Guarantor (FR-M-029): the customer page shows the guarantor's name and phone from the ERP data on the phone, with a one-tap call. After the call the same outcome sheet as customer calls appears and the attempt is logged offline as a `contact_attempt` with `target: guarantor` (no phone index; the number is never stored or sent). The customer timeline says "Called the guarantor".
- Database schema 6: table `broadcasts`; `contact_attempts.target` (default `customer`, so older calls stay customer calls). Migration tests from schema 1, 2, 3, 4 and 5.
- Demo API: two notices (one must-read), an approved leave, the 1.12.0 leave rules (overlap, 31 days, cancel only while pending), branch and national holidays, my shift, and the `broadcast_ack` mutation.
### Changed
- Tests: notices, leave and guarantor flow tests (offline read sent later with the tap time, Today banner until read, new notice on the next sync, ask / overlap / withdraw / decided, offline cache with time, form rules, holidays and shift cached, guarantor parsing, guarantor call payload without the number).

## [0.8.0] — 2026-11-17
### Added
- Contract pinned to field-api 1.11.0 (map pins, `customers.staffPinApproval`; field-api PR #8, merge d5a0123).
- Map pin screen (FR-CUS-011, owner request 2026-11-17), replacing the GPS-only pin screen at `/customers/:id/pin`: the pin stays in the middle and the map moves under it, as ride apps pick a pick-up spot (drag, pinch, tap a spot to bring it under the pin; no rotation). It starts at the customer's pin (drawn hollow for comparison), else at the phone's position; the my-location button brings the map back to the phone. It shows the coordinates, how far the pin moved, and how far the phone is from the pin (warning above 300 m). Coordinates can be typed or pasted (decimal, N/E degrees, map links with `@lat,lng` or `q=lat,lng`, Bangla digits; longitude-first pairs are swapped). A camera photo of the house is optional; a note too. Works offline: the pin is saved and sent later.
- What happens is said before sending: under `customers.staffPinApproval = when_missing` (default, owner decision 2026-11-17) a pin for a customer without a usable location is set as soon as it is sent ("Set pin"); moving an existing pin, a phone reporting a fake location, or the `always` setting waits for a manager ("Send for approval"). Outside Bangladesh cannot be sent. The customer's status line says "set as soon as it is sent" while the pin waits in the queue.
- The proposal goes as `method: map` with `deviceGeo` (the phone's fix, or null), so the manager sees how far away the staff was; the server's `approved` push result clears the status line at once and the pin arrives with the same sync.
- Database schema 5: `location_proposals.method` (`gps` for rows from before 0.8.0, which keep their old body) and `location_proposals.device_geo_json`. Migration tests from schema 1, 2, 3 and 4.
- Demo API: the 1.11.0 pin rules (auto-apply for pinless customers, approved pins update the customer) and the setting.
### Changed
- A pin no longer needs the phone at the door with ≤ 30 m GPS accuracy, and the photo is optional (owner request: pin like in Uber). The manager still sees the phone's distance and any fake location.
- Tests: map pin rules and coordinate parsing (unit), map pin flows (photo and no photo, offline, auto-apply, moved pin and fake location wait, approval brings the pin, old GPS rows), a widget test of the screen (drag, typed coordinates, set pin), screenshot 14 updated.

## [0.7.0] — 2026-11-17
### Added
- Contract pinned to field-api 1.10.0 (targets and reports).
- My daily target on Today (FR-COL-015, owner request 2026-11-17): `/sync/pull` carries `target` (MyTarget: amount, visits, personal or branch, working day) while flag `module.targets` is on; it is stored on the phone, so the Today card works offline. The card compares today's field collections with the amount target and today's visit credit (single + co-work × `cowork.visitCredit`, worked out on the phone) with the visit target, shows "My target" for a personal target, a "Target met" pill, and "Day off, no target today" on a weekly off, holiday or approved leave. A target from another day is ignored.
- My performance (`/performance`, FR-M-021 / FR-REP-005, flag `module.reports`, self-service): month switcher (this month and 11 back); collected this month against the target to date and the whole month, with posted vs pending in ERP; visit credit against the target to date, single and co-work visits; promises kept, days present, late days; my place in the branch when the leaderboard is visible; a daily bar chart (collected, target met, target tick; days off muted). Online; the last answer per month is kept and shown offline with its time.
- Leaderboard (`/leaderboard`, FR-REP-005): only when the admin turns on `reports.leaderboardVisibleToStaff` (default off; the server answers 403 otherwise). Today / this month; metric chips (collected, visit credit, promises kept, target achieved); my row highlighted; ties share a rank; staff with too few days present are listed apart as not ranked. Reached from the Me tab and the rank card.
### Changed
- The branch settings `dailyTargetPoisha` / `dailyVisitTarget` are no longer read: targets are dated records on the server (contract 1.10.0).
- Checked against the field-api 1.10.0 contract: visit targets are numbers (a target of 12.5 is kept, not cut to 12) and the leaderboard list is read from `items`.
- Tests: targets and reports flow tests (target on pull and day off, visit credit weight, month online then cached offline, leaderboard ties and hidden, month arithmetic); screenshots 22-performance, 23-leaderboard; Today and Me screenshots updated.

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
