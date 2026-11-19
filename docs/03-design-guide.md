# 03 — Design Guide (staff-app) — Material 3, Bangla-first, field-ready

Design intent: **a tool you can use with one thumb, in sunlight, on a 5.5-inch ৳10,000 phone with a dusty screen, while a customer watches.** Calm, confident, fast. Every screen answers "what should I do next?" Material 3 is the system; the brand and status colours come from the shared tokens so the app and admin panel feel like one product.

---

## 1. Principles
1. **Next best action.** Home shows today's priorities in order (promised today → due today → overdue nearest) with one-tap Collect / Visit.
2. **One-handed.** Primary actions in the bottom 40 % of the screen: bottom navigation, FAB, bottom sheets. No critical action in the top corners.
3. **Offline is normal, not an error.** Sync state is a quiet chip, not a scary dialog. Every action works offline and says so ("Saved on phone · will sync").
4. **Money moments are deliberate.** Collection uses a dedicated full-screen flow with a large amount keypad, a review step and a clear success screen with receipt number.
5. **Sunlight-readable.** High contrast by default; optional "High contrast" mode; minimum body 16 sp; no light-grey text on white.
6. **Bangla-first.** Bangla default; layout tested with Bangla strings (≈ 15–25 % taller line boxes).
7. **Honest tracking.** When tracking is on, the user always sees it (status chip + persistent notification).
8. **Forgiving.** Undo for non-money actions; drafts autosave; nothing lost when the app is killed.

## 2. Shared design tokens v1.1 (identical to admin-web)

Canonical values: `admin-web/docs/03-design-guide.md §2`. Repeated here for the app team; **must stay identical**.

| Group | Tokens (light) |
|---|---|
| Brand | 50 `#EEF3FF` · 100 `#DCE5FF` · 200 `#BACBFF` · 300 `#8EA8FF` · 400 `#5F7DF7` · 500 `#3D5AE8` · **600 `#2C44CC` (primary)** · 700 `#2437A6` · 800 `#1F3085` · 900 `#1C2B6B` · 950 `#121A42` |
| Neutral | 0 `#FFFFFF` · 25 `#FBFCFD` · 50 `#F6F7F9` · 100 `#EDEFF3` · 200 `#DDE1E8` · 300 `#C4CAD4` · 400 `#98A1B0` · 500 `#6B7587` · 600 `#4D5666` · 700 `#374050` · 800 `#232A36` · 900 `#151A23` · 950 `#0B0E14` |
| Semantic fg / bg | success `#166534`/`#E8F6EC` · warning `#92400E`/`#FEF3C7` · danger `#B91C1C`/`#FDECEC` · info `#0369A1`/`#E6F4FB` |
| Status fg / bg | overdue `#C62828`/`#FDECEC` · dueToday `#92400E`/`#FEF3C7` · promised `#6D28D9`/`#F1EAFE` · current `#2C44CC`/`#EEF3FF` · paid `#166534`/`#E8F6EC` · badSuggested `#C2410C`/`#FFF1E8` (dashed) · tagged white on `#7F1D1D` · pending `#475569`/`#EEF1F5` · mock `#9D174D`/`#FCE7F3` |
| Dark (fg / bg) | text `#E7EAF0` on `#0B0E14`; surface `#121722`; raised `#1A2030`; primary `#7C93FA`; overdue `#F87171`/`#2D1212`; dueToday `#FBBF24`/`#2E2208`; promised `#A78BFA`/`#1F1536`; paid `#4ADE80`/`#0F2A1A`; pending `#A9B1BF`/`#1A2030`; tagged white on `#B91C1C` |
| Pay state (pin / fg / bg, v1.1) | bad `#DC2626`/`#B91C1C`/`#FDECEC` · missedMany `#EA580C`/`#C2410C`/`#FFF1E8` · missedOne `#EAB308`/`#854D0E`/`#FEF9C3` · dueToday `#2563EB`/`#1D4ED8`/`#E8F0FE` · onTrack `#16A34A`/`#166534`/`#E8F6EC` · paidOff `#64748B`/`#475569`/`#EEF1F5`; pin shadow `rgb(16 24 40 / 0.35)` |
| Pay state dark (pin / fg / bg) | bad `#EF4444`/`#F87171`/`#2D1212` · missedMany `#F97316`/`#FB923C`/`#2E1A0C` · missedOne `#FACC15`/`#FDE047`/`#2E2A08` · dueToday `#60A5FA`/`#93C5FD`/`#0F1F3D` · onTrack `#4ADE80`/`#4ADE80`/`#0F2A1A` · paidOff `#94A3B8`/`#A9B1BF`/`#1A2030` |
| Spacing (4-pt) | 0, 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64 (dp) |
| Radius | xs 4 · sm 6 · md 8 · lg 12 · xl 16 · xxl 28 (M3 large FAB/sheets) · full |
| Motion | fast 120 ms · base 200 ms · slow 300 ms; standard `cubic-bezier(.2,0,0,1)`; emphasized M3 curves for sheets |
| Icons | Material Symbols Rounded, weight 400, fill 0 (fill 1 for selected nav) — mapping table in admin-web §2.7 |

