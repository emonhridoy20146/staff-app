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

## 2. Shared design tokens v1.4 (identical to admin-web)

Canonical values: `admin-web/docs/03-design-guide.md §2`. Repeated here for the app team; **must stay identical**.

| Group | Tokens (light) |
|---|---|
| Brand | 50 `#EEF3FF` · 100 `#DCE5FF` · 200 `#BACBFF` · 300 `#8EA8FF` · 400 `#5F7DF7` · 500 `#3D5AE8` · **600 `#2C44CC` (primary)** · 700 `#2437A6` · 800 `#1F3085` · 900 `#1C2B6B` · 950 `#121A42` |
| Neutral | 0 `#FFFFFF` · 25 `#FBFCFD` · 50 `#F6F7F9` · 100 `#EDEFF3` · 200 `#DDE1E8` · 300 `#C4CAD4` · 400 `#98A1B0` · 500 `#6B7587` · 600 `#4D5666` · 700 `#374050` · 800 `#232A36` · 900 `#151A23` · 950 `#0B0E14` |
| Semantic fg / bg | success `#166534`/`#E8F6EC` · warning `#92400E`/`#FEF3C7` · danger `#B91C1C`/`#FDECEC` · info `#0369A1`/`#E6F4FB` |
| Status fg / bg | overdue `#C62828`/`#FDECEC` · dueToday `#92400E`/`#FEF3C7` · promised `#6D28D9`/`#F1EAFE` · current `#2C44CC`/`#EEF3FF` · paid `#166534`/`#E8F6EC` · badSuggested `#C2410C`/`#FFF1E8` (dashed) · tagged white on `#7F1D1D` · pending `#475569`/`#EEF1F5` · mock `#9D174D`/`#FCE7F3` · returned `#0F766E`/`#E3F5F2` (v1.4; dark `#2DD4BF`/`#0B2624`, icon package-return / `assignment_return`) |
| Dark (fg / bg) | text `#E7EAF0` on `#0B0E14`; surface `#121722`; raised `#1A2030`; primary `#7C93FA`; overdue `#F87171`/`#2D1212`; dueToday `#FBBF24`/`#2E2208`; promised `#A78BFA`/`#1F1536`; paid `#4ADE80`/`#0F2A1A`; pending `#A9B1BF`/`#1A2030`; tagged white on `#B91C1C` |
| Pay state (pin / fg / bg, v1.1) | bad `#DC2626`/`#B91C1C`/`#FDECEC` · missedMany `#EA580C`/`#C2410C`/`#FFF1E8` · missedOne `#EAB308`/`#854D0E`/`#FEF9C3` · dueToday `#2563EB`/`#1D4ED8`/`#E8F0FE` · onTrack `#16A34A`/`#166534`/`#E8F6EC` · paidOff `#64748B`/`#475569`/`#EEF1F5`; pin shadow `rgb(16 24 40 / 0.35)` |
| Pay state dark (pin / fg / bg) | bad `#EF4444`/`#F87171`/`#2D1212` · missedMany `#F97316`/`#FB923C`/`#2E1A0C` · missedOne `#FACC15`/`#FDE047`/`#2E2A08` · dueToday `#60A5FA`/`#93C5FD`/`#0F1F3D` · onTrack `#4ADE80`/`#4ADE80`/`#0F2A1A` · paidOff `#94A3B8`/`#A9B1BF`/`#1A2030` |
| Tag kind fg / bg (v1.3) | absconded `#7F1D1D`/`#FBDADA` · legal `#991B1B`/`#FDE3E3` · refused_to_pay `#B91C1C`/`#FDECEC` · other `#D42020`/`#FEF2F2` · fraud_suspected `#9D174D`/`#FCE7F3` · repeated_broken_promise `#6D28D9`/`#F1EAFE` · plan_ended_unpaid `#C2410C`/`#FFF1E8` |
| Tag kind dark fg / bg | absconded `#EF4444`/`#2D1212` · legal `#F87171`/`#2D1212` · refused_to_pay `#FCA5A5`/`#2D1212` · other `#FECACA`/`#2D1212` · fraud_suspected `#F472B6`/`#2E1020` · repeated_broken_promise `#A78BFA`/`#1F1536` · plan_ended_unpaid `#FB923C`/`#2E1A0C` |
| Action tone fg / bg (v1.3) | brand `#2437A6`/`#DCE5FF` · teal `#115E59`/`#D5F3F0` · green `#166534`/`#DDF3E4` · violet `#5B21B6`/`#EBE5FD` · amber `#92400E`/`#FEF0C7` |
| Action tone dark fg / bg | brand `#B9C6FF`/`#1B2757` · teal `#5EEAD4`/`#0E2F2D` · green `#4ADE80`/`#0F2A1A` · violet `#C4B5FD`/`#251A45` · amber `#FBBF24`/`#2E2208` |
| Spacing (4-pt) | 0, 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64 (dp) |
| Radius | xs 4 · sm 6 · md 8 · lg 12 · xl 16 · xxl 28 (M3 large FAB/sheets) · full |
| Shadow (v1.2) | sm `0 1px 2px rgb(16 24 40 / 0.06), 0 1px 3px rgb(16 24 40 / 0.08)` · md `0 4px 12px -2px rgb(16 24 40 / 0.08), 0 2px 4px -2px rgb(16 24 40 / 0.04)`; light theme only — dark mode has no shadow, depth comes from the surface steps and the 1 px border (`Shadows.of(brightness, level)`) |
| Motion | fast 120 ms · base 200 ms · slow 300 ms; standard `cubic-bezier(.2,0,0,1)`; emphasized M3 curves for sheets |
| Icons | Material Symbols Rounded, weight 400, fill 0 (fill 1 for selected nav) — mapping table in admin-web §2.7 |

