import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import 'cowork_data.dart';
import 'cowork_domain.dart';

String coworkErrorText(AppLocalizations l, CoworkError e) => switch (e) {
      CoworkError.offline => l.coworkOffline,
      CoworkError.alreadyInSession => l.coworkErrAlreadyIn,
      CoworkError.sessionEnded => l.coworkErrEnded,
      CoworkError.notInvited => l.coworkErrNotInvited,
      CoworkError.tooMany => l.coworkErrTooMany,
      CoworkError.invalidInvitee => l.coworkErrInvitee,
      CoworkError.failed => l.errorGeneric,
    };

void _snackFor(BuildContext context, CoworkResult r, String okText) {
  final l = AppLocalizations.of(context);
  if (r.ok) {
    showAppSnack(context, okText);
  } else {
    showAppSnack(context, coworkErrorText(l, r.error!), icon: r.error == CoworkError.offline ? Icons.wifi_off_rounded : Icons.error_rounded);
  }
}

String _initial(String name) {
  final cleaned = name.replaceFirst(RegExp(r'^(মোঃ|মো\.|Md\.?)\s*'), '').trim();
  return cleaned.isEmpty ? '?' : cleaned.characters.first;
}

/// Small round initial for a person.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.name, this.size = 40, this.waiting = false});
  final String name;
  final double size;
  final bool waiting;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: waiting ? cs.surfaceContainerHigh : cs.primaryContainer,
        border: Border.all(color: cs.surface, width: 2),
      ),
      child: Text(
        _initial(name),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(color: waiting ? cs.onSurfaceVariant : cs.onPrimaryContainer, height: 1.1),
      ),
    );
  }
}

/// Today: invitations to answer, my group, or a way to start one.
class CoworkTodayCard extends ConsumerWidget {
  const CoworkTodayCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(coworkTodayProvider);
    final onDuty = ref.watch(onDutyProvider);
    final children = <Widget>[
      for (final s in t.invites) CoworkInviteCard(session: s),
      if (t.active != null) CoworkGroupCard(session: t.active!),
      if (t.active == null && t.invites.isEmpty && onDuty) const _StartCard(),
    ];
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(children: [
      for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: Space.cardGap), children[i]],
    ]);
  }
}

class _StartCard extends StatelessWidget {
  const _StartCard();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/cowork'),
      child: ListTile(
        minTileHeight: 72,
        leading: CircleAvatar(backgroundColor: cs.secondaryContainer, foregroundColor: cs.onSecondaryContainer, child: const Icon(Icons.group_add_rounded)),
        title: Text(l.coworkStartTitle),
        subtitle: Text(l.coworkStartBody),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

/// An invitation to answer (accept / reject, online-only).
class CoworkInviteCard extends ConsumerStatefulWidget {
  const CoworkInviteCard({super.key, required this.session});
  final CoworkSession session;
  @override
  ConsumerState<CoworkInviteCard> createState() => _CoworkInviteCardState();
}

class _CoworkInviteCardState extends ConsumerState<CoworkInviteCard> {
  bool? _busy; // true = accepting, false = rejecting

  Future<void> _answer(bool accept) async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = accept);
    final r = await ref.read(coworkServiceProvider).respond(widget.session.id, accept: accept);
    if (!mounted) return;
    setState(() => _busy = null);
    if (r.ok) unawaited(HapticFeedback.mediumImpact());
    _snackFor(context, r, accept ? l.coworkJoined : l.coworkDeclined);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final me = ref.watch(myUserIdProvider);
    final s = widget.session;
    final inviter = s.nameOf(s.memberOf(me ?? '')?.invitedBy ?? s.createdBy) ?? '—';
    final others = [for (final m in s.members) if (m.userId != me && m.occupies) m];
    return AppCard(
      color: cs.primaryContainer,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.groups_rounded, color: cs.onPrimaryContainer),
          const SizedBox(width: Space.s12),
          Expanded(child: Text(l.coworkInviteFrom(inviter), style: t.titleMedium!.copyWith(color: cs.onPrimaryContainer))),
        ]),
        if (others.length > 1) ...[
          const SizedBox(height: Space.s8),
          Text(l.coworkWith(others.map((m) => m.name).join(', ')), style: t.bodyMedium!.copyWith(color: cs.onPrimaryContainer)),
        ],
        if (s.note != null && s.note!.isNotEmpty) ...[
          const SizedBox(height: Space.s4),
          Text('“${s.note!}”', style: t.bodyMedium!.copyWith(color: cs.onPrimaryContainer, fontStyle: FontStyle.italic)),
        ],
        const SizedBox(height: Space.s8),
        Row(children: [
          Icon(Icons.wifi_rounded, size: 18, color: cs.onPrimaryContainer),
          const SizedBox(width: Space.s4),
          Expanded(child: Text(l.coworkNeedsInternet, style: t.bodySmall!.copyWith(color: cs.onPrimaryContainer))),
        ]),
        const SizedBox(height: Space.s12),
        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _busy != null ? null : () => _answer(false),
              child: _busy == false ? const _Spinner() : Text(l.actionReject),
            ),
          ),
          const SizedBox(width: Space.s12),
          Expanded(
            child: FilledButton(
              onPressed: _busy != null ? null : () => _answer(true),
              child: _busy == true ? const _Spinner() : Text(l.actionAccept),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.5));
}

