# Changelog — staff-app

## [Unreleased]

### Changed (owner request 2026-11-26: Home redesign; FR-M-004/005, ADR-M41, tokens v1.2)
- **Home** keeps everything (greeting, duty card, collapsible collected card with the "বিস্তারিত" pill, quick actions, feature cards, promised / due / overdue sections with work rows and Collect, cash warning, broken promises without follow-up) in a clearer hierarchy: a **header** (greeting that wraps instead of being cut, date, sync chip) and a **summary card** — today's collection, target line, a 10 dp bar with "N% পূরণ", and three **KPI tiles** (প্রতিশ্রুতি / আজ দেয় / বকেয়া) in their status colours that scroll to their section (0 shows neutral). Details open in an inner panel.
- One card style (surface, 16 dp corners, hairline border, soft shadow in light mode), 16 / 12 / 32 dp rhythm; quick tiles of one height with a tonal icon; banners use the same corner. A "আজকের কাজের তালিকা" title over the sections; each section header has a toned icon, title and count pill; "N more" is an outlined button.
- **Loading** shows three skeleton work rows (no spinner); empty and error states sit in the same card style. Works at 360 dp and 1.3 text in bn and en, light and dark.
- **Tokens v1.2:** new `shadow.sm` / `shadow.md` (`Shadows` in `core/theme/tokens.dart`, `docs/design-tokens.json`); light only. admin-web shares tokens v1.x and needs the same group (design guide §2).
- Screenshots: `test/screenshots/home_test.dart` → `test/screenshots/goldens/home/` (bn/en × light/dark, full page, 360 dp, 1.3 text, start of day); the before set is in `docs/screenshots/home-before/`. Shared screenshot set-up in `test/screenshots/shot_helpers.dart`.
- l10n: `homeKpiPromised`, `homeKpiDue`, `homeKpiOverdue`, `homeKpiLabel`, `homeWorkListTitle`, `homeWorkListBody`, `homeLoading`, `homeTargetPct`.

### Added (owner request 2026-11-26: pull to refresh everywhere it makes sense; FR-M-079, ADR-M42)
- Audit of every screen and route (`docs/pull-to-refresh-audit.md`). **Added** on Me, Sync centre, Alerts, Today's work, Attendance hub, Receipt, Handovers, Notices, Notice detail, Prospects, Requests, Request detail, Tasks, Task detail and the new background set-up (`syncNow`, or the screen's own read); **already had** Today, Customers, Customer detail, Leave, Work calendar, Cash in hand, Co-work, Performance, Leaderboard (explicit always-scrollable physics added; Leave and Work calendar now wait for the refetch); **not needed** on forms, the collect flow, work-in/out, map, map pin, place move, visit, camera, Settings (local only), OEM guide and the sign-in gates.
- Scrollables use `AlwaysScrollableScrollPhysics`; empty and "not on this phone" states are pullable (`PullableFill`). Shared helper `lib/core/ui/refreshable.dart` (`PullToRefresh`, `syncNowFromPull`).
- Fake API `requestLog`. Test `test/flows/pull_to_refresh_test.dart`: table-driven over every refreshable route — the indicator exists, nothing is fetched until pulled, then the refresh reaches the fake server; real flings on an empty and a short page.
- Goldens re-rendered for the Home redesign and the banner corner.

### Fixed (owner report 2026-11-26: live location froze ~15 min after the app was closed; FR-M-077, ADR-M40, contract 1.49.0)
- The native `LocationTrackingService` now uploads with a **points-only tracking token** (`POST /location/tracking-token`, ≈ 24 h, bound to the device) instead of the 15-minute access token. Dart gets it at duty start, renews it on app open / resume when it expires within 12 h or the server refused it, and passes it with its expiry through `storeTrackingCredentials`; it is cleared on both sides (`clearTrackingCredentials`, keystore) at duty end and logout, so none exists off duty.
- On 401/403 or an expired token the service keeps every point buffered (as before) and its notification turns amber with "লাইভ লোকেশন পাঠানো যাচ্ছে না। অ্যাপটি একবার খুলুন।" (localized, handed over with the token); the next successful upload clears it.
- The tracker waits for today's attendance to load before deciding, so opening the app no longer stops the native service for a moment.
- **Contract 1.49.0** pinned (copy merged from `claude/contract-1-49`): `POST /location/tracking-token` (`issueTrackingToken`, no body, 200 `TrackingToken { token: trk_…, expiresAt }`, every call rotates), and POST /location/points accepts `Authorization: Tracking <token>` — the scheme the native service now sends. `FieldApi.trackingToken`; the fake API issues rotating `trk_` tokens and records them.

