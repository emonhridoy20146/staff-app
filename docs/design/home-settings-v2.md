# Home and Settings v2 — design plan (2026-11-26)

**Status 2026-11-26:** §4 (bad-tag customers) and the v1.3 tokens are built; §5 filters, §6 quick actions, §7 Settings and the Home re-ordering of §2 are planned and not built yet.

Owner request 2026-11-26. Scope: Home (Today), the customer rows everywhere, the tag sheet and Settings. This is the plan the code follows; the lasting rules are copied into `03-design-guide.md` (§2 tokens v1.3, §5.1, §5.7, §6). Decision record: ADR-M44.

The user: a field collector on a 5.5-inch, 2–3 GB phone, one thumb, in sunlight, often with the customer watching. Bangla first. The test for every element: **does it help decide what to do next, or do it faster?** If not, it is not on Home.

## 1. The first three seconds

Home answers three questions, in this order, without scrolling on a 360 × 780 dp phone:

1. **Am I on duty, and is anything wrong?** Duty card, sync chip, the red tracking line.
2. **How am I doing today?** Collected against the target, one bar, one percent.
3. **What is next?** Three numbers: promised today, due today, overdue. A tap on a number opens that list.

Everything else (shortcuts, notices, co-work, the list itself) is the second level, one thumb-scroll away.

## 2. Information hierarchy

| # | Block | Why here |
|---|---|---|
| 0 | Top bar: branch, online, GPS, bell | unchanged, every tab |
| 1 | Greeting, date, sync chip | orientation, one glance |
| 2 | **Summary card**: collected, target bar, three counts | question 2 and 3 |
| 3 | **Duty card** | question 1; the day's first and last action |
| 4 | **Alerts** (only when there is one): tracking not running, must-read notice, sync problem, tasks, receipts low, handover, cash limit | something is wrong or waiting: it goes above shortcuts, never below the fold behind them |
| 5 | **Quick actions**: a 3 × 3 grid | the tools that were buried in Me |
| 6 | Feature cards: co-work, visit suggestion, broken promises | context, not urgent |
| 7 | **Work list**: title, filter chips, sections of customer rows | the job itself |

Change from 2026-11-26 (v1): alerts moved above the shortcuts. With three tiles it did not matter; with nine, a "tracking is not running" line would have dropped under the fold.

### The day in three states
The order never changes (muscle memory); the emphasis does.

| State | What leads | How |
|---|---|---|
| **Morning**, before work-in | Start work | duty card is neutral with the sunrise icon; the Attendance tile carries the amber "still to give" mark; the summary shows ৳0 of the target and the day's three counts |
| **On duty** | The next customer | duty card turns green and small; the counts and the filtered list do the work; alerts appear only when something breaks |
| **End of day** | Hand in and close | "target met" pill when reached; the cash-limit alert; Cash in hand and Today's work are the first row of the grid; work-out is on the duty card |

## 3. Layout, type, colour

- **Spacing rhythm** (4-pt tokens only): 16 dp screen margin · 12 dp between cards · 24 dp before a new group (alerts → grid) · 32 dp before the work list · 20 dp above a section header · 8 dp between a frame and its neighbours.
- **One card style** (unchanged): surface, 16 dp corners, 1 px `outlineVariant`, `shadow.sm` in light mode only. The grid is **one** card with nine cells, not nine cards: fewer borders, calmer.
- **Type scale** (guide §3.2, nothing new): greeting `headlineSmall` · amount `headlineMedium` · list title `titleLarge` · names and money `titleMedium` · secondary lines `bodyMedium` (16 sp) · chips, tile labels `labelMedium` (14 sp) · counts tabular.
- **Bangla typography:** Noto Sans Bengali through the Inter fallback; line height 1.35–1.45 so matras and reph are never clipped; labels wrap to two lines instead of ending in "…" (names are the only single-line text); no capitals, no letter-spacing, weight ≤ 700; numbers follow the digits setting and stay tabular so columns do not jump.
- **Colour carries meaning or it is absent.** Status colours on counts, section headers and marks; the brand colour only on the summary stripe and selected chips; the new tag colours only on a bad-tag customer; the new action tones only inside the 40 dp icon circles of the grid. Never colour alone: every colour has an icon and a word.

## 4. Bad-tag customers (tokens `status.tag.*`, v1.3)

A customer whose tag is `tagged` with severity `bad` or `legal` (a missing or unknown severity counts as bad; `watch` does not), or whose **latest visit says `runaway`**, gets a **frame** in the reason's colour around its row, with a **chip on the frame** (icon + short word). Wherever a customer row appears: Home, Customers (and its search results), the Collect picker, the Map list and sheets, and the customer page header.

