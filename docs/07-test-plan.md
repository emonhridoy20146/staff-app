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
| M-E5 | Cash limit: exceed 80 % offline → banner; deposit with slip; verified → on-hand drops |
| M-E6 | Handover incoming accept → new customers appear; outgoing device keeps queued notes until synced |
| M-E7 | Permission `tag.set` revoked → tag action disappears after pull |
| M-E8 | Version gate 426 → update screen, queue intact |
| M-E9 | Promise reminder fires at 09:00 Dhaka (fake clock) offline |
| M-E10 | Work-in → break → over-break reminder → work-out summary lists unsynced items |
| M-E11 | (P2) Tracking only between work-in and work-out; mock provider flagged |

## 3. Manual device checklist (every release candidate)
Devices (minimum set): **Xiaomi Redmi (MIUI/HyperOS, 2–3 GB)**, **Samsung Galaxy A0x/A1x**, **Realme or Oppo (ColorOS)**, **Vivo (Funtouch)**, **one Android 8/9 device**, **one Android 14/15 device**.

**Install & onboarding**
- [ ] Fresh install, permissions primer, "While using the app" location flow works per Android version (no background permission asked)
- [ ] Battery optimisation guide opens the correct OEM settings page
- [ ] Bangla renders correctly everywhere (conjuncts ক্ষ ঙ্গ ন্ত্র, reph, ya-phala, hasanta), no clipped matras at font scale 1.3
**Offline & sync**
- [ ] Airplane mode full day simulation (20 actions), then sync on 2G/EDGE (developer network throttling or real SIM)
- [ ] Network flaps during upload; no duplicates (verify in admin)
- [ ] App force-stopped and phone rebooted with queue → queue intact
- [ ] Storage nearly full → photo capture shows clear error, data still saved
**Money**
- [ ] Collection flow ≤ 15 s for experienced user; amount in words correct for 1, 15, 101, 1,000, 1,00,000, 12,50,500
- [ ] Receipt image shares to WhatsApp and is readable
- [ ] Cash limit warn/block per setting works offline
**Camera & media**
- [ ] No gallery option anywhere; watermark correct; size ≤ 250 KB; upload resumes after network loss
**Location (P2)**
- [ ] 9 h duty test (bike + walk) battery ≤ 12 %; persistent notification visible; no points after work-out; tracking resumes after reboot while on duty
- [ ] OEM killing: lock screen for 1 h on Xiaomi/Oppo/Vivo; heartbeat gaps visible in admin if killed
- [ ] Mock GPS app → flagged
- [ ] Attendance photo: front camera opens at work-in, break start, break end, work-out; cancelling records nothing; offline the duty status changes at once and the events reach admin in order with photos after reconnecting
- [ ] Co-work with two phones on staging: A asks B; B sees the invitation after a pull and accepts; both see the group; A records a visit offline with the co-work switch on; after reconnecting B sees it on the customer timeline as "recorded by A", admin shows it as one joint visit with both; B's work-out removes B from A's group
- [ ] Pin correction at a real door: accuracy reaches ≤ 30 m within 1 min outdoors; photo required; proposal arrives in admin after the photo uploads (also when saved offline)
- [ ] Notification shows on work-in and disappears on work-out; Me tab card says "On · standard"
- [ ] Admin sets `location.trackingProvider = paid` on this build → Me tab shows the fallback note, heartbeat reports it; tracking continues
- [ ] Visit suggestion appears after 5 min at a customer pin; "Not now" hides it for that customer
- [ ] Android 14+: foreground service type `location` accepted (no crash at work-in)
**Usability & accessibility**
- [ ] Sunlight readability outdoors (high-contrast mode on/off)
- [ ] TalkBack reads Bangla labels and amounts in words
- [ ] All targets ≥ 48 dp (Layout inspector spot-check)
- [ ] One-handed use: Collect, Visit, Promise reachable by thumb on 6.5" device
**Security**
- [ ] App lock after 5 min background; PIN lockout after 5 tries
- [ ] Screenshots blocked on money screens when setting on
- [ ] Rooted/emulator device reported to admin

## 4. Performance budgets
Cold start ≤ 3 s (Redmi 2 GB); customer list of 2,000 scrolls without dropped frames > 5 % (DevTools); Today screen first frame ≤ 500 ms after unlock; APK ≤ 30 MB per ABI; memory ≤ 250 MB.
