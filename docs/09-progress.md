# 09 — Progress (staff-app)

Legend: ✅ done and covered by automated tests or screenshots · ◐ partly done · ☐ not started. Nothing is yet verified on a real Android device (see `07-test-plan.md §3`).

Phases match `field-api/docs/09-progress.md`. Start each phase against the Prism mock of `openapi.yaml`.

## Phase 0 — Foundations
| Item | Status |
|---|---|
| Project, flavors, CI (analyze, fos_lints, tests, goldens, APK build), signing via CI secrets | ◐ project, env flavours, CI builds the live APK (artifact `staff-app-live-apk`); fos_lints not written |
| Live test server build without flags: `config/live.env` + Android Studio run configurations (ADR-M16) | ✅ 0.10.1, guard test; first login on a real phone against the live server pending |
| Theme: tokens, ColorScheme, StatusColors, typography with bundled fonts, high-contrast mode | ✅ |
| Core: drift + SQLCipher, dio + interceptors, clock with server offset, format (money/digits/words) | ✅ (sqlite3mc, see ADR-M02 amendment) |
| Auth: login, refresh, change password, PIN/biometric, app lock, version gate | ◐ biometric not yet |
| Feature registry, permissions & flags services, shell with bottom nav | ✅ |
| Sync engine skeleton (outbox, push/pull, bootstrap) with unit tests | ✅ |
**Acceptance:** M-E1 (without customers), M-E8; goldens for theme in bn/en light/dark; analyze + lints clean.

