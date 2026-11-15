# 01 — System Analysis (staff-app's role)

> Whole-system context, contradictions, risks and scale: `field-api/docs/01-system-analysis.md`. This file covers the field app.

## 1. Role
staff-app is the **field staff's only tool**: Flutter, Android APK first, offline-first. It records collections, visits (camera photos), notes, promises, attendance, cash deposits, pin corrections and (phase 2) duty-hour location, and shows the staff's assigned customers with balances from the ERP cache. It talks **only** to field-api (+ FCM, map tiles, presigned storage URLs).

Branch managers may also install it (same app, role-based UI) for field visits; their main tool is admin-web.

## 2. Field reality (design inputs)
| Reality | Consequence |
|---|---|
| Low-end phones (2–3 GB RAM, Android 8–12, 16–32 GB storage, often full) | APK < 30 MB; SQLite; image compression; storage-full handling; no heavy animations |
| Weak/absent network (2G/3G, rural char areas, network drops in buildings) | Local DB is the source for UI; background sync with backoff; small payloads; resumable uploads |
| Motorbikes | Large targets; no typing while moving; tracking samples fast when moving; mount-friendly map |
| Bright sunlight | High contrast default + optional high-contrast mode; 16–17 sp body |
| OEM battery killers (Xiaomi MIUI/HyperOS, Oppo/Realme ColorOS, Vivo FuntouchOS, Samsung) | Foreground service during duty, battery-optimisation guide screen per OEM, heartbeat to detect killing |
| Shared/second-hand phones, risk of misuse | PIN/biometric lock, device binding, encrypted DB, remote logout, root/mock signals |
| Customers watching the screen | Clear amount review, shareable receipt, no internal flags visible to customer on the success screen |
| Staff literacy varies, Bangla-first | Icons + Bangla labels; amount in words; minimal free text; outcome chips |

## 3. What the app stores locally
Assigned customers (with plans, schedule, recent payments, notes, promises, last visits), own collections/visits/notes/promises/attendance/deposits, mutation queue, location queue, media queue, receipt number blocks, settings/permissions/flags snapshot, tile cache. Encrypted (SQLCipher); wiped on logout (after confirming the queue is empty or exported to server), on remote unbind, or after 5 failed PINs (queue preserved encrypted until next successful login of the same user).

## 4. Risks specific to the app
| Risk | Mitigation |
|---|---|
| Queue lost (app uninstall, phone lost) before sync | Sync immediately when online; warn when queue older than 2 h; "unsynced" count on work-out; manager sees device `pendingReported` via heartbeat |
| Duplicate submissions on flaky network | UUIDv7 idempotency per mutation, created once at save time |
| Device clock wrong | Store device time and server offset; server flags skew; business date from server-corrected time |
| Background tracking killed | Foreground service + OEM guide + heartbeat + gap reporting |
| Mock GPS | `isMocked` flag, developer-options check, flagged not blocked |
| Battery drain | Adaptive sampling, activity recognition, stop when off duty |
| Storage full | Check free space before photo; compress; purge synced media after 7 days |
| Old app versions in the field | Version gate (426) + in-app update prompt (Play in-app updates if distributed via Play; else APK link via managed distribution — OD-M01) |