**Tokens v1.2 (2026-11-26, Home redesign, ADR-M41):** adds only the `shadow.sm` / `shadow.md` elevation group; no colour, spacing or radius changed. **admin-web shares tokens v1.x:** the canonical copy in `admin-web/docs/03-design-guide.md §2` and its `design-tokens.json` must take the same `shadow` group (web: `box-shadow` with the same values; dark: none) — follow-up for the admin-web session.

**Pay state (v1.1, field-api `PayState`, ADR-035):** the colour of a customer's map pin and pay-state badge, worst first: bad = tagged bad or the full term is over with money left (glyph `!`); missedMany = 2+ installments missed (glyph = number missed); missedOne = one missed (glyph 1); dueToday = due today, nothing missed (dot); onTrack = everything due so far paid (check); paidOff = nothing left (check). The pin has the map-pin shape (round head, point on the spot), the pin colour as body with a 1.25 outline in the fg colour, a white face and the glyph in the fg colour; clusters take the worst state. admin-web uses these on its customer map since contract 1.14.0; the app's map still uses `status.*` glyph markers (§5.6) until it is moved to pay state.

**Map places (FR-M-063, ADR-M28):** shown on every map, by zoom like Google Maps: below zoom 13 (`placeIconMinZoom`) nothing; from 13 a **24 dp square** (`Space.s24`, `Radii.sm` corners, semantic `info` bg with a 1.5 dp `info` fg border, the kind's Material icon at 16 dp in fg; `warning` while a move waits for the office); from 16 (`placeLabelMinZoom`) the name to its right in a `surface` label (92 % opacity, `labelMedium`, `Radii.xs`, one line, ellipsis, at most 200 dp wide). Deliberately not the customer pin (round/teardrop) so the two never look alike. On an interactive map the square sits in a 48 dp tap target; on the pin-setting screen places are reference only (no target, touches go to the map). The semantics label reads name and kind. No new tokens. Every map opens at `defaultMapCenter` (Galachipa, zoom 12) when there is no better point.

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

### 5.1 Today (Home) — redesign 2026-11-26 (ADR-M41), v2 the same day (ADR-M45)
```
┌──────────────────────────────────────┐
│ ▣ বরিশাল সদর        ● অনলাইন  📍  🔔 │  shell top bar (unchanged)
│ শুভ সকাল, রাকিব              ⟳ সিঙ্ক  │  header: greeting headlineSmall w700 (wraps to 2 lines,
│ 📅 ১৫ নভেম্বর ২০২৬                     │  never cut), date with icon; SyncChip right
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ │  SUMMARY CARD ("hero"): 4 dp primary stripe on top,
│ ┃ [▣] আজকের আদায়        বিস্তারিত ▾ ┃ │  surface, xl radius, border, shadow.md (light only)
│ ┃ ৳৫,৫০০                              ┃ │  amount headlineMedium w700 tabular
│ ┃ লক্ষ্য ৳৪০,০০০ · আমার টার্গেট         ┃ │  target line (wraps); "টার্গেট পূরণ" pill when met
│ ┃ ▓▓░░░░░░░░░░░░░░░░░░    ১৩% পূরণ    ┃ │  10 dp bar + percent
│ ┃ (open: visit target, cash/mobile/   ┃ │  details in an inner surfaceContainerLow panel
│ ┃  visits, cash meter)                ┃ │
│ ┠──────────────────────────────────┨ │
│ ┃ [ ৫ প্রতিশ্রুতি ][ ৭ আজ দেয় ][ ১২ বকেয়া ]┃ │  KPI tiles in status colours (promised, dueToday,
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ │  overdue); 0 = neutral; tap picks that filter (v2)
│ ● ডিউটিতে · ১০:০০ থেকে       বিস্তারিত ▾ │  duty card (attendance feature)
│ ⚠ alerts (todayCards, alert: true)     │  v2: only when there is one, above the shortcuts: tracking,
│                                      │  must-read notice, sync problem, tasks, receipts, handover
│ ┌──────────────────────────────────┐ │  QUICK ACTIONS (v2): one card, 3 × 3 equal cells; 40 dp
│ │ (◔)উপস্থিতি ✓  (▤)আজকের কাজ  (▣)হাতে নগদ │ │  circle in an `action.*` tone, label on up to 2 lines,
│ │ (▧)আমার কাজ   (📣)নোটিশ ②   (💬)অনুরোধ  │ │  count badge, attendance done / to-do mark
│ │ (👤)সম্ভাব্য গ্রাহক (📈)পারফরম্যান্স (☂)ছুটি │ │
│ └──────────────────────────────────┘ │
│ feature cards (todayCards, the rest)   │  co-work, visit suggestion, broken promises
│ আজকের কাজের তালিকা                      │  titleLarge + one-line explanation
│ [সব ২৪][আজ প্রতিশ্রুতি ৫][আজ দেয় ৭][বকেয়া ১২]¦[খারাপ ট্যাগ ৩]… │  FILTER CHIPS (v2): pinned under the top bar, scroll sideways
│ [🤝] আজ প্রতিশ্রুতি (৫)                   │  section header: 32 dp toned icon square, titleMedium,
│ ┌ work rows (CustomerWorkRow) ───────┐ │  toned count pill; rows in one surface card (shadow.sm)
│ [📅] আজ দেয় (৭) …                       │
│ [➤] বকেয়া · কাছের আগে (১২) … [আরও ৪ জন →]│  outlined "N more" button picks the Overdue filter (v2)
└──────────────────────────────────────┘  no FAB (2026-11-23): each row has its own Collect
```
- **Rhythm:** 16 dp screen margin, 12 dp between cards (`Space.cardGap`, collapsing when a feature card renders nothing), 32 dp before the work list, 20 dp above each section header.
- **One card style:** surface, `Radii.xl`, 1 px `outlineVariant`, `Shadows.sm` (summary card `Shadows.md`); banners use `Radii.xl` too. Status colours appear only where they carry meaning (KPIs, section icons and counts, marks); the brand colour as a surface only in the summary stripe and icon chips.
- **Loading:** three skeleton work rows (static `surfaceContainerHigh` bars shaped like name / amount / marks / Collect; no spinner, no shimmer animation; TalkBack reads "লোড হচ্ছে…"). **Empty / all done** and **error** sit in the same card style.
- **Small phones (360 dp) and 1.3 text:** greeting, collected label, KPI labels and tile labels wrap to two lines instead of being cut; the target line wraps under the amount. Pull to refresh runs `syncNow` (AlwaysScrollable, also when the list is empty).
- **Order (v2, ADR-M45):** header → summary card → duty card → alerts → quick actions → feature cards → work list, the same all day. A Today card says whether it is an alert (`TodayCardDef.alert`: tracking health, must-read notice, sync problems, tasks, receipts low, handover); alerts and the cash-limit warning come before the shortcuts, so nine tiles never push "tracking is not running" under the fold. On a 360 × 780 dp phone the first screen still answers: on duty? how much today? what is next (the three counts)?
- **Quick actions (v2, FR-M-083):** one surface card holding a grid of equal cells, three to a row. Features give their shortcuts through the manifest (`quickActions`), so a module that is off or not permitted leaves no cell and Home imports no feature screen. The grid shows the first 9 by order, 6 when fewer than 9 are there, 3 when fewer than 6: always full rows; what does not fit stays in Me. The nine: উপস্থিতি · আজকের কাজ · হাতে নগদ / আমার কাজ · নোটিশ · আমার অনুরোধ / সম্ভাব্য গ্রাহক · পারফরম্যান্স · ছুটি; the bench that fills a gap: লিডারবোর্ড, সহকর্মীর সাথে কাজ, হস্তান্তর, সিঙ্ক সেন্টার. **Cell:** ≥ 88 dp high (`Sizes.row3`), ripple with `Radii.lg`; a 40 dp circle in the tone's bg with a 22 dp icon in its fg (`action.*`, §2: brand, teal, green, violet, amber; green is money, amber is time and notices; no row or column repeats a tone), 8 dp, the label in labelMedium on up to two lines; a count `Badge` on the circle for what waits behind it (open tasks, unread notices, news on my requests); attendance keeps its done (success, check) / still to give (warning, "!") mark on the circle with the words under the label (FR-M-042). Every row is as tall as the tallest, so all cells are one size at any text size. TalkBack: the card is "শর্টকাট", a cell is one button, "নোটিশ: ২টি অপেক্ষায়", "উপস্থিতি, হাজিরা বাকি".
- **Filter chips (v2, FR-M-082):** single choice, each chip an icon (18 dp, the list's status colour), its words and its count (tabular, w700): **সব** · **আজ প্রতিশ্রুতি** · **আজ দেয়** · **বকেয়া** ¦ **খারাপ ট্যাগ** · **ভাঙা প্রতিশ্রুতি** (the last only when promises are on and permitted). Chips are 48 dp targets, 8 dp apart, in one row that scrolls sideways; a hairline divider sets the two lenses apart from the four groups of the list. The row is a pinned header (56 dp, page background) that stays under the top bar while the list scrolls, with a hairline once rows pass beneath it. The picked chip is always in sight: the row brings it to its middle in 120 ms (at once with reduced motion) when a count in the summary card, "N more" or the choice kept for the session picks one past the edge. **সব** shows the three sections (Overdue cut at 8, "আরও N জন" picks the Overdue filter in place); any other chip shows only that list, whole, nearest first, under one section header, as lazy rows. A chip's number is always its section's number and the summary card's; **সব** is their sum. An empty filter is one calm card ("এই তালিকায় কেউ নেই") with "সব দেখুন". The choice is kept until sign-out or the app is closed; it is not stored. Two bad-tag frames in a row have no hairline between them.
- Screenshots: `test/screenshots/goldens/home/` (bn/en, light/dark, 360 dp, 1.3, full page, start of day) and `goldens/tags/home-bad-tags-*` (a picked filter); before: `docs/screenshots/home-before/` (v1) and `docs/screenshots/home-settings-v2-before/` (v2).

**Home row (`CustomerWorkRow`, 2026-11-23, FR-M-067):** replaces `CustomerTile` on Today. No avatar, so lines 2 and 4 get the full width. Line 1 name (titleMedium, one line, …) and the outstanding (titleMedium tabular) at the far right. Line 2 bodySmall onSurfaceVariant: branch name and the open invoices' numbers (newest sale first, max 2 lines). Line 3 the four work marks at 32 dp with 20 dp icons (were 22/14) and, at the right end, `FilledButton.tonalIcon` "আদায়" with a payments icon, 48 dp high; it opens the collect screen for that customer. Line 4 "২ মাস ১৫ দিন বকেয়া" (bodyMedium w600, overdue fg) only when overdue. An open promise adds "প্রতিশ্রুতি নিয়েছেন: <name>" with a handshake icon in the promised colour; the name is the promise's `createdByName`, the user for a promise made on this phone, or a colleague's; unknown → no line. The extended "আদায়" FAB is gone.

**Target (0.7.0):** the progress card's money bar compares with my own daily target from the server (`MyTarget`); top right shows "আমার টার্গেট" for a personal target or a green "টার্গেট পূরণ" pill once met. Under it a thin visit-target bar: "ভিজিট টার্গেট  ৩ / ২০" (visit credit, decimals allowed). On a day off the line reads "আজ ছুটির দিন, টার্গেট নেই" and no bars show.

### 5.1b Online / offline mark (0.12.3; moved to the top bar 2026-11-23)
`OnlineDot` in the app's top bar (the branch bar, primaryContainer) just left of the GPS icon, on every signed-in tab: 10 dp dot with a 1.5 dp surface ring + labelMedium word in onPrimaryContainer. Online = success-green dot + "অনলাইন"; offline = outline-grey dot + "অফলাইন" (text at 75 %). The word is always there (never colour alone); live region, so TalkBack reads a change. The 28 dp strip above the bottom tabs is removed.

### 5.2 Customer list
Search field (name, phone, code; Bangla & English; phonetic tolerant) · filter chips (horizontal scroll): আজ দেয়, বকেয়া, প্রতিশ্রুতি আজ, আমার, সম্ভাব্য খারাপ, চিহ্নিত, পিন নেই · sort menu (distance, days overdue, amount, name) · rows 88 dp: avatar initial in status-tinted circle, name (titleMedium), code · area (bodySmall), right side outstanding (titleMedium tabular) + badge, distance. Pagination: infinite scroll from local DB (instant), never network-bound. Since 0.11.0 (contract 1.19.0) the phone holds the whole branch: the আমার chip shows once colleagues' customers are on the phone; when the phone holds more than one branch, the row reads code · branch · area. The customer page header then adds a line with the branch and whose customer it is (storefront icon). **Invoice type (2026-11-23, FR-M-066):** the chip row starts with two type chips, "কিস্তি N" (event-repeat icon) and "বাকি বিক্রি N" (receipt icon), then a vertical outlineVariant divider, then the status chips. One type at a time; tapping the picked one clears it. The two groups combine with AND (বকেয়া + কিস্তি = overdue customers with an open installment invoice); each chip's number is what tapping it would show. A customer with both kinds matches both. Rows show `InvoiceKindLabel` first in the badge line: "কিস্তি" or "বাকি" for one open invoice, counts per kind for several ("১ কিস্তি", "২ বাকি" as two chips; TalkBack: "খোলা ইনভয়েস: ১ কিস্তি · ২ বাকি"). Open = still owed and not returned, cancelled or settled. Since 0.12.3 the top bar has a reload icon button (refresh, tooltip "গ্রাহক আবার লোড করুন") and the list reloads on pull-down; with no customer on the phone the empty state says loading (cloud-download icon + linear progress), failed (cloud-off icon + error code) or nothing yet, each with a filled Reload button; opening the tab with no customer on the phone starts a sync by itself; while a load runs with rows already on the phone, a secondaryContainer banner above the rows shows a 16 dp spinner, "গ্রাহক লোড হচ্ছে… (N জন)" and a linear progress bar (live region).

### 5.2a Bad-tag customers (2026-11-26, FR-M-081)
A customer whose tag is set with severity bad or legal (a missing or unknown severity counts as bad; `watch` does not), or whose latest visit on the phone says `runaway` with no later visit or collection, is framed on every customer row: Home (`CustomerWorkRow`), Customers and its search results, the Collect picker, the Map list and sheets (`CustomerTile`), and the customer page header. **`TagFrame`:** a border in the kind's `status.tag.*` fg, `Radii.md` (header `Radii.lg`), 8 dp inside the row, with the **`TagChip`** (icon 16 + short word) on its top edge 8 dp in, so framed and plain rows keep the same 16 dp content column. 1.5 dp; পলাতক 2 dp with a filled chip; +0.5 dp in high contrast. When several apply: absconded tag → runaway visit → legal → the reason. In `CustomerTile` the initial takes the kind's colours and the chip replaces the plain "চিহ্নিত" badge; a `watch` tag keeps that badge and gets no frame. TalkBack: "খারাপ ট্যাগ: পলাতক", or "শেষ ভিজিটে পলাতক" when it comes from a visit. Customer page: the tag card is in the kind's colours with "<reason> · <level>" and who tagged it; a runaway visit adds a line with its time. **Tag sheet:** each reason is a full-width 56 dp option with its swatch (the kind's icon in its colour on its tint), its words and a radio mark; picked, it takes the kind's frame and tint. Under the options a live line shows the chip the customer's row will get for the chosen level and reason (Legal → the legal chip, Watch → a sentence saying there is no frame), and the Tag button takes that colour. Map pins are unchanged.

### 5.3 Customer detail
Large header (surfaceContainer): name bn (titleLarge) + en (bodyMedium), code, phone with call button, address with navigate button (opens Google Maps/any maps app via geo: intent), status badges, tag control. **Balance card**: total outstanding (headlineMedium), "ইআরপি অনুযায়ী · ১০:৪২" as-of, pending field collections line ("আপনার ৳৫,০০০ ইআরপি-তে অপেক্ষমাণ"). Plans as expandable cards with schedule list (paid ✓ / due / overdue). Since 0.10.0 (real ERP shape) a plan card is one ERP invoice: subtitle "INV-… · ১০টির মধ্যে ৮টি পরিশোধ · মাসিক" (or "বাকিতে বিক্রি"), products with model and serials (mono) and the plan guarantor above the lines, "বিলম্ব ফি ৳৫০ সহ" (labelSmall) under a line's amount, rolled lines hidden with a one-line count; returned/cancelled invoices last, title in onSurfaceVariant and a warning-coloured "not collectable" line. Header extras: ERP detailed address under the address (onSurfaceVariant), directions row with a signpost icon, and the **ERP risk chip** beside the status badges (speed icon + "ইআরপি গ্রেড C"; medium = warning, high = danger colours and the level in words, low = neutral, grade only; read only, never a filter). **2026-11-23:** `InvoiceKindLabel` with counts ("১ কিস্তি", "১ কিস্তি · ২ বাকি") at the top right of the name; `AppBackButton` in the top bar (48 dp tonal circle, 28 dp arrow, ripple); the "এই মাসে" card says who did each: "ভিজিট: <name> · <date or আজ>", "পরিশোধ: <amount> · <collector>" (the ERP's collector; an office payment shows the person the ERP names), "প্রতিশ্রুতি: <amount> · <name> · <date>". Since contract 1.44.0 the names come from the server's month activity: newest name + "+N" for the others, "অফিস" for an office payer with no name, and pending field money named on its own "ERP-তে অপেক্ষমাণ" line. A name nobody has is left out, the line reads as before. Action bar (sticky bottom): **আদায়** (primary filled) · ভিজিট · প্রতিশ্রুতি · নোট (tonal/outlined). Tabs below: টাইমলাইন · নোট · ভিজিট · প্রতিশ্রুতি.


