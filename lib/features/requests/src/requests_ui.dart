import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/api/field_api.dart' show ApiException;
import '../../../core/media/media.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'requests_data.dart';
import 'requests_domain.dart';

String requestTypeLabel(AppLocalizations l, String type) => switch (type) {
      'request' => l.requestTypeRequest,
      'report' => l.requestTypeReport,
      'inform' => l.requestTypeInform,
      'complaint' => l.requestTypeComplaint,
      _ => type,
    };

IconData requestTypeIcon(String type) => switch (type) {
      'report' => Icons.report_rounded,
      'inform' => Icons.info_rounded,
      'complaint' => Icons.feedback_rounded,
      _ => Icons.help_center_rounded,
    };

String requestStatusLabel(AppLocalizations l, String s) => switch (s) {
      'open' => l.requestStatusOpen,
      'forwarded' => l.requestStatusForwarded,
      'assigned' => l.requestStatusAssigned,
      'in_progress' => l.requestStatusInProgress,
      'resolved' => l.requestStatusResolved,
      'closed' => l.requestStatusClosed,
      'reopened' => l.requestStatusReopened,
      _ => s,
    };

/// A queue (1.48.0 `RequestQueue`) in words; unknown kept as sent.
String requestQueueLabel(AppLocalizations l, String q) => switch (q) {
      'area_manager' => l.requestQueueAreaManager,
      'super_admin' => l.requestQueueSuperAdmin,
      _ => q,
    };

/// Who it goes to, in words.
String requestRecipientLabel(AppLocalizations l, RequestPriority p) => p == RequestPriority.important ? l.requestToSuperAdmin : l.requestToAreaManager;

String requestErrorText(AppLocalizations l, RequestError e) => switch (e) {
      RequestError.titleMissing => l.requestErrTitle,
      RequestError.titleTooLong => l.requestErrTitleLong,
      RequestError.detailsMissing => l.requestErrDetails,
      RequestError.detailsTooLong => l.requestErrDetailsLong,
      RequestError.tooManyPhotos => l.requestErrPhotos,
      RequestError.commentMissing => l.requestErrComment,
      RequestError.commentTooLong => l.requestErrCommentLong,
      RequestError.notOpen => l.requestErrNotOpen,
      RequestError.noteMissing => l.requestErrNote,
      RequestError.noteTooLong => l.requestErrNoteLong,
    };

/// Why the server refused a request or a comment, in words; else its code.
String requestRefusalText(AppLocalizations l, String? code) => switch (code) {
      'VALIDATION_FAILED' => l.requestRefusedInvalid,
      'FORBIDDEN' || 'MODULE_DISABLED' => l.requestRefusedNotAllowed,
      _ => l.requestRefused(code ?? '—'),
    };

/// Status as colour + icon + label (design guide §3: never colour alone). Unsent and refused come first.
class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({super.key, required this.request});
  final StaffRequest request;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = context.semanticColors;
    final cs = Theme.of(context).colorScheme;
    final r = request;
    final (fg, bg, icon, label) = r.refused
        ? (s.danger.fg, s.danger.bg, Icons.error_rounded, l.requestStatusRefused)
        : r.waiting
            ? (s.info.fg, s.info.bg, Icons.cloud_upload_rounded, l.requestStatusQueued)
            : switch (r.row.status) {
                'resolved' => (s.success.fg, s.success.bg, Icons.check_circle_rounded, requestStatusLabel(l, r.row.status)),
                'closed' => (cs.onSurfaceVariant, cs.surfaceContainerHigh, Icons.block_rounded, requestStatusLabel(l, r.row.status)),
                'forwarded' || 'assigned' || 'in_progress' => (s.warning.fg, s.warning.bg, Icons.forward_rounded, requestStatusLabel(l, r.row.status)),
                _ => (s.info.fg, s.info.bg, Icons.radio_button_unchecked_rounded, requestStatusLabel(l, r.row.status)),
              };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Space.s8, vertical: Space.s2),
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.all(Radius.circular(Radii.full))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: Space.s4),
        Flexible(child: Text(label, style: Theme.of(context).textTheme.labelMedium!.copyWith(color: fg, height: 1.2))),
      ]),
    );
  }
}