/// Co-work visits of one session on this phone (mine and partners').
final coworkVisitCountProvider = StreamProvider.family<int, String>((ref, sessionId) {
  final db = ref.watch(databaseProvider);
  final c = db.visits.clientId.count();
  final q = db.selectOnly(db.visits)
    ..addColumns([c])
    ..where(db.visits.coWorkSessionId.equals(sessionId));
  return q.map((r) => r.read(c) ?? 0).watchSingle();
});

/// My group today: who is in, who has not answered, joint visits, add / leave.
class CoworkGroupCard extends ConsumerStatefulWidget {
  const CoworkGroupCard({super.key, required this.session, this.showAdd = true});
  final CoworkSession session;
  final bool showAdd;
  @override
  ConsumerState<CoworkGroupCard> createState() => _CoworkGroupCardState();
}

class _CoworkGroupCardState extends ConsumerState<CoworkGroupCard> {
  bool _busy = false;

  Future<void> _leave() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.coworkLeave),
        content: Text(l.coworkLeaveConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(d).pop(false), child: Text(l.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(d).pop(true), child: Text(l.coworkLeave)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    final r = await ref.read(coworkServiceProvider).leave(widget.session.id);
    if (!mounted) return;
    setState(() => _busy = false);
    _snackFor(context, r, l.coworkLeft);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final me = ref.watch(myUserIdProvider) ?? '';
    final s = widget.session;
    final people = [for (final m in s.members) if (m.occupies) m]..sort((a, b) => a.userId == me ? -1 : (b.userId == me ? 1 : 0));
    final visits = ref.watch(coworkVisitCountProvider(s.id)).value ?? 0;
    final seats = coworkSeatsLeft(s, ref.watch(coworkMaxMembersProvider));
    final st = context.statusColors.of(AppStatus.pending);
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.groups_rounded, color: cs.primary),
          const SizedBox(width: Space.s12),
          Expanded(child: Text(l.coworkActiveTitle, style: t.titleMedium)),
          Text(l.coworkVisitsToday(f.num(visits)), style: t.labelLarge!.copyWith(color: cs.primary)),
        ]),
        const SizedBox(height: Space.s12),
        for (final m in people)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.s4),
            child: Row(children: [
              PersonAvatar(name: m.name, waiting: m.isInvited),
              const SizedBox(width: Space.s12),
              Expanded(child: Text(m.userId == me ? l.coworkYou(m.name) : m.name, style: t.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (m.isInvited)
                _WaitingChip(label: l.coworkWaiting)
              else
                Icon(Icons.check_circle_rounded, size: 20, color: context.statusColors.of(AppStatus.paid).fg),
            ]),
          ),
        if (s.partnersOf(me).isEmpty) ...[
          const SizedBox(height: Space.s8),
          Text(l.coworkNoPartnerYet, style: t.bodySmall!.copyWith(color: st.fg)),
        ],
        const SizedBox(height: Space.s12),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _leave,
              icon: const Icon(Icons.logout_rounded),
              label: Text(l.coworkLeave),
            ),
          ),
          if (widget.showAdd && seats > 0) ...[
            const SizedBox(width: Space.s12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => context.push('/cowork'),
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: Text(l.coworkAdd),
              ),
            ),
          ],
        ]),
      ]),
    );
  }
}

