import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'performance_screen.dart' show reportErrorText;
import 'reports_data.dart';

/// The collection board (FR-M-048, field-api FR-REP-007): everyone who
/// collected, ranked by the money the ERP has accepted, this month or all
/// time, across every branch unless the office narrowed it. A crown marks
/// first place. Managers and admins who collect are on it too. Online.
class CollectionBoardView extends ConsumerStatefulWidget {
  const CollectionBoardView({super.key});
  @override
  ConsumerState<CollectionBoardView> createState() => _CollectionBoardViewState();
}

class _CollectionBoardViewState extends ConsumerState<CollectionBoardView> with AutomaticKeepAliveClientMixin {
  bool _allTime = false;
  CollectionBoard? _data;
  ReportError? _error;
  bool _loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final (data, err) = await ref.read(reportsServiceProvider).collectionBoard(allTime: _allTime);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _data = data;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final d = _data;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s12, Space.screen, Space.s32),
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: false, label: Text(l.leaderMonth), icon: const Icon(Icons.calendar_month_rounded)),
              ButtonSegment(value: true, label: Text(l.boardAllTime), icon: const Icon(Icons.all_inclusive_rounded)),
            ],
            selected: {_allTime},
            onSelectionChanged: (s) {
              setState(() => _allTime = s.first);
              _load();
            },
          ),
          const SizedBox(height: Space.s16),
          if (d == null && _loading)
            const Padding(padding: EdgeInsets.all(Space.s48), child: Center(child: CircularProgressIndicator()))
          else if (d == null)
            EmptyState(
              icon: switch (_error) {
                ReportError.offline => Icons.wifi_off_rounded,
                ReportError.hidden => Icons.visibility_off_rounded,
                _ => Icons.error_outline_rounded,
              },
              title: reportErrorText(l, _error ?? ReportError.failed),
              body: _error == ReportError.hidden ? l.leaderboardHiddenBody : '',
              action: _error == ReportError.hidden ? null : OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(l.actionRetry)),
            )
          else ...[
            if (d.myRank != null)
              InfoBanner(icon: Icons.emoji_events_rounded, text: l.boardMyRank(f.num(d.myRank!), f.num(d.of ?? d.ranked.length), f.money(d.myPostedPoisha ?? 0)))
            else
              InfoBanner(icon: Icons.info_outline_rounded, tone: BannerTone.warning, text: l.boardNotRankedMe),
            const SizedBox(height: Space.cardGap),
            if (d.ranked.isEmpty)
              EmptyState(icon: Icons.emoji_events_outlined, title: l.boardEmpty, body: '')
            else
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  for (var i = 0; i < d.ranked.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                    _BoardTile(row: d.ranked[i]),
                  ],
                ]),
              ),
            if (d.unranked.isNotEmpty) ...[
              const SizedBox(height: Space.s16),
              Text(l.boardNoPosted, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: Space.s8),
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  for (var i = 0; i < d.unranked.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                    _BoardTile(row: d.unranked[i]),
                  ],
                ]),
              ),
            ],
            const SizedBox(height: Space.s12),
            Text(d.allBranches ? l.boardFootnoteAll : l.boardFootnoteBranch, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

/// Words for a role that is not field staff (they are on the board by
/// collections alone); null for field staff.
String? boardRoleLabel(AppLocalizations l, String role) => switch (role) {
      'field_staff' => null,
      'branch_manager' => l.boardRoleManager,
      'super_admin' => l.boardRoleAdmin,
      _ => l.boardRoleOffice,
    };

class _BoardTile extends ConsumerWidget {
  const _BoardTile({required this.row});
  final BoardRow row;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final name = row.nameOf(lang);
    final role = boardRoleLabel(l, row.role);
    final top = row.rank != null && row.rank! <= 3;
    return Container(
      color: row.me ? cs.primaryContainer : null,
      constraints: const BoxConstraints(minHeight: Sizes.row2),
      padding: const EdgeInsets.symmetric(horizontal: Space.s16, vertical: Space.s8),
      child: Row(children: [
        SizedBox(
          width: 40,
          child: row.rank == null
              ? Icon(Icons.remove_rounded, color: cs.onSurfaceVariant)
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  // First place wears the crown (owner request); the number stays for screen readers and ties.
                  if (row.crowned) Text('👑', semanticsLabel: l.boardCrown, style: t.titleMedium),
                  if (top)
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: row.crowned ? cs.primary : cs.secondaryContainer),
                      child: Text(f.num(row.rank!), style: AppTheme.tabular(t.titleSmall!).copyWith(color: row.crowned ? cs.onPrimary : cs.onSecondaryContainer, fontWeight: FontWeight.w700)),
                    )
                  else
                    Text(f.num(row.rank!), textAlign: TextAlign.center, style: AppTheme.tabular(t.titleMedium!).copyWith(color: cs.onSurfaceVariant)),
                ]),
        ),
        const SizedBox(width: Space.s12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(row.me ? l.coworkYou(name) : name, style: t.bodyLarge!.copyWith(fontWeight: row.me || row.crowned ? FontWeight.w700 : null), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              [row.employeeCode, ?role, if (row.count > 0) l.boardCount(f.num(row.count))].where((s) => s.isNotEmpty).join(' · '),
              style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
        const SizedBox(width: Space.s8),
        Text(f.money(row.postedPoisha), style: AppTheme.tabular(t.titleMedium!).copyWith(fontWeight: row.me || row.crowned ? FontWeight.w700 : null)),
      ]),
    );
  }
}
