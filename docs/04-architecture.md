# 04 — Architecture (staff-app)

## 1. Stack
| Concern | Choice |
|---|---|
| Framework | Flutter (stable, Dart 3), Android first |
| State & DI | Riverpod 2 (code-gen `riverpod_generator`) |
| Navigation | go_router (typed routes) |
| Local DB | drift (SQLite) + `sqlcipher_flutter_libs` (encryption) |
| HTTP | dio + interceptors (auth, version gate, gzip, retry), generated client or freezed models (ADR-M04) |
| Models | freezed + json_serializable |
| Background work | workmanager (periodic sync), foreground service for tracking (via location engine) |
| Location | `LocationEngine` interface → `flutter_background_geolocation` impl (if licensed) or `geolocator` + foreground service + `flutter_activity_recognition` impl (ADR-009) |
| Maps | flutter_map (+ flutter_map_marker_cluster, flutter_map_tile_caching) with TileProvider from `/meta/app-config` |
| Camera | camera (custom capture UI), image (compress/watermark in isolate) |
| Push | firebase_messaging + flutter_local_notifications |
| Secure storage | flutter_secure_storage (Keystore) |
| Biometric | local_auth |
| Device info / integrity | device_info_plus, package_info_plus, `safe_device`-style root/dev-mode checks; Play Integrity (if Play distributed, P4) |
| Connectivity | connectivity_plus + real reachability ping |
| Time | timezone (Asia/Dhaka), server offset |
| IDs | uuid (v7) |
| i18n | flutter_localizations + intl ARB |
| Logging/crash | `logger` + Sentry or Firebase Crashlytics (OD-M03) with PII scrubbing |
| Tests | flutter_test, mocktail, drift in-memory, integration_test + Patrol for E2E |
| Lint | flutter_lints (strict) + `custom_lint` rule package `fos_lints` enforcing feature boundaries |

## 2. Layering
```
presentation (widgets, screens, controllers: Riverpod Notifiers)
   → application (use cases: RecordCollection, CheckInVisit, StartBreak …)
      → domain (entities, value objects, pure rules: priority, cashOnHand, receiptNo)
      → data (repositories: local drift DAOs + remote API + sync queue)
```
Rule: **UI never calls the network directly.** Writes go: use case → local DB transaction (entity + outbox mutation) → sync engine uploads later. Reads come from local DB streams.

## 3. Features (modules)
Each feature: `lib/features/<name>/` with `manifest.dart`, public `<name>.dart` barrel, and private `src/`.

```dart
// lib/core/feature/feature_manifest.dart
class FeatureManifest {
  final String name;
  final String? flag;                    // e.g. 'module.collections' (default OFF until server says ON)
  final List<String> permissions;        // keys checked by this feature (must exist in master catalog)
  final List<RouteBase> routes;
  final List<NavDestinationDef> nav;     // bottom-nav or Me-menu entries
  final List<SyncEntityHandler> syncHandlers; // pull upsert/delete + push mutation types it owns
  final List<DriftMigrationStep> migrations;
  final List<CustomerActionDef> customerActions; // extension point: buttons on customer detail
  final List<TodayCardDef> todayCards;            // extension point: cards on Today
}
```