| Kind (reason) | Chip | Icon | Light fg / bg | Dark fg / bg |
|---|---|---|---|---|
| `absconded`, or latest visit `runaway` | পলাতক · Runaway | running person | `#7F1D1D` / `#FBDADA` | `#EF4444` / `#2D1212` |
| severity `legal` | আইনি ব্যবস্থা · Legal action | gavel | `#991B1B` / `#FDE3E3` | `#F87171` / `#2D1212` |
| `refused_to_pay` | দিতে অস্বীকার · Refuses to pay | block | `#B91C1C` / `#FDECEC` | `#FCA5A5` / `#2D1212` |
| `other`, none, unknown code | খারাপ ট্যাগ · Bad tag | flag | `#D42020` / `#FEF2F2` | `#FECACA` / `#2D1212` |
| `fraud_suspected` | প্রতারণার সন্দেহ · Fraud suspected | shield alert | `#9D174D` / `#FCE7F3` | `#F472B6` / `#2E1020` |
| `repeated_broken_promise` | বারবার কথা রাখেননি · Broken promises | broken heart | `#6D28D9` / `#F1EAFE` | `#A78BFA` / `#1F1536` |
| `plan_ended_unpaid` | দীর্ঘদিন বকেয়া · Long overdue | calendar with a cross | `#C2410C` / `#FFF1E8` | `#FB923C` / `#2E1A0C` |

- **One red family, three hues.** The four "will not pay" kinds are one red ramp, darker = harder case (dark mode: more saturated = harder). The three other hues are borrowed from meanings the app already has: magenta = something is fake (mock location), violet = promises, orange = the term ran out (the dashed "possibly bad" suggestion is the same orange; solid = decided).
- **Runaway is the strongest:** 2 dp frame and a filled chip (the others: 1.5 dp, tinted chip). Order when several apply: runaway → legal → the reason.
- **Runaway from a visit** counts only while that visit is the latest contact the phone knows: a later visit or a collection clears it.
- Contrast: every fg is ≥ 4.5 : 1 on its bg and ≥ 3 : 1 on every surface, light and dark (unit-tested).
- The frame sits 8 dp inside the row and the content keeps its 16 dp column, so names and amounts stay aligned down the list. TalkBack reads "খারাপ ট্যাগ: পলাতক" before the name.
- **Tag sheet:** each reason is a full-width 56 dp option with its swatch (the icon in its colour on its tint), its words, and its frame colour when picked; a live line under the options shows the chip the row will get for the chosen level and reason (Legal → the legal chip, Watch → no frame). Staff learn the mapping where they set it. The chip words are the tag sheet's words.
- `watch` tags keep the plain "চিহ্নিত" badge. Map pins are unchanged (they follow pay state with admin-web).

## 5. Home filters

A row of single-choice chips, each with its count, at the top of the work list; it stays pinned under the top bar while the list scrolls.

**সব** All · **আজ প্রতিশ্রুতি** Promise today · **আজ দেয়** Due · **বকেয়া** Overdue ‖ **খারাপ ট্যাগ** Bad tag · **ভাঙা প্রতিশ্রুতি** Broken promise

- The first four are the work list and its three sections: the same groups, the same order (a customer is in its first group only), so a chip's number is always its section's number and the summary card's number. **All** is their sum.
- The two after the divider are lenses across the same customers: every bad-tag customer, and every customer with a broken promise nobody has followed up (only when promises are on). They can overlap the others; that is why they sit apart.
- A filter shows **only** that list, all of it (Overdue is no longer cut at 8), nearest first, as lazy rows. All keeps the three sections with Overdue cut at 8 and an "N more" button that now opens the Overdue filter in place.
- A tap on a count in the summary card picks that filter and brings the list up.
- The choice is kept for the session (until sign-out or the app is closed).
- **Scope:** a field staff member sees their own and unassigned customers, as before; a branch manager, area manager, viewer or super admin sees the branch(es) the server gave them. Both follow the branch picked in the top bar.
- Offline: everything is read from the phone's database; counts are computed once per data change, not per frame.
- Empty filter: one calm card, "এই তালিকায় কেউ নেই", with "সব দেখুন".

## 6. Quick actions (tokens `action.*`, v1.3)

**Nine**, 3 × 3, in one card. Six would leave Requests, Prospects and Leave buried; each of the nine is used at least weekly and none is reachable from Home any other way.

