# 09 — Progress (staff-app)

Legend: ✅ done and covered by automated tests or screenshots · ◐ partly done · ☐ not started. Nothing is yet verified on a real Android device (see `07-test-plan.md §3`).

Phases match `field-api/docs/09-progress.md`. Start each phase against the Prism mock of `openapi.yaml`.

## Phase 0 — Foundations
| Item | Status |
|---|---|
| Project, flavors, CI (analyze, fos_lints, tests, goldens, APK build), signing via CI secrets | ◐ project, env flavours, CI workflow written; APK build not yet run (no Android SDK in build sandbox); fos_lints not written |
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
| Today screen with priorities and progress | ✅ |
| Collect flow, receipt blocks, receipt share image | ✅ |
| Cash: position, limit, deposits with slip, end-of-day closing | ◐ slip photo and closing not yet |
| Visits with camera, media queue | ✅ |
| Notes, promises, local reminders | ✅ |
| Tags (with reason), pin correction proposals | ◐ tags done; pin proposals not yet |
| Attendance: work-in/out, breaks, summary | ✅ |
| Handovers incoming/outgoing | ◐ incoming done; outgoing (P4 staff-initiated) not yet |
| Notifications (FCM + centre), Sync centre & Problems | ◐ sync centre done; FCM not yet (needs Firebase project) |
| Onboarding: consent, permissions primer | ✅ |
**Acceptance:** M-E2…M-E7, M-E9, M-E10 green; manual device checklist (non-location sections) signed off on 4 OEM devices; pilot 5 staff × 2 weeks with zero lost/duplicate collections.

## Phase 2 — Location
LocationEngine spike (ADR-009) → duty-aware tracking, adaptive sampling, filters, queue, heartbeat, mock detection, OEM battery guide, visit suggestion. **Acceptance:** M-E11; battery ≤ 12 %/9 h; OEM checklist passed.

| Item | Status |
|---|---|
| Provider abstraction; free provider (geolocator foreground service); paid slot; admin setting switch with fallback (ADR-M11) | ✅ unit + flow tests (fake provider) |
| Duty-aware start/stop, shift end + 3 h limit, module flag | ✅ flow tests |
| Adaptive sampling, filters, 20,000 cap, batch upload, heartbeat | ✅ unit + flow tests |
| Mock flag sent with each point | ◐ sent; server decides |
| Visit suggestion (5 min / 60 m) | ✅ flow test; Today card |
| Tracking status card (Me) | ✅ screenshot |
| Call logging (`contact_attempt`) | ✅ flow test |
| OEM battery guide screen | ☐ |
| Battery level in heartbeat | ☐ blocked (`battery_plus` dependency conflict) |
| Real-device checks (battery, OEM killing, reboot) | ☐ needs phones |

## Phase 3 — Reports in app
My performance, targets progress, day route suggestion.

## Phase 4 — Premium (as approved)
Voice notes, offline map packs, Bluetooth printing, broadcasts with acknowledgement, leave requests, staff-initiated handover.