**Pay state (v1.1, field-api `PayState`, ADR-035):** the colour of a customer's map pin and pay-state badge, worst first: bad = tagged bad or the full term is over with money left (glyph `!`); missedMany = 2+ installments missed (glyph = number missed); missedOne = one missed (glyph 1); dueToday = due today, nothing missed (dot); onTrack = everything due so far paid (check); paidOff = nothing left (check). The pin has the map-pin shape (round head, point on the spot), the pin colour as body with a 1.25 outline in the fg colour, a white face and the glyph in the fg colour; clusters take the worst state. admin-web uses these on its customer map since contract 1.14.0; the app's map still uses `status.*` glyph markers (§5.6) until it is moved to pay state.

## 3. Material 3 theme

### 3.1 ColorScheme (light)
Built with `ColorScheme.fromSeed(seedColor: Color(0xFF2C44CC))` **then overridden** so roles match tokens exactly:

| M3 role | Light | Dark |
|---|---|---|
| `primary` | `#2C44CC` | `#B9C6FF` (tone 80) |
| `onPrimary` | `#FFFFFF` | `#0F1F7A` |
| `primaryContainer` | `#DCE5FF` | `#2437A6` |
| `onPrimaryContainer` | `#121A42` | `#DCE5FF` |
| `secondary` | `#4D5666` | `#C4CAD4` |
| `secondaryContainer` | `#EDEFF3` | `#2A3242` |
| `tertiary` (promises) | `#6D28D9` | `#CDB8FF` |
| `error` | `#B91C1C` | `#FFB4AB` |
| `errorContainer` | `#FDECEC` | `#5C1414` |
| `surface` | `#FFFFFF` | `#121722` |
| `surfaceContainerLowest` | `#FFFFFF` | `#0B0E14` |
| `surfaceContainerLow` | `#FBFCFD` | `#151B27` |
| `surfaceContainer` | `#F6F7F9` | `#1A2030` |
| `surfaceContainerHigh` | `#EDEFF3` | `#212839` |
| `surfaceContainerHighest` | `#DDE1E8` | `#283043` |
| `onSurface` | `#151A23` | `#E7EAF0` |
| `onSurfaceVariant` | `#4D5666` | `#A9B1BF` |
| `outline` | `#98A1B0` | `#6B7587` |
| `outlineVariant` | `#DDE1E8` | `#2A3242` |

Status colours are a `ThemeExtension<StatusColors>` (fg, bg, icon per status) — never mapped onto M3 roles.
**High-contrast mode** (setting): `onSurfaceVariant → #232A36`, outlines → `#4D5666`, status fg darkened one step, borders 1.5 dp.

### 3.2 Typography
- Bangla: **Noto Sans Bengali** (bundled, weights 400/500/600/700, subset to Bengali + Latin + digits, ~350 KB total). Alternative for headings: **Hind Siliguri 600** (OD-M02).
- Latin and numbers: **Inter** (bundled, 400/500/600/700) with `FontFeature.tabularFigures()` for money and times.
- `fontFamily: 'Inter'`, `fontFamilyFallback: ['NotoSansBengali']` — Flutter shapes Bangla with HarfBuzz; verify conjuncts on device.
- Bangla `height` multiplier 1.35–1.45 to prevent matra clipping.

