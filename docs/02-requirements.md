# 02 — Requirements (staff-app subset)

Master IDs, statuses and permission keys: `field-api/docs/02-requirements.md`. App-only requirements use `FR-M-…`.

## 1. Master FRs implemented in staff-app

| Area | FR-IDs |
|---|---|
| Auth & device | FR-AUTH-001, 002, 003, 006, 007, 008, 009, 010 |
| RBAC | FR-RBAC-006 |
| Flags | FR-FLAG-002 |
| Customers | FR-CUS-001…008, FR-CUS-010, FR-ERP-003 |
| Tags | FR-TAG-002, 003, 006, 007, 008 |
| Collections | FR-COL-001…007 (staff side), 011, 013 (GPS, mock, clock data capture) |
| Cash | FR-CASH-001, 002, 003, 006 |
| Handovers | FR-HO-002, 003, 004, 005, 007 |
| Visits/notes/promises/media | FR-VIS-001…005, FR-NOTE-001, FR-PRM-001, 002, FR-MED-001 (client side) |
| Attendance | FR-ATT-001, 002, 005, 007, 008 |
| Location | FR-LOC-001…005, 010, 011 |
| Notifications | FR-NOT-001, 002, 003, 005 |
| Sync | FR-SYNC-001…006 |
| Reports | FR-REP-005 (my performance) |
| Microfinance | FR-MF-001 (reserved folder only) |

## 2. App-only requirements

| ID | Requirement | Status | Phase | Test |
|---|---|---|---|---|
| FR-M-001 | First-run flow: login → forced password change if required → PIN setup → privacy & tracking consent (versioned) → permissions primer (location "Allow all the time" explained, camera, notifications, ignore battery optimisation) → initial bootstrap with progress. | active | P1 | D E |
| FR-M-002 | Local DB is the UI source of truth; every list/detail renders from SQLite in < 300 ms for 2,000 customers. | active | P1 | U D |
| FR-M-003 | Background sync: on connectivity regain, on app foreground, every 15 min via WorkManager, and immediately after a money mutation; exponential backoff with jitter (max 15 min); battery-aware. | active | P1 | U D |
| FR-M-004 | Sync centre: counts by entity, oldest item age, last success, problem list (conflict/rejected with explanation), manual retry, "export queue" (encrypted file) for support. | active | P1 | D |
| FR-M-005 | Today screen priority ordering: promised today → due today → overdue by distance → others; recomputed locally on location change > 200 m. | active | P1 | U D |
| FR-M-006 | Collection flow per design guide §5.4: amount chips, keypad, method tiles, txn-ref validation, review with amount in words, hold-to-confirm, success with receipt number; median completion ≤ 15 s in usability test. | active | P1 | U D |
| FR-M-007 | Receipt numbers from allocated blocks; request new block when < 20 left; if exhausted offline, fallback `…-OFF{seq}` series reserved per device (flagged for review). | active | P1 | U |
| FR-M-008 | Cash limit enforced offline: on-hand = server position at last sync + local unsynced cash − local unsynced deposits. | active | P1 | U |
| FR-M-009 | Camera-only capture (no gallery picker anywhere); watermark; compression ≤ 250 KB; EXIF stripped except capture time; media queue with resumable retries; synced media purged after 7 days. | active | P1 | U D |
| FR-M-010 | Local notifications for promise reminders at 09:00 Dhaka on promised date (scheduled from local DB; rescheduled after each sync) and for break-too-long (> max break). | active | P1 | D |
| FR-M-011 | Duty-aware tracking service: starts on work-in, stops on work-out/auto-close; persistent notification; resumes after reboot if still on duty; never runs off duty. | active | P2 | D |
| FR-M-012 | OEM battery guide: detect manufacturer, show step-by-step screens to whitelist app; re-check weekly; heartbeat reports `bgRestricted`. | active | P2 | D |
| FR-M-013 | Navigate to customer: opens external maps app via `geo:`/`google.navigation:` intent (no in-app turn-by-turn). | active | P1 | D |
| FR-M-014 | Call/SMS customer via intents; call attempts are logged locally; sending them to the server as timeline items needs a new `contact_attempt` sync entity in the contract (proposed, not yet in openapi.yaml). | active | P1 | D |
| FR-M-015 | Security: SQLCipher DB key in Android Keystore; FLAG_SECURE on money screens (setting); root/emulator detection reported; app lock after 5 min background. | active | P1 | D |
| FR-M-016 | Logout safety: blocked while queue non-empty unless user confirms "upload first" or a manager-approved forced logout; remote unbind wipes data after uploading queue if possible. | active | P1 | D |
| FR-M-017 | In-app update: honour 426, show update screen with download; keep queue intact across upgrades (DB migrations tested). | active | P0 | D |
| FR-M-018 **[ADDED]** | Voice note on customer (≤ 60 s, AAC) for low-literacy users. | proposed | P1 | D |
| FR-M-019 **[ADDED]** | Offline map area packs (download branch area tiles on Wi-Fi). | proposed | P4 | D |
| FR-M-020 **[ADDED]** | Bluetooth thermal printer receipts (ESC/POS, 58 mm). | proposed | P4 | D |
| FR-M-021 **[ADDED]** | My performance screen: month-to-date collected, visits, promise kept %, attendance, rank (if leaderboard on). | proposed | P3 | D |
| FR-M-022 **[ADDED]** | Day route suggestion: order today's priority customers by nearest-neighbour route from current location. | proposed | P3 | U D |
| FR-M-023 | Home screen widget / quick tile: none in v1 (dropped to keep scope). | dropped | — | — |
| FR-M-024 **[ADDED]** | Map filters and list view (owner request 2026-11-16): multi-select filter chips on the map (due today, overdue, promised today, tagged, likely bad; a customer shows if it matches any selected), with a count on each chip; a Map/List toggle where the list shows the same filtered customers nearest first with distance from the staff member's last GPS fix, customers without a pin last. Fully offline (local data); only map tiles need the network. | active | P1 | U D |

## 3. Non-functional (app specifics)
| ID | Requirement |
|---|---|
| NFR-M-001 | Android 8.0+ (API 26), target latest SDK required by Play; arm64-v8a + armeabi-v7a splits; APK ≤ 30 MB per ABI. |
| NFR-M-002 | Cold start ≤ 3 s on 2 GB RAM device; memory ≤ 250 MB; jank-free scrolling of 2,000 rows. |
| NFR-M-003 | Tracking battery ≤ 12 % over 9 h duty on mid-range device (phase 2 acceptance). |
| NFR-M-004 | Initial bootstrap ≤ 2 min on 3G for 500 customers. |
| NFR-M-005 | No data loss on: app kill, phone reboot, low battery shutdown, app upgrade, network loss mid-request. |
| NFR-M-006 | Accessibility: 48 dp targets, font scale 1.3, TalkBack Bangla labels, contrast AA. |
