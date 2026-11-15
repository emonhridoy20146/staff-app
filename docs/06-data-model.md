# 06 — Data Model (staff-app local SQLite via drift, encrypted)

Server model: `field-api/docs/06-data-model.md`. Local tables mirror the **user's scope only**. All money in poisha (INTEGER). Times stored as INTEGER epoch ms UTC; business dates as TEXT `YYYY-MM-DD` (Dhaka).

## 1. Common columns
`client_id TEXT` (UUIDv7, PK for locally created rows) · `server_id TEXT NULL` · `sync_state TEXT` (`synced|queued|sending|conflict|failed`) · `updated_at INTEGER` · `server_version INTEGER NULL`.

## 2. Tables

| Table | Key columns | Indexes | Notes |
|---|---|---|---|
| `customers` | `server_id PK`, `erp_customer_id`, `code`, `name_bn`, `name_en`, `phones_json`, `address`, `area_id`, `lat`, `lng`, `location_status`, `total_outstanding_poisha`, `next_due_date`, `days_overdue`, `due_today`, `overdue`, `bad_suggested`, `bad_reason_json`, `tag_state`, `tag_severity`, `last_visit_at`, `open_promise_id`, `erp_fetched_at`, `search_text` (normalized bn+en+phone+code) | `(overdue, days_overdue)`, `(due_today)`, `(lat,lng)`, FTS5 on `search_text` | replaced by pull upserts |
| `plans` | `erp_plan_id PK`, `customer_id`, `product`, `start_date`, `final_due_date`, `installment_count`, `total_payable_poisha`, `paid_poisha`, `outstanding_poisha`, `status` | `(customer_id)` | |
| `schedule_lines` | `(erp_plan_id, seq) PK`, `due_date`, `amount_poisha`, `paid_poisha`, `status`, `estimated` | `(due_date)` | |
| `erp_payments` | `erp_payment_id PK`, `customer_id`, `plan_id`, `date`, `amount_poisha`, `method`, `source`, `receipt_no`, `reversed` | `(customer_id, date DESC)` | last 20 per customer |
| `collections` | `client_id PK`, `server_id`, `customer_id`, `erp_plan_id`, `amount_poisha`, `method`, `transaction_ref`, `receipt_no UNIQUE`, `physical_receipt_no`, `payer_name`, `note`, `recorded_at`, `device_time`, `lat`, `lng`, `accuracy_m`, `mock`, `visit_client_id`, `photo_media_client_id`, `status` (`queued|received|posting|posted|conflict|resolved_*|voided`), `erp_receipt_no`, `conflict_code`, `conflict_message`, `resolution_text`, `flags_json`, `sync_state` | `(recorded_at DESC)`, `(customer_id)`, `(status)` | own collections, 60 days kept locally |
| `receipt_blocks` | `id PK`, `prefix`, `business_date`, `from_seq`, `to_seq`, `last_used` | `(business_date)` | |
| `cash_position` | single row: `server_on_hand_poisha`, `limit_poisha`, `as_of` | — | local unsynced adds computed in query |
| `deposits` | `client_id PK`, `server_id`, `amount_poisha`, `destination`, `reference`, `slip_media_client_id`, `deposited_at`, `status`, `reject_reason`, `sync_state` | `(deposited_at DESC)` | |
| `cash_closings` | `business_date PK`, totals, `confirmed_at`, `sync_state` | — | |
| `visits` | `client_id PK`, `server_id`, `customer_id`, `check_in_at`, `check_out_at`, `outcome`, `lat`, `lng`, `accuracy_m`, `mock`, `distance_to_pin_m`, `photo_media_client_ids_json`, `source`, `sync_state` | `(customer_id, check_in_at DESC)` | own + last 5 per customer from others |
| `notes` | `client_id PK`, `server_id`, `customer_id`, `author_id`, `author_name`, `category`, `text`, `voice_media_client_id`, `created_at`, `editable_until`, `sync_state` | `(customer_id, created_at DESC)` | last 20 per customer |
| `promises` | `client_id PK`, `server_id`, `customer_id`, `erp_plan_id`, `promised_date`, `promised_amount_poisha`, `status`, `note`, `sync_state`, `reminder_scheduled` | `(promised_date, status)` | |
| `tag_events` | `client_id PK`, `customer_id`, `previous_json`, `next_json`, `reason_code`, `reason`, `at`, `sync_state` | `(customer_id)` | |
| `location_proposals` | `client_id PK`, `customer_id`, `lat`, `lng`, `accuracy_m`, `photo_media_client_id`, `note`, `status`, `sync_state` | | |
| `attendance_events` | `client_id PK`, `type`, `at`, `device_time`, `lat`, `lng`, `accuracy_m`, `mock`, `selfie_media_client_id`, `sync_state` | `(at)` | |
| `attendance_day` | `business_date PK`, `status`, `first_in`, `last_out`, `break_min`, `late_min`, `breaks_json` | | computed locally, replaced by server |
| `handovers` | `server_id PK`, `from_user_name`, `to_user_id`, `summary_json`, `status`, `expires_at`, `role` (`incoming|outgoing`) | | |
| `media_queue` | `client_id PK`, `kind`, `local_path`, `sha256`, `size_bytes`, `captured_at`, `owner_entity`, `owner_client_id`, `server_media_id`, `state` (`pending|uploading|uploaded|confirmed|failed`), `attempts`, `next_attempt_at` | `(state, next_attempt_at)` | files under app-private dir; purged 7 days after confirm |
| `outbox` | `mutation_id PK`, `entity`, `op`, `payload_json`, `depends_on_json`, `created_at`, `state` (`pending|sending|done|failed`), `attempts`, `next_attempt_at`, `last_error` | `(state, created_at)` | never deleted while `pending/failed`; `done` purged after 7 days |
| `id_map` | `client_id PK`, `entity`, `server_id` | | |
| `sync_state` | single row: `pull_cursor`, `last_pull_at`, `last_push_at`, `server_offset_ms`, `bootstrap_done` | | |
| `location_queue` | `id INTEGER PK AUTOINCREMENT`, `t`, `lat`, `lng`, `acc`, `spd`, `hdg`, `alt`, `act`, `bat`, `chg`, `mock` | `(t)` | cap 20,000 |
| `notifications` | `server_id PK`, `type`, `title`, `body`, `data_json`, `read_at`, `created_at` | `(created_at DESC)` | 30 days |
| `kv_settings` | `key PK`, `value_json` | | permissions snapshot, flags, settings, consents |

## 3. Migrations
drift `schemaVersion` integer; each feature contributes `MigrationStep`s registered in `core/db/migrations`; every version upgrade is tested from **every** previous released schema (`drift_dev schema dump` + `verifySchema` tests). Never drop a table containing `outbox`/`collections` rows without migrating data.

## 4. Data lifecycle on device
- Out-of-scope customers (tombstones) deleted after their pending mutations are done.
- Own collections kept 60 days, visits/notes 30 days beyond scope.
- Logout: requires empty outbox (or explicit manager-forced logout) → wipe DB file + media dir + secure storage tokens.
- 5 failed PINs → lock; requires online password login of the **same** user to unlock (data kept encrypted).