| M3 style | Size (sp) | Line height | Weight | Use |
|---|---|---|---|---|
| `displaySmall` | 36 | 44 | 600 | amount on collection keypad |
| `headlineMedium` | 28 | 36 | 600 | success amount, today's total |
| `headlineSmall` | 24 | 32 | 600 | screen titles (large app bar) |
| `titleLarge` | 22 | 28 | 600 | customer name in detail header |
| `titleMedium` | 18 | 26 | 600 | card titles, list primary text |
| `titleSmall` | 16 | 24 | 600 | section headers |
| `bodyLarge` | 17 | 26 | 400 | **default body** (larger than M3 default for sunlight/low vision) |
| `bodyMedium` | 16 | 24 | 400 | secondary text — minimum for content |
| `bodySmall` | 14 | 20 | 400 | meta (time ago, as-of) — never for important info |
| `labelLarge` | 16 | 22 | 600 | buttons |
| `labelMedium` | 14 | 20 | 600 | chips, badges |
| `labelSmall` | 12 | 16 | 600 | nav labels only |

Supports system font scale up to 1.3 without truncating money or buttons (test matrix §07).

### 3.3 Sizing
- Minimum touch target **48 × 48 dp**; primary buttons **56 dp** tall, full width in flows; the Collect action is an extended FAB, 56 dp tall, with icon and label.
- List rows: 72 dp (2-line) / 88 dp (3-line with badges).
- Screen margins 16 dp; card padding 16 dp; gap between cards 12 dp.
- Bottom navigation (M3 `NavigationBar`) 80 dp, 4 destinations.

## 4. Information architecture

Bottom navigation (4): **আজ (Today)** · **গ্রাহক (Customers)** · **ম্যাপ (Map)** · **আমি (Me)**.
Global: sync chip (top app bar), duty status chip, notifications bell. FAB on Today/Customers: **Collect** (extended FAB "আদায়").

```
Splash/version gate → Login → (first time) Change password → Set PIN → Privacy & tracking consent → Permissions primer (location, camera, notifications, battery optimisation)
                                          ↓
                                   Work-in screen (if not on duty)
                                          ↓
┌────────────┬──────────────┬────────────┬─────────────┐
│ Today      │ Customers    │ Map        │ Me          │
│ • Duty card│ • Search     │ • Pins     │ • Attendance│
│ • Progress │ • Filter     │ • Filters  │ • Cash      │
│ • Priority │   chips      │ • Bottom   │ • Deposits  │
│   list     │ • List       │   sheet    │ • Handovers │
│ • Problems │              │   preview  │ • Sync centre│
│ • Handover │              │ • Navigate │ • My perf.  │
│   inbox    │              │            │ • Settings  │
└────────────┴──────────────┴────────────┴─────────────┘
Customer detail → Collect flow · Visit check-in (camera) · Promise sheet · Note sheet · Tag sheet · Pin correction · Timeline
```

## 5. Key screens (layout specs)

### 5.1 Today
```
┌──────────────────────────────────────┐
│ শুভ সকাল, রাকিব        ⟳ সিঙ্ক হয়েছে · 🔔 │  top app bar: greeting, sync chip, bell
│ ● ডিউটিতে · ০৯:০৮ থেকে · বিরতি নিন      │  duty card (tap → break / work-out)
├──────────────────────────────────────┤
│ আজকের আদায়   ৳১৮,৫০০ / ৳৪০,০০০ ▓▓▓░░ │  progress card: collected vs target,
│ ভিজিট ৭/২০ · হাতে নগদ ৳১২,০০০ (২৪%)   │  visits, cash meter (warning colour ≥80%)
├──────────────────────────────────────┤
│ ⚠ ২টি সমস্যা দেখুন                   │  problems banner (conflicts, rejected) — only if any
│ ⇄ ১টি হস্তান্তর অপেক্ষমাণ              │  handover banner
├──────────────────────────────────────┤
│ প্রতিশ্রুতি আজ (৩)                     │  section headers with counts
│ ┌ করিম উদ্দিন  ৳৩,৫০০  ৪৮০ মি  [আদায়] ┐│  row: name, promised amt, distance, quick action
│ আজ দেয় (৫) …                          │
│ বকেয়া — কাছাকাছি (১২) …                 │  sorted by distance
└───────────────────────────── [＋ আদায়] ┘  extended FAB
```

**Target (0.7.0):** the progress card's money bar compares with my own daily target from the server (`MyTarget`); top right shows "আমার টার্গেট" for a personal target or a green "টার্গেট পূরণ" pill once met. Under it a thin visit-target bar: "ভিজিট টার্গেট  ৩ / ২০" (visit credit, decimals allowed). On a day off the line reads "আজ ছুটির দিন, টার্গেট নেই" and no bars show.

### 5.1b Online / offline line (0.12.3)
A 28 dp line between the screen and the bottom tabs on every signed-in screen: 10 dp dot + labelMedium text, centred, on surfaceContainer. Online = success-green dot + "অনলাইন" (onSurface); offline = outline-grey dot + "অফলাইন" (onSurfaceVariant). Live region, so TalkBack reads a change.