| Row | 1 | 2 | 3 |
|---|---|---|---|
| My day | উপস্থিতি Attendance (brand) · done / to-do mark | আজকের কাজ Today's work (teal) | হাতে নগদ Cash in hand (green) |
| Office | আমার কাজ Tasks (violet) · open count | নোটিশ Notices (amber) · unread count | অনুরোধ Requests (brand) · news count |
| Growth | সম্ভাব্য গ্রাহক Prospects (teal) | পারফরম্যান্স Performance (violet) | ছুটি Leave (amber) |

Bench, used only to keep the grid full when a module is off: Leaderboard (amber), Co-work (teal), Handovers (brand), Sync centre (green). They already have their own place on Home (co-work card, handover alert, sync chip) or inside Performance.

- **Five tones for nine icons** (brand, teal, green, violet, amber), each tone a tinted 40 dp circle with a darker icon; a tone is tied to a meaning (green is money, amber is time and notices), and no row or column repeats one.
- **Reflow:** features give their actions through the manifest (`quickActions`); flag off or no permission = not there. The grid shows the first 9 by order; with fewer than 9 it shows 6, with fewer than 6 it shows 3, with fewer than 3 one row of what is left. Always full rows of equal cells; what does not fit stays in Me.
- Cell: icon circle, label (two lines allowed), optional state line; ≥ 96 × 88 dp; badge on the circle; TalkBack "নোটিশ, ২টি নতুন".

## 7. Settings

Six sections of uniform rows: **icon in a tonal square · title · one-line hint · current value · chevron** (64 dp minimum). A choice opens a bottom sheet of radio rows and applies at once.

| Section | Rows (value) |
|---|---|
| অ্যাকাউন্ট Account | Profile (name · staff code · role) · Sign out |
| কাজ Work | Sync centre (all synced / N waiting / N problems) · Office hours (09:00–21:00, from the office) · Holidays and shift |
| লোকেশন ও ব্যাটারি Location & battery | Location tracking (on duty: on / off duty: off) · Background set-up (battery permission) · Phone-brand guide |
| ভাষা ও প্রদর্শন Display & language | Language (বাংলা) · Digits (১২৩) · Theme (light) · High contrast (switch) |
| গোপনীয়তা Privacy | What this app records |
| সাহায্য ও অ্যাপ সম্পর্কে Help & about | Version · Device · Server (demo / live) |

- Features add their rows through the manifest (`settingsRows`), so a module that is off leaves no row.
- **No search:** 16 rows in 6 titled groups fit in two screens; a search field would be the largest thing on the page and save nothing. Add it when Settings passes ~25 rows.
- Sign-out keeps its guard (blocked while anything is unsent).
- The Me tab keeps every card; its Settings entry gets a hint line.

## 8. States, motion, reach

- **Loading:** static skeleton rows (as v1). **Empty / all done / error:** one card in the page's card style, one sentence, one action at most. **Offline:** nothing changes; the chip says so.
- **Motion:** tokens only (120 / 200 / 300 ms, standard curve). Chips change state in 120 ms; the list swaps without animation (a moving list under the thumb costs a mis-tap); the summary card opens with the existing 200 ms size animation; jumping to the list scrolls in 300 ms, at once with reduced motion. Nothing loops, nothing shimmers.
- **One-handed reach:** Collect stays at the right edge of each row; grid cells and chips are ≥ 48 dp; the bottom bar is unchanged; nothing critical in the top corners (the sync chip and bell report, they do not block).

## 9. Low-end Android and sunlight

- **Performance:** a filtered list is a lazy sliver, so 300 overdue customers cost one screen of rows; groups and counts are one pass in a provider, shared by the summary card, the chips and the sections; the customer query stays one SQL statement (two indexed sub-selects for the latest visit); no blur, no gradients, no animation at rest; shadows are static and light-mode only; the grid is laid out once (nine children).
- **Sunlight:** all text and icons ≥ 4.5 : 1, frames ≥ 3 : 1 and 1.5–2 dp thick; no grey text for content; the strongest state is filled, not just outlined; high-contrast mode adds 0.5 dp to frames.

## 10. Kept exactly as it was
Greeting, date, sync chip · the collapsible collected card with "বিস্তারিত" · target, visit target, cash meter · duty card · every feature card and banner · sections with work rows and Collect · skeleton, empty and error states · pull to refresh on Home and Me (#59), none on Settings · the Me tab's cards and sign-out · the bell, branch switch and bottom bar.