**Returned invoices (FR-M-085, 2026-11-26).** Under the Plans card, a card "ফেরত চালান / Returned invoices" (icon and title in `status.returned`) lists the invoices returned in the ERP with a one-line note that they count in no total and take no collection. Each is an expansion tile: product, the Returned `StatusBadge`, invoice number, kind and sale date, "Invoice total · Paid so far" in onSurfaceVariant (never red or green), then its products and its payments (48 dp rows: date, receipt, method, amount in onSurfaceVariant). No collect action. In the timeline a payment to a returned invoice carries the Returned badge and the line "Payment to a returned invoice · not counted".
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

**Map pin screen (0.8.0, FR-CUS-011):** app bar with the title (লোকেশন দিন / লোকেশন ঠিক করুন) and a "type coordinates" icon. The map fills the top; the pin (`location_on`, 48 dp, primary, soft shadow) is fixed in the middle with its tip on the centre and a small shadow dot on the exact point; while the map moves the pin lifts 8 dp (no animation with reduced motion). The current pin is a hollow 24 dp `onSurfaceVariant` ring; the phone is a `secondary` dot; map places show as reference landmarks (not tappable, see Map places). It opens at the customer's pin, else the phone's fix, else `defaultMapCenter` (Galachipa, zoom 12). My-location small FAB bottom-right (spinner while locating). Panel below (max 45 % of the height, scrolls): customer name, one-line how-to, coordinates in mono with a pin icon (TalkBack live region), "N from the current pin", "You are N from the pin" (warning colour above 300 m), one banner: outside Bangladesh (danger, send disabled) / fake location (warning) / "set as soon as it is sent" (success) / "a manager checks" (info); optional photo button with a 48 dp thumbnail; one-line note. Bottom button: "পিন বসান" when it applies at once, else "অনুমোদনের জন্য পাঠান".