### 5.2 Customer list
Search field (name, phone, code; Bangla & English; phonetic tolerant) · filter chips (horizontal scroll): আজ দেয়, বকেয়া, প্রতিশ্রুতি আজ, আমার, সম্ভাব্য খারাপ, চিহ্নিত, পিন নেই · sort menu (distance, days overdue, amount, name) · rows 88 dp: avatar initial in status-tinted circle, name (titleMedium), code · area (bodySmall), right side outstanding (titleMedium tabular) + badge, distance. Pagination: infinite scroll from local DB (instant), never network-bound. Since 0.11.0 (contract 1.19.0) the phone holds the whole branch: the আমার chip shows once colleagues' customers are on the phone; when the phone holds more than one branch, the row reads code · branch · area. The customer page header then adds a line with the branch and whose customer it is (storefront icon). Since 0.12.3 the top bar has a reload icon button (refresh, tooltip "গ্রাহক আবার লোড করুন") and the list reloads on pull-down; with no customer on the phone the empty state says loading (cloud-download icon + linear progress), failed (cloud-off icon + error code) or nothing yet, each with a filled Reload button; opening the tab with no customer on the phone starts a sync by itself; while a load runs with rows already on the phone, a secondaryContainer banner above the rows shows a 16 dp spinner, "গ্রাহক লোড হচ্ছে… (N জন)" and a linear progress bar (live region).

### 5.3 Customer detail
Large header (surfaceContainer): name bn (titleLarge) + en (bodyMedium), code, phone with call button, address with navigate button (opens Google Maps/any maps app via geo: intent), status badges, tag control. **Balance card**: total outstanding (headlineMedium), "ইআরপি অনুযায়ী · ১০:৪২" as-of, pending field collections line ("আপনার ৳৫,০০০ ইআরপি-তে অপেক্ষমাণ"). Plans as expandable cards with schedule list (paid ✓ / due / overdue). Since 0.10.0 (real ERP shape) a plan card is one ERP invoice: subtitle "INV-… · ১০টির মধ্যে ৮টি পরিশোধ · মাসিক" (or "বাকিতে বিক্রি"), products with model and serials (mono) and the plan guarantor above the lines, "বিলম্ব ফি ৳৫০ সহ" (labelSmall) under a line's amount, rolled lines hidden with a one-line count; returned/cancelled invoices last, title in onSurfaceVariant and a warning-coloured "not collectable" line. Header extras: ERP detailed address under the address (onSurfaceVariant), directions row with a signpost icon, and the **ERP risk chip** beside the status badges (speed icon + "ইআরপি গ্রেড C"; medium = warning, high = danger colours and the level in words, low = neutral, grade only; read only, never a filter). Action bar (sticky bottom): **আদায়** (primary filled) · ভিজিট · প্রতিশ্রুতি · নোট (tonal/outlined). Tabs below: টাইমলাইন · নোট · ভিজিট · প্রতিশ্রুতি.

### 5.4 Collect flow (full-screen, 3 steps, ≤ 15 s for a regular collection)
1. **Amount:** customer + plan selector (if > 1 plan) at top; quick chips: "কিস্তি ৳৯,৬৬৭", "বকেয়া ৳৮,৫০০", "প্রতিশ্রুতি ৳৩,৫০০"; large keypad (digits in Bangla or Latin per setting), amount in `displaySmall`; warning if amount > outstanding (allowed, flagged); warning `InfoBanner` (event-repeat icon) when the chosen installment invoice already has a payment today (0.10.0, OD-27), also repeated on the review step. Only collectable invoices are offered, named "INV-… · product".
2. **Method:** segmented large tiles: নগদ · বিকাশ · নগদ (Nagad) · রকেট · ব্যাংক · অন্যান্য, each with brand-neutral icon (no third-party logos unless licensed); transaction ID field (auto-uppercase, validated) for non-cash; optional physical receipt no., payer name, note; optional photo.
3. **Review:** summary card (customer, plan, amount in words in Bangla — "পাঁচ হাজার টাকা", method, txn, receipt no.), GPS status ("অবস্থান ১২ মি নির্ভুল"), slide-to-confirm or hold-to-confirm button (prevents accidental taps).
**Success:** check animation (respect reduced motion), amount, receipt no. (mono), "ফোনে সংরক্ষিত · সিঙ্ক হবে" or "সার্ভারে পৌঁছেছে", buttons: রসিদ শেয়ার (image), নতুন প্রতিশ্রুতি, শেষ.