| Feature | Flag | Permissions | Owns local tables | Push mutation types |
|---|---|---|---|---|
| `auth` | — | — | (secure storage) | — |
| `onboarding` | — | — | `consents` | — |
| `shell` | — | — | — | — |
| `today` | — | — | — | — |
| `customers` | `module.customers` | `customer.view`, `customer.location.propose` | `customers`, `plans`, `schedule_lines`, `erp_payments`, `location_proposals` | `location_proposal` |
| `tags` | `module.tags` | `tag.view`, `tag.set` | `tag_events` | `tag` |
| `collections` | `module.collections` | `collection.record`, `collection.view` | `collections`, `receipt_blocks` | `collection` |
| `cash` | `module.cash` | `cash.view`, `cash.deposit.record` | `deposits`, `cash_closings`, `cash_position` | `deposit`, `cash_closing` |
| `visits` | `module.visits` | `visit.record`, `visit.view` | `visits` | `visit`, `visit_checkout` |
| `notes` | `module.notes` | `note.create`, `note.view` | `notes` | `note` |
| `promises` | `module.promises` | `promise.create`, `promise.view` | `promises` | `promise`, `promise_cancel` |
| `media` | — | — | `media_queue` | (HTTP upload) |
| `attendance` | `module.attendance` | `attendance.record`, `leave.request` | `attendance_events`, `attendance_day` | `attendance_event` |
| `handovers` | `module.handovers` | — (receiver), `handover.request` | `handovers` | `handover_decision` |
| `location` | `module.location` | — (staff on duty) | `location_queue`, `heartbeat_state` | (batch HTTP) |
| `map` | `module.customers` | `customer.view` | `tile cache` (FMTC store) | — |
| `notifications` | `module.notifications` | — | `notifications` | — |
| `sync` | `module.sync` | — | `outbox`, `sync_state`, `id_map` | — |
| `settings` | — | — | `kv_settings` | — |
| `performance` | `module.reports` | — | — | — |
| `microfinance` | `module.microfinance` | reserved | none — README only | — |

Future features land in `lib/features/<new-feature>/` and register in `lib/app/features.dart` (the only list).

## 4. Folder tree
```
staff-app/
├── CLAUDE.md · README.md · pubspec.yaml · analysis_options.yaml · l10n.yaml · Makefile
├── .env.example                      # names only (used by --dart-define-from-file)
├── android/                          # app id, flavors (dev, staging, prod), foreground service config, network security config
├── assets/ fonts/ (Inter, NotoSansBengali, HindSiliguri, JetBrainsMono) · images/ · lottie/ (success, optional)
├── docs/ 01…09 · CHANGELOG.md · design-tokens.json
├── packages/
│   ├── field_api_client/             # generated from field-api openapi.yaml (do not edit)
│   └── fos_lints/                    # custom_lint rules: feature boundary, no network in UI, no DateTime.now() in domain
├── tool/ gen_api.sh · check_permissions.dart · check_l10n.dart
├── integration_test/ journeys/*.dart (Patrol)
├── test/ (mirrors lib/)
└── lib/
    ├── main_dev.dart · main_staging.dart · main_prod.dart
    ├── app/ app.dart · router.dart · features.dart (ONLY feature list) · bootstrap.dart
    ├── core/
    │   ├── config/ env, flavors
    │   ├── db/ app_database.dart (drift), encryption, migrations registry
    │   ├── network/ dio_client.dart, interceptors (auth refresh single-flight, 426 gate, gzip, request id), reachability
    │   ├── sync/ sync_engine.dart, outbox, pull_handler_registry, push_dispatcher, backoff, id_map
    │   ├── auth/ session, pin_lock, biometric
    │   ├── permissions/ permission_service (effective keys from server), Can widget
    │   ├── flags/ flag_service
    │   ├── location/ location_engine.dart (interface), impls/, duty_guard.dart, filters.dart
    │   ├── media/ camera_capture, compress_watermark (isolate), upload_queue
    │   ├── notifications/ fcm, local_notifications, channels
    │   ├── time/ clock.dart (server-offset aware, Dhaka business date)
    │   ├── format/ money, digits, amount_in_words_bn/en, dates
    │   ├── device/ device_id, integrity, oem_battery_guide
    │   ├── theme/ tokens.dart, color_scheme.dart, status_colors.dart (ThemeExtension), typography.dart
    │   └── ui/ shared widgets (StatusBadge, MoneyText, SyncChip, DutyChip, AmountKeypad, HoldToConfirmButton, ReasonSheet, EmptyState)
    ├── features/
    │   └── <feature>/
    │       ├── manifest.dart
    │       ├── <feature>.dart        # public barrel
    │       └── src/ domain/ · data/ (dao, repository, sync_handler) · application/ (use cases) · presentation/ (screens, widgets, controllers)
    └── l10n/ app_bn.arb · app_en.arb
```

## 5. Offline sync engine

