import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/location/location_engine.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../core/ui/refreshable.dart';
import '../../../core/ui/status_badge.dart';
import '../../../l10n/app_localizations.dart';
import 'prospects_data.dart';

String prospectStatusLabel(AppLocalizations l, String s) => switch (s) {
      'new' => l.prospectStatusNew,
      'contacted' => l.prospectStatusContacted,
      'converted' => l.prospectStatusConverted,
      'dropped' => l.prospectStatusClosed,
      _ => s,
    };

AppStatus _tone(String s) => switch (s) {
      'new' => AppStatus.promised,
      'contacted' => AppStatus.current,
      'converted' => AppStatus.paid,
      _ => AppStatus.pending,
    };

String prospectErrorText(AppLocalizations l, ProspectError e) => switch (e) {
      ProspectError.nameMissing => l.prospectErrName,
      ProspectError.nameTooLong => l.prospectErrNameLong,
      ProspectError.phoneMissing => l.prospectErrPhone,
      ProspectError.phoneInvalid => l.prospectErrPhoneInvalid,
      ProspectError.phoneRepeated => l.prospectErrPhoneRepeated,
      ProspectError.addressTooLong => l.prospectErrAddressLong,
      ProspectError.noteTooLong => l.prospectErrNoteLong,
      ProspectError.notEditable => l.prospectErrNotEditable,
    };

/// Why the server refused a prospect or its change, in words; else its code.
String prospectRefusalText(AppLocalizations l, String? code) => switch (code) {
      'VALIDATION_FAILED' => l.prospectRefusedInvalid,
      'FORBIDDEN' || 'MODULE_DISABLED' => l.prospectRefusedNotAllowed,
      _ => l.prospectRefused(code ?? '—'),
    };

/// Me entry: possible customers (FR-M-073).
class ProspectsMeEntry extends ConsumerWidget {
  const ProspectsMeEntry({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final n = ref.watch(prospectsProvider).value?.length ?? 0;
    return AppCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        minTileHeight: 64,
        leading: const Icon(Icons.person_add_alt_1_rounded),
        title: Text(l.prospectsTitle),
        subtitle: Text(l.prospectsMeSubtitle),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (n > 0) Text(ref.watch(fmtProvider).num(n), style: Theme.of(context).textTheme.titleMedium),
          const Icon(Icons.chevron_right_rounded),
        ]),
        onTap: () => context.push('/prospects'),
      ),
    );
  }
}

/// My possible customers with their status and who added them; add a new one (offline).
class ProspectsScreen extends ConsumerWidget {
  const ProspectsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final rows = ref.watch(prospectsProvider).value ?? const <Prospect>[];
    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: Text(l.prospectsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'prospect-add',
        onPressed: () => context.push('/prospects/new'),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l.prospectAdd),
      ),
      body: PullToRefresh(
        child: rows.isEmpty
          ? PullableFill(child: EmptyState(icon: Icons.person_search_rounded, title: l.prospectsEmpty, body: l.prospectsEmptyBody))
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(Space.screen, Space.s8, Space.screen, 96),
              itemCount: rows.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.cardGap),
              itemBuilder: (_, i) => _ProspectCard(p: rows[i]),
            ),
      ),
    );
  }
}

class _ProspectCard extends ConsumerWidget {
  const _ProspectCard({required this.p});
  final Prospect p;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(fmtProvider);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final by = p.mine ? l.prospectByMe : (p.row.createdByName ?? '—');
    return AppCard(
      onTap: p.editable ? () => context.push('/prospects/${p.row.clientId}/edit') : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(p.row.name, style: t.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: Space.s8),
          StatusBadge(_tone(p.row.status), dense: true, label: prospectStatusLabel(l, p.row.status)),
        ]),
        const SizedBox(height: Space.s4),
        Text(p.phones.map(f.num).join(' · '), style: t.bodyLarge),
        if (p.row.address != null) Text(p.row.address!, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        if (p.row.note != null) Text(p.row.note!, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: Space.s4),
        Text(l.prospectAddedBy(by, f.dateTime(p.row.createdAt)), style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        if (p.hasLocation) Text(l.prospectHasLocation, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        if (p.waiting) Text(l.prospectWaiting, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        if (p.refused) Text(prospectRefusalText(l, p.row.errorCode), style: t.bodyMedium!.copyWith(color: cs.error)),
        if (p.editable)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => context.push('/prospects/${p.row.clientId}/edit'),
              icon: const Icon(Icons.edit_rounded),
              label: Text(l.prospectEdit),
            ),
          ),
      ]),
    );
  }
}

