# 07 — Test Plan (staff-app)

System journeys J-1…J-12 and the FR traceability matrix: `field-api/docs/07-test-plan.md`.

## 1. Automated
| Level | Tool | Focus | Gate |
|---|---|---|---|
| Unit | flutter_test + mocktail | domain rules (priority ordering, cash on hand incl. unsynced, receipt numbers, amount in words bn/en, Bangla digits, Dhaka dates, location filters, sampling profile selection, duty guard), sync engine state machine (all result types, backoff, dependsOn, 410 bootstrap), interceptors (refresh single-flight, 426) | 90 % on `domain/` and `core/sync` |
| DB | drift in-memory + schema migration tests | every migration from every released schema; outbox survives upgrade | CI |
| Widget | flutter_test, golden tests (bn/en × light/dark/high-contrast × font scale 1.0/1.3) | StatusBadge, MoneyText, CustomerTile, AmountKeypad, HoldToConfirm, Today, Collect flow | goldens reviewed |
| Contract | generated client compile + JSON fixtures from openapi examples parsed by models | drift with contract fails CI | CI |
| Integration/E2E | integration_test + Patrol on emulator (API 26, 30, 34) against staging + mock-erp | journeys below; airplane mode toggling via Patrol native | release gate |
| Lints | `fos_lints` (boundaries, no network in UI, no `DateTime.now()` in domain), `flutter analyze` | 0 issues | CI |

## 2. App journeys (Patrol)
| ID | Journey |
|---|---|
| M-E1 | First run: login → change password → PIN → consent → permissions primer → bootstrap 500 customers |
| M-E2 | Airplane mode: 3 collections (cash, bKash, Nagad) + 2 visits with photos + 1 promise → kill app → reboot emulator → network on → all synced once (server count check) |
| M-E3 | Duplicate tap on hold-to-confirm and network timeout mid-push → single server record |
| M-E4 | Conflict returned → Problems shows message → manager resolves (API) → app shows resolution after pull |
| M-E5 | Cash limit: exceed 80 % offline → banner; deposit everything (contract 1.35.0, FR-M-059): confirm names cash, mobile/bank and count; on-hand drops to 0 at once and the collections lock, offline too; a refused deposit shows in Problems and the collections are back in hand (`test/flows/deposit_flow_test.dart`). Bank (FR-M-065): Deposit disabled until a camera photo of the slip is taken (no gallery); the slip shows on the confirm and in the history; offline the deposit waits and goes with `slipMediaId` once the photo uploads (`deposit_slip_sheet_test.dart`) |
| M-E6 | Handover incoming accept → new customers appear; outgoing device keeps queued notes until synced |
| M-E7 | Permission `tag.set` revoked → tag action disappears after pull |
| M-E8 | Version gate 426 → update screen, queue intact |
| M-E9 | Promise reminder fires at 09:00 Dhaka (fake clock) offline |
| M-E10 | Work-in → break → over-break reminder → work-out summary lists unsynced items |
| M-E11 | (P2) Tracking only between work-in and work-out; mock provider flagged |

## 3. Manual device checklist (every release candidate)
Devices (minimum set): **Xiaomi Redmi (MIUI/HyperOS, 2–3 GB)**, **Samsung Galaxy A0x/A1x**, **Realme or Oppo (ColorOS)**, **Vivo (Funtouch)**, **one Android 8/9 device**, **one Android 14/15 device**.