### 5.1 Write path (e.g. Record Collection)
```
RecordCollection(input):
  validate (amount > 0, method, txn regex, plan)
  key = uuidv7()                                  // generated ONCE here
  receiptNo = receiptBlocks.next()                // transactional increment
  geo = locationEngine.currentFix(timeout: 20s)   // accuracy, mock flag
  DB transaction:
     insert collections(clientId=key, status='queued', …)
     insert outbox(mutationId=key, entity='collection', op='create', payload, createdAt, attempts=0, state='pending', dependsOn=[visitClientId?])
     update cash_position (local unsynced cash += amount if cash)
  syncEngine.kick(reason: 'money')                // immediate attempt if online
```

### 5.2 Push
- Outbox processed FIFO by `createdAt`, respecting `dependsOn` (a note waits for its visit; collection with photo doesn't wait for photo upload — photo links later by `photoMediaId` update).
- Batches of ≤ 50 mutations to `/sync/push`; per-item results:
  - `applied` / `replayed` → state `done`, store `entityId` in `id_map`, update entity status.
  - `conflict` → entity status `conflict` + local notification + appears in Problems; outbox item `done` (server owns resolution).
  - `rejected` (validation/permission) → state `failed`, shown in Problems with message; user can edit-and-resubmit for non-money, or "contact manager" for money (never silently deleted).
  - network/5xx → state stays `pending`, `attempts++`, `nextAttemptAt = backoff(attempts)`.
- `Idempotency` guaranteed: mutationId = entity clientId = server idempotency key.

### 5.3 Pull
- After every push, and on schedule: `GET /sync/pull?cursor` loop until `hasMore=false`; handlers per entity upsert/delete in one transaction per page; cursor saved after commit.
- Local unsynced edits win for display until their mutation completes (e.g. a queued collection still shows as "queued" even if pull brings older collection list).
- `410 CURSOR_EXPIRED` → bootstrap (paged), keeping outbox untouched.
- Pull also refreshes permissions, flags, settings, cash position, server time offset.

### 5.4 Media
`media_queue` row per captured file: `{ localPath, kind, sha256, size, ownerClientId, state }` → `POST /media/upload-url` → PUT to presigned URL (chunk-free, ≤ 250 KB) → `confirm` → enqueue `update` mutation linking `mediaId` to visit/deposit. Retries independently of data sync; Wi-Fi not required.

### 5.5 Location (phase 2)
`LocationEngine` emits fixes → `filters.dart` (accuracy ≤ 50 m, speed ≤ 120 km/h, dedupe) → `duty_guard` (only if on duty and within shift + 3 h) → `location_queue` → batch upload every 2 min when online (or 100 points) gzip; cap 20,000 points (drop oldest **stationary** points first). Sampling profile from settings, chosen by activity: `in_vehicle/on_bicycle` 15 s/25 m · `walking` 45 s · `still` 180 s · stationary near customer pin 180 s and raise "visit suggestion" after dwell ≥ 5 min within 60 m.

### 5.6 Conflict display
Collections show status chip: queued (pending) · sent (pending, "ERP-তে অপেক্ষমাণ") · posted (paid, with ERP receipt no.) · conflict (overdue colour, "ম্যানেজার দেখছেন") · resolved (paid/neutral with resolution text) · voided.

## 6. Handover on device
Pull delivers `handover` (pending) → banner + push → summary screen → accept/reject (`handover_decision` mutation; requires online, because it changes scope — offline shows "ইন্টারনেট প্রয়োজন"). After acceptance pull brings new customers; for the outgoing staff, tombstones remove customers **only after** their pending mutations for those customers are synced.

## 7. Security on device
SQLCipher key: random 256-bit, stored in Keystore-backed secure storage. Tokens in secure storage. PIN hashed (argon2 / PBKDF2 with device salt) — never sent to server. App lock after 5 min in background. FLAG_SECURE on collection/cash screens (setting). Network security config: HTTPS only, certificate pinning to API host (with 2 backup pins) — optional per OD-M04.

## 8. Build & distribution
Flavors dev/staging/prod with different app ids and API URLs. Release APK signed with upload key in CI secrets (never in repo). Distribution: Google Play internal/closed testing track (recommended; enables in-app updates) or managed APK download page (OD-M01). Version: `major.minor.patch+build`; `minAppVersion` enforced by field-api.