### 5.6a Co-work (0.6.0)
Today card (order 4, after the progress card): an invitation is a `secondaryContainer` card (groups icon, "{name} আজ আপনার সাথে একসাথে কাজ করতে চান", other members, the note in quotes, a "needs internet" line, Reject outlined + Accept filled, 48 dp). My group is a surface card: title, today's co-work visit count in primary, one row per member (40 dp initial avatar, name, green tick or a "waiting" pending badge; me first, marked "(আপনি)"), Leave (outlined, confirm dialog) and Ask more (tonal, only while seats are left). Off duty with no group: nothing; on duty with no group: a one-line "Work with a colleague" tile. The `/cowork` screen repeats the invitation and group cards, then "কাকে ডাকবেন?" with seats left, a card of `CheckboxListTile`s (avatar, name, code, coloured status: on duty / not on duty / in another group / in this group) and an optional note; the send button appears at the bottom with the count. Timeline: joint visits carry a "কো-ওয়ার্ক" badge (current tone) and "সাথে …" / "লিখেছেন …".

### 5.6b My performance and leaderboard (0.7.0)
Me tab card "আমার পারফরম্যান্স" (plus a "লিডারবোর্ড" row when visible to staff). The screen: month switcher (chevrons, 48 dp); money card (headline amount, achievement % in primary or success, 10 dp bar, "আজ পর্যন্ত লক্ষ্য … · পুরো মাসে …", then posted vs pending in ERP); visits card (credit "১৯৬ / ২৬০", %, 8 dp bar, single and co-work); three equal tiles (promises kept a/b, days present, late days in overdue colour when > 0); rank card in `primaryContainer` with a trophy (tap → leaderboard, current month only); daily chart: one bar per day, primary or success when the day's target was met, a 2 dp onSurface tick at the day's target, days off as a muted stub, first/last date under it, a Semantics summary. Offline with a cached month: warning banner "ইন্টারনেট নেই। {time}-এর হিসাব…". Leaderboard: Today / This month `SegmentedButton`, metric `ChoiceChip`s, my-rank banner, rows 64 dp (rank in a 32 dp circle for the top three, primary for first; plain number otherwise; name, code, value right-aligned tabular), my row in `primaryContainer` and bold, "র‍্যাঙ্কে নেই" group below, a footnote on what counts.

