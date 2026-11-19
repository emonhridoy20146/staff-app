# 06 — Data Model (staff-app local SQLite via drift, encrypted)

Server model: `field-api/docs/06-data-model.md`. Local tables mirror the **user's scope only**. All money in poisha (INTEGER). Times stored as INTEGER epoch ms UTC; business dates as TEXT `YYYY-MM-DD` (Dhaka).

## 1. Common columns
`client_id TEXT` (UUIDv7, PK for locally created rows) · `server_id TEXT NULL` · `sync_state TEXT` (`synced|queued|sending|conflict|failed`) · `updated_at INTEGER` · `server_version INTEGER NULL`.

## 2. Tables

| Table | Key columns | Indexes | Notes |
|---|---|---|---|
| `customers` | `server_id PK`, `erp_customer_id`, `code`, `name_bn`, `name_en`, `phones_json`, `address`, `area_id`, `lat`, `lng`, `location_status`, `total_outstanding_poisha`, `next_due_date`, `days_overdue`, `due_today`, `overdue`, `bad_suggested`, `bad_reason_json`, `tag_state`, `tag_severity`, `last_visit_at`, `open_promise_id`, `erp_fetched_at`, `guarantor_json`, `detailed_address`, `directions`, `erp_risk_json` (v7), `branch_id`, `branch_code`, `branch_name_bn`, `branch_name_en`, `assignee_name` (v8), `search_text` (normalized bn+en+phone+code) | `(overdue, days_overdue)`, `(due_today)`, `(lat,lng)`, FTS5 on `search_text` | replaced by pull upserts |
| `plans` | `erp_plan_id PK`, `customer_id`, `product`, `start_date`, `final_due_date`, `installment_count`, `total_payable_poisha`, `paid_poisha`, `outstanding_poisha`, `status`; v7 (one plan = one ERP invoice): `kind` (`installment` \| `credit`), `invoice_no`, `sale_date`, `frequency`, `custom_days`, `items_json`, `guarantor_json`, `written_off_poisha` | `(customer_id)` | closed/cancelled = returned/cancelled in the ERP, never offered for collection |
| `schedule_lines` | `(erp_plan_id, seq) PK`, `due_date`, `amount_poisha`, `paid_poisha`, `status`, `estimated`, `late_fee_poisha` (inside `amount_poisha`), `rolled` (v7) | `(due_date)` | |
| `erp_payments` | `erp_payment_id PK`, `customer_id`, `plan_id`, `date`, `amount_poisha`, `method`, `source`, `receipt_no`, `reversed`, `method_label`, `collector_name`, `advance`, `discount_poisha` (v7) | `(customer_id, date DESC)` | last 20 per customer |
| `collections` | `client_id PK`, `server_id`, `customer_id`, `erp_plan_id`, `amount_poisha`, `method`, `transaction_ref`, `receipt_no UNIQUE`, `physical_receipt_no`, `payer_name`, `note`, `recorded_at`, `device_time`, `lat`, `lng`, `accuracy_m`, `mock`, `visit_client_id`, `photo_media_client_id`, `status` (`queued|received|posting|posted|conflict|resolved_*|voided`), `erp_receipt_no`, `conflict_code`, `conflict_message`, `resolution_text`, `flags_json`, `sync_state` | `(recorded_at DESC)`, `(customer_id)`, `(status)` | own collections, 60 days kept locally |
| `receipt_blocks` | `id PK`, `prefix`, `business_date`, `from_seq`, `to_seq`, `last_used` | `(business_date)` | |
| `cash_position` | single row: `server_on_hand_poisha`, `limit_poisha`, `as_of` | — | local unsynced adds computed in query |
| `deposits` | `client_id PK`, `server_id`, `amount_poisha`, `destination`, `reference`, `slip_media_client_id`, `deposited_at`, `status`, `reject_reason`, `sync_state` | `(deposited_at DESC)` | |
| `cash_closings` | `business_date PK`, totals, `confirmed_at`, `sync_state` | — | |
| `visits` | `client_id PK`, `server_id`, `customer_id`, `user_id` (v4; recorder from the server, null = recorded on this phone), `check_in_at`, `check_out_at`, `outcome`, `lat`, `lng`, `accuracy_m`, `mock`, `distance_to_pin_m`, `photo_media_client_ids_json`, `source`, `sync_state`, `co_work_session_id` (v4), `co_work_participant_ids_json` (v4; partners without the recorder, server's list replaces ours) | `(customer_id, check_in_at DESC)` | own + last 5 per customer from others + partners' joint visits |
| `notes` | `client_id PK`, `server_id`, `customer_id`, `author_id`, `author_name`, `category`, `text`, `voice_media_client_id`, `created_at`, `editable_until`, `sync_state` | `(customer_id, created_at DESC)` | last 20 per customer |
| `promises` | `client_id PK`, `server_id`, `customer_id`, `erp_plan_id`, `promised_date`, `promised_amount_poisha`, `status`, `note`, `sync_state`, `reminder_scheduled` | `(promised_date, status)` | |
| `tag_events` | `client_id PK`, `customer_id`, `previous_json`, `next_json`, `reason_code`, `reason`, `at`, `sync_state` | `(customer_id)` | |
| `location_proposals` | `client_id PK`, `customer_id`, `lat`, `lng`, `accuracy_m`, `photo_media_client_id`, `note`, `status` (`pending|approved|rejected`), `sync_state` (`waiting_photo|queued|synced|failed`), `decision_reason` (v3), `method` (v5, `gps|map`, default `gps`; `accuracy_m` is 0 for `map`), `device_geo_json` (v5, the phone's fix when a map pin was picked) | | |
| `attendance_events` | `client_id PK`, `type`, `at`, `device_time`, `lat`, `lng`, `accuracy_m`, `mock`, `selfie_media_client_id`, `sync_state` | `(at)` | |
| `attendance_day` | `business_date PK`, `status`, `first_in`, `last_out`, `break_min`, `late_min`, `breaks_json` | | computed locally, replaced by server |
| `cowork_sessions` (v4) | `id PK`, `business_date`, `status` (`open|ended`), `created_by`, `note`, `members_json` (userId, name, status `invited|accepted|rejected|left`, invitedBy, invitedAt, respondedAt, leftAt), `created_at`, `ended_at` | | server-owned (pull entity `cowork_session` + online calls) |
| `handovers` | `server_id PK`, `from_user_name`, `to_user_id`, `summary_json`, `status`, `expires_at`, `role` (`incoming|outgoing`) | | |
| `media_queue` | `client_id PK`, `kind`, `local_path`, `sha256`, `size_bytes`, `captured_at`, `owner_entity`, `owner_client_id`, `server_media_id`, `state` (`pending|uploading|uploaded|confirmed|failed`), `attempts`, `next_attempt_at` | `(state, next_attempt_at)` | files under app-private dir; purged 7 days after confirm |
| `outbox` | `mutation_id PK`, `entity`, `op`, `payload_json`, `depends_on_json`, `created_at`, `state` (`held|pending|sending|done|failed`; `held` = waiting for its photo), `attempts`, `next_attempt_at`, `last_error` | `(state, created_at)` | never deleted while `pending/failed`; `done` purged after 7 days |
| `id_map` | `client_id PK`, `entity`, `server_id` | | |
| `sync_state` | single row: `pull_cursor`, `last_pull_at`, `last_push_at`, `server_offset_ms`, `bootstrap_done` | | |
| `location_queue` | `id INTEGER PK AUTOINCREMENT`, `t`, `lat`, `lng`, `acc`, `spd`, `hdg`, `alt`, `act`, `bat`, `chg`, `mock` | `(t)` | cap 20,000 |
| `contact_attempts` (v2) | `client_id PK`, `server_id`, `customer_id`, `channel` (`call`), `phone_index` (null for a guarantor call), `target` (v6, `customer|guarantor`, default `customer`), `at`, `outcome`, `sync_state` | | phone number never stored |
| `broadcasts` (v6) | `server_id PK`, `title_bn`, `title_en`, `body_bn`, `body_en`, `require_ack`, `sender_name`, `created_at`, `acked_at` (my tap time, then the server's), `ack_state` (`none|queued|synced|failed`), `ack_mutation_id` | | server-owned (pull entity `broadcast`); a row with a queued tap is never deleted |
| `notifications` | `server_id PK`, `type`, `title`, `body`, `data_json`, `read_at`, `created_at` | `(created_at DESC)` | 30 days |
| `kv_settings` | `key PK`, `value_json` | | permissions snapshot, flags, settings, consents |

## 3. Migrations
Current `schemaVersion` = **8**. v7 → v8 (0.11.0, contract 1.19.0): add the branch and assignee-name columns on `customers` and set `sync_state.bootstrap_done = 0`, so the next sync takes a fresh snapshot of the whole branch (snapshot pages only upsert). v6 → v7 (0.10.0, contract 1.13.0): add the ERP-shape columns on `customers`, `plans`, `schedule_lines` and `erp_payments` listed above (all nullable or with defaults: `kind` = `installment`, amounts 0, flags false; the next pull fills them). v5 → v6 (0.9.0): create `broadcasts`; add `contact_attempts.target` (default `customer`; a v1 file gets the column when the v2 step creates the table). v4 → v5 (0.8.0): add `location_proposals.method` (default `gps`, so queued old proposals keep their body) and `location_proposals.device_geo_json`. v3 → v4 (0.6.0): create `cowork_sessions`; add `visits.user_id`, `visits.co_work_session_id`, `visits.co_work_participant_ids_json`. v2 → v3 (0.3.0): add `location_proposals.decision_reason`. v1 → v2 (0.2.0): create `contact_attempts`, add index `idx_location_queue_t`. Tested in `test/core/migration_test.dart` (outbox rows survive). `bat`/`chg` in `location_queue` stay null until a battery plugin is added.

drift `schemaVersion` integer; each feature contributes `MigrationStep`s registered in `core/db/migrations`; every version upgrade is tested from **every** previous released schema (`drift_dev schema dump` + `verifySchema` tests). Never drop a table containing `outbox`/`collections` rows without migrating data.

## 4. Data lifecycle on device
- Out-of-scope customers (tombstones) deleted after their pending mutations are done.
- Own collections kept 60 days, visits/notes 30 days beyond scope.
- Logout: requires empty outbox (or explicit manager-forced logout) → wipe DB file + media dir + secure storage tokens.
- 5 failed PINs → lock; requires online password login of the **same** user to unlock (data kept encrypted).