**Install & onboarding**
- [ ] Live build (`Live API (release)` or `staff-app-live-apk`): no demo ribbon, login with a staff user from the admin panel, first sync pulls the staff's customers; a second phone on the same account waits for approval under Devices
- [ ] Fresh install, permissions primer, "While using the app" location flow works per Android version (no background permission asked)
- [ ] Battery optimisation guide opens the correct OEM settings page
- [ ] Closed-app tracking (FR-M-077): work in, swipe the app away, wait **45 min** (3× the access-token life) with the phone locked → the admin live map keeps moving; turn on airplane mode for 10 min and back → buffered points arrive; work out → no point after it, and the native prefs hold no `tracking_token`
- [ ] Refused token (FR-M-077): revoke the device's tracking token in field-api (or wait past its expiry with the app closed) → the duty notification turns amber with "অ্যাপটি একবার খুলুন"; open the app → it renews, the line goes, buffered points upload
- [ ] Background set-up (FR-M-078) on Xiaomi/Redmi, Oppo, Realme, Vivo and Samsung: the detected brand is right, "সেটিংস খুলুন" lands on the autostart / background screen (or the closest one), "অনুমতি দিন" shows Android's battery dialog and the pill turns "অনুমতি আছে"; on duty with the service killed from the brand's task manager, Today shows the red line within a minute; off duty nothing shows
- [ ] Home (2026-11-26) on a 360 dp phone at font scale 1.3 in bn and en, light and dark: nothing cut or overlapping; KPI tiles scroll to their section
- [ ] Pull to refresh (FR-M-079) on each screen in the audit: works on an empty list too; forms have none
- [ ] Bangla renders correctly everywhere (conjuncts ক্ষ ঙ্গ ন্ত্র, reph, ya-phala, hasanta), no clipped matras at font scale 1.3
**Offline & sync**
- [ ] Airplane mode full day simulation (20 actions), then sync on 2G/EDGE (developer network throttling or real SIM)
- [ ] Network flaps during upload; no duplicates (verify in admin)
- [ ] App force-stopped and phone rebooted with queue → queue intact
- [ ] Places (FR-M-063): long-press the map in airplane mode, add a place, edit it, ask to move a colleague's place; back online they reach the admin panel once each; labels readable on a 5" phone at 130 % text
- [ ] Photos (FR-M-069): take an attendance selfie and a visit photo against the live server (cloudinary); each leaves the sync centre's photo list within a minute online; in airplane mode the list says "no connection" with a next try time, and Retry uploads it once back online
- [ ] Super admin (FR-M-070): log in as a super admin on a 1.45.0 server: no duty card, no attendance tile, no attendance card in Me, no location notification
- [ ] Possible customers (FR-M-073): add one in airplane mode off duty (location switch disabled), one on duty with location; change one before it is sent; back online both reach the admin panel once with the changed words
- [ ] Storage nearly full → photo capture shows clear error, data still saved
**Money**
- [ ] Collection flow ≤ 15 s for experienced user; amount in words correct for 1, 15, 101, 1,000, 1,00,000, 12,50,500
- [ ] Receipt image shares to WhatsApp and is readable
- [ ] Cash limit warn/block per setting works offline
- [ ] Same-day warning (0.10.0): collect twice on one installment invoice in a day; the second shows the warning, is still saved and synced, and arrives in admin as a conflict (OD-27 default)
- [ ] Real ERP data (0.10.0, against field-api in `live` mode): invoice numbers, products and serials, late fees and the ERP receipt numbers match the ERP for 5 customers; returned invoices are not offered for collection
**Camera & media**
- [ ] No gallery option anywhere; watermark correct; size ≤ 250 KB; upload resumes after network loss
**Location (P2)**
- [ ] 9 h duty test (bike + walk) battery ≤ 12 %; persistent notification visible; no points after work-out; tracking resumes after reboot while on duty
- [ ] OEM killing: lock screen for 1 h on Xiaomi/Oppo/Vivo; heartbeat gaps visible in admin if killed
- [ ] Mock GPS app → flagged
- [ ] Attendance photo: front camera opens at work-in, break start, break end, work-out; cancelling records nothing; offline the duty status changes at once and the events reach admin in order with photos after reconnecting
- [ ] Co-work with two phones on staging: A asks B; B sees the invitation after a pull and accepts; both see the group; A records a visit offline with the co-work switch on; after reconnecting B sees it on the customer timeline as "recorded by A", admin shows it as one joint visit with both; B's work-out removes B from A's group
- [ ] Targets on staging: set a personal target in admin → Today shows it after a pull; mark a holiday → "day off"; My performance matches the admin staff report for the month; leaderboard appears only after the admin turns it on
- [ ] Map pin on a real phone (0.8.0): the map pans and pinches smoothly under the fixed pin; the my-location button brings it to the phone; a location shared on WhatsApp pasted in "type coordinates" lands on the right house; for a customer without a location "Set pin" works offline and the pin shows on the map after reconnecting; moving an existing pin shows "waiting for manager approval" and arrives in admin pin approvals with the phone distance; with a photo the proposal arrives after the photo uploads
- [ ] Notices, leave and guarantor (0.9.0) on staging: a notice sent from admin with "must read" shows on Today after a pull; tapping "পড়েছি" in airplane mode shows "will be sent", and after reconnecting the admin recipients list shows the tap time; asking for leave offline says the network is needed; a request approved or rejected in admin shows its reason after reopening Leave; the guarantor call button opens the phone dialer with the guarantor's number and the call shows on the customer timeline as a guarantor call
- [ ] Notification shows on work-in and disappears on work-out; Me tab card says "On · standard"
- [ ] Admin sets `location.trackingProvider = paid` on this build → Me tab shows the fallback note, heartbeat reports it; tracking continues
- [ ] Visit suggestion appears after 5 min at a customer pin; "Not now" hides it for that customer
- [ ] Android 14+: foreground service type `location` accepted (no crash at work-in)
**Tasks & exit (0.12.0)**
- [ ] Back at Today / Customers / Map / Me asks "অ্যাপ বন্ধ করবেন?"; "থাকুন" stays, "অ্যাপ বন্ধ করুন" leaves; back from a customer or task page goes one step back with no question; Android 13+ predictive-back gesture behaves the same
- [ ] Admin gives a task: it shows on Today and Me → আমার কাজ after the next sync; "কাজ হয়েছে" in flight mode says "will be sent", goes out when online, and the admin sees the request; sent back with a reason shows the reason
**Usability & accessibility**
- [ ] Sunlight readability outdoors (high-contrast mode on/off)
- [ ] TalkBack reads Bangla labels and amounts in words
- [ ] All targets ≥ 48 dp (Layout inspector spot-check)
- [ ] One-handed use: Collect, Visit, Promise reachable by thumb on 6.5" device
**Bad tags, Home v2 and Settings (2026-11-26, FR-M-081 to FR-M-084)**
- [ ] Outdoors in sunlight, light and dark mode: the seven tag frames and chips can be told apart, and পলাতক reads as the strongest
- [ ] A tag set on this phone shows its colour at once, also in flight mode; after the next sync it is still the same colour
- [ ] Home on a 360 dp phone: the filter chips scroll sideways with the thumb, stay under the top bar while the list scrolls, and the picked chip is always in sight; each count equals its section and the summary card
- [ ] Overdue filter with 300+ customers scrolls without a stutter on a 2 GB phone; flight mode changes nothing
- [ ] Branch manager login: Home lists the whole branch; the branch switcher narrows it; field staff see only their own and unassigned
- [ ] Quick-action grid: nine equal cells, each opens its screen and Back returns to Home; badges follow unread notices and open tasks; TalkBack reads "নোটিশ: ২টি অপেক্ষায়"
- [ ] Settings: every row opens what it says; language, digits, theme and high contrast apply at once; sign-out is refused while anything is unsent
**Security**
- [ ] App lock after 5 min background; PIN lockout after 5 tries
- [ ] Screenshots blocked on money screens when setting on
- [ ] Rooted/emulator device reported to admin

## 4. Performance budgets
Cold start ≤ 3 s (Redmi 2 GB); customer list of 2,000 scrolls without dropped frames > 5 % (DevTools); Today screen first frame ≤ 500 ms after unlock; APK ≤ 30 MB per ABI; memory ≤ 250 MB.