/// "Waiting" pill for an invitation not yet answered (hourglass, amber).
class _WaitingChip extends StatelessWidget {
  const _WaitingChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final st = context.statusColors.of(AppStatus.dueToday);
    return DecoratedBox(
      decoration: BoxDecoration(color: st.bg, borderRadius: Radii.brSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s2),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.hourglass_top_rounded, size: 16, color: st.fg),
          const SizedBox(width: Space.s4),
          Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: st.fg, height: 1.2)),
        ]),
      ),
    );
  }
}

/// Me tab entry.
class CoworkMeEntry extends ConsumerWidget {
  const CoworkMeEntry({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final today = ref.watch(coworkTodayProvider);
    final me = ref.watch(myUserIdProvider) ?? '';
    final n = today.invites.length;
    final partners = today.active?.partnersOf(me) ?? const [];
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/cowork'),
      child: ListTile(
        minTileHeight: 64,
        leading: const Icon(Icons.groups_rounded),
        title: Text(l.coworkTitle),
        subtitle: partners.isEmpty ? null : Text(l.coworkWith(partners.map((m) => m.name).join(', ')), maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (n > 0) Badge(label: Text(f.num(n))),
          const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    );
  }
}

/// Co-work screen: my group, invitations, and asking colleagues (FR-CW-001).
class CoworkScreen extends ConsumerStatefulWidget {
  const CoworkScreen({super.key});
  @override
  ConsumerState<CoworkScreen> createState() => _CoworkScreenState();
}

class _CoworkScreenState extends ConsumerState<CoworkScreen> {
  late final _svc = ref.read(coworkServiceProvider);
  late String _requestId = _svc.newRequestId();
  final _note = TextEditingController();
  final _picked = <String>{};
  List<CoworkColleague>? _colleagues;
  CoworkError? _loadError;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final (list, err) = await _svc.colleagues();
    if (err == null) await _svc.refresh();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _colleagues = list;
      _loadError = err;
    });
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    setState(() => _sending = true);
    final r = await _svc.request(clientId: _requestId, toUserIds: _picked.toList(), note: _note.text);
    if (!mounted) return;
    setState(() => _sending = false);
    _snackFor(context, r, l.coworkSent);
    if (r.ok) {
      unawaited(HapticFeedback.mediumImpact());
      // The next invitation is a new request (new idempotency key).
      setState(() {
        _picked.clear();
        _note.clear();
        _requestId = _svc.newRequestId();
      });
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final today = ref.watch(coworkTodayProvider);
    final active = today.active;
    final seats = coworkSeatsLeft(active, ref.watch(coworkMaxMembersProvider));
    final inGroup = {for (final m in active?.members ?? const <CoworkMember>[]) if (m.occupies) m.userId: m.isInvited};

    final list = _colleagues ?? const <CoworkColleague>[];
    return Scaffold(
      appBar: AppBar(title: Text(l.coworkTitle)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, 120),
          children: [
            for (final s in today.invites) ...[CoworkInviteCard(session: s), const SizedBox(height: Space.cardGap)],
            if (active != null) ...[CoworkGroupCard(session: active, showAdd: false), const SizedBox(height: Space.s24)],
            Text(l.coworkInviteSection, style: t.titleMedium),
            const SizedBox(height: Space.s4),
            Text(
              seats > 0 ? '${l.coworkSeatsLeft(f.num(seats))} · ${l.coworkNeedsInternet}' : l.coworkFull,
              style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: Space.s12),
            if (_loading && _colleagues == null)
              const Padding(padding: EdgeInsets.all(Space.s32), child: Center(child: CircularProgressIndicator()))
            else if (_loadError != null && _colleagues == null)
              EmptyState(
                icon: _loadError == CoworkError.offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                title: coworkErrorText(l, _loadError!),
                body: '',
                action: OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: Text(l.actionRetry)),
              )
            else if (list.isEmpty)
              EmptyState(icon: Icons.group_off_rounded, title: l.coworkNoColleagues, body: '')
            else
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Column(children: [
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: Space.s16, endIndent: Space.s16),
                    _ColleagueTile(
                      c: list[i],
                      inThisGroup: inGroup.containsKey(list[i].id),
                      asked: inGroup[list[i].id] ?? false,
                      selected: _picked.contains(list[i].id),
                      canPickMore: _picked.length < seats,
                      onChanged: (v) => setState(() => v ? _picked.add(list[i].id) : _picked.remove(list[i].id)),
                    ),
                  ],
                ]),
              ),
            if (list.isNotEmpty && seats > 0) ...[
              const SizedBox(height: Space.s16),
              TextField(controller: _note, maxLength: 300, maxLines: 2, decoration: InputDecoration(labelText: l.actionNote, hintText: l.coworkNoteHint)),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _picked.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s16),
                child: FilledButton.icon(
                  onPressed: _sending ? null : _send,
                  icon: _sending ? const _Spinner() : const Icon(Icons.send_rounded),
                  label: Text(l.coworkSend(f.num(_picked.length))),
                ),
              ),
            ),
    );
  }
}