### Added (owner request 2026-11-26: background tracking on Android brands; FR-M-078)
- **Background set-up** screen (`/location/background-setup`): why it is needed; 1. ignore battery optimisation (Android's dialog, status pill); 2. the detected brand's (Xiaomi/Redmi/POCO, Oppo/Realme, Vivo/iQOO, Samsung, Huawei/Honor, OnePlus, other) autostart / background steps with a deep link to its settings screen; 3. what runs right now. Pull to read the phone again.
- **On-duty health line**: first on Today (and in the Me tracking card) while on duty and tracking is not running (danger), the token was refused (warning, renewed automatically) or battery optimisation is on (warning); a tap opens the set-up. Never shown off duty. The Me tracking card has a "ব্যাকগ্রাউন্ড সেটআপ" button.
- Native channel: `isTrackingAuthFailed`, `manufacturer`, `clearTrackingCredentials`.
- Tests: `test/flows/tracking_token_flow_test.dart` (duty start, 12 h renewal, refused token, offline keeps the old token, duty end and logout clear, rules, brand mapping), `test/flows/tracking_health_ui_test.dart` (danger and warning lines, set-up screen, nothing off duty).

### Added (owner request 2026-11-24: staff requests, reports and complaints; FR-M-075, ADR-M38, contract 1.48.0, schema 18)
- **New feature `requests`** (flag `module.requests`, permission `request.create`, registered in `lib/app/features.dart`): staff report, tell or ask the office in a traceable way.
  - **New request form** (Me → **আমার অনুরোধ** → "নতুন অনুরোধ", and **"অফিসকে জানান / Tell the office"** on the customer page with the customer filled in and removable): type (অনুরোধ, রিপোর্ট, জানানো, অভিযোগ), who it goes to as two clear choices — **"এরিয়া ম্যানেজারকে"** (`normal`) or **"সুপার অ্যাডমিনকে — খুব জরুরি"** (`important`) —, subject (≤ 160) and details (≤ 4000, sent as `body`), up to 5 **camera-only** photos (existing media queue, watermarked, kind `visit_photo` because 1.48.0 adds no request kind; no gallery). Errors in words; 48 dp targets.
  - **Offline-first:** saved at once and queued as the `request` mutation with its UUIDv7 clientId (never regenerated). With photos the mutation is saved `held` and goes with `photoMediaIds` once every photo is on the server (media owner hook `request`); a photo that cannot upload keeps it held and visible, never sent without it, never deleted.
  - **List:** "আমাকে দেওয়া হয়েছে / Assigned to me" (items the office forwarded or assigned to me, open first) and "আমার পাঠানো / Sent by me" with **খোলা / সমাধান হয়েছে** filter chips; each row shows a status chip (icon + colour + word; waiting to send and refused first), type, recipient, customer, time and "নতুন আপডেট".
  - **Detail:** the whole timeline (1.48.0 `timeline`: sent, forwarded to a queue or a person, assigned, comments, status changes, resolved with the note, reopened, closed) with who and when; where it is now (the person, or the area manager / super admin queue) and the resolution note. **Comments** are saved at once and sent as the `request_comment` mutation (`requestId`, or `requestClientId` with `dependsOn` while the request is unsent), shown "waiting to send" until the server's timeline holds the same clientId; none on a refused or closed request (a resolved one still takes them, as the server does).
  - **Reopen:** on my own resolved or closed request, "আবার খুলুন / Reopen" asks for a reason (required, ≤ 1000) and calls `POST /requests/{id}/reopen` — **online only** (1.48.0 has no sync mutation for it, ADR-M08); offline it says so and nothing changes; the answer is stored like a pull.
  - **Notifications:** a step by someone else after I last opened the request (forwarded, assigned, comment, resolved, reopened) is an alert behind the bell (existing `alertSources` flow): "আপনার অনুরোধে আপডেট / নতুন মন্তব্য / সমাধান হয়েছে / আপনাকে দেওয়া হয়েছে", opening it clears it; my own steps are never news. The Me entry shows the count.
  - Refusals stay visible with their reason in words (and in Problems as "other"); a pull never deletes a request with something of mine unsent.
- **Schema 18:** tables `staff_requests` and `request_comments` plus index `idx_staff_requests_created`, created only when missing; migration test from 17 (and every older schema through the drop chain).
- **Contract 1.48.0** (copy merged from `claude/contract-1-48`, field-api main 360ce85): `request` (`RequestCreate`) and `request_comment` added to `SyncMutation.entities`; pull entity `request` (`Request` with `timeline`, `currentQueue`, `level`, `assignee`; a request no longer given to me arrives as a delete, which never removes anything of mine unsent); `FieldApi.reopenRequest`; `Perm.requestCreate`. Statuses `open`, `in_progress`, `forwarded`, `resolved`, `closed`, `reopened`; unknown types, statuses and timeline kinds are shown as their key.
- Fake API like field-api 1.48.0: strict `RequestCreate` (photos must be uploaded first), replay by clientId, comments by `requestId` or `requestClientId`, REQUEST_CLOSED, `POST /requests/{id}/reopen` (REQUEST_OPEN, note required); office hooks `forwardRequest` (queue or person), `assignRequest` (`in_progress`), `commentOnRequest`, `resolveRequest`, `closeRequest`, `addRequestForMe`, `refuseRequests`; `module.requests` on in the demo.
- Tests: `test/features/requests_rules_test.dart` (rules, payload, timeline merge, news, given-to-me, comment rules), `test/flows/requests_flow_test.dart` (offline create + comment sent once in order, photos held then sent with ids, photo failure keeps it held, office forward/comment/resolve/close on timeline and bell, reopen online only, given to me, refused, no delete while unsent; screens in bn and en at 1.3 text scale, customer page prefill, reopen dialog, flag/permission gate), `test/core/migration_test.dart`.

### Fixed (owner report 2026-11-24: "account blocked" until the office approved the phone; FR-M-074, ADR-M37, ADR-M25 amendment)
- **Login refusals have their own words** instead of all reading "Account locked. Contact your branch manager.", read from the server's problem `code`:
  - 403 `DEVICE_NOT_APPROVED`: "এই ফোনটি নতুন। অনুমোদনের অনুরোধ অফিসে পাঠানো হয়েছে। ম্যানেজার অনুমোদন দিলে আবার লগইন করুন।" as an info banner (not an error) with an "আবার চেষ্টা / Try again" button (48 dp).
  - 423 `ACCOUNT_LOCKED`: "অনেকবার ভুল পাসওয়ার্ড। <time> এর পর আবার চেষ্টা করুন।" with `details.until` in Dhaka time via `core/format` (date added when it is not today; "a little later" without a time).
  - Another user's unsynced data on the phone: its own message telling that user to sign in and send it (nothing deleted).
  - Any other 403: "Can't sign in (code: …)".
- **Contract 1.47.0** (copy merged from field-api main): 423 `details.scope: ip` reads "এই নেটওয়ার্ক থেকে অনেকবার ভুল চেষ্টা হয়েছে। <time> এর পর আবার চেষ্টা করুন।" (the network is locked, not the account); `details.retryAfterSec` gives the time when `until` is missing; 403 `details.pendingDeviceId` is shown as "অনুরোধ নম্বর / Request number" under the banner, so the office can find the request (a retry keeps the same pending request).
- `LoginError` gains `deviceNotApproved`, `otherUserUnsynced`, `forbidden`; `LoginFailure` carries `code` and `until`. l10n: `loginErrorLocked` now takes `{time}`; new `loginErrorLockedNoTime`, `loginErrorLockedIp`, `loginErrorLockedIpNoTime`, `loginDeviceRequestId`, `loginDeviceNotApproved`, `loginRetry`, `loginErrorOtherUserUnsynced`, `loginErrorForbidden`.
- **Device id (FR-M-060, ADR-M25):** unchanged behaviour, moved into `DeviceIdentity.resolveDeviceId` so it is tested: a reinstall with the same ANDROID_ID gives the same id; an update keeps the stored id. **Known one-time case:** a phone that ran a build from before ADR-M25 (random id) and is then uninstalled and reinstalled with a newer build needs one approval; after that, reinstalls keep the id as long as the release signing key stays the same (ANDROID_ID on Android 8+ depends on the signing key, ADR-M26).
- Fake API hook `loginRefusal`. Tests: `test/features/login_errors_test.dart` (every mapping, bn/en words, Dhaka midnight, the unsynced-user case, login screen in bn and en with info state and retry, lock as danger banner, 1.47.0 details). The login widget tests unmount and dispose the container before closing the database, so teardown no longer hangs on drift stream queries left in the fake-async zone. `test/core/device_identity_test.dart`.

### Changed (contract 1.45.0/1.46.0 pinned; items FR-M-070, 072, 073 aligned)
- Contract copy `docs/contract/openapi.yaml` → **1.46.0** (field-api main, merged from `claude/contract-1-45`; 1.46.0 is additive: customer list paging). 1.45.0 also accepts an offset-less `capturedAt` (read as Asia/Dhaka); the app sends UTC anyway.
- **attendanceRequired** is top level on login, refresh, `/auth/me` and sync (permission `attendance.exempt`); the refresh answer now updates it too.
- **Promises:** the server's `followUpId` is stored (`promises.follow_up_id`, schema 17): a broken promise someone else (e.g. a colleague) already followed up is not on Home and has no follow-up action.
- **Possible customers aligned with 1.45.0:** the `prospect` mutation is `ProspectCreate` only (idempotent by clientId; numbers sent as `{number}`, stored by the server as `+8801…` and shown as `01…`; no unknown fields). Staff have **no edit once it is sent** (`PATCH /prospects/{id}` needs `prospect.manage`), so "change my own" works only while the create has never been tried: the queued payload is rewritten with the same clientId, never a second mutation. Statuses `new`, `contacted`, `converted`, `dropped`; limits name 120, phones 5, address 500, note 1000. Permissions `prospect.create` (Me entry) and `prospect.view` added to `Perm`. `module.prospects` is off by default on the server.
- Tests: `prospects_flow_test.dart` (payload shape, +880 numbers back as 01…, rewrite before sending, refused after, `dropped`), `promise_follow_up_test.dart` (followed up by someone else).

### Added (owner request 2026-11-23: possible customers; FR-M-073, ADR-M36, contract 1.45.0, schema 17)
- **New feature `prospects`** (flag `module.prospects`, registered in `lib/app/features.dart`): Me → **সম্ভাব্য গ্রাহক / Possible customers** lists every prospect on the phone with its status (নতুন, যোগাযোগ হয়েছে, গ্রাহক হয়েছেন, বাদ দেওয়া হয়েছে; unknown shown as sent), who added it and when, "waiting to be sent", and a refusal in words. **Add** opens a form: name, 1–5 mobile numbers (Bangla digits, `+880`, dashes accepted; cleaned to `01XXXXXXXXX`; repeats refused), address and note (optional), and **"এখন যেখানে আছি তা সংরক্ষণ"**, which can be turned on only while on duty (off duty it is disabled with the reason, and the service drops any fix; CLAUDE.md §2.6).
- **Offline-first:** saved at once and queued as the `prospect` mutation (`ProspectCreate`) with its UUIDv7 clientId. My own can be changed until it is sent (the queued payload is rewritten, same clientId). A refusal stays visible with its reason in words. Nothing unsent is deleted by a pull.
- **Schema 17:** table `prospects` (created only when missing) in the same v17 step; migration test.
- `prospect` added to `SyncMutation.entities` (contract 1.45.0); permissions `prospect.create` / `prospect.view`. The server keeps `module.prospects` off by default.
- Fake API: `prospect` create like field-api 1.45.0 (strict fields, numbers stored as `+8801…`, replay by clientId), `setProspectStatus` hook; `module.prospects` on in the demo. `normalizeMobile` is exported from the customers barrel.
- Tests: `prospects_flow_test.dart` (rules, offline create sent once with cleaned numbers and no location off duty, on-duty location, change before sending, none after, the office's status, Me → list → form with the disabled location switch, error in words, 48 dp save), `migration_test.dart`.

### Added (owner request 2026-11-23: follow up a broken promise; FR-M-072, ADR-M35, contract 1.45.0, schema 17)
- **"নতুন প্রতিশ্রুতি (ফলো-আপ) / New promise (follow-up)"** on a broken promise ("কথা রাখেননি") on the customer page's timeline. It opens the promise sheet titled as a follow-up, with "<date> তারিখের <amount> এর ভাঙা প্রতিশ্রুতির ফলো-আপ · চেষ্টা N". The promise is saved offline-first through the same `promise` mutation (one UUIDv7 clientId, never regenerated) with `followUpOf` = the broken promise's server id (or its clientId with `dependsOn` while unsent). A plain new promise on a customer with an unfollowed broken promise is linked the same way.
- **Chain:** every promise in a chain shows "চেষ্টা 1, 2, 3 …" on the timeline (the phone counts until the server's `attempt` arrives).
- **Home:** a "ভাঙা প্রতিশ্রুতি: ফলো-আপ করুন" card lists broken promises nobody has followed up (customer, amount, due date, the action; 48 dp), oldest due first; nothing when there are none.
- **Schema 17:** `promises.follow_up_of`, `promises.attempt` (default 1), in the same idempotent v17 step as the photo columns; migration test with a broken promise.
- `PromiseService` (Ref-based) holds the save logic so it is tested without widgets; `recordPromise` calls it. Fake API: `breakPromise(mutationId)` and the server's attempt count.
- Tests: `promise_follow_up_test.dart` (offline follow-up with the link in the outbox and once on the server, a plain promise following up, chain 1→2→3, open needs none, Home card and customer page on screen), `migration_test.dart`.

### Changed (owner request 2026-11-23: super admin gives no attendance; FR-M-070, ADR-M34, contract 1.45.0)
- The server's `attendanceRequired` (1.45.0, read from login, `/auth/me` and the sync snapshot; missing = true for older servers) is kept on the phone (`attendanceRequiredProvider`, `kv` `attendance_required`). When it is false (super admin): no duty card and no attendance tile on Home, no attendance card in Me, the attendance screen shows only "আপনার অ্যাকাউন্টে হাজিরা দিতে হয় না" (no work-in, even by a link), and today's attendance is never fetched from the server. One provider (`attendanceShownProvider`: module flag, `attendance.record`, required) decides everywhere. `MeEntryDef` gets an optional `visible` condition.
- Fake API hook `attendanceRequired` (null = not sent). Tests: `attendance_required_test.dart` (where the field may sit, older server, super admin, snapshot change, Home/Me/hub on screen, field staff unchanged).

### Added (owner request 2026-11-23: leaderboard easier to find; FR-M-071)
- While `reports.leaderboardVisibleToStaff` is on, the Me tab has its own **লিডারবোর্ড / Leaderboard** entry ("এই মাসে কে সবচেয়ে বেশি আদায় করেছেন"), besides the line in the Performance card. Off: nothing, as before. Test: `me_leaderboard_test.dart`.

### Fixed (owner report 2026-11-23: photos stayed "upload pending" and never reached the server; FR-M-069, schema 17)
- **Cause:** `POST /media/upload-url` sent `capturedAt` as `m.capturedAt.toIso8601String()`. drift reads a `DateTime` column back in **local time**, so on a phone in Dhaka this went out as `2026-11-23T16:00:00.000`: no `Z`, no offset. That is not an RFC 3339 `date-time` (contract `capturedAt: { format: date-time }`), and field-api answered **400 `VALIDATION_FAILED`** at the very first step (presign). The PUT and the confirm were never reached, the row went to `failed`, was retried with backoff and failed the same way forever: every attendance selfie, visit photo, pin photo and bank-deposit slip. The error was swallowed (`catch (_)`), so nothing on the phone said why. A test reproduces it (`test/flows/media_upload_test.dart`, "the cause"); the fake API now validates the presign like the server and the four existing photo flow tests failed against it before the fix.
- **Fix:** `capturedAt` is sent as UTC (`…Z`). Also hardened, each with a test: a relative `uploadUrl` (`/api/v1/storage/o?t=…`, field-api's own store) is resolved against the API origin instead of being glued to `/api/v1` by dio; the body is sent as bytes with `Content-Type: image/jpeg` and the exact `Content-Length`, no bearer token, 2-minute send/receive timeouts; photos upload after **every** sync that reached the server, not only after a fully successful one (one server error in a pull held every photo back); a Retry while an upload run is going is queued, not dropped.
- **Queue visible (sync centre):** every photo not yet on the server is listed with its kind (attendance photo, visit photo, deposit slip, pin photo), when it was taken, its state ("waiting to upload" / "not uploaded yet: <reason>") and, for a failed one, how many tries and when it tries again, with **Retry** on each and **Upload all now**. Reasons in words (bn/en) with the step: no connection, network too slow, file no longer on this phone, office deleted the photo (`MEDIA_DELETED`), server did not accept the details (`VALIDATION_FAILED`), upload link refused or expired (403), server did not receive the photo (confirm before upload), server not answering (5xx), else the server's code. Nothing is deleted (CLAUDE.md §2.3).
- **Schema 17:** `media_queue.last_error` (`<step>:<code>`) and `media_queue.last_attempt_at`, nullable; idempotent migration step; migration test from schema 16 with a queued failed photo.
- Fake API answers media like field-api 1.40+ (`storage: cloudinary`/`db`): presign validated (enums, size ≤ 1 MiB, lowercase hex sha256, RFC 3339 `capturedAt`), 201 with a signed `/api/v1/storage/o?t=` URL, the PUT checked against the signed type, size and sha256 (no token needed), confirm 409 `INVALID_STATE` before the bytes arrived. Test hooks `relativeUploadUrl`, `presignBodies`, `storagePuts`.
- Tests: `test/flows/media_upload_test.dart` (the cause, presign → PUT → confirm with headers, relative URL, refused upload with reason + backoff + Retry, offline, missing file, reasons in bn/en, sync-centre list with a 48 dp Retry that uploads), `migration_test.dart`.

### Fixed (owner report 2026-11-23: customer page showed the pin icon with no address; FR-M-005)
- **Cause:** the address line was shown whenever `customers.address` was not null. field-api maps a missing ERP address to `""` (`address: c.address ?? ''`), so a customer whose ERP address is blank got the pin icon with nothing beside it. The detailed address was only shown under a non-blank address.
- **Fix:** `Customer.address` is the ERP address, or the ERP detailed address when it is blank, or the area. The line is always shown. With none of them it reads "ERP তে ঠিকানা নেই / No address in the ERP". A detailed address equal to the shown one is not repeated. Test: `test/features/customer_address_test.dart`.

### Changed (owner request 2026-11-23: pages must not reload every few minutes)
- **Foreground sync every 15 minutes** (was 5) and only when the phone has a network. Saved work still goes out at once (each use case kicks a sync); network-back and pull-down still sync immediately.
- **Resume no longer syncs every time:** coming back from the camera or a call syncs only when the last good sync is 15 minutes old or failed.
- **Distance fix every 15 minutes** (was 2) while on duty. Each new fix re-sorted the near-me lists, which looked like a reload.

### Changed (owner requests 2026-11-23: customer list and Home)
- **Customer list rows use the Home row** (`CustomerWorkRow`) in four lines, with no Collect button. Line 2 also shows the invoice type label and the distance. At the right of the marks is a 40 dp tonal arrow (`OpenDetailsArrow`) that says the row opens the details. The Home rows are unchanged.
- **"আজকের আদায়" card is compact:** it shows the amount, the target and its bar. A tap opens the visit target, cash / mobile / visits and the cash meter. A "বিস্তারিত ▾ / লুকান ▴" pill (`core/ui/expand_hint.dart`) says it can be opened. The **duty card** uses the same pill in place of the bare chevron. At 130 % text the pill and the target pills shrink instead of overflowing.
- Tests: `customers_home_ui_test.dart` (arrow on list rows, no Collect in the list, card opens and closes), `customer_search_keyboard_test.dart` and `places_screens_test.dart` (130 %) updated for the new row.

### Fixed (customer reload said "Code: VALIDATION_FAILED"; owner report 2026-11-23, FR-M-063)
- **Cause:** the reload button and pull-down send `POST /api/v1/customers/{id}/refresh`, which has no request body in the contract (1.43.0: only the `id` path parameter, no query, no `requestBody`). dio's base options set `contentType: application/json` for every request, so it went out with `Content-Type: application/json`, `Content-Length: 0` and an empty body. An empty string is not a JSON document, and field-api's strict JSON parser answered 400 `VALIDATION_FAILED`. The path, the id and the (absent) query were right.
- **Fix:** `ClientHeadersInterceptor` drops the content type of a request that has no body (`lib/core/network/dio_client.dart`). This fixes every body-less POST the same way (`/auth/logout`, `/handovers/{id}/accept`, `/cowork/sessions/{id}/leave`, `/leave-requests/{id}/cancel`). Requests with a body still say JSON.
- Test: `test/core/body_less_post_test.dart` (a fake adapter that answers like the strict server; fails on the old code).

### Added (contract 1.44.0: cash sales and who did this month's work; FR-M-066, FR-M-068; schema 16)
- **Cash sales** (contract 1.44.0 `Plan.kind: cash`, now pinned): get their own label, "নগদ / Cash" (primaryContainer chip), so a row can read "১ কিস্তি · ১ নগদ". The plan card says "নগদ বিক্রি" with the sale date instead of a due date, without installments or frequency. A cash plan has no schedule; its status is `completed` when paid and `closed` while money is still owed (not "returned"). It counts on the label until cancelled, counts in the invoice total and is never open, due, overdue or collectable. The Installment and Credit chips are unchanged; cash-only customers are in "All" and are found by search. An unknown `kind` is stored as sent and treated like cash, as the contract asks. Before this change, the installment count used `kind != 'credit'` and would have counted cash sales as installments.
- **Who did this month's work, from the server:** the customer pull stores `activity` (`visitedBy`, `paidBy`, `promisedBy`, `lastVisitByName`, `lastPaidByName`, plus the list row's `lastVisitByName`) in `customers.activity_json`, and `Payment.referrerName` in `erp_payments.referrer_name`. "এই মাসে" shows the newest name with "+N" for the others. An office payer without a name reads "অফিস". Field money not yet in the ERP (`pending`) is named on the "ERP-তে অপেক্ষমাণ" line and is never added to the paid amount. Last month's activity is ignored. Without these fields (a server older than 1.44.0), the names on the phone are used as before; an office payment names its ERP referrer first.
- **Schema 16:** two nullable columns (`customers.activity_json`, `erp_payments.referrer_name`); the migration step is idempotent. Migration test from schema 15, and every older migration test now drops the new columns too.
- Contract copy `docs/contract/openapi.yaml` → **1.44.0** (field-api main). The list row's `lastVisitByName` (any month) is kept apart as `rowLastVisitByName` and is only a last fallback.
- Tests: `invoice_kinds_test.dart` (kind mapping, cash counted until cancelled, never collectable, its `closed` not "returned", unknown kind as cash, label texts, server activity first with "+N", office payer and pending, last month ignored, referrer vs collector), `work_marks_test.dart` (cash in the invoice total, never open), `migration_test.dart`.

### Added (owner requests 2026-11-23: customers and Home; FR-M-066, FR-M-067, FR-M-068)
- **Installment / credit-sale chips** on the customer list: "কিস্তি / Installment" and "বাকি বিক্রি / Credit sale" start the chip row, followed by a divider and then the status chips. One type at a time; tap it again to clear. They combine with the status chips by AND (বকেয়া + কিস্তি = overdue customers with an open installment invoice), and a customer with both kinds matches both. Every chip's number is what tapping it would show. The open invoices per kind come from `plans.kind` and are counted in the customers repository's SQL (correlated subqueries in `watchAll` / `watchOne`), never in widgets. No schema change.
- **Type label on each row** (`InvoiceKindLabel`, token chips: installment on secondaryContainer, credit on tertiaryContainer): "কিস্তি" or "বাকি" for one open invoice, counts per kind for several ("১ কিস্তি", "২ বাকি"; TalkBack "খোলা ইনভয়েস: ১ কিস্তি · ২ বাকি"). The **customer page header** shows the counts at the right of the name.
- **"এই মাসে" says who:** "ভিজিট: <name> · <date>", "পরিশোধ: <amount> · <collector>", "প্রতিশ্রুতি: <amount> · <name> · <date>", using names already on the phone: own visits and promises are the user, colleagues' come from `colleague_activities`, payments use `ErpPayment.collectorName`, promises use `createdByName`. A name the phone does not have is left out. The visitor and payment-referrer names are not in contract 1.43.0 and have been asked for in 1.44.0 (`monthPeopleProvider`, `domain/month_people.dart`).
- **Back button** on the customer page (`AppBackButton`): 48 dp tonal circle (secondaryContainer), 28 dp arrow, ink ripple on press.

### Changed (owner requests 2026-11-23)
- **Home row** (`CustomerWorkRow`) replaces the customer tile on Today, in four lines: name with only the amount at the far right; branch and the open invoices' numbers; larger work marks (32 dp, 20 dp icons) with a tonal **আদায় / Collect** button at the right (48 dp, icon and word); "N মাস M দিন বকেয়া". A row with an open promise adds "প্রতিশ্রুতি নিয়েছেন: <name>" when the maker is known.
- **No floating Collect button on Home.** Each row has its own Collect. The unused `todayCollectFab` string is removed.
- **Online / offline mark moved to the top bar** (`OnlineDot`, just left of the GPS icon, on every tab). The strip above the bottom navigation (`OnlineStrip`) is removed.
- Tests: `test/features/invoice_kinds_test.dart` (AND rules, SQL counts and invoice numbers, who-did-it rules, promise maker), `test/flows/customers_home_ui_test.dart` (Overdue + Installment, row labels and TalkBack, header counts, back button size, tonal colour and pop, Home row layout with Collect and "promised by", no FAB), `customer_list_reload_test.dart` (online mark in the top bar, left of GPS, not at the bottom).

### Changed (owner decision 2026-11-22: the office moves a place at once, offline too; FR-M-063, master FR-PLC-003, ADR-M30, contract 1.43.0)
- **"সরান / Move" for office users:** a holder of `place.manage` (super admin, branch manager; from the server snapshot, new `Perm.placeManage`) sees "সরান" instead of "সরাতে বলুন" on any place, also while a request is open. The move screen has no reason field and saves with "এখানে সরান".
- **Offline-first:** the marker moves on the phone at once and `place_edit` with `location` is queued (`PlaceService.moveNow`; contract 1.43.0, field-api ADR-055). No "waiting for the office" state; the server closes any open request. The row remembers the server's point (`moveState = moved`, `moveLat`/`moveLng`; no schema change) and a pull keeps my point while it is unsent. A place I made offline can be moved before it is sent (`placeClientId`, after the create).
- **Refusals:** the marker goes back to the server's point at once and the item is listed in **Problems** with the place name and the reason in words (`OUTSIDE_BANGLADESH`, `PLACE_DELETED`, new `MOVE_NEEDS_MANAGE`, …; bn + en). Problems now names place items "ম্যাপের জায়গা / Map place".
- **Field staff: no change** — "সরাতে বলুন" still sends a `place_move_request` that the office approves.
- Contract copy `docs/contract/openapi.yaml` → **1.43.0** (from field-api main). **Needs field-api 1.43.0** for office moves; an older server would refuse them (they come back with the reason).
- Fake API follows 1.43.0: `place_edit` with `location` (place.manage only, `MOVE_NEEDS_MANAGE`, outside Bangladesh, `PLACE_DELETED`, closes an open request, same point is a no-op, unknown fields `VALIDATION_FAILED`); `placeManager` and `officeMovesPlace` test hooks.
- Tests: `places_flow_test.dart` (moves at once offline with only a `place_edit` queued, a pull keeps my point, closes an open request, a refused second move goes back, field staff refused with `MOVE_NEEDS_MANAGE`, removed place, a place made offline), `places_screens_test.dart` ("সরান" for office users offline with the row moved and `place_edit` queued, field staff still see "সরাতে বলুন", the refusal in Problems in words).

### Fixed (bank deposits were always refused; FR-M-065, ADR-M29)
- **A bank deposit now carries a photo of its slip.** field-api refuses a bank deposit without `slipMediaId` (`SLIP_REQUIRED`), and the app never sent one, so every bank deposit ended in Problems. When **Bank** is chosen on the deposit sheet, a warning asks for the slip and **জমা দিন / Deposit** stays disabled until a photo is taken with the camera (no gallery). The photo shows on the sheet (Retake), on the confirm and as a thumbnail in the deposit history.
- **Offline-first:** the slip goes through the media queue (kind `deposit_slip`: presign, PUT, confirm) and the deposit is saved in the same transaction with its mutation `held`; the collections lock at once as before. When the slip is confirmed, the new `deposit` media hook releases the deposit with `slipMediaId` and starts a sync. A bank deposit is never sent without its slip. The existing column `deposits.slip_media_client_id` now holds the slip's media id; no schema change.
- Branch cashier and manager deposits need no slip and are unchanged (not held, no `slipMediaId`).
- If the server still answers `SLIP_REQUIRED`, Problems now says "the server got no slip photo for this bank deposit; deposit again and take a photo of the slip, or deposit to the branch cashier or the manager" (bn/en).
- New `MediaService.localBytes` reads a queued photo back for thumbnails.
- Tests: `deposit_flow_test.dart` (bank without slip is not saved; with slip it is held until the photo uploads, then sent with the server's media id; a second confirm changes nothing; cashier deposit unchanged; server `SLIP_REQUIRED` in words), `deposit_slip_sheet_test.dart` (button disabled until the photo, slip on the confirm, manager needs none, history thumbnail), `deposit_confirm_test.dart` (slip on the confirm). The deposit flow tests now wait for a background sync before closing the database.

### Changed (CI, owner decision 2026-11-22)
- **A pull request builds the APK only when it can break the Android build:** `pubspec.yaml`/`pubspec.lock`, `android/`, `config/`, the workflows or build config (new `changes` job, plain `git diff`, no third-party action). Other pull requests run the tests only, about 8 minutes faster; a skipped `apk` job counts as passed.
- **Main always builds the APK** and publishes the numbered test release, as before. New **"Run workflow" button** (`workflow_dispatch`) builds an APK from any branch on demand (published as a release when run on main). The release-key guard is unchanged.

### Changed (owner decisions 2026-11-22: places on every map, Google-Maps-style zoom, all branches, Galachipa default; FR-M-063, ADR-M28, contract 1.42.0)
- **Places show on every map:** the customer map, the **pin-setting screen** (set/move a customer's pin) and the place-move screen. On the pin screen they are landmarks for reference only: not tappable, a tap still moves the pin. The `mapLayers` extension point now serves every map: `MapLayerDef.layer` gets a `MapLayerMode` (`interactive` | `reference`), and maps list the layers through the new `mapLayersProvider` (`lib/core/map/map_defaults.dart`, flag + permission), so customers never import places.
- **Marker by zoom** (`placeIconMinZoom` = 13, `placeLabelMinZoom` = 16 in `places_ui.dart`): below 13 no places at all; 13–15.9 only a small **24 dp rounded square** with the kind's icon; 16 and up the square with the name next to it. Replaces the 40 dp round marker whose name was always shown. Where tappable the target stays 48 dp.
- **No branch on a new place:** the add-place sheet never had a branch field; a new place is now also saved on the phone without a branch, and the `place` mutation sends no `branchId` (contract 1.42.0: optional on create, lists and pulls return all branches' places). All staff see all places.
- **Default map centre: Galachipa upazila, Patuakhali** (22.164, 90.426, zoom 12) — `defaultMapCenter` / `defaultMapZoom`, used by the customer map (when there is no GPS fix and no pinned customer) and the pin screen (when the customer has no pin and the phone no fix). Was Barishal at zoom 14 in two separate constants.
- Tests: `test/features/place_marker_zoom_test.dart` (thresholds; zoom 12 nothing, 14 icon only with a 20–24 dp square and 48 dp target, 17 icon + name, dark; reference mode not tappable; 130 % text), `map_pin_screen_test.dart` (places on the pin screen, name shown, tap goes to the map), `places_screens_test.dart` updated for the zoom rule.
- Contract copy `docs/contract/openapi.yaml` pinned to **field-api 1.42.0** (ADR-054: `branchId` on create is ignored; list, pull and bootstrap return every branch's places; phones from before 1.42.0 get a one-time 410 `CURSOR_EXPIRED` resync, which the sync engine already handles). Screenshot goldens 07/14/16 are not re-rendered here (rendered in CI on Linux; review the diff).

### Fixed (office users' pins; master FR-CUS-020, contract 1.39.0)
- **An office user's pin is set at once, and the app now says so.** Since field-api 1.39.0 a user who holds `customer.location.approve` for the branch (super admin, branch manager) sets a customer pin directly, whatever `customers.staffPinApproval` says and whether or not the customer had a pin. The pin screen used only the policy, so such users saw "Send for approval" and "waiting for manager approval". Now, when the server snapshot holds that key (`canApprovePinsProvider`, via `accessProvider`/`Perm.customerLocationApprove`): the button is "পিন বসান / Set pin", the snackbar is `pinSentApplied`, the note is the new `pinWillApplyApprover` ("You can approve pins: the pin is set as soon as it is sent") instead of "A manager checks the new pin", and the customer line shows `pinApplyWhenSent` while the pin is unsent. A mocked phone location still waits, as on the server. Field staff see no change.
- The push result `approved` already marks the proposal approved, which removes the waiting line; now covered by a test.
- Fake API follows 1.39.0 (`pinApprover`). Tests: `pin_rules_test.dart` (approver vs field staff), `pin_correction_flow_test.dart` (approver moves a pin under `always` → approved, nothing left waiting; field staff → pending), `map_pin_screen_test.dart` (approver and field staff button, note and snackbar).

### Added (owner request 2026-11-22: names on the map; master FR-PLC-001..006, FR-M-063, ADR-M27, contract 1.38.0, schema 15)
- **Places on the map.** OpenStreetMap has few names here, so staff put their own: **long-press the map** → a sheet asks the name (required, ≤ 60), the kind (ten chips with an icon: দোকান, বাজার, মসজিদ, স্কুল, ব্যাংক, হাসপাতাল, বাস স্ট্যান্ড, অফিস, চিহ্ন, অন্যান্য) and an optional note (≤ 200). The place shows at once, **with its name always written next to its icon**; everyone of the branch gets it on their next sync.
- **Tap a place:** what it is, the note, who added it ("আপনি এই জায়গাটি যোগ করেছেন" for my own), "saved on the phone" while unsent, a move waiting for the office, the office's last decision with its reason, and a refusal in words. **Edit** only for places I added; **Ask to move** (সরাতে বলুন) for any place: the map moves under a fixed pin, the distance is shown, optional reason, "Send to the office". The marker stays where it is until the office approves; one request at a time (warning-coloured marker while it waits).
- **Offline-first:** new table `map_places` (schema 15); outbox kinds `place`, `place_edit`, `place_move_request`. A change or move of a place not sent yet names it by my `placeClientId` and waits for its create (`dependsOn`); the server id comes back with the push result and the next pull matches the row by clientId, so the place keeps its local id. Pull entity `place` (bootstrap snapshot = the branch's places); a removed place leaves the phone unless something of mine for it is still unsent. Refusals (`NOT_OWNER`, `MOVE_PENDING`, `MOVE_TOO_SHORT`, `OUTSIDE_BANGLADESH`) stay on the place with their reason.
- New extension point `mapLayers` (`MapLayerDef`): a feature draws a layer on the customer map and may take the map's long-press; the map screen renders layers by flag and permission. Feature `places` behind flag `module.places`, permissions `place.view`, `place.create`.
- Fixed on the map screen (found by the new widget tests): the map/list toggle and the sync chip overflowed by 88 px on a 412 dp phone (they now wrap), and the "N without location" chip overflowed at 130 % text.
- Fake API follows 1.38.0 (place mutations and their refusals, `addPlace`, `decidePlaceMove`, `deletePlace`).
- Tests: `places_flow_test.dart` (offline create + edit before sending, server id back, move request → reject with reason → approve, refusals, unsent work survives a removal), `places_screens_test.dart` (labels, long-press sheet with validation, own vs colleague's actions, 48 dp markers, move screen, 130 % text), migration test from schema 14.
- Contract copy `docs/contract/openapi.yaml` stays at **1.41.0** (from main; it includes the 1.38.0 places part). **Needs field-api 1.38.0 or later** and `module.places` turned on by the owner; with the flag off nothing shows.
### Added (owner request 2026-11-22: visit outcome "Runaway"; FR-M-064, master FR-VIS-006, contract 1.41.0)
- **New visit outcome "পলাতক / Runaway"** (the customer has absconded) in the visit outcome picker, after "Customer died". Its label and running-person icon (`directions_run_rounded`) show wherever a visit outcome is shown: the customer timeline, Today's Work and other staff's activity.
- Sent as `outcome: runaway` in the `visit` mutation (and accepted by `visit_checkout`'s optional `outcome`); field-api adds `runaway` to `VisitOutcome` in contract 1.41.0. The local `visits.outcome` and `colleague_activities.outcome` columns are plain text, so no schema change. An older server refuses the value and the visit stays in Problems until field-api 1.41.0 is live.
- A visit outcome the app does not know yet now shows as its code instead of "Other" (contract 1.41.0 rule for clients).
- Contract pinned at field-api 1.41.0 (`docs/contract/openapi.yaml`).
- Tests: `test/features/visit_outcome_test.dart` (in the picker, bn/en labels, own icon, unknown value shown as its code).

### Fixed (owner report 2026-11-22: customer search under the keyboard; branch names too big)
- **Customer search with the keyboard open:** a large blank band covered the filtered customers. Cause: the app shell (`lib/app/shell.dart`) rebuilt the tabs' `MediaQuery` from its own context, above its `Scaffold`, which put the keyboard inset back after the shell had already made room for it, so each tab's `Scaffold` shrank for the keyboard a second time. The shell now reads the `MediaQuery` inside its body (a `Builder`), so the list fills the space between the search field and the keyboard and scrolls. This applies to every tab.
- **Branch picker in the top bar:** branch names use `labelMedium` (was `titleSmall`), one line with "…" when long; picker rows keep the 48 dp target (`Sizes.minTarget`).
- Test: `test/flows/customer_search_keyboard_test.dart` (keyboard open via `tester.view.viewInsets`: a filtered row lies below the field, above the keyboard, the list reaches the keyboard, and the row is hit-testable).

### Added (owner request 2026-11-22: reload on the customer page; FR-M-063, ADR-M27)
- **Reload button and pull-to-refresh on the customer page.** Both ask the server for this customer now (`POST /customers/{id}/refresh`, already in the contract): ERP balance, invoices, installment lines and payments are stored like a pull, then a sync runs so queued work goes out. The top-bar button turns into a spinner while it runs. Messages (bn/en): "সার্ভার থেকে হালনাগাদ হয়েছে / Updated from the server"; offline "ইন্টারনেট লাগবে। ফোনে রাখা তথ্য দেখানো হচ্ছে। / Needs internet. Showing the data saved on this phone."; ERP busy (503/429); no longer yours (404, the phone's data is kept); no permission (403); otherwise the error code.
- Nothing unsynced is touched: the answer goes through the same `customer` pull handler as sync (pending field amounts and numbers typed on the phone are kept); the outbox is not changed.
- Fixed: on a narrow phone in English the "This month" card's title row overflowed when the invoice count line was long; the count now wraps.
- Fake API counts `customerRefreshCalls`. Tests: `test/flows/customer_detail_refresh_test.dart` (button, pull down, offline keeps data and outbox, English).

### Changed (owner report 2026-11-22: "App not installed" over an older build; ADR-M26)
- **A build on `main` without the release key now fails** (`apk` job, step "Decode keystore") instead of publishing a debug-signed APK. A debug key is generated anew on each CI run, so such APKs have a different signature every time and Android refuses them as an update. Other branches still build, with a warning.
- `tool/make_release_keystore.sh`: one-time helper to make the key and the four `STAFF_*` secret values (asks for the password; refuses to overwrite an existing key; output git-ignored: `*.jks`, `*.b64`).
- README "Release signing" explains the rule, the one-time uninstall for phones that have a differently signed build, and that the key must never change.

### Changed (owner request 2026-11-22: reinstall, attendance, break photo, default shift; FR-M-060, FR-M-061, ADR-M25, contract 1.36.0)
- **A reinstall no longer needs a new device approval.** The device id is now derived from Android's ANDROID_ID (UUID v5, name `bd.howlader.staff_app/device/<ANDROID_ID>`), read through the existing `com.howlader.staff/permissions` channel (`androidId`). The same phone gives the same id after uninstall and install. A phone that already has an id keeps it. Without a usable ANDROID_ID a random id is used as before.
- **Attendance survives a reinstall.** After each successful sync, if the phone has no attendance event today, it asks `GET /attendance/me/today` (1.36.0, once per day per app run) and stores the events under their own clientId as already sent (no outbox entry). Duty, breaks and tracking then show the real state; staff are not asked to work in again. The phone's own events always win.
- **No photo at breaks by default.** Without `attendance.selfieEvents` from the server the app asks for a photo only at work-in and work-out (server default since 1.36.0).
- **Which invoice is always in view** on the collect screen (FR-M-062): a labelled choice "কোন ইনভয়েসের টাকা / Which invoice" with the number of open invoices, or the single invoice shown read-only.
- **No shift data: 09:00–21:00** (was 09:00–18:00) in `DutySettings` and `MyShift` fallbacks.

### Changed (owner request 2026-11-22: deposit everything, then it goes to the ERP; FR-M-059, ADR-M24, contract 1.35.0, schema 14)
- **Every collection stays in your hand until you deposit, whatever the method.** Change and Delete on the cash-in-hand screen now also cover bKash, Nagad, Rocket, bank and other mobile collections (new section "মোবাইল / ব্যাংক আদায় (জমার সাথে যাবে)", from the phone's copy; online, as before, ADR-M23). The server no longer answers `NOT_CASH`.
- **One "সব জমা দিন / Deposit everything" action.** No amount to type: the deposit takes all the cash in hand (fixed) and every mobile/bank collection not handed in. Before saving, a confirm says: "এই ৳X নগদ ও ৳Y মোবাইল/ব্যাংক (মোট N টি আদায়) জমা দিলে অনলাইনে থাকলে সাথে সাথে ইআরপিতে পেমেন্ট হিসেবে চলে যাবে। জমার পর আর বদলানো বা মুছে ফেলা যাবে না।" (offline: as soon as the phone is online). If the money in hand changed between the confirm and the save, nothing is saved and the sheet asks again.
- **After the deposit nothing can be changed or deleted.** The collections lock on the phone the moment the deposit is saved (offline too; `collections.deposit_id`), and the server's `depositId` replaces it on pull. While a deposit is unsent, the cash-in-hand screen says so and offers no Change/Delete. A collection handed in reads "জমা হয়েছে / Deposited" on the timeline until the ERP posts it.
- **Deposit history:** `submitted` reads "জমা হয়েছে / Deposited" (final) with "N collections · mobile/bank ৳Y". "Waiting for verification" is gone (the saved message, the cash-in-hand line about earlier deposits). Older pending, verified, rejected and deleted deposits still show.
- **A deposit the server refuses** (`DEPOSIT_MUST_BE_ALL`, `DEPOSIT_EXCEEDS_ON_HAND`, `NOTHING_TO_DEPOSIT`, `SLIP_REQUIRED`, `STATUS_CHANGED`) stays in Problems with the reason in words and "the collections are back in your hand", with a "আবার জমা দিন" button instead of Retry. Its lock is taken off and cash on hand counts the money again. Nothing is deleted.
- **Local DB schema 14:** `collections.deposit_id`, `deposited_at`; `deposits.collection_count`, `non_cash_poisha`, `non_cash_count`, `failure_code`. Migration tested from every released schema.
- Fake API follows 1.35.0 (deposit-all rules and refusals, `submitted`, `depositId` on collections, PATCH and withdraw for any method, `officeVoid` for tests).
- Tests: `test/features/deposit_rules_test.dart`, `test/features/deposit_confirm_test.dart` (bn/en, online/offline), `test/flows/deposit_flow_test.dart` (edit/delete a mobile collection, deposit → locked, a pull keeps the lock, a refused deposit → Problems and unlocked, confirm vs save), `test/core/migration_test.dart`.
- Contract copy `docs/contract/openapi.yaml` updated to **1.35.0**. **Needs field-api 1.35.0**; an older server keeps verifying deposits and accepts part deposits.
- Known gap (unchanged): the deposit sheet still has no slip photo, so a bank deposit is refused with `SLIP_REQUIRED` (now explained in Problems).

### Fixed (owner report 2026-11-22: a co-work request could not be cancelled; FR-CW-002, contract 1.34.0)
- **The person who asked can cancel a co-work request.** Before, leaving took the requester out but the invitation stayed open for the others, so the request was never withdrawn. The server (1.34.0) now ends a session as soon as no accepted member is left. In the app the button reads "Cancel request" while nobody has accepted (the confirmation says it is withdrawn for everyone), and "Leave group" warns that the group ends when only two are in it. The office can end a co-work from the admin panel; the phone learns it on the next pull.
- Tests: `test/flows/cowork_flow_test.dart` (cancel before anyone accepts; leave with one partner). Contract copy 1.34.0.

### Fixed (owner report: error in the app after test builds; schema 13)
- **A phone that ran a test build from the middle of schema 12 stopped with "no such column".** Schema 12 grew while it was built (who made a promise, edited and voided collections), so such a phone had version 12 but some columns missing and the migration did not run again. Schema 13 runs one idempotent step that adds whatever is missing and nothing else. Test `test/core/migration_test.dart` (a middle-of-12 phone) plus every older version.

### Added (owner request 2026-11-22: cash in hand change/delete, other staff's work, PIN progress; FR-M-058, ADR-M23, contract 1.32.0)
- **Cash in hand: Change and Delete on every line not covered by a deposit.** Change: amount, payer, note. Delete: confirm naming the amount and customer, optional reason. The server refuses (and the app says why) when a deposit covers the cash, the ERP already took it, or it is being posted. Online only; the deleted line stays in the history as voided and its receipt number stays used. Test `test/features/cash_actions_test.dart`.
- A deposit the office deleted shows "deleted by office" in the deposit list; its money returns to cash in hand. The depositor gets the server's notification.
- **Other staff's work:** Today's Work has a "My work / Other staff" switch (day arrows work), and the notification screen has an "Other staff today" section, both from the phone's own copy with staff names. My own lists, performance, totals and cash stay mine only.
- A promise a colleague made on a customer assigned to me no longer counts as a promise I made today (Today's Work, end-of-day count).
- **PIN screen shows "Checking your PIN and signing you in…" with a spinner** while the PIN is checked, instead of an idle screen.
- Contract copy updated to 1.32.0, then 1.33.0.
- **A collection's timeline line says when it was edited ("edited · was ৳X", from `edited.previousAmountPoisha`; new column `collections.previous_amount_poisha`, schema 12) and a colleague's deleted collection says "deleted"** on the customer timeline and in the Other staff list. My own deleted line shows who voided it: "Deleted by you" (the collector withdrew it) or "Voided by office" with the office user's name and the reason (`voided.kind`, `byName`, `reason`; new columns `collections.voided_kind/voided_by_name/voided_reason` and `colleague_activities.voided_kind`, schema 12); a colleague's deleted line says the same.

### Added (owner request 2026-11-22: who did it; FR-M-057, ADR-M22, contract 1.31.0, schema 12)
- **Every visit, promise, collection and pin on a customer's timeline says who made it** ("visited by…", "promise taken by…", "by…", "pin set by…"), including colleagues' records of the same branch, which the phone now receives (field-api 1.31.0, ADR-046).
- Colleagues' records live in a new table `colleague_activities` (migration v11 → v12, tested), never in the user's own `visits`/`promises`/`collections`, so Today totals, cash in hand, reminders and targets are unchanged. A promise a colleague made on a customer assigned to me stays in my promises (I follow it up) and shows who made it (`promises.created_by_name`). A joint visit I took part in stays mine. The signed-in user's id is saved as `kv_settings.my_user_id` at sign-in.
- Pins: a colleague's pin proposal or applied pin appears on the timeline with the proposer's name; my own show the decision.
- Contract copy in `docs/contract/openapi.yaml` updated to 1.31.0. Tests: `test/features/colleague_activity_test.dart`, `test/core/migration_test.dart`.
- **Deploy order:** release this app before field-api 1.31.0 is switched on. An older app that pulls the widened feed would put colleagues' promises in its own list.

### Changed (owner request 2026-11-21: Today duty card is a summary, not buttons; FR-M-004)
- The duty card on Today no longer has Start work / Break / End work buttons (the Attendance tile has them). It is one collapsed line (on duty since…, on break, ended, not started) with the date. Tap it to open today's facts: office time set by the admin, attendance time and late minutes (or "on time"), break taken against the admin's limit and any minutes over, work-end time, and overtime. Tapping outside or the header closes it.
- After the office end time, while still on duty, an amber strip says "Office time is over. You can end work now." (tap opens Attendance). Overtime counts from the office end to the work-out time, or to now while still on duty (`DutySettings.overtimeMin`, test `test/core/duty_overtime_test.dart`).
- A live GPS icon sits left of the bell in the app header: green pin when location is on, red crossed pin when off (tap opens location settings). `core/location/gps_status.dart`.
- While on break, End work stays off and both the card and the Attendance screen say to end the break first.

### Fixed (owner report: battery "Allow" did not open the system dialog)
- Battery is no longer required to press Continue on the permissions screen, so a phone that cannot grant it is still usable. If the system dialog does not grant it, the app opens the system battery-optimisation list (falling back to battery saver, then app info) so the user can switch it off by hand.
- The fallback now walks a chain until one screen opens: system battery-optimisation list, battery saver, and the brand's own battery/autostart screen (Xiaomi/Redmi/Poco, Oppo/Realme, Vivo/iQOO, Huawei/Honor, Samsung, OnePlus, Tecno/Infinix/itel, Asus, Nokia), ending at app info. Xiaomi, Oppo, Vivo, Huawei and Transsion phones try their own screen first. Android below 6 has no battery optimisation and counts as allowed.
- Added the missing `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission to the Android manifest, so the system "let app run in background" dialog now opens. The native side now waits for the dialog result (`startActivityForResult`) instead of answering "denied" immediately, and falls back to the battery-optimisation settings page if the dialog cannot open.
Contract pinned: field-api `openapi.yaml` **1.27.0** (1.22.0 → 1.27.0, additive: 1.23.0 extra phone numbers, 1.24.0 this month on a customer and invoice counts, 1.25.0 duty hours per branch with break windows, overtime and late absences, 1.26.0 the collection board, 1.27.0 cash in hand by collection; `docs/contract/openapi.yaml`). The collection board needs the server at 1.26.0; on an older server its tab says it could not be loaded and the branch ranking still works. Adding phone numbers needs 1.23.0; break windows and the late-days setting need 1.25.0; everything else works with 1.22.0.
### Fixed (owner report: two GPS notifications while the app is open; FR-M-056, ADR-M21)
- The geolocator position stream no longer opens its own foreground notification while the native tracking service runs; the native service is started first and is the only "on duty" notification. If it fails to start, geolocator keeps one (tracking is never invisible). Test `test/core/tracking_settings_test.dart`.
### Added (owner request 2026-11-21: receipt as a PDF; FR-M-055)
- **PDF button next to "রসিদ শেয়ার"** on the success screen and the receipt screen: a one-page PDF, 80 mm wide, of the same receipt card; the share sheet prints, saves or sends it. Works offline. New package `pdf` (pure Dart). Test `test/features/receipt_pdf_test.dart`.
### Added (owner request 2026-11-21: installment detail like the ERP; FR-M-054, contract 1.14.0)
- **Every installment line says what the ERP knows**: "৯ অক্টো-এ পরিশোধ · ৪ দিন দেরিতে", or "কিস্তি বাদ পড়েছে" on a missed one (in red when late or missed). Tap a line to see the payments that went to it (date, receipt, amount).
- **Local DB schema 11**: `schedule_lines.paid_on`, `days_late`, `missed`, `payments_json`; migration tested from every released schema. Fake ERP sends the fields. Tests `test/flows/installment_detail_test.dart`.
### Added (owner request 2026-11-21: remove an added number from the app; FR-M-053, master FR-CUS-016)
- **A bin icon next to every number added in the field** on the customer page (once it reached the server; `customer.phone.manage`). A confirm names the number; the server is asked (`DELETE /customers/{id}/phones/{number}`, contract 1.23.0) and the number leaves the list. Online only, like the admin panel (ADR-M08 exception); offline the app says internet is needed. ERP numbers cannot be removed (no button; the server refuses too).
- Fake API answers the DELETE by the server's rules. Test in `test/flows/customer_phone_flow_test.dart`.
### Tests (plan item 3.1)
- Widget tests for the attendance hub screen (`test/flows/attendance_hub_screen_test.dart`): before work-in it shows "শুরু হয়নি" and the history section, with no layout errors.
### Build
- Every push to `main` builds the APK with build number = CI run number and publishes it as a **pre-release on the GitHub Releases page** (`staff-app-<version>-<build>.apk`), so each test build installs over the last one and can be downloaded without opening Actions.

### Added (owner request 2026-11-21: how many invoices my branches have; FR-M-052, master FR-CUS-018)
- **The customer list's count line now says how many invoices the customers in view have and how many still take money**: "৩৪ জন গ্রাহক · ইনভয়েস ৪১টি · বাকি আছে ২৯টি". It follows the branch picked in the top bar (one branch, or all my branches) and uses the customer page's rule (cancelled invoices not counted). From the phone's own invoices, offline; no schema or contract change. Unit test in `test/features/work_marks_test.dart`.
### Added (owner request 2026-11-21: overtime and break over the limit on the attendance history; FR-M-051, field-api FR-ATT-010/011, contract 1.25.0)
- **Every day of the attendance history now carries the server's marks in words**, next to the late mark: "ওভারটাইম ৪৫ মি" (green) and "বিরতি ১২ মি বেশি" (amber). On a weekly off day or holiday the worked time reads "ছুটির দিনে কাজ: ৩ ঘ ০ মি". Days with nothing to mark show nothing.
- **Local DB schema 10**: `attendance_day.overtime_min` and `over_break_min` (default 0; the next pull fills them). Migration from every released schema is tested (`test/core/migration_test.dart`); nothing unsynced is touched and no new snapshot is forced.
- Tests `test/flows/attendance_marks_test.dart` (pull handler, the marks on screen).
### Added (owner request 2026-11-21: the receipt of any collection, later too; FR-M-050)
- **A receipt screen for every collection on the phone** (`/receipt/:clientId`): the same receipt the customer saw, with "রসিদ শেয়ার" (the phone's share sheet sends it, saves it or prints it) and "গ্রাহক খুলুন". Works offline.
- Opened by a tap on a collection in **Today's Work** (any day) and by the new "রসিদ" button on a collection in the **customer's timeline**. Until now the receipt was shown once, right after collecting.
- The receipt is shared as an image, as before. A PDF file needs two new packages and is left for when the build tools are available here.
### Added (owner request 2026-11-21: where my cash on hand came from; FR-M-049, field-api FR-CASH-007, contract 1.27.0)
- **"কোন আদায়ের টাকা হাতে আছে"** on the cash card (Me): a list of the cash collections not yet covered by a deposit, newest first, each with the customer, the invoice, the receipt number, the time and the amount still in hand ("মোট …-এর বাকি" when a deposit covered part of it). A tap opens the customer. The total and deposits waiting for verification are on top.
- A deposit pays off the oldest collections first (the server's rule, said under the list). Online; when this phone still holds unsent money the screen says that it is not in the list.
- Tests `test/flows/cash_in_hand_test.dart`; demo data in the fake API.
### Added (owner request 2026-11-21: one board for everyone, verified money, month and all time, a crown; FR-M-048, field-api FR-REP-007)
- **"আদায় বোর্ড" is the first tab of the leaderboard**: everyone who collected, in every branch, ranked by the collections the ERP has accepted. "এই মাস" and "সর্বকালের" switch the period. Money still waiting for the ERP is not counted (said under the list).
- **First place wears a crown** (people who are level share it). A manager or an admin who collects is on the board with their role named, ranked by collections alone.
- My place and my verified amount are on top; my row is highlighted; people with nothing verified yet are listed below without a rank.
- The earlier board (my branch, today / this month, four measures) is the second tab, "শাখার র‍্যাঙ্ক", unchanged.
- Shown when the office turns on "Field staff can see the leaderboard" for the branch, as before. The office can narrow the board to the own branch (`reports.leaderboardScope`).
- Online only. Tests in `test/flows/targets_reports_test.dart`; demo data in the fake API.
### Fixed (2026-11-21: the phone follows the office's duty settings; FR-M-047, field-api contract 1.25.0)
- **The app read setting names the server never sends** (`dutyStart`, `dutyEnd`, `lateGraceMin`, `maxBreakMin`, `geofenceRadiusM`, `cashBlockOverLimit`), so with the live server it always used 09:00–18:00, 15 minutes grace, 60 minutes break, 150 m and "warn only", whatever the office had set. It now reads the server's own keys: `attendance.defaultShift` (per branch), `collections.geofenceM`, `cash.limitMode`, `attendance.lateDaysPerAbsent`. The old names are kept as a fallback.
- **Friday break window**: break time inside the branch's window of the day (e.g. Friday 12:30–15:30) is not counted against the break limit; the "break too long" warning uses the same rule as the server.
- **Late days per absent day** on the attendance hub and Performance follow the server setting (2 until it says otherwise; 0 hides the count).
- The "far from the customer" question (FR-M-043) now uses the same distance as the office's `far_from_pin` flag.
- Rules in `core/settings/duty_settings.dart`; unit tests `test/core/duty_settings_test.dart`. A staff member with a named shift of their own still sees the branch hours on the duty card (the calendar screen shows their own shift).

### Added (owner request 2026-11-21: who paid this month; FR-M-046)
- Two new chips on the customer list with their counts: **"এ মাসে দিয়েছে"** (an ERP payment dated this month, or field money still waiting for the ERP) and **"এ মাসে দেয়নি"** (owes money and gave nothing this month). Same rule as the money work mark; sorted by days overdue, so long-overdue customers come first in both. They follow the branch picked in the top bar and combine with search.
- From the phone's own data, works offline. No schema or contract change.

### Fixed (owner request 2026-11-21: the branch switch filters everywhere; FR-M-045)
- Picking a branch in the top bar narrowed only the customer list. Today's priorities and counts, the map, the collect customer picker and the numbers on the list's filter chips still showed every branch. All of them now read one provider (`branchCustomersProvider`, rule `inBranch`), so the switch changes them together; "সব শাখা" shows everyone.
- A picked branch that is no longer on the phone falls back to all branches instead of breaking the dropdown.

### Added (owner request 2026-11-21: the bell shows what waits for me; FR-M-044)
- **Notifications screen behind the bell** (`/alerts`): promises due today (customer name + amount), new tasks, co-work requests, unread notices from the office and handovers waiting for an answer. A tap opens the customer or the page that deals with it. Built from the phone's own data, so it works offline; the bell's number is the count of these items.
- **The coloured top bar is now on every main tab for everyone**; with one branch it shows the branch name instead of a dropdown. The dropdown's first entry reads "সব শাখা / All branches". The bell used to open Me and count sync problems; those stay on the Me tab's badge.
- Fixed: the four work marks ran 6 px over the edge on Today's narrow customer rows; they now scale down to fit.
- New extension point `alertSources` on `FeatureManifest` (promises, tasks, cowork, notices, handovers register one each); `alertsProvider` joins them. No schema or contract change.
- These are in-app notifications. Notifications on the phone while the app is closed need the Firebase project (owner decision D-1).

### Added (owner request 2026-11-21: confirm work done far from the customer; FR-M-043)
- **Collecting or recording a visit far from the customer's pin asks first**: "আপনি গ্রাহকের পিন থেকে X দূরে আছেন। তবুও রেকর্ড করা যাবে; অফিস দূরত্বটি দেখতে পাবে।" with "ফিরে যান" and "তবুও রেকর্ড করুন". It never blocks (money taken at the shop or on the road must still be recorded). The visit screen already showed a warning line; the collect flow had nothing.
- "Far" = outside the server's `geofenceRadiusM` (150 m until the server says). No fix or no pin: no question. The distance goes to the server with the record as before; field-api flags collections `far_from_pin`.
- Rule in `core/location/geofence.dart`, dialog in `core/ui/far_confirm.dart`; unit tests `test/core/geofence_test.dart`.
### Added (owner request 2026-11-21: attendance reminder on Home, late warning and history on Performance; FR-M-042)
- **Attendance tile on Home** shows whether today's attendance has been given: an amber "!" and "হাজিরা বাকি" until the work-in, a green tick and "হাজিরা হয়েছে" after it (colour, icon and words).
- **Performance**: when the month has late days, a warning says "এ মাসে দেরি N দিন · অনুপস্থিতি ধরা হবে M দিন" (two late days = one absent day, FR-M-040), and a button "দিন অনুযায়ী কাজের ইতিহাস" opens Today's Work for that month (today, or the last day of an earlier month; the arrows go through the days).
- Tests: `lastDayOfMonth` in `test/core/clock_test.dart`.
### Changed (owner request 2026-11-21: everything I did today, and on earlier days; FR-M-041)
- **Today's Work lists all of the day's work**, latest first: visits, collections, promises, notes, map pins sent, calls and tasks reported done. Before it had visits and collections only. A row opens the customer (or the task).
- **Earlier days**: the arrows in the top bar go back a day at a time (and forward again up to today); `/today-work?date=YYYY-MM-DD` opens a given day.
- **Counts at the top**: visits, money posted in the ERP, money pending in ERP as its own chip (never one sum), promises.
- **Customer names** are shown for every row (a visit without a collection used to show the customer's id).
- New extension point `workLogSources` (`core/feature/feature_manifest.dart`): each feature lists the user's own work of a business day from its own table; the screen only merges. The `today` feature no longer imports the visits feature's internals or reads its table.
- A map pin proposal has no time column; the moment comes from its UUIDv7 client id (`uuidV7Time`).
- Tests: `test/features/work_log_test.dart` (counts, order, day bounds, UUIDv7 time). Device check pending.
### Fixed (owner rule 2026-11-21: two late days = one absent day; FR-M-040)
- The attendance hub marked a late day red only when the day before or after was late too. The owner's rule is by count, not by neighbours: **every two late days in a month are one absent day**. The 2nd, 4th, … late day of a month is now the one marked "অনুপস্থিতি হিসেবে গণ্য"; other late days stay amber.
- A line above the history says "এ মাসে দেরি N দিন · অনুপস্থিতি ধরা হবে M দিন" (amber, red once an absent day is counted).
- Rule in `attendance_domain.dart` (`lateTally`), unit tests in `test/features/late_tally_test.dart`. The pair size is 2 on the phone until the server sends it as a setting (open decision OD-M07).
### Changed (owner request 2026-11-21: hours and minutes, years / months / days; FR-M-039)
- A count of days is shown as its two largest units (`Fmt.daySpan`): the overdue badge says "১ বছর ৭ মাস বকেয়া" for 584 days, "১ মাস ১৫ দিন বকেয়া" for 45, "২০ দিন বকেয়া" for 20 (a month is 30 days, a year 365; never used to work out a date).
- Minutes are shown as hours and minutes (`Fmt.minutes`): late time on Me and in the attendance hub ("১ ঘ ২০ মি দেরি"), the visit suggestion, and the shift's late grace and break limit.
- Tests: `test/core/spans_test.dart`.
### Added (owner request 2026-11-21: who has been dealt with this month; FR-M-038, master FR-CUS-017)
- **Four work marks on every customer row, in every filter**: visited (today / this month), money (in the ERP this month / collected and still waiting for the ERP), open promise, and map pin set or missing. On = status colour and icon, off = grey outline; each has its meaning in words for TalkBack. They replace the two small dots on the avatar (which only said "visited today" and "promise today").
- **"এ মাসে" card on the customer page**: visited today or the last visit date, money in the ERP this month, money still pending in ERP on its own line (never one sum), the open promise, and "ইনভয়েস Nটি · বাকি আছে Mটি".
- Worked out on the phone from what it already holds (last visit, ERP payments, pending field money, open promise, pin, invoices), so a mark is right the moment a visit or a collection is saved, also offline. Dates are Dhaka dates (the old dot used the phone's own time zone).
- No database change. Contract file updated to 1.24.0 (the server's `activity` is not needed by the app).
- Tests: `test/features/work_marks_test.dart` (mark rules, Dhaka month boundary, ERP money per customer).
### Added (owner request 2026-11-21: several phone numbers for a customer; FR-M-037, master FR-CUS-016)
- **"নম্বর যোগ করুন" on the customer page** (permission `customer.phone.manage`): a sheet with one row per number (number + whose number) and "আরেকটি নম্বর", up to five added numbers per customer. Bangla digits, spaces, dashes and `+880` are accepted; a wrong number, one the customer already has, or one typed twice is named under its field.
- **Works offline**: the numbers show on the customer at once with a cloud icon, and go to the server as one `customer_phone` mutation (id made once, kept on every retry). A pull never removes a number that is still waiting. A refused mutation takes its numbers off the list again and stays visible in Problems.
- **Marks**: every ERP number says "ইআরপি" (the main one in the primary colour), every added one "যোগকৃত" with whose number it is. Before, the second and later numbers were all shown as "added", also when they came from the ERP.
- Added numbers are kept by field-api only; nothing is written to the ERP. Calls are still logged by the number's index, and ERP numbers keep their places at the front.
- No database change: `customers.phones_json` keeps ERP numbers as plain strings and stores an added one as `{n, s, l, p}`; older rows read unchanged.
- Tests: `test/features/customer_phones_test.dart` (stored list, server shapes, pending kept across a pull, typing rules), `test/flows/customer_phone_flow_test.dart` (offline add → push → pull; nothing queued for numbers already there).
### Fixed (owner report 2026-11-21: a partly paid installment looked unpaid and the overdue under the list was wrong; FR-M-036)
- **Installment lines on the customer page.** The row added the late fee to the line amount a second time (`amountPoisha` already includes it, contract `Plan.schedule[]`), so "left" was too high on lines with a late fee, and a partly paid line past its date lost its **Overdue** state (it was relabelled "partly paid" in the due-today colour). Now: left = amount − paid; a line past its date stays Overdue and shows "পরিশোধ X · বাকি Y" under the date; a line with nothing left is Paid.
- **"N of M paid"** counts only lines with nothing left (a stale stored status no longer counts).
- **Each invoice says what is open:** "Nটি বাকি · বকেয়া X" under the progress bar: installments with money left and the unpaid part of the lines past their date. The header total already came from the server and was right; the list now agrees with it.
- Rules are pure functions in `customers/src/domain/schedule.dart` with unit tests (`test/features/schedule_line_test.dart`). No schema, contract or string change.
### Fixed (2026-11-21: `main` did not pass CI)
- `flutter analyze` failed on two unused imports in `attendance_widgets.dart`, so the tests and the APK build were skipped. Removed.
- Golden diff images of a failed local screenshot run (`test/screenshots/failures/`) were committed; removed and git-ignored.

## [0.12.5] — 2026-11-20
Contract pinned: field-api `openapi.yaml` **1.22.0** (unchanged). No server change needed.
### Added (owner request 2026-11-20)
- **Attendance hub screen** (`/attendance`): middle screen before work-in showing today's duty status (color-coded header), in/out times, work duration, break total, late warning, GPS-off banner, Break / End Break / End Work action buttons, and a full 60-day attendance history list from the server snapshot.
- **3 quick-action tiles on Today**: Attendance (→ hub), Today's Work (→ `/today-work`), Performance (→ `/performance`), shown when the user has access.
- **Today's Work screen** (`/today-work`): chronological log of today's visits (with outcome icon) and collections (receipt + amount), merged and sorted by time, with visit count + collected total chips at the top.
- **Colored branch top bar** in the shell: `primaryContainer` background, store icon, 2/3-width branch dropdown ("All" for all-branches), notification bell with badge count on the right (navigates to Me tab).
- **Customer list visit/promise dots**: small colored dot overlay on the customer avatar — green when visited today (`lastVisitAt` date = today), primary-blue when the customer has an open promise today.
- **Consecutive-late absence indicator**: in the attendance hub history list, any day that is part of a 2+ consecutive late streak is highlighted red with an "অনুপস্থিতি হিসেবে গণ্য" label; a single late day stays amber.
- **Invoice summary row on customer detail**: 3-column Total / Paid / Outstanding row under each plan header.
- **Partial installment display**: installments that are partially paid now show "Paid X · left Y" regardless of server status (overdue partial lines are correctly identified on the client).
- **Multiple phones on customer detail**: all phone numbers shown with ERP-primary chip; each taps to call.
### Admin-web (2026-11-20)
- **Sidebar reorganized into 4 groups**: Field Work (customers, map, collections, visits, tasks…), People (staff, attendance, leave, targets, areas), Insights (live map, routes, reports, leaderboard, data-quality), Admin (unchanged).

## [0.12.4] — 2026-11-19
Contract pinned: field-api `openapi.yaml` **1.22.0** (unchanged). No server change needed.
### Fixed (owner report 2026-11-19: staff saw only their assigned customers; a customer vanished after a pin; no distance on Home)
- **The whole branch now reaches the phone** (FR-M-032). Root cause, checked against the live server with a real staff login: `GET /sync/bootstrap` answers `items` + a snapshot `nextCursor` + `pullCursor` (contract `SyncBootstrapResponse` since 1.5.0), but the app read it like a pull page (`changes`), so it stored **none** of the snapshot. A phone only got customers that changed later on the change feed (an assignment, a pin), which looked like "only assigned customers". The server was sending all of them (32 of the test branch, 28 unassigned). The fake API answered bootstrap like a pull, which is why tests never caught it; it now uses the real shape, pages the snapshot, and refuses a snapshot cursor on /sync/pull like the server.
- **One fresh snapshot after the update:** a phone without the new mark (`kv sync.snapshotFormat`) takes the snapshot again on its next sync. Bootstrap only upserts: the outbox, collections and anything unsynced are untouched. No schema change.
- **Distance on Home and the customer list** (FR-M-005): the phone's position was read once from Android's last known position, which is often empty, so no distance showed. While on duty the app now takes a fresh foreground fix and refreshes it every 2 minutes (only shown on the phone, never stored or sent; off duty it uses the last known position only).
### Added
- **Same-day repeat visit warning** (FR-M-035): the visit screen says when the customer was already visited today (how many times, last check-in time). Saving is still allowed (the customer may not have been home earlier).
- Tests `test/features/sync_bootstrap_test.dart`: the bootstrap shape, a paged first login, an older phone taking one fresh snapshot with its outbox kept, the same-day visit rule across Dhaka midnight.

## [0.12.3] — 2026-11-19
Contract pinned: field-api `openapi.yaml` **1.22.0** (unchanged from 0.12.2). Works best with field-api PR #23, which sends a whole branch in small, fast pages.
### Fixed (owner report 2026-11-19: the customer list was blank after login, with no way to load it)
- **Customer list: pull down or tap the reload button** (top bar) to load now (FR-M-032). It runs the same sync as "Sync now".
- **No more blank screen:** when no customer is on the phone the list says whether the first load is running (with progress), failed (with the error code) or has not happened, with a Reload button. "No customers match" stays for an empty filter.
- The customer count row no longer overflows at large font sizes.
- **"Still loading" banner:** while customers are downloading, a banner above the rows says "গ্রাহক লোড হচ্ছে… (N জন)" with a spinner and progress bar, so a half-filled list is not mistaken for the whole branch.
- **Customers tab loads by itself:** opening it with no customer on the phone starts a sync at once (the first load after login already runs in the background; the app still opens on Today).
### Added (owner request 2026-11-19)
- **Online / offline line on every screen**, just above the tabs: green dot + "অনলাইন" while the server answers, grey dot + "অফলাইন" when the phone has no network or the last sync could not reach the server (`OnlineStrip`, core/ui/chips.dart). Losing the network turns it grey at once; getting it back starts a sync, and the dot turns green when the server answers.
- Tests `test/flows/customer_list_reload_test.dart`: empty phone shows Reload, offline reload shows the failure, a reload that gets a fresh snapshot fills the list; opening the tab empty loads by itself; the online/offline line on every tab.

## [0.12.2] — 2026-11-19
Contract pinned: field-api `openapi.yaml` **1.22.0** (field-api PR #22, ADR-041; `docs/contract/openapi.yaml`).
### Fixed (owner report 2026-11-19: work-in saved, but the live map stayed empty)
- **Indoor fixes are no longer thrown away** (ADR-M20). The phone dropped every point worse than `maxAccuracyM` (50 m); indoors it reports 100–500 m, so nothing was ever sent. Points up to 5 km are now sent; the server keeps the rough ones for the live map only. A rough fix never becomes the reference for the speed check or the visit suggestion. The speed check allows for both fixes' accuracy (GPS error is not movement).
- **A position every few minutes even when standing still:** with no point from the stream for 2 minutes (a distance filter sends nothing while still), the tracker takes a one-off fix. Tracking also takes one right at the work-in and uploads the first point at once.
- Heartbeat every 5 minutes (was 15), so the office sees sooner that the phone is alive.
- **Times show in Bangladesh time with AM/PM** (owner request): `formatTimeDhaka` is 12-hour, e.g. `৯:০৮ AM`, the same as admin-web.
### Added
- Tests: rough fix kept, noise beyond 5 km dropped, jitter within accuracy not "impossible speed"; a quiet stream still sends a point at work-in and again after 3 minutes, rough fixes included.

## [0.12.1] — 2026-11-19
Contract pinned: field-api `openapi.yaml` **1.21.0** (field-api PR #20, ADR-040; `docs/contract/openapi.yaml`).
### Fixed (owner report 2026-11-19: attendance always "1 waiting", so no location reaches the live map)
- **Attendance never waits for its photo** (ADR-M19). Since 0.4.0 the app held each attendance event until its photo was uploaded. When the upload failed (server not redeployed, wrong `PUBLIC_BASE_URL`, weak network) the work-in never reached the server, the server treated the staff member as off duty and refused every location point. Now the event is sent at once, like a visit; the photo uploads on its own and is linked afterwards with the new `attendance_selfie` mutation (after its event, via `dependsOn`, once per event). The server flags an event without a photo `no_selfie` until the photo is linked.
- **Phones already stuck recover by themselves:** at start-up the app sends any attendance event an older version held for its photo (`releaseHeldAttendance`). Nothing is deleted; the photo is linked when it uploads.
- The camera is still required where the office asks for a photo; only the upload no longer blocks anything.
### Added
- `attendance_selfie` in the known mutation types; `OutboxWriter.release` returns whether a held row was released.
- Test hook `FakeFieldApi.uploadsFail`. Tests in `test/flows/attendance_selfie_flow_test.dart`: events go at once while uploads fail, location is not blocked, photos linked later exactly once each; a held work-in from an older app is sent at start-up and then gets its photo.

## [0.12.0] — 2026-11-19
Contract pinned: field-api `openapi.yaml` **1.20.0** (field-api PR #17, ADR-037; `docs/contract/openapi.yaml`).
### Added (owner request 2026-11-18: the office gives a staff member a free-form task with a note; FR-M-033)
- **Tasks from the office** (new feature `tasks`, flag `module.tasks`, permission `task.work`; master FR-TASK-001..005): a job with a title, a note and an optional due date, not tied to a customer. It arrives as the `task` sync entity (the snapshot holds open tasks and the ones closed in the last 30 days), shows on **Today** (overdue first, then "new", then "to do") and as **Me → আমার কাজ** with the number still to do, and opens in a list (to do · waiting for the office · finished) and a detail page with the office's note, history and, when it was sent back, the reason.
- **"কাজ হয়েছে"** (the work is done): an optional note, saved on the phone at once and sent as the `task_resolve_request` mutation, so it works without a network. The task then reads "will be sent" until the server has it and "office is checking" after. Only the office makes it resolved; if the office sends it back, the reason shows and the button returns. A task the office cancelled while the tap was waiting just shows as cancelled.
- Opening a task clears its "new" marker (local only).
- The phone shows a new task on the next sync. A lock-screen push needs FCM, which is not built yet; the server already creates the `task.assigned` notification for it.
- **Close-the-app question** (FR-M-034): pressing back at the root of the signed-in app (any of the four tabs) asks "অ্যাপ বন্ধ করবেন?" with "থাকুন" (focused) and "অ্যাপ বন্ধ করুন"; the second back while it is open only closes the question. Screens opened above the tabs go back one step as before.
- DB schema **9**: new table `tasks` (nothing else touched; no new snapshot is forced). `task_resolve_request` added to the known mutation types.
- Tests: `test/flows/tasks_flow_test.dart` (arrival, "new", offline "done" as one mutation then confirmed, sent back, cancelled while waiting, never dropped while queued, ordering and Dhaka overdue), `test/flows/tasks_screens_test.dart` (Today → Me → list → detail → "done" with a note offline → sent back; back at the root), `test/app/exit_confirm_test.dart`, `test/core/migration_test.dart` (schema 8 → 9, `_dropV9`).
- The fake API (demo and tests) knows tasks: `addTask`, `decideTask`, the `task_resolve_request` mutation with the real rejection codes, permission `task.work` and flag `module.tasks`.

## [0.11.0] — 2026-11-19
Contract pinned: field-api `openapi.yaml` **1.19.0** (field-api PR #18, ADR-038; `docs/contract/openapi.yaml`).
### Added (owner request 2026-11-18: staff see every customer of their branch, staff in several branches; FR-M-032)
- The phone now holds **every customer of the staff member's branches**, assigned or not (server setting `customers.staffVisibility`, default whole branch). Staff can open, visit, call and collect from any of them.
- **Several branches:** when the phone holds customers of more than one branch, every customer row says which branch it is in, and the customer page shows the branch.
- Customer page: for someone else's or an unassigned customer, a line says whose customer it is ("রাকিবের গ্রাহক" / "কাউকে বরাদ্দ নেই").
- Customer list: the **আমার (Mine)** filter chip appears once colleagues' customers are on the phone.
### Changed
- **Today** lists the user's own customers and the ones nobody is assigned to, never a colleague's (before, everything on the phone was the user's own). The collect picker suggests the same first; search still finds everyone.
- DB schema **8**: `customers.branch_id`, `branch_code`, `branch_name_bn`, `branch_name_en`, `assignee_name`. The v8 step resets `bootstrap_done`, so the first sync after the update takes a fresh snapshot of the whole branch (it only upserts: outbox, collections and everything unsynced stay). Migration test from every released schema.
- A reassigned customer is no longer removed from the old assignee's phone while it is still in their branch (field-api now sends an upsert).

## [0.10.2] — 2026-11-18
### Fixed
- **Live location lost while the work-in was still unsent** (owner report 2026-11-18: staff online and on duty, but nobody on the admin live map; attendance stuck on "sync pending"). The server keeps location points only while it knows the person is on duty (FR-LOC-001), and it learns that from the work-in. The app sent points even when the work-in was still waiting for its photo, so every point was refused as `OFF_DUTY` and then deleted from the phone. Points now wait in the phone's queue while an `attendance_event` is held, pending or sending (`LocationTracker.uploadPending`), and go out as soon as it reaches the server (`locationBackgroundProvider` watches `OutboxReader.watchUnsentOf`). The queue cap still applies. The photo itself could not upload because the test server had no file storage; that is fixed on the server side (field-api contract 1.18.0, ADR-039): no app change is needed for it, the app retries the stuck photos on its own.
- Test `points wait on the phone until the work-in is on the server, then go out` in `test/flows/location_flow_test.dart`.

## [Unreleased]
### Changed
- Shared design tokens v1.1 (docs only, mirrors admin-web `docs/03-design-guide.md §2.3a`, admin ADR-W18): pay-state colours (`payState.bad`, `missedMany`, `missedOne`, `dueToday`, `onTrack`, `paidOff`, each pin / fg / bg, light and dark) and the pin shadow, from field-api contract 1.14.0 `PayState` (ADR-035). `docs/design-tokens.json` is the same file as admin-web's again. Nothing in the app changes yet; its map keeps the `status.*` markers.
### Fixed
- Widget-flow tests now set Bangla explicitly for Bangla assertions and mock the enabled GPS service/permission checks, so they remain deterministic with the app's English default and do not call a platform channel.

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