/// Add (clientId null) or change my own prospect.
class ProspectFormScreen extends ConsumerStatefulWidget {
  const ProspectFormScreen({super.key, this.clientId});
  final String? clientId;
  @override
  ConsumerState<ProspectFormScreen> createState() => _ProspectFormState();
}

class _ProspectFormState extends ConsumerState<ProspectFormScreen> {
  final _name = TextEditingController();
  final _phones = [TextEditingController()];
  final _address = TextEditingController();
  final _note = TextEditingController();
  bool _withLocation = false;
  bool _busy = false;
  bool _loaded = false;
  ProspectError? _error;

  @override
  void dispose() {
    for (final c in [_name, ..._phones, _address, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  void _load(Prospect p) {
    _loaded = true;
    _name.text = p.row.name;
    final phones = (jsonDecode(p.row.phonesJson) as List).cast<String>();
    _phones
      ..clear()
      ..addAll([for (final n in phones.isEmpty ? [''] : phones) TextEditingController(text: n)]);
    _address.text = p.row.address ?? '';
    _note.text = p.row.note ?? '';
  }

  ProspectDraft get _draft => (name: _name.text, phones: [for (final c in _phones) c.text], address: _address.text, note: _note.text);

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final v = validateProspect(_draft);
    if (v.error != null) {
      setState(() => _error = v.error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final svc = ref.read(prospectServiceProvider);
      if (widget.clientId == null) {
        GeoFix? fix;
        if (_withLocation && ref.read(prospectLocationAllowedProvider)) {
          fix = await ref.read(locationEngineProvider).currentFix(timeout: const Duration(seconds: 15));
        }
        await svc.create(_draft, fix: fix);
      } else {
        await svc.update(widget.clientId!, _draft);
      }
      if (!mounted) return;
      showAppSnack(context, l.prospectSaved);
      context.pop();
    } on ProspectInvalid catch (e) {
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
    final editing = widget.clientId != null;
    if (editing && !_loaded) {
      final p = ref.watch(prospectProvider(widget.clientId!)).value;
      if (p != null) _load(p);
    }
    final canLocate = ref.watch(prospectLocationAllowedProvider);
    return Scaffold(
      appBar: AppBar(title: Text(editing ? l.prospectEditTitle : l.prospectNewTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.screen, Space.s16, Space.screen, Space.s32),
        children: [
          TextField(key: const Key('prospect-name'), controller: _name, maxLength: prospectNameMax, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: l.prospectName)),
          for (var i = 0; i < _phones.length; i++) ...[
            const SizedBox(height: Space.s8),
            TextField(
              key: Key('prospect-phone-$i'),
              controller: _phones[i],
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: i == 0 ? l.prospectPhone : l.prospectPhoneMore),
            ),
          ],
          if (_phones.length < prospectMaxPhones)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: () => setState(() => _phones.add(TextEditingController())),
                icon: const Icon(Icons.add_rounded),
                label: Text(l.prospectAddPhone),
              ),
            ),
          const SizedBox(height: Space.s8),
          TextField(key: const Key('prospect-address'), controller: _address, maxLength: prospectAddressMax, maxLines: 2, minLines: 1, decoration: InputDecoration(labelText: l.prospectAddress)),
          const SizedBox(height: Space.s8),
          TextField(key: const Key('prospect-note'), controller: _note, maxLength: prospectNoteMax, maxLines: 3, minLines: 1, decoration: InputDecoration(labelText: l.prospectNote)),
          if (!editing) ...[
            const SizedBox(height: Space.s8),
            SwitchListTile(
              key: const Key('prospect-location'),
              contentPadding: EdgeInsets.zero,
              value: canLocate && _withLocation,
              onChanged: canLocate ? (v) => setState(() => _withLocation = v) : null,
              title: Text(l.prospectLocation),
              subtitle: Text(canLocate ? l.prospectLocationHint : l.prospectLocationOffDuty),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: Space.s8),
            Text(prospectErrorText(l, _error!), style: t.bodyMedium!.copyWith(color: cs.error)),
          ],
          const SizedBox(height: Space.s16),
          FilledButton(key: const Key('prospect-save'), onPressed: _busy ? null : _save, child: Text(l.actionSave)),
          const SizedBox(height: Space.s8),
          Text(l.prospectOfflineHint, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