/// Me entry: my requests and reports (FR-M-075).
class RequestsMeEntry extends ConsumerWidget {
  const RequestsMeEntry({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final news = ref.watch(requestsWithNewsProvider).length;
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        key: const Key('requests-me-entry'),
        minTileHeight: 64,
        leading: const Icon(Icons.forum_rounded),
        title: Text(l.requestsTitle),
        subtitle: Text(l.requestsMeSubtitle),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (news > 0) Badge(label: Text(ref.watch(fmtProvider).num(news))),
          const Icon(Icons.chevron_right_rounded),
        ]),
        onTap: () => context.push('/requests'),
      ),
    );
  }
}

final _filterProvider = StateProvider.autoDispose<RequestFilter>((ref) => RequestFilter.open);

/// `/requests`: given to me by the office, then mine with an open / resolved filter; a new one (offline).
class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final all = ref.watch(requestsProvider);
    final filter = ref.watch(_filterProvider);
    final assigned = assignedRequests(all);
    final mine = filterRequests(all, filter);
    Widget section(String label) => Padding(
          padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s8),
          child: Text(label, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
        );
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.requestsTitle), backgroundColor: cs.surfaceContainer),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('request-add'),
        heroTag: 'request-add',
        onPressed: () => context.push('/requests/new'),
        icon: const Icon(Icons.add_comment_rounded),
        label: Text(l.requestNew),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, 96),
        children: [
          if (assigned.isNotEmpty) ...[
            section(l.requestsAssignedToMe),
            for (final r in assigned) ...[_RequestCard(request: r), const SizedBox(height: Space.cardGap)],
          ],
          section(l.requestsMine),
          Wrap(spacing: Space.s8, runSpacing: Space.s8, children: [
            for (final (f, label) in [(RequestFilter.open, l.requestFilterOpen), (RequestFilter.resolved, l.requestFilterResolved)])
              ChoiceChip(
                key: Key('request-filter-${f.name}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                selected: filter == f,
                label: Text(label),
                onSelected: (_) => ref.read(_filterProvider.notifier).state = f,
              ),
          ]),
          const SizedBox(height: Space.s8),
          if (mine.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.s24),
              child: EmptyState(icon: Icons.forum_outlined, title: l.requestsEmpty, body: l.requestsEmptyBody),
            )
          else
            for (final r in mine) ...[_RequestCard(request: r), const SizedBox(height: Space.cardGap)],
        ],
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  const _RequestCard({required this.request});
  final StaffRequest request;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = context.semanticColors;
    final r = request;
    final news = r.unseenChange != null;
    final important = r.priority == RequestPriority.important;
    return AppCard(
      onTap: () => context.push('/requests/${r.key}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(requestTypeIcon(r.row.type), color: cs.onSurfaceVariant),
          const SizedBox(width: Space.s8),
          Expanded(
            child: Text(r.row.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.titleMedium!.copyWith(fontWeight: news ? FontWeight.w700 : FontWeight.w500)),
          ),
          const SizedBox(width: Space.s8),
          Flexible(child: RequestStatusChip(request: r)),
        ]),
        const SizedBox(height: Space.s4),
        Wrap(spacing: Space.s12, runSpacing: Space.s4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(requestTypeLabel(l, r.row.type), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(important ? Icons.priority_high_rounded : Icons.person_rounded, size: 16, color: important ? s.danger.fg : cs.onSurfaceVariant),
            const SizedBox(width: Space.s2),
            Flexible(
              child: Text(important ? l.requestPriorityImportantShort : l.requestPriorityNormalShort,
                  style: t.bodySmall!.copyWith(color: important ? s.danger.fg : cs.onSurfaceVariant, fontWeight: important ? FontWeight.w700 : FontWeight.w400)),
            ),
          ]),
          if (r.row.customerName != null) Text(r.row.customerName!, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          Text(f.dateTime(r.row.createdAt), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          if (r.assignedToMe && r.row.createdByName != null) Text(l.requestFrom(r.row.createdByName!), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          if (news)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.fiber_new_rounded, size: 18, color: s.info.fg),
              const SizedBox(width: Space.s4),
              Flexible(child: Text(l.requestNewsMark, style: t.bodySmall!.copyWith(color: s.info.fg, fontWeight: FontWeight.w700))),
            ]),
        ]),
        if (r.refused) ...[
          const SizedBox(height: Space.s4),
          Text(requestRefusalText(l, r.row.errorCode), style: t.bodyMedium!.copyWith(color: cs.error)),
        ],
      ]),
    );
  }
}

