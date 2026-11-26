# Pull-to-refresh audit (2026-11-26)

Every route in `lib/app/router.dart` and `lib/features/*/manifest.dart`, plus full screens opened outside the router.

- **Sync** = `ref.read(syncEngineProvider).syncNow()`, the same as "Sync now": it pushes the outbox, then pulls. The screen's database streams update by themselves. Shared helper: `lib/core/ui/refreshable.dart` (`PullToRefresh`, `syncNowFromPull`, `PullableFill` for empty or message bodies).
- Every pullable scroll view uses `AlwaysScrollableScrollPhysics`, so a short or empty screen can still be pulled.
- Test: `test/flows/pull_to_refresh_test.dart`. It opens each screen below and runs its refresh. It checks that the expected request reaches the fake server, and that the request is not sent while the screen just sits open. Two tests do a real drag-down: the Tasks empty state and a short notice.

| Screen | Route | Result | Why / what refresh it triggers |
|---|---|---|---|
| Today (Home) | `/today` | already had | Sync; the redesigned Home sets `AlwaysScrollableScrollPhysics` explicitly. |
| Customers | `/customers` | already had | Sync (`reload`). Its empty, error and list states were already always-scrollable. No change. |
| Customer detail | `/customers/:id` | already had | `POST /customers/{id}/refresh` (FR-M-063), then sync. Already always-scrollable. No change. |
| Map | `/map` | not needed | Map pan and zoom take the drag gesture. Customers sync from the Customers tab or Today. |
| Me | `/me` | **added** | Sync: refreshes what the Me entries show (cash, attendance, tasks, notices, requests, target). |
| Settings | `/settings` | not needed | Language, digits, theme, contrast and privacy are local. Version and device id do not change. |
| Sync centre | `/sync` | **added** | Sync, like the "Sync now" button. While an app update is required it does nothing, like the disabled button. |
| Alerts | `/alerts` | **added** | Sync: promises, tasks, co-work, notices, handovers and team activity are all read from the local DB. Empty state is pullable. |
| Today's work | `/today-work` | **added** | Sync: work log and team activity are read from the local DB. Covers both tabs and the `SliverFillRemaining` empty states. |
| Attendance hub | `/attendance` | **added** | Sync: today's status and history are local and update after the push and pull. |
| Work in / Work out | `/attendance/work-in`, `/attendance/work-out` | not needed | Forms (selfie + GPS step). |
| Leave | `/attendance/leave` | already had (improved) | Online fetch `GET /leave-requests`. The pull now awaits `ref.refresh(myLeaveProvider.future)` (before, it only invalidated and ended at once). Explicit always-scrollable physics added. |
| Leave request form | `/attendance/leave/new` | not needed | Form. |
| Work calendar | `/attendance/calendar` | already had (improved) | Online fetch: shift, holidays and leave. Now awaits `ref.refresh(_calendarProvider(year).future)`. Explicit physics added. |
| Cash in hand | `/cash/in-hand` | already had | Online fetch `GET /cash/me/collections` (`_load`). Explicit physics added. |
| Collect: pick customer | `/collect` | not needed | First step of the collect flow (search with autofocus). The customer list itself is pullable on the Customers tab. |
| Collect flow | `/collect/:customerId` | not needed | Form. |
| Collect success | `/collect/success/:clientId` | not needed | Confirmation step of the collect flow. |
| Receipt | `/receipt/:clientId` | **added** | Sync: brings the ERP posting state and server receipt for this collection. |
| Co-work | `/cowork` | already had | Online colleagues fetch plus co-work refresh (`_load`). Explicit physics added. |
| Map pin | `/customers/:id/pin` | not needed | Map pin setting (form on a map). |
| Handovers | `/handovers` | **added** | Sync: handovers are a pulled entity. Accept and reject stay online-only. Empty state is pullable. |
| Notices | `/notices` | **added** | Sync: new notices and read confirmations. Empty state is pullable. |
| Notice detail | `/notices/:id` | **added** | Sync: the read state is confirmed by the server. The "not on phone" state is pullable too. |
| Place move | `/places/:id/move` | not needed | Moving a pin on the map (form). |
| Prospects | `/prospects` | **added** | Sync: office status changes on my prospects. Empty state is pullable. |
| Prospect form | `/prospects/new`, `/prospects/:id/edit` | not needed | Form. |
| Performance | `/performance` | already had | Online fetch `GET /reports/me/performance` (`_load`). Explicit physics added. |
| Leaderboard | `/leaderboard` | already had | Both tabs: `GET /reports/collection-board` (collection board view) and `GET /reports/leaderboard`. Explicit physics added to both. |
| Requests | `/requests` | **added** | Sync: office steps on my requests and requests given to me. |
| Request form | `/requests/new` | not needed | Form. |
| Request detail | `/requests/:key` | **added** | Sync: timeline, comments and status. The "not on phone" state is pullable too. Reopen stays online-only. |
| Tasks | `/tasks` | **added** | Sync: new and decided tasks. Empty state is pullable. |
| Task detail | `/tasks/:id` | **added** | Sync: the office's decision. The "not on phone" state is pullable too. |
| Visit | `/visit/:customerId` | not needed | Form. |
| OEM battery guide | `/location/battery-guide` | not needed | Static guide. |
| Background location set-up | `/location/background-setup` | **added** (new screen) | Re-reads the phone's state (native running, battery optimisation, token refused, brand). FR-M-078. |
| Splash, login, change password, PIN set-up and PIN, consent, permissions primer, bootstrap, update required | `/splash`, `/login`, `/change-password`, `/pin/setup`, `/pin`, `/consent`, `/primer`, `/bootstrap`, `/update` | not needed | Gates and forms. |
| Location gate | (overlay, `core/location`) | not needed | Gate (and `lib/core/location/` is out of scope here). |
| Camera | (full-screen dialog, `core/media`) | not needed | Camera. |
| Attendance, not required | `/attendance` for a user who gives no attendance | not needed | A static info banner only. |