### 5.7 Me
Attendance card (today timeline: in, breaks, out; buttons বিরতি শুরু/শেষ, কাজ শেষ); Cash card (on hand, limit meter, **Deposit everything** button, deposit history: amount, time, "N collections · mobile/bank ৳Y", badge জমা হয়েছে / ফোনে আছে / জমা হয়নি, older deposits keep posted / rejected / deleted by office; nothing says "waiting for verification"). Deposit sheet (FR-M-059): no amount field; the cash in hand as a fixed headlineSmall amount with words, mobile/bank amount with its count, "মোট N টি আদায়", a bodySmall hint that part deposits do not exist, destination segments, reference, a filled Deposit button; it opens an AlertDialog (savings icon) naming cash, mobile/bank and count, saying it goes to the ERP as payments (online now / as soon as the phone is online) and cannot be changed or deleted after; Cancel / জমা দিন. Cash-in-hand screen: an info banner while a deposit is unsent; a "মোবাইল / ব্যাংক আদায় (জমার সাথে যাবে)" section (method icon in its method colour) with the same Change / Delete menu. Problems: a refused deposit card (error icon, amount, reason in words, "the collections are back in your hand", text button আবার জমা দিন, no Retry); Handovers; Sync centre (queued counts by type, last sync, Problems list with explanations and "manager notified" state, Sync now); My performance (month); Settings (language, digits, theme, high contrast, text size preview, PIN/biometric, privacy notice, battery optimisation guide, about/version, logout).