## Phase 1 — MVP
| Item | Status |
|---|---|
| Customers (list, search, filters, detail, timeline), Map with pins and sheet | ✅ (tile cache not yet) |
| Map filters (multi-select) and Map/List toggle with distance | ✅ 0.5.0, flow test + screenshots |
| Co-work: ask / accept / leave (online), Today and Me cards, joint-visit switch, partner visits, single/co-work split (contract 1.9.0) | ✅ 0.6.0, flow tests + screenshots; two-phone check pending |
| Today screen with priorities and progress | ✅ |
| Collect flow, receipt blocks, receipt share image | ✅ |
| Cash: position, limit, deposits with slip, end-of-day closing | ◐ slip photo and closing not yet |
| Visits with camera, media queue | ✅ |
| Notes, promises, local reminders | ✅ |
| Tags (with reason), pin correction proposals | ✅ tags; pin correction in 0.3.0 (flow test + screenshots); map pin screen in 0.8.0 (contract 1.11.0: map moves under a fixed pin, typed coordinates, optional photo, set at once for customers without a location; flow + widget tests, screenshot) |
| Attendance: work-in/out, breaks, summary | ✅ |
| Attendance photo at every event (setting `attendance.selfieEvents`) | ✅ 0.4.0, flow tests + screenshot; device camera check pending. 0.12.1: the event no longer waits for its photo (ADR-M19). 0.12.2: rough indoor fixes sent, a fix every 2 minutes on duty (ADR-M20) |
| Handovers incoming/outgoing | ◐ incoming done; outgoing (P4 staff-initiated) not yet |
| Notices from the office: list, detail, offline "পড়েছি" (`broadcast_ack`), Today banner, Me count (contract 1.12.0) | ✅ 0.9.0, flow tests + screenshots |
| Tasks from the office: list, detail with history, offline "কাজ হয়েছে" (`task_resolve_request`), Today card, Me count, sent-back reason (contract 1.20.0, flag `module.tasks`) | ✅ 0.12.0, flow + screen tests; lock-screen alert waits for FCM |
| Back at the root asks "close the app?" | ✅ 0.12.0, widget + app tests; device check in the manual list |
| Leave requests (ask, withdraw, status with reason), holidays of my branch, my shift; cached offline | ✅ 0.9.0, flow tests + screenshots |
| Guarantor on the customer page with one-tap call, logged offline as a guarantor call | ✅ 0.9.0, flow test + screenshot; device call check pending |
| Real ERP shape (contract 1.13.0): invoice numbers, products and serials, credit sales, frequency, late fees, rolled lines hidden, returned invoices not collectable, directions and risk grade, ERP method and collector on payments; database schema 7 | ✅ 0.10.0, unit + migration tests, screenshots 29-31; check with real ERP data once field-api runs in `live` mode |
| Same-day warning in the collect flow (one payment per installment invoice per day, OD-27) | ✅ 0.10.0, unit test + screenshot; device check pending |
| Whole branch on the phone, staff in several branches, branch on rows, whose customer it is, Today = own + unassigned (contract 1.19.0, schema 8) | ✅ 0.11.0, unit + migration tests; device check pending |
| Customer list reload (pull-down + top-bar button), auto-load when the tab opens empty, loading/failed empty states (FR-M-032); online/offline line on every screen | ✅ 0.12.3, flow tests |
| Whole-branch first load fixed (bootstrap read in the contract shape; one fresh snapshot after update); distance on Home from a fresh on-duty fix; same-day repeat visit warning (FR-M-032/005/035) | ✅ 0.12.4, unit + flow tests |
| Attendance hub screen (history, today status, break/end-work buttons, late warning, GPS banner); colored branch top bar + notification bell in shell; customer list visited/promised dot indicators; Today's Work history screen (visits + collections merged); quick-action tiles on Today screen (Attendance, Today's Work, Performance) | ◐ 0.12.5, widget tests pending; GPS double-notification known issue (ADR-M20, requires native fix) |
| Installment lines: partly paid keeps Overdue, late fee counted once, open installments per invoice (FR-M-036) | ✅ 2026-11-21, unit tests |
| Extra phone numbers: ERP / added marks, add several at once, offline (contract 1.23.0, FR-M-037) | ✅ 2026-11-21, unit + flow tests; device check pending |
| Work marks on every customer row and a "this month" card on the customer page (FR-M-038) | ✅ 2026-11-21, unit tests; device check pending |
| Home attendance mark, late warning and work-history link on Performance (FR-M-042) | ✅ 2026-11-21, unit tests; device check pending |
| Confirm a visit or collection recorded far from the customer's pin (FR-M-043) | ✅ 2026-11-21, unit tests; device check pending |
| Bell with what waits for the user: promises due today, new tasks, co-work requests, notices, handovers (FR-M-044) | ✅ 2026-11-21, unit tests; device check pending |
| Branch switch filters list, Today, map and collect picker together (FR-M-045) | ✅ 2026-11-21, unit test; device check pending |
| Customer list: paid / not paid this month filters with counts (FR-M-046) | ✅ 2026-11-21, unit test; device check pending |
| Duty hours, Friday break window, geofence and cash rule read from the server's real setting keys (FR-M-047) | ✅ 2026-11-21, unit tests; device check pending |
| Collection board: verified money, every branch, month and all time, crown on first place (FR-M-048, contract 1.26.0) | ✅ 2026-11-21, unit tests; device check pending |
| Cash on hand by collection: customer, invoice, receipt per line (FR-M-049, contract 1.27.0) | ✅ 2026-11-21, unit tests; device check pending |
| Receipt of any collection from Today's Work and the customer timeline (FR-M-050) | ✅ 2026-11-21, CI only; device check pending |
| Remove an added phone number from the customer page, online (FR-M-053) | ✅ 2026-11-21, CI only; device check pending |
| Same device id after a reinstall (ANDROID_ID); attendance restored from the server after a reinstall; no photo at breaks by default; 09:00–21:00 without shift data (FR-M-060, FR-M-061, ADR-M25, contract 1.36.0) | 🚧 2026-11-22, unit + flow tests; needs field-api 1.36.0; device check pending (reinstall on a real phone) |
| Customer page: reload button and pull down refresh this customer from the server (ERP figures, invoices, payments), then sync; offline says internet is needed and keeps the saved data (FR-M-063, ADR-M27) | 🚧 2026-11-22, flow tests (button, pull, offline, English); device check pending |
| Deposit everything; collections of any method editable until deposited; locked after; refused deposit in Problems (FR-M-059, ADR-M24, contract 1.35.0, schema 14) | 🚧 2026-11-22, unit + widget + flow tests; needs field-api 1.35.0; device check pending |
| Bank deposit slip photo: camera only, required for Bank, held deposit released with `slipMediaId` after upload; thumbnail on the confirm and in the history (FR-M-065, ADR-M29) | 🚧 2026-11-22, unit + widget + flow tests; device check pending (camera, upload on a real phone) |
| Co-work: the requester can cancel; a group of one ends (contract 1.34.0) | ✅ 2026-11-22, CI only; device check pending |
| Visit outcome "পলাতক / Runaway" (FR-M-064, contract 1.41.0) | 🚧 2026-11-22, unit test; needs field-api 1.41.0 |
| Cash in hand: change or delete until deposited; other staff's work list; PIN progress (FR-M-058, ADR-M23, contract 1.32.0) | 🚧 2026-11-22, CI only; needs field-api 1.32.0; device check pending |
| Who did it: colleagues' visits, promises, collections and pins with the staff name; schema 12 (FR-M-057, ADR-M22) | 🚧 2026-11-22, CI only; needs field-api 1.31.0; device check pending |
| One on-duty notification instead of two (FR-M-056, ADR-M21) | ✅ 2026-11-21, CI only; **device check needed** |
| Receipt as a PDF from the success and receipt screens (FR-M-055) | ✅ 2026-11-21, CI only; device check pending |
| Installment detail like the ERP: paid on, days late, missed, payments per line; schema 11 (FR-M-054) | ✅ 2026-11-21, CI only; device check pending |
| Invoice total of the customers in view on the list header (FR-M-052) | ✅ 2026-11-21, CI only; device check pending |
| Overtime and break-over-limit marks on the attendance history, schema 10 (FR-M-051) | ✅ 2026-11-21, CI only; device check pending |
| Notifications (FCM + centre), Sync centre & Problems | ◐ sync centre done; FCM not yet (needs Firebase project) |
| Onboarding: consent, permissions primer | ✅ |
**Acceptance:** M-E2…M-E7, M-E9, M-E10 green; manual device checklist (non-location sections) signed off on 4 OEM devices; pilot 5 staff × 2 weeks with zero lost/duplicate collections.

