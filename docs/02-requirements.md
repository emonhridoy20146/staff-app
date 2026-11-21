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
| FR-M-021 **[ADDED]** | My performance screen: month-to-date collected (posted / pending in ERP) against target to date, visit credit with single / co-work split, promises kept, attendance, rank and leaderboard (if `reports.leaderboardVisibleToStaff`), daily chart; last month cached for offline (contract 1.10.0, 0.7.0). | active | P3 | D |
| FR-M-022 **[ADDED]** | Day route suggestion: order today's priority customers by nearest-neighbour route from current location. | proposed | P3 | U D |
| FR-M-023 | Home screen widget / quick tile: none in v1 (dropped to keep scope). | dropped | — | — |
| FR-M-025 **[ADDED 2026-11-17]** | Map pin (FR-CUS-011, owner request): set or move a customer's pin by moving the map under a fixed centre pin (ride-app style), or by typing or pasting coordinates; starts at the customer's pin, else the phone's position; shows coordinates, distance moved and distance from the phone; optional camera photo and note; offline (queued). Says before sending whether the pin is set at once (customer without a usable pin, setting `customers.staffPinApproval = when_missing`, phone not mocked) or waits for a manager. Sent as `method: map` with `deviceGeo`. | active | P1 | U W D |
| FR-M-024 **[ADDED]** | Map filters and list view (owner request 2026-11-16): multi-select filter chips on the map (due today, overdue, promised today, tagged, likely bad; a customer shows if it matches any selected), with a count on each chip; a Map/List toggle where the list shows the same filtered customers nearest first with distance from the staff member's last GPS fix, customers without a pin last. Fully offline (local data); only map tiles need the network. | active | P1 | U D |
| FR-M-025 **[ADDED]** | Co-work in the app (master FR-CW-001…005, owner request 2026-11-16): ask / accept / reject / leave online with clear errors; invitations and the group on Today and Me; joint-visit switch on the visit screen (offline, `coWorkSessionId`); partners' joint visits on pull and on the timeline; Today visit count split single / co-work. Money stays with the recorder. | active | P2 | U I D |
| FR-M-026 **[ADDED]** | Today progress against my own daily target (master FR-COL-015): amount and visit credit, personal or branch target, day off shown, offline from the last pull (contract 1.10.0). | active | P3 | U D |
| FR-M-027 **[ADDED 2026-11-17]** | Notices from the office (master FR-NOT-005, owner request): list and detail from the pull, offline "পড়েছি" sent as `broadcast_ack` with the tap time, must-read banner on Today until read, unread count on Me (contract 1.12.0). | active | P2 | U I D |
| FR-M-028 **[ADDED 2026-11-17]** | Leave, holidays and my shift (master FR-ATT-008, FR-SET-002/003, owner request): ask for leave online with form checks (dates, 31 days, overlap), see status and the manager's reason, withdraw while pending; my branch's holidays and my shift; last answers cached for offline (contract 1.12.0). | active | P2 | U I D |
| FR-M-029 **[ADDED 2026-11-17]** | Guarantor on the customer page (owner request): name and phone from ERP data, one-tap call, call logged offline as `contact_attempt` with `target: guarantor` and no number (contract 1.12.0). | active | P2 | U D |
| FR-M-030 **[ADDED 2026-11-18]** | ERP invoice details (master FR-ERP-006, contract 1.13.0): invoice number, installment or credit sale, frequency, products with model and serials, plan guarantor, late fee in a line, rolled lines hidden with a count, written-off amount; returned and cancelled invoices last, muted and not offered for collection; ERP detailed address, directions and risk grade on the customer; ERP method name, collector, advance and removed payments on the timeline. All offline from the pull. | active | P1 | U D |
| FR-M-031 **[ADDED 2026-11-18]** | Same-day warning (master FR-ERP-006 `DUPLICATE_SAME_DAY`, OD-27): when the chosen installment invoice already has a payment today (ERP payment on the phone or a collection from this phone today), the amount and review steps warn that the office may need to decide on it. Never blocks or drops the collection. | active | P1 | U D |
| FR-M-032 **[ADDED 2026-11-18]** | Whole branch on the phone (master FR-CUS-015, contract 1.19.0): every customer of the staff member's branches is synced; rows show the branch when there are several; the customer page says whose customer it is; Today lists own and unassigned customers only; a Mine filter. 0.12.3: the list reloads by pull-down or a top-bar button and says when the first load is running or failed. 0.12.4: the first-load snapshot is read in the contract shape (it was dropped before, so only customers that changed later reached the phone). | active | P1 | U W |
| FR-M-035 **[ADDED 2026-11-19]** | Same-day repeat visit: the visit screen warns when the customer already has a visit today on this phone (count, last check-in time). Never blocks: a second visit the same day is allowed. | active | P2 | U |
| FR-M-036 **[ADDED 2026-11-21]** | Installment lines show the truth of each line: left = amount − paid (the late fee is inside the amount); a partly paid line shows paid and left and keeps its Overdue / Due state; each invoice shows its open installments and the unpaid part of its overdue lines; "N of M paid" counts fully paid lines only. | active | P1 | U |
| FR-M-037 **[ADDED 2026-11-21]** | Customer phone numbers (master FR-CUS-016, contract 1.23.0): the customer page marks each number as the ERP's or added, with whose number an added one is. Staff with `customer.phone.manage` add one to five numbers in one sheet, offline too (sync mutation `customer_phone`); a number waiting to be sent is marked and survives a pull. Added numbers never go to the ERP. Calls are logged by index, ERP numbers first. | active | P1 | U F |
| FR-M-038 **[ADDED 2026-11-21]** | Work marks (master FR-CUS-017): every customer row, in every filter, shows four marks for the current Dhaka month: visited (today / this month), money (in the ERP / pending in ERP), open promise, map pin set or missing; each has colour, icon and a spoken label. The customer page has a "this month" card with the same facts and the invoice count. Derived on the phone, so they work offline and update at once. | active | P1 | U |
| FR-M-039 **[ADDED 2026-11-21]** | Readable spans: minutes are shown as hours and minutes and a count of days as years, months and days (two largest units), wherever the app shows a length of time (overdue, late, break, dwell, shift rules). | active | P2 | U |
| FR-M-040 **[ADDED 2026-11-21]** | Late days count toward absence: every two late days in a Dhaka month are one absent day (owner rule). The attendance history marks the day that completes each pair and shows the month's late days and the absent days they count as. | active | P1 | U |
| FR-M-041 **[ADDED 2026-11-21]** | Today's Work: one list of everything the signed-in user did on a Dhaka business day (visits, collections, promises, notes, map pins, calls, tasks reported done), latest first, each row opening its customer or task; counts on top with posted and pending money apart; earlier days by arrows. Offline, from the phone's own data, through the `workLogSources` extension point. | active | P1 | U |
| FR-M-042 **[ADDED 2026-11-21]** | Home's attendance tile marks today's attendance as still to give (amber) or given (green). The Performance screen warns about the month's late days and the absent days they count as, and links to the day-by-day work history. | active | P2 | U |
| FR-M-043 **[ADDED 2026-11-21]** | Far from the customer: when a visit or a collection is saved outside the geofence around the customer's pin (`geofenceRadiusM`), the app shows the distance and asks to confirm; "record anyway" saves it. Never blocks; no question without a fix or a pin. The office sees the distance and the `far_from_pin` flag. | active | P1 | U |
| FR-M-044 **[ADDED 2026-11-21]** | Bell: the top bar (all main tabs) has a bell with the number of things waiting for the user: open promises due today, new tasks, co-work requests, unread notices, handovers to answer. It opens a list; each row opens the customer or the page concerned. Offline-capable; features supply rows through `alertSources`. | active | P1 | U |
| FR-M-045 **[ADDED 2026-11-21]** | Branch switch: the branch picked in the top bar filters the customer list and its chip counts, Today, the map and the collect picker together; "all branches" removes the filter; a branch no longer available falls back to all. The pick is a view filter only (no data is removed, sync is unchanged). | active | P1 | U |
| FR-M-046 **[ADDED 2026-11-21]** | Customer list filters "paid this month" (ERP payment dated this month or pending field money) and "not paid this month" (outstanding > 0 and neither), each with a count; default sort keeps the longest overdue first. Offline. | active | P1 | U |
| FR-M-047 **[ADDED 2026-11-21]** | Duty settings from the server: late time, break limit, the Friday break window, tracking end, the far-from-customer distance, the cash-limit behaviour and late days per absent day are read from the server's settings (`attendance.defaultShift`, `collections.geofenceM`, `cash.limitMode`, `attendance.lateDaysPerAbsent`), per branch, and kept for offline use. Built-in values apply only when the server sent none. | active | P1 | U |
| FR-M-048 **[ADDED 2026-11-21]** | Collection board (master FR-REP-007, contract 1.26.0): first tab of the leaderboard; everyone who collected, every branch (unless the office narrows it), ranked by money the ERP has accepted, this month or all time; a crown on first place; managers and admins named by role; my place and amount on top. Online; shown under the same setting as the leaderboard. | active | P1 | U |
| FR-M-049 **[ADDED 2026-11-21]** | Cash on hand by collection (master FR-CASH-007, contract 1.27.0): from the cash card, the cash collections not yet covered by a deposit with customer, invoice, receipt, time and amount in hand; a tap opens the customer. Online (server-computed); unsent money on the phone is called out. | active | P1 | U |
| FR-M-050 **[ADDED 2026-11-21]** | Receipt of any collection: every collection on the phone opens its receipt again (from Today's Work and from the customer's timeline) to show, share, save or print through the share sheet; offline. | active | P1 | U |
| FR-M-052 **[ADDED 2026-11-21]** | Invoice total on the customer list (master FR-CUS-018): the count line reads "N জন গ্রাহক · ইনভয়েস T টি · বাকি আছে O টি" for the customers in view (the branch picked in the top bar, or all my branches), the same rule as the customer page (cancelled invoices not counted; open = still takes money). From the phone's own data, offline; search and chips do not change it. | active | P2 | U |
| FR-M-033 **[ADDED 2026-11-19, owner request]** | Tasks from the office (master FR-TASK-001..005, contract 1.20.0, flag `module.tasks`, permission `task.work`): a free-form task with a note and an optional due date, not tied to a customer; shown on Today and Me with the number to do, list and detail with history; "কাজ হয়েছে" with an optional note works offline (`task_resolve_request`); only the office resolves; a task sent back shows the reason. | active | P1 | U W |
| FR-M-034 **[ADDED 2026-11-19, owner request]** | Back at the root of the signed-in app asks "close the app?" (stay / close) before leaving; screens above the tabs go back one step as usual. | active | P1 | U W |

## 3. Non-functional (app specifics)
| ID | Requirement |
|---|---|
| NFR-M-001 | Android 8.0+ (API 26), target latest SDK required by Play; arm64-v8a + armeabi-v7a splits; APK ≤ 30 MB per ABI. |
| NFR-M-002 | Cold start ≤ 3 s on 2 GB RAM device; memory ≤ 250 MB; jank-free scrolling of 2,000 rows. |
| NFR-M-003 | Tracking battery ≤ 12 % over 9 h duty on mid-range device (phase 2 acceptance). |
| NFR-M-004 | Initial bootstrap ≤ 2 min on 3G for 500 customers. |
| NFR-M-005 | No data loss on: app kill, phone reboot, low battery shutdown, app upgrade, network loss mid-request. |
| NFR-M-006 | Accessibility: 48 dp targets, font scale 1.3, TalkBack Bangla labels, contrast AA. |
