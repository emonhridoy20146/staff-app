import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'notices_data.dart';

/// Read state as colour + icon + label (design guide §3: never colour alone).
class NoticeReadChip extends StatelessWidget {
  const NoticeReadChip({super.key, required this.notice});
  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.semanticColors;
    final (st, icon, label) = notice.read
        ? (s.success, Icons.done_all_rounded, l.noticeRead)
        : notice.row.requireAck
            ? (s.warning, Icons.mark_email_unread_rounded, l.noticeMustRead)
            : (s.info, Icons.mark_email_unread_rounded, l.noticeUnread);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s2),
      decoration: BoxDecoration(color: st.bg, borderRadius: const BorderRadius.all(Radius.circular(Radii.full))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: st.fg),
        const SizedBox(width: Space.s4),
        Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: st.fg, height: 1.2)),
      ]),
    );
  }
}

/// `/notices`: every notice from the office, newest first.
class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final notices = ref.watch(noticesProvider).value ?? const <Notice>[];
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.noticesTitle), backgroundColor: cs.surfaceContainer),
      body: notices.isEmpty
          ? Center(child: EmptyState(icon: Icons.campaign_rounded, title: l.noticesEmpty, body: l.noticesEmptyBody))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
              itemCount: notices.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.cardGap),
              itemBuilder: (_, i) => _NoticeTile(notice: notices[i]),
            ),
    );
  }
}

class _NoticeTile extends ConsumerWidget {
  const _NoticeTile({required this.notice});
  final Notice notice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    return AppCard(
      onTap: () => context.push('/notices/${notice.id}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(
              notice.title(lang),
              style: t.titleMedium!.copyWith(fontWeight: notice.read ? FontWeight.w500 : FontWeight.w700),
            ),
          ),
          const SizedBox(width: Space.s8),
          NoticeReadChip(notice: notice),
        ]),
        const SizedBox(height: Space.s4),
        Text(notice.body(lang), maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodyMedium),
        const SizedBox(height: Space.s8),
        Text(
          [if (notice.row.senderName?.isNotEmpty == true) notice.row.senderName!, f.dateTime(notice.row.createdAt)].join(' · '),
          style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
        ),
      ]),
    );
  }
}

/// `/notices/:id`: the whole notice and the "পড়েছি" button.
class NoticeDetailScreen extends ConsumerWidget {
  const NoticeDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final n = ref.watch(noticeProvider(id)).value;
    if (n == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(l.noticesEmpty)));
    }
    final s = context.semanticColors;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.noticeTitle), backgroundColor: cs.surfaceContainer),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
        children: [
          Align(alignment: AlignmentDirectional.centerStart, child: NoticeReadChip(notice: n)),
          const SizedBox(height: Space.s12),
          Text(n.title(lang), style: t.headlineSmall),
          const SizedBox(height: Space.s4),
          Text(
            [if (n.row.senderName?.isNotEmpty == true) l.noticeFrom(n.row.senderName!), f.dateTime(n.row.createdAt)].join(' · '),
            style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: Space.s16),
          AppCard(child: SelectableText(n.body(lang), style: t.bodyLarge)),
          if (n.read) ...[
            const SizedBox(height: Space.s16),
            InfoBanner(
              icon: n.readNotSent ? Icons.cloud_upload_rounded : Icons.done_all_rounded,
              tone: n.readNotSent ? BannerTone.info : BannerTone.success,
              text: n.readNotSent ? l.noticeReadQueued(f.dateTime(n.row.ackedAt!)) : l.noticeReadAt(f.dateTime(n.row.ackedAt!)),
            ),
          ],
          if (n.row.ackState == 'failed') ...[
            const SizedBox(height: Space.s8),
            Text(l.noticeReadFailed, style: t.bodyMedium!.copyWith(color: s.danger.fg)),
          ],
        ],
      ),
      bottomNavigationBar: n.read
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.screen, Space.s12, Space.screen, Space.s12),
                child: SizedBox(
                  height: Sizes.primaryButton,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await ref.read(noticeServiceProvider).markRead(id);
                      if (context.mounted) showAppSnack(context, l.noticeThanks);
                    },
                    icon: const Icon(Icons.done_all_rounded),
                    label: Text(l.noticeMarkRead),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Today: the office asked for a confirmation that is not given yet.
class NoticesTodayBanner extends ConsumerWidget {
  const NoticesTodayBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final must = ref.watch(mustReadNoticesProvider);
    if (must.isEmpty) return const SizedBox.shrink();
    return InfoBanner(
      icon: Icons.campaign_rounded,
      tone: BannerTone.warning,
      text: must.length == 1 ? l.todayNoticeOne(must.first.title(lang)) : l.todayNoticeMany(f.num(must.length)),
      onTap: () => context.push(must.length == 1 ? '/notices/${must.first.id}' : '/notices'),
    );
  }
}

/// Me: notices with the unread count.
class NoticesMeEntry extends ConsumerWidget {
  const NoticesMeEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final n = ref.watch(unreadNoticesProvider).length;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/notices'),
      child: ListTile(
        minTileHeight: 64,
        leading: const Icon(Icons.campaign_rounded),
        title: Text(l.noticesTitle),
        subtitle: Text(n > 0 ? l.noticesUnreadCount(f.num(n)) : l.noticesAllRead),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (n > 0) Badge(label: Text(f.num(n))),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    );
  }
}