## Phase 2 — Location
LocationEngine spike (ADR-009) → duty-aware tracking, adaptive sampling, filters, queue, heartbeat, mock detection, OEM battery guide, visit suggestion. **Acceptance:** M-E11; battery ≤ 12 %/9 h; OEM checklist passed.

| Item | Status |
|---|---|
| Provider abstraction; free provider (geolocator foreground service); paid slot; admin setting switch with fallback (ADR-M11) | ✅ unit + flow tests (fake provider) |
| Duty-aware start/stop, shift end + 3 h limit, module flag | ✅ flow tests |
| Adaptive sampling, filters, 20,000 cap, batch upload, heartbeat | ✅ unit + flow tests; 0.10.2: points wait until the work-in is on the server (else refused as OFF_DUTY) |
| Mock flag sent with each point | ◐ sent; server decides |
| Visit suggestion (5 min / 60 m) | ✅ flow test; Today card |
| Tracking status card (Me) | ✅ screenshot |
| Call logging (`contact_attempt`) | ✅ flow test |
| OEM battery guide screen | ☐ |
| Battery level in heartbeat | ☐ blocked (`battery_plus` dependency conflict) |
| Real-device checks (battery, OEM killing, reboot) | ☐ needs phones |
| Places on the map: long-press add, labels, own edit, move request, offline (FR-M-063, contract 1.38.0) | ✅ flow + widget tests; ☐ real phone check |
| Places on every map by zoom (none / square icon / icon + name), pin screen landmarks, all branches, Galachipa default centre (FR-M-063, ADR-M28) | ✅ 2026-11-22 widget tests; ☐ real phone check of the zoom steps |

## Phase 3 — Reports in app
My performance, targets progress, day route suggestion.

| Item | Status |
|---|---|
| Today progress against my daily target (amount + visit credit, day off) | ✅ 0.7.0, flow test + screenshots |
| My performance (month, cached offline, daily chart, rank) | ✅ 0.7.0, flow test + screenshot |
| Leaderboard (when visible to staff) | ✅ 0.7.0, flow test + screenshot |
| Day route suggestion | ☐ |

## Phase 4 — Premium (as approved)
Voice notes, offline map packs, Bluetooth printing, staff-initiated handover. (Broadcasts with acknowledgement and leave requests were brought forward to 0.9.0, owner request 2026-11-17.)