class _ColleagueTile extends StatelessWidget {
  const _ColleagueTile({required this.c, required this.inThisGroup, required this.asked, required this.selected, required this.canPickMore, required this.onChanged});
  final CoworkColleague c;
  final bool inThisGroup;

  /// In this group but has not answered yet.
  final bool asked;
  final bool selected;
  final bool canPickMore;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final sc = context.statusColors;
    final blocked = inThisGroup || c.inSession;
    final enabled = !blocked && (selected || canPickMore);
    final (label, color) = inThisGroup
        ? (asked ? l.coworkAsked : l.coworkInThisGroup, sc.of(asked ? AppStatus.dueToday : AppStatus.paid).fg)
        : c.inSession
            ? (l.coworkInOtherGroup, cs.onSurfaceVariant)
            : c.onDutyToday
                ? (l.coworkOnDuty, sc.of(AppStatus.paid).fg)
                : (l.coworkOffDuty, cs.onSurfaceVariant);
    return CheckboxListTile(
      value: selected || inThisGroup,
      onChanged: enabled ? (v) => onChanged(v ?? false) : null,
      minTileHeight: 72,
      secondary: PersonAvatar(name: c.name, waiting: !c.onDutyToday),
      title: Text(c.name, style: t.bodyLarge),
      subtitle: Text.rich(TextSpan(children: [
        TextSpan(text: '${c.employeeCode} · '),
        TextSpan(text: label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ])),
    );
  }
}

/// Visit screen: "joint visit with …" switch, shown only when I have an
/// accepted partner today (works offline from the local session).
class CoworkVisitSwitch extends ConsumerWidget {
  const CoworkVisitSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final s = ref.watch(coworkForVisitProvider);
    final me = ref.watch(myUserIdProvider) ?? '';
    if (s == null) return const SizedBox.shrink();
    final names = s.partnersOf(me).map((m) => m.name).join(', ');
    return Card(
      margin: EdgeInsets.zero,
      color: value ? cs.primaryContainer : null,
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        minTileHeight: 72,
        secondary: Icon(Icons.groups_rounded, color: value ? cs.onPrimaryContainer : cs.onSurfaceVariant),
        title: Text(l.coworkVisitToggle),
        subtitle: Text(value ? l.coworkVisitWith(names) : l.coworkVisitSingle),
      ),
    );
  }
}

/// Names of everyone in my sessions, for "with X" / "recorded by X".
final coworkNamesProvider = Provider<Map<String, String>>((ref) => {
      for (final s in ref.watch(coworkSessionsProvider).value ?? const <CoworkSession>[])
        for (final m in s.members) m.userId: m.name,
    });

/// "Joint" chip for timelines and visit rows.
class CoworkChip extends StatelessWidget {
  const CoworkChip({super.key});
  @override
  Widget build(BuildContext context) => StatusBadge(AppStatus.current, dense: true, label: AppLocalizations.of(context).coworkBadge);
}