### 5.5 Visit check-in
Camera screen (custom, camera package) with overlay guide; shutter 72 dp; after capture: preview with watermark (date-time, staff code, lat/lng), retake/use; outcome chips (large); note field; save. If GPS accuracy > 50 m: shows "অবস্থান খোঁজা হচ্ছে…" up to 20 s then allows save with flag.

**Co-work visit (0.6.0):** when the staff member has an accepted co-work partner and is on duty, a `SwitchListTile` card sits under the GPS banner: "কো-ওয়ার্ক ভিজিট", subtitle names the partners ("… সবার হিসাবে যোগ হবে"); on by default, tinted `secondaryContainer` while on; off says it will be a single visit.

### 5.6 Map
flutter_map with TileProvider config; pins = status glyph markers; clustering; my location button; filter chips row; tap pin → bottom sheet (peek 160 dp: name, outstanding, status, last note; expanded: last 3 notes, last visit, open promise, actions Collect/Visit/Navigate/Details). Offline: cached tiles of visited areas (and optional area packs, P4).

**Controls overlay (0.5.0):** top row = Map/List `SegmentedButton` (icons + labels) and the sync chip; below it a horizontally scrolling row of multi-select `FilterChip`s with counts (OR match) plus a clear chip when any is on; then the count pill ("ম্যাপে N জন" / "N জন গ্রাহক") and the "N without location" chip. List mode reuses `CustomerTile` sorted nearest first (distance from the last fix; no fix → a note above the list), customers without a pin last.

**Map pin screen (0.8.0, FR-CUS-011):** app bar with the title (লোকেশন দিন / লোকেশন ঠিক করুন) and a "type coordinates" icon. The map fills the top; the pin (`location_on`, 48 dp, primary, soft shadow) is fixed in the middle with its tip on the centre and a small shadow dot on the exact point; while the map moves the pin lifts 8 dp (no animation with reduced motion). The current pin is a hollow 24 dp `onSurfaceVariant` ring; the phone is a `secondary` dot. My-location small FAB bottom-right (spinner while locating). Panel below (max 45 % of the height, scrolls): customer name, one-line how-to, coordinates in mono with a pin icon (TalkBack live region), "N from the current pin", "You are N from the pin" (warning colour above 300 m), one banner: outside Bangladesh (danger, send disabled) / fake location (warning) / "set as soon as it is sent" (success) / "a manager checks" (info); optional photo button with a 48 dp thumbnail; one-line note. Bottom button: "পিন বসান" when it applies at once, else "অনুমোদনের জন্য পাঠান".

### 5.6a Co-work (0.6.0)
Today card (order 4, after the progress card): an invitation is a `secondaryContainer` card (groups icon, "{name} আজ আপনার সাথে একসাথে কাজ করতে চান", other members, the note in quotes, a "needs internet" line, Reject outlined + Accept filled, 48 dp). My group is a surface card: title, today's co-work visit count in primary, one row per member (40 dp initial avatar, name, green tick or a "waiting" pending badge; me first, marked "(আপনি)"), Leave (outlined, confirm dialog) and Ask more (tonal, only while seats are left). Off duty with no group: nothing; on duty with no group: a one-line "Work with a colleague" tile. The `/cowork` screen repeats the invitation and group cards, then "কাকে ডাকবেন?" with seats left, a card of `CheckboxListTile`s (avatar, name, code, coloured status: on duty / not on duty / in another group / in this group) and an optional note; the send button appears at the bottom with the count. Timeline: joint visits carry a "কো-ওয়ার্ক" badge (current tone) and "সাথে …" / "লিখেছেন …".

### 5.6b My performance and leaderboard (0.7.0)
Me tab card "আমার পারফরম্যান্স" (plus a "লিডারবোর্ড" row when visible to staff). The screen: month switcher (chevrons, 48 dp); money card (headline amount, achievement % in primary or success, 10 dp bar, "আজ পর্যন্ত লক্ষ্য … · পুরো মাসে …", then posted vs pending in ERP); visits card (credit "১৯৬ / ২৬০", %, 8 dp bar, single and co-work); three equal tiles (promises kept a/b, days present, late days in overdue colour when > 0); rank card in `primaryContainer` with a trophy (tap → leaderboard, current month only); daily chart: one bar per day, primary or success when the day's target was met, a 2 dp onSurface tick at the day's target, days off as a muted stub, first/last date under it, a Semantics summary. Offline with a cached month: warning banner "ইন্টারনেট নেই। {time}-এর হিসাব…". Leaderboard: Today / This month `SegmentedButton`, metric `ChoiceChip`s, my-rank banner, rows 64 dp (rank in a 32 dp circle for the top three, primary for first; plain number otherwise; name, code, value right-aligned tabular), my row in `primaryContainer` and bold, "র‍্যাঙ্কে নেই" group below, a footnote on what counts.