### 5.7b Background location set-up (2026-11-26, FR-M-078)
Route `/location/background-setup`, from the Today tracking line and the Me tracking card ("ব্যাকগ্রাউন্ড সেটআপ"). An info banner says why (live location on duty even when the app is closed; phones stop apps to save battery; never off duty). Three `AppCard` steps: **1. battery optimisation** with a status pill (অনুমতি আছে success · অনুমতি নেই warning · জানা যায়নি neutral) and a filled "অনুমতি দিন" that opens Android's own dialog; **2. autostart and background** for the detected brand (`Build.MANUFACTURER`: Xiaomi/Redmi/POCO, Samsung, Oppo/Realme, Vivo/iQOO, Huawei/Honor, OnePlus, other) with its numbered steps, an outlined "সেটিংস খুলুন" deep link to the brand's screen (snackbar when none opens) and "অন্য ফোনের নিয়ম দেখুন" to the full guide; **3. right now**: running (success) / on duty but not running (danger) / reconnecting (warning) / off duty (neutral). Pull to read the phone again. The native notification shows a second line "লাইভ লোকেশন পাঠানো যাচ্ছে না। অ্যাপটি একবার খুলুন।" (amber) while the server refuses the tracking token.

### 5.7c Settings (v2, 2026-11-26, FR-M-084)
Six titled groups, each one card of uniform rows: **অ্যাকাউন্ট** (profile: name, staff code and role · sign out) · **কাজ** (sync centre, value: all synced / N waiting / N problems · holidays and shift, value: duty hours) · **লোকেশন ও ব্যাটারি** (location tracking, value চালু / বন্ধ, opens the background set-up of §5.7b · battery and background guide for the phone brand) · **ভাষা ও প্রদর্শন** (language · digits · theme · high contrast as a switch) · **গোপনীয়তা** (what the app records) · **সাহায্য ও অ্যাপ সম্পর্কে** (version · device id · server: demo / live).
- **Row** (≥ 64 dp, 16 dp side padding): a 40 dp tonal square (`Radii.lg`, an `action.*` tone, 22 dp icon) · title (titleSmall) over a **one-line hint** (bodyMedium, onSurfaceVariant; written to fit one line at 412 dp, it wraps rather than being cut on a narrow phone or at 1.3 text) · the **current value** at the right (labelLarge tabular, onSurfaceVariant, at most 128 dp and two lines; the device id in mono) · a chevron when the row opens something, or a `Switch` (the whole row toggles it). Group title: titleSmall onSurfaceVariant, a semantics header; hairlines between rows start after the icon; 20 dp between groups.
- **A choice** (language, digits, theme) opens a bottom sheet of 56 dp radio rows; a tap applies it at once and closes the sheet. No save button anywhere.
- **Sign out** is the only row in the danger colour (errorContainer square, error title); it keeps its guard: refused while anything is unsent.
- Features add rows through the manifest (`settingsRows`: section, order, icon, tone, title, hint, value, route), so a module that is off leaves no row. No search field: 14 rows in six titled groups fit in two screens; add one when Settings passes about 25 rows.
- No pull to refresh (local settings only, ADR-M42). The Me tab keeps every card; its Settings entry carries the hint "ভাষা, থিম, লোকেশন, গোপনীয়তা".
- Screenshots: `test/screenshots/goldens/settings/` (bn light, en dark, 360 dp at 1.3); before: `docs/screenshots/home-settings-v2-before/settings-bn.png`.

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
| `CustomerWorkRow` | Home row, four lines, see §5.1 (2026-11-23) |
| `InvoiceKindLabel` | one chip per kind, radius 6, labelMedium, h-padding 8 / v-padding 2: installment on secondaryContainer / onSecondaryContainer, credit on tertiaryContainer / onTertiaryContainer, cash ("নগদ", contract 1.44.0; unknown kinds too) on primaryContainer / onPrimaryContainer; word for one invoice, counts for several (always counts with `counted`, the customer page) |
| `TagChip` | bad-tag kind (§2 `status.tag.*`): 24 dp tall (grows with the text size), radius 6, icon 16 + labelMedium word, kind fg on kind bg with a 1 px fg hairline; পলাতক is filled (bg on fg) |
| `ReturnedCustomerMark` | FR-M-085 (2026-11-26): `StatusBadge` in `status.returned` (v1.4) with the label "ফেরত পণ্যের customer" / "Returned product customer", on every customer row (Home, Customers and search, Collect picker, Map list) and the customer header when `returnedInvoiceCount` > 0. A row with `onlyReturned` keeps the mark, has no tap action, no Collect button or open arrow, and TalkBack says it cannot be opened; its map pin is drawn in `status.returned` with its icon and does not open. A pin of a customer with some returned invoices carries a 20 dp returned dot on its corner. Never hidden |
| `TagFrame` | the frame of a bad-tag customer's row or header with its `TagChip` on the top edge, see §5.2a |
| `AppBackButton` | `IconButton.filledTonal`, fixed 48 × 48 dp, `BackButtonIcon` at 28 dp, secondaryContainer / onSecondaryContainer, ink ripple (`InkRipple`, overlay onSecondaryContainer), 12 dp start inset; app bar `leadingWidth` 72; shown only when the route can pop |
| `OnlineDot` | see §5.1b |
| Home summary card / KPI tile | see §5.1 (2026-11-26); KPI tile: `Radii.lg`, status bg / fg, number titleLarge w700 tabular, label labelSmall (2 lines), ≥ 48 dp, TalkBack "<label>: <n> জন" |
| Home section header | 32 dp toned icon square (`Radii.md`), titleMedium title, toned count pill (`Radii.full`); one semantics header "<title>, <n>" |
| Home filter chips | `FilterChip` row, pinned; icon 18 + words + count (tabular w700), 48 dp targets, divider before the lenses, the picked chip kept in sight, see §5.1 (v2) |
| Quick-action grid / cell | one card, full rows of three equal cells (9 / 6 / 3); cell: 40 dp `action.*` circle, 22 dp icon, labelMedium label (2 lines), count badge, optional state mark and words; ≥ 88 dp, see §5.1 (v2) |
| Settings row / group | 64 dp row: 40 dp tonal square, title, one-line hint, current value, chevron or switch; groups are titled cards, see §5.7c |
| Choice sheet | bottom sheet of 56 dp radio rows for a single choice; a tap applies and closes (Settings: language, digits, theme) |
| Tracking health line | `InfoBanner` first on Today while on duty and tracking is unhealthy: danger "not running", warning "reconnecting" / "battery saver"; tap → background set-up (FR-M-078) |
| `RefreshIndicator` | every screen that shows synced or server data; scrollable uses `AlwaysScrollableScrollPhysics` (pull works on short and empty pages); triggers `syncNow` or the screen's online fetch (ADR-M42) |
| `AmountKeypad` | 3×4 grid, keys 72 dp, haptic on press, backspace long-press clears |
| `HoldToConfirmButton` | 56 dp, fills over 800 ms, cancel on release; accessible alternative: double-tap with TalkBack |
| `BottomSheet` | M3 modal; radius 28; drag handle; max 90 % height |
| `ReasonSheet` | reason chips + text (min 10 chars) for tag, cancel promise |
| `EmptyState` | icon 48 dp, title, one sentence, action |
| `Banner` | M3 banner for problems/handover/version |
| `Snackbar` | for undo and confirmations ("নোট সংরক্ষিত · পূর্বাবস্থা") |

## 7. States & feedback
- **Loading:** local DB makes most screens instant; Home shows static skeleton rows while its list loads; network-only views (fresh balance refresh, route) show shimmer.
- **Refresh:** pull down on any data screen (ADR-M42); forms, the camera and local-only settings have none.
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
