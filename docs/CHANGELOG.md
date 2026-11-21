# Changelog — staff-app

## [Unreleased]
Contract pinned: field-api `openapi.yaml` **1.27.0** (1.22.0 → 1.27.0, additive: 1.23.0 extra phone numbers, 1.24.0 this month on a customer and invoice counts, 1.25.0 duty hours per branch with break windows, overtime and late absences, 1.26.0 the collection board, 1.27.0 cash in hand by collection; `docs/contract/openapi.yaml`). The collection board needs the server at 1.26.0; on an older server its tab says it could not be loaded and the branch ranking still works. Adding phone numbers needs 1.23.0; break windows and the late-days setting need 1.25.0; everything else works with 1.22.0.
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