/// `/requests/new`: a new request, report, information or complaint; optional customer (from the customer page)
/// and camera photos. Saved on the phone and sent when there is a network.
class RequestFormScreen extends ConsumerStatefulWidget {
  const RequestFormScreen({super.key, this.customerId, this.customerName});
  final String? customerId;
  final String? customerName;
  @override
  ConsumerState<RequestFormScreen> createState() => _RequestFormState();
}

class _RequestFormState extends ConsumerState<RequestFormScreen> {
  final _title = TextEditingController();
  final _details = TextEditingController();
  RequestType _type = RequestType.request;
  RequestPriority _priority = RequestPriority.normal;
  late String? _customerId = widget.customerId;
  late String? _customerName = widget.customerName;
  final _photos = <Uint8List>[];
  bool _busy = false;
  RequestError? _error;

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    super.dispose();
  }

  RequestDraft get _draft => (type: _type, priority: _priority, title: _title.text, details: _details.text, customerId: _customerId, customerName: _customerName, photoCount: _photos.length);

  Future<void> _takePhoto() async {
    // Camera only (CLAUDE.md §2.5): no gallery or file picker.
    final bytes = await ref.read(photoCapturerProvider).capture(context);
    if (bytes != null && mounted) setState(() => _photos.add(bytes));
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final v = validateRequest(_draft);
    if (v.error != null) {
      setState(() => _error = v.error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(requestServiceProvider).create(_draft, photos: List.of(_photos));
      if (!mounted) return;
      showAppSnack(context, l.requestSaved);
      context.pop();
    } on RequestInvalid catch (e) {
      setState(() {
        _error = e.error;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = context.semanticColors;
    Widget label(String text) => Padding(padding: const EdgeInsets.only(top: Space.s16, bottom: Space.s8), child: Text(text, style: t.titleSmall));
    return Scaffold(
      appBar: AppBar(title: Text(l.requestNewTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, Space.s32),
        children: [
          label(l.requestTypeLabel),
          Wrap(spacing: Space.s8, runSpacing: Space.s8, children: [
            for (final ty in RequestType.values)
              ChoiceChip(
                key: Key('request-type-${ty.wire}'),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                avatar: Icon(requestTypeIcon(ty.wire), size: 18),
                selected: _type == ty,
                label: Text(requestTypeLabel(l, ty.wire)),
                onSelected: (_) => setState(() => _type = ty),
              ),
          ]),
          label(l.requestSendTo),
          RadioGroup<RequestPriority>(
            groupValue: _priority,
            onChanged: (p) => setState(() => _priority = p ?? _priority),
            child: Column(children: [
              for (final (p, title, hint) in [
                (RequestPriority.normal, l.requestToAreaManager, l.requestToAreaManagerHint),
                (RequestPriority.important, l.requestToSuperAdmin, l.requestToSuperAdminHint),
              ]) ...[
                AppCard(
                  padding: EdgeInsets.zero,
                  color: _priority == p ? (p == RequestPriority.important ? s.danger.bg : cs.primaryContainer) : null,
                  child: RadioListTile<RequestPriority>(
                    key: Key('request-priority-${p.wire}'),
                    value: p,
                    title: Text(title, style: t.titleMedium!.copyWith(color: p == RequestPriority.important && _priority == p ? s.danger.fg : null)),
                    subtitle: Text(hint),
                    secondary: Icon(p == RequestPriority.important ? Icons.priority_high_rounded : Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: Space.s8),
              ],
            ]),
          ),
          const SizedBox(height: Space.s8),
          TextField(key: const Key('request-title'), controller: _title, maxLength: requestTitleMax, decoration: InputDecoration(labelText: l.requestTitleField)),
          const SizedBox(height: Space.s8),
          TextField(
            key: const Key('request-details'),
            controller: _details,
            maxLength: requestDetailsMax,
            minLines: 3,
            maxLines: 8,
            decoration: InputDecoration(labelText: l.requestDetailsField, alignLabelWithHint: true),
          ),
          if (_customerId != null) ...[
            label(l.requestCustomer),
            InputChip(
              key: const Key('request-customer'),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              avatar: const Icon(Icons.person_pin_rounded),
              label: Text(_customerName ?? _customerId!),
              deleteButtonTooltipMessage: l.requestCustomerRemove,
              onDeleted: () => setState(() {
                _customerId = null;
                _customerName = null;
              }),
            ),
          ],
          label(l.requestPhotos(ref.watch(fmtProvider).num(requestMaxPhotos))),
          Wrap(spacing: Space.s8, runSpacing: Space.s8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            for (var i = 0; i < _photos.length; i++)
              Stack(children: [
                ClipRRect(borderRadius: Radii.brMd, child: Image.memory(_photos[i], width: 88, height: 88, fit: BoxFit.cover)),
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: IconButton.filledTonal(
                    tooltip: l.requestRemovePhoto,
                    onPressed: () => setState(() => _photos.removeAt(i)),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ]),
            if (_photos.length < requestMaxPhotos)
              OutlinedButton.icon(
                key: const Key('request-photo'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: _busy ? null : _takePhoto,
                icon: const Icon(Icons.photo_camera_rounded),
                label: Text(l.requestAddPhoto),
              ),
          ]),
          if (_error != null) ...[
            const SizedBox(height: Space.s12),
            Text(requestErrorText(l, _error!), style: t.bodyMedium!.copyWith(color: cs.error)),
          ],
          const SizedBox(height: Space.s16),
          FilledButton.icon(
            key: const Key('request-save'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            onPressed: _busy ? null : _save,
            icon: const Icon(Icons.send_rounded),
            label: Text(l.requestSend),
          ),
          const SizedBox(height: Space.s8),
          Text(l.requestOfflineHint, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// `/requests/:key`: the whole request, its timeline and my comments (offline-first).
class RequestDetailScreen extends ConsumerStatefulWidget {
  const RequestDetailScreen({super.key, required this.requestKey});
  final String requestKey;
  @override
  ConsumerState<RequestDetailScreen> createState() => _RequestDetailState();
}

class _RequestDetailState extends ConsumerState<RequestDetailScreen> {
  final _comment = TextEditingController();
  RequestError? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Opening it clears its alert (after the first frame: it writes to the database).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(requestServiceProvider).markSeen(widget.requestKey);
    });
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final v = validateComment(_comment.text);
    if (v.error != null) {
      setState(() => _error = v.error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(requestServiceProvider).comment(widget.requestKey, _comment.text);
      _comment.clear();
      if (mounted) showAppSnack(context, l.requestCommentSaved);
    } on RequestInvalid catch (e) {
      _error = e.error;
    }
    if (mounted) setState(() => _busy = false);
  }

  /// Reopen needs a reason and the internet (contract 1.48.0 has no sync mutation for it).
  Future<void> _reopen() async {
    final l = AppLocalizations.of(context);
    final note = await showDialog<String>(context: context, builder: (_) => const _ReopenDialog());
    if (note == null || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(requestServiceProvider).reopen(widget.requestKey, note);
      if (mounted) showAppSnack(context, l.requestReopenDone);
    } on RequestInvalid catch (e) {
      if (mounted) showAppSnack(context, requestErrorText(l, e.error), icon: Icons.error_rounded);
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.isNetwork ? l.requestReopenOffline : l.requestReopenFailed(e.problem?.details?['reason'] as String? ?? e.code), icon: Icons.error_rounded);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = context.semanticColors;
    final f = ref.watch(fmtProvider);
    final r = ref.watch(requestProvider(widget.requestKey));
    if (r == null) {
      return Scaffold(appBar: AppBar(title: Text(l.requestDetailTitle)), body: Center(child: EmptyState(icon: Icons.forum_outlined, title: l.requestsEmpty, body: '')));
    }
    final important = r.priority == RequestPriority.important;
    final held = r.waiting && r.localPhotos > 0;
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.requestDetailTitle), backgroundColor: cs.surfaceContainer),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
        children: [
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(r.row.title, style: t.titleLarge)),
                const SizedBox(width: Space.s8),
                Flexible(child: RequestStatusChip(request: r)),
              ]),
              const SizedBox(height: Space.s8),
              KeyValueRow(label: l.requestTypeLabel, value: Text(requestTypeLabel(l, r.row.type))),
              KeyValueRow(label: l.requestSendTo, value: Text(requestRecipientLabel(l, r.priority))),
              if (r.row.assigneeName != null || r.row.currentQueue != null)
                KeyValueRow(label: l.requestHolder, value: Text(r.row.assigneeName ?? requestQueueLabel(l, r.row.currentQueue!))),
              if (!r.mine && r.row.createdByName != null) KeyValueRow(label: l.requestSentBy, value: Text(r.row.createdByName!)),
              if (r.row.customerName != null || r.row.customerId != null) KeyValueRow(label: l.requestCustomer, value: Text(r.row.customerName ?? r.row.customerId!)),
              KeyValueRow(label: l.requestCreatedAt, value: Text(f.dateTime(r.row.createdAt))),
              if (r.row.status == 'resolved' && r.resolutionNote != null) KeyValueRow(label: l.requestResolution, value: Text(r.resolutionNote!)),
              if (r.photoCount > 0) KeyValueRow(label: l.requestPhotosShort, value: Text(f.num(r.photoCount))),
              const SizedBox(height: Space.s8),
              Text(r.row.details, style: t.bodyLarge),
              if (important) ...[
                const SizedBox(height: Space.s8),
                Row(children: [
                  Icon(Icons.priority_high_rounded, color: s.danger.fg),
                  const SizedBox(width: Space.s4),
                  Expanded(child: Text(l.requestPriorityImportantShort, style: t.bodyMedium!.copyWith(color: s.danger.fg, fontWeight: FontWeight.w700))),
                ]),
              ],
              if (held) ...[
                const SizedBox(height: Space.s8),
                Text(l.requestPhotosWaiting, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              ],
              if (r.refused) ...[
                const SizedBox(height: Space.s8),
                Text(requestRefusalText(l, r.row.errorCode), style: t.bodyMedium!.copyWith(color: cs.error)),
              ],
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: Space.s16, bottom: Space.s8),
            child: Text(l.requestTimeline, style: t.titleSmall!.copyWith(color: cs.onSurfaceVariant)),
          ),
          AppCard(
            child: Column(children: [
              for (final (i, e) in r.timeline.indexed) _TimelineTile(event: e, me: r.me, last: i == r.timeline.length - 1),
            ]),
          ),
          const SizedBox(height: Space.s16),
          if (r.canComment) ...[
            TextField(
              key: const Key('request-comment'),
              controller: _comment,
              maxLength: requestCommentMax,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(labelText: l.requestCommentHint),
            ),
            if (_error != null) Text(requestErrorText(l, _error!), style: t.bodyMedium!.copyWith(color: cs.error)),
            const SizedBox(height: Space.s8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.icon(
                key: const Key('request-comment-send'),
                style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: _busy ? null : _send,
                icon: const Icon(Icons.send_rounded),
                label: Text(l.requestCommentSend),
              ),
            ),
          ] else if (r.isClosed)
            Text(l.requestClosedNoComment, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          if (r.canReopen) ...[
            const SizedBox(height: Space.s8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                key: const Key('request-reopen'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: _busy ? null : _reopen,
                icon: const Icon(Icons.replay_rounded),
                label: Text(l.requestReopen),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineTile extends ConsumerWidget {
  const _TimelineTile({required this.event, required this.me, required this.last});
  final RequestEvent event;
  final String? me;
  final bool last;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final s = context.semanticColors;
    final f = ref.watch(fmtProvider);
    final e = event;
    final to = e.toId != null && e.toId == me ? l.requestByMe : e.toName ?? (e.toQueue == null ? null : requestQueueLabel(l, e.toQueue!));
    final (icon, color, title) = switch (e.type) {
      'created' => (Icons.add_circle_rounded, s.info.fg, l.requestEventCreated),
      'forwarded' => (Icons.forward_rounded, s.warning.fg, to == null ? l.requestEventForwardedNoName : l.requestEventForwarded(to)),
      'assigned' => (Icons.assignment_ind_rounded, s.warning.fg, to == null ? l.requestEventAssignedNoName : l.requestEventAssigned(to)),
      'comment' => (Icons.chat_bubble_rounded, cs.primary, l.requestEventComment),
      'resolved' => (Icons.check_circle_rounded, s.success.fg, l.requestEventResolved),
      'reopened' => (Icons.replay_rounded, s.warning.fg, l.requestEventReopened),
      'closed' => (Icons.block_rounded, cs.onSurfaceVariant, l.requestEventClosed),
      'status_changed' => (Icons.sync_alt_rounded, cs.onSurfaceVariant, l.requestEventStatusChanged(requestStatusLabel(l, e.toStatus ?? '—'))),
      _ => (Icons.circle_outlined, cs.onSurfaceVariant, e.type),
    };
    final by = e.byId != null && e.byId == me ? l.requestByMe : e.byName;
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Icon(icon, color: color, size: 22),
          if (!last) Expanded(child: Container(width: 2, color: cs.outlineVariant)),
        ]),
        const SizedBox(width: Space.s12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : Space.s16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.titleSmall),
              Text([?by, f.dateTime(e.at)].join(' · '), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              if (e.note?.isNotEmpty == true) ...[
                const SizedBox(height: Space.s4),
                Text(e.note!, style: t.bodyMedium),
              ],
              if (e.pending) Text(l.requestCommentPending, style: t.bodySmall!.copyWith(color: s.info.fg)),
              if (e.failed) Text(l.requestCommentFailed, style: t.bodySmall!.copyWith(color: cs.error)),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Asks for the reason to reopen. It owns its text controller, so the controller lives exactly as long as the dialog.
class _ReopenDialog extends StatefulWidget {
  const _ReopenDialog();
  @override
  State<_ReopenDialog> createState() => _ReopenDialogState();
}

class _ReopenDialogState extends State<_ReopenDialog> {
  final _controller = TextEditingController();
  RequestError? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.requestReopenTitle),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.requestReopenBody),
          const SizedBox(height: Space.s12),
          TextField(
            key: const Key('request-reopen-note'),
            controller: _controller,
            maxLines: 3,
            maxLength: requestNoteMax,
            decoration: InputDecoration(hintText: l.requestReopenNoteHint, errorText: _error == null ? null : requestErrorText(l, _error!)),
          ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.actionCancel)),
        FilledButton(
          key: const Key('request-reopen-send'),
          onPressed: () {
            final v = validateReopenNote(_controller.text);
            if (v.error != null) {
              setState(() => _error = v.error);
              return;
            }
            Navigator.of(context).pop(v.text);
          },
          child: Text(l.requestReopen),
        ),
      ],
    );
  }
}