### 5.7 Me
Attendance card (today timeline: in, breaks, out; buttons বিরতি শুরু/শেষ, কাজ শেষ); Cash card (on hand, limit meter, deposit button, deposit history); Handovers; Sync centre (queued counts by type, last sync, Problems list with explanations and "manager notified" state, Sync now); My performance (month); Settings (language, digits, theme, high contrast, text size preview, PIN/biometric, privacy notice, battery optimisation guide, about/version, logout).

### 5.8 Work-in / work-out
Full-screen card: date, shift, GPS status, optional selfie (front camera), big button **কাজ শুরু**. Work-out shows end-of-day summary (collections by method, deposits, on hand, visits, promises created, unsynced items warning) → **কাজ শেষ**. Tracking state explained in one line.

## 6. Components
| Component | Spec |
|---|---|
| `StatusBadge` | 24 dp tall, radius 6, icon 16 + label (labelMedium), fg/bg from StatusColors; tagged = filled |
| `MoneyText` | tabular figures; `৳` prefix; Bangla/Latin digits; South-Asian grouping; colour neutral (never red for amounts—status badge conveys state) |
| `SyncChip` | states: synced (check, neutral) · syncing (spinner) · queued N (cloud-upload, pending colour) · problem N (error colour) · offline (cloud-off) |
| `DutyChip` | off duty (neutral) · on duty (success dot, "ট্র্যাকিং চালু") · on break (warning) |
| `CustomerTile` | 88 dp, see §5.2 |
| `AmountKeypad` | 3×4 grid, keys 72 dp, haptic on press, backspace long-press clears |
| `HoldToConfirmButton` | 56 dp, fills over 800 ms, cancel on release; accessible alternative: double-tap with TalkBack |
| `BottomSheet` | M3 modal; radius 28; drag handle; max 90 % height |
| `ReasonSheet` | reason chips + text (min 10 chars) for tag, cancel promise |
| `EmptyState` | icon 48 dp, title, one sentence, action |
| `Banner` | M3 banner for problems/handover/version |
| `Snackbar` | for undo and confirmations ("নোট সংরক্ষিত · পূর্বাবস্থা") |

## 7. States & feedback
- **Loading:** local DB makes most screens instant; network-only views (fresh balance refresh, route) show shimmer.
- **Offline:** SyncChip "অফলাইন"; actions proceed; no blocking dialogs.
- **Errors:** human message + what happens next; technical code under "বিস্তারিত".
- **Haptics:** light on keypad, success pattern on saved collection, error buzz on validation.
- **Sounds:** none by default.

## 8. Accessibility
- Targets ≥ 48 dp; contrast per tokens; high-contrast mode; font scale ≤ 130 % supported; TalkBack labels in Bangla on all icons; money read as words (`semanticsLabel: "পাঁচ হাজার টাকা"`); focus order logical; no information by colour alone; reduced motion respected.

## 9. Localization
- `flutter_localizations` + `intl` ARB files (`app_bn.arb` default, `app_en.arb`); `l10n.yaml` with `nullable-getter: false`.
- Number/date formatting via `core/format` only (Bangla digits toggle, South-Asian grouping, Dhaka timezone with `timezone` package).
- Amount in words (Bangla and English) helper for review screen and receipts.

## 10. Receipt image (share)
1080 × 1350 px PNG rendered offscreen: brand header, "Field receipt / মাঠ রসিদ", receipt no. (mono), date-time, customer name & code, plan/product, amount (large) + in words, method + txn ref, collector name & code, status note "ইআরপি-তে পোস্টের অপেক্ষায়" if not posted, hotline, QR with signed verification link (P4). Shared via Android share sheet (WhatsApp, Messenger, SMS).

## 11. App icon & splash
Adaptive icon: brand.600 background, white mark; monochrome layer for Android 13 themed icons. Splash (Android 12 SplashScreen API): brand mark on neutral.0 (dark: neutral.950); no long animations.
