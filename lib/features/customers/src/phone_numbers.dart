import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api/api_models.dart';
import '../../../core/api/field_api.dart';
import '../../../core/db/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/settings/ui_prefs.dart';
import '../../../core/sync/sync_handlers.dart';
import '../../../core/text/search_text.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/ui/common.dart';
import '../../../l10n/app_localizations.dart';
import 'domain/phones.dart';

/// Adds phone numbers to a customer, offline-first (FR-M-037, contract 1.23.0).
///
/// The numbers show on the customer at once (marked as waiting) and go to the
/// server with the `customer_phone` mutation. field-api keeps them in the
/// field system; nothing is written to the ERP. Returns how many were saved.
Future<int> addCustomerPhones(Ref ref, {required String customerId, required List<PhoneToAdd> phones}) async {
  if (phones.isEmpty) return 0;
  final db = ref.read(databaseProvider);
  final id = const Uuid().v7(); // made once; the same id is sent on every retry
  var saved = 0;
  await db.transaction(() async {
    final row = await (db.select(db.customers)..where((t) => t.serverId.equals(customerId))).getSingleOrNull();
    if (row == null) return;
    final list = decodePhones(row.phonesJson);
    final have = {for (final p in list) p.number};
    var room = phoneRoom(list);
    final add = <PhoneToAdd>[];
    for (final p in phones) {
      if (room <= 0 || !have.add(p.number)) continue;
      room--;
      add.add(p);
    }
    if (add.isEmpty) return;
    saved = add.length;
    await (db.update(db.customers)..where((t) => t.serverId.equals(customerId))).write(CustomersCompanion(
      phonesJson: Value(encodePhones([...list, for (final p in add) CustomerPhone(number: p.number, fromErp: false, label: p.label, pending: true)])),
      // so the customer is found by the new number before the next pull
      searchText: Value(addToSearchText(row.searchText, add.map((p) => p.number).join(' '))),
    ));
    await ref.read(outboxWriterProvider).enqueue(mutationId: id, entity: 'customer_phone', payload: {
      'customerId': customerId,
      'phones': [for (final p in add) {'number': p.number, 'label': ?p.label}],
    });
  });
  if (saved > 0) unawaited(ref.read(syncEngineProvider).kick(reason: 'phone'));
  return saved;
}

/// After the server answered: an accepted number is no longer "waiting"; a
/// refused one (no permission, customer gone) leaves the list again. The
/// refusal itself stays visible in the sync centre's Problems.
class CustomerPhonePushHandler implements PushResultHandler {
  @override
  Set<String> get mutationTypes => const {'customer_phone'};

  @override
  Future<void> onResult(AppDatabase db, OutboxRow m, SyncPushResult r) async {
    if (r.result == 'rejected' && r.retryable) return; // still queued
    final payload = jsonDecode(m.payloadJson) as Json;
    final customerId = payload['customerId'] as String?;
    if (customerId == null) return;
    final sent = {for (final p in (payload['phones'] as List? ?? const [])) if (p is Map) p['number']};
    final row = await (db.select(db.customers)..where((t) => t.serverId.equals(customerId))).getSingleOrNull();
    if (row == null) return;
    final refused = r.result == 'rejected';
    final next = <CustomerPhone>[
      for (final p in decodePhones(row.phonesJson))
        if (!(p.pending && sent.contains(p.number)))
          p
        else if (!refused)
          CustomerPhone(number: p.number, fromErp: false, label: p.label),
    ];
    await (db.update(db.customers)..where((t) => t.serverId.equals(customerId))).write(CustomersCompanion(phonesJson: Value(encodePhones(next))));
  }
}

final customerPhoneServiceProvider = Provider<CustomerPhoneService>(CustomerPhoneService.new);

enum PhoneRemoveError { offline, notAllowed, failed }

class CustomerPhoneService {
  CustomerPhoneService(this._ref);
  final Ref _ref;
  Future<int> add({required String customerId, required List<PhoneToAdd> phones}) => addCustomerPhones(_ref, customerId: customerId, phones: phones);

  /// FR-M-053: removes a number added in the field. Online only (ADR-M08
  /// exception, like the admin panel): the server is asked first, then the
  /// number leaves the local list. An ERP number is never removed; a number
  /// still waiting to reach the server is not removable until it got there.
  Future<PhoneRemoveError?> remove({required String customerId, required String number}) async {
    try {
      await _ref.read(fieldApiProvider).removeCustomerPhone(customerId, number);
    } on ApiException catch (e) {
      if (e.isNetwork) return PhoneRemoveError.offline;
      return e.statusCode == 403 || e.statusCode == 422 ? PhoneRemoveError.notAllowed : PhoneRemoveError.failed;
    }
    final db = _ref.read(databaseProvider);
    final row = await (db.select(db.customers)..where((t) => t.serverId.equals(customerId))).getSingleOrNull();
    if (row == null) return null;
    final next = [for (final p in decodePhones(row.phonesJson)) if (p.fromErp || p.number != number) p];
    await (db.update(db.customers)..where((t) => t.serverId.equals(customerId))).write(CustomersCompanion(phonesJson: Value(encodePhones(next))));
    return null;
  }
}

/// Asks before removing an added number and says what happened (FR-M-053).
Future<void> confirmRemovePhone(BuildContext context, WidgetRef ref, {required String customerId, required CustomerPhone phone}) async {
  final l = AppLocalizations.of(context);
  final f = ref.read(fmtProvider);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.phoneRemoveTitle),
      content: Text(l.phoneRemoveBody(f.num(phone.number))),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.actionCancel)),
        FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l.phoneRemove)),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final err = await ref.read(customerPhoneServiceProvider).remove(customerId: customerId, number: phone.number);
  if (!context.mounted) return;
  final text = switch (err) {
    null => l.phoneRemoved,
    PhoneRemoveError.offline => l.phoneRemoveOffline,
    PhoneRemoveError.notAllowed => l.phoneRemoveNotAllowed,
    PhoneRemoveError.failed => l.errorGeneric,
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

Future<void> showAddPhonesSheet(BuildContext context, {required String customerId, required List<CustomerPhone> existing}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddPhonesSheet(customerId: customerId, existing: existing),
    );

class _AddPhonesSheet extends ConsumerStatefulWidget {
  const _AddPhonesSheet({required this.customerId, required this.existing});
  final String customerId;
  final List<CustomerPhone> existing;
  @override
  ConsumerState<_AddPhonesSheet> createState() => _AddPhonesSheetState();
}

class _Row {
  final number = TextEditingController();
  final label = TextEditingController();
  void dispose() {
    number.dispose();
    label.dispose();
  }
}

class _AddPhonesSheetState extends ConsumerState<_AddPhonesSheet> {
  final _rows = <_Row>[_Row()];
  // Rows the user dropped: their controllers are disposed with the sheet, not while their fields unmount.
  final _dropped = <_Row>[];
  bool _tried = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final r in [..._rows, ..._dropped]) {
      r.dispose();
    }
    super.dispose();
  }

  DraftCheck get _check => checkPhoneDrafts([for (final r in _rows) (number: r.number.text, label: r.label.text)], widget.existing);

  String? _errorText(AppLocalizations l, PhoneDraftError? e) => switch (e) {
        PhoneDraftError.invalid => l.phoneErrInvalid,
        PhoneDraftError.duplicate => l.phoneErrDuplicate,
        PhoneDraftError.repeated => l.phoneErrRepeated,
        null => null,
      };

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final f = ref.read(fmtProvider);
    final check = _check;
    setState(() => _tried = true);
    if (check.hasError || check.phones.isEmpty) return;
    setState(() => _saving = true);
    final n = await ref.read(customerPhoneServiceProvider).add(customerId: widget.customerId, phones: check.phones);
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnack(context, l.phoneSavedN(f.num(n)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final f = ref.watch(fmtProvider);
    final check = _check;
    final room = phoneRoom(widget.existing);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(Space.s24, 0, Space.s24, MediaQuery.of(context).viewInsets.bottom + Space.s24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(l.phoneAddTitle, style: t.titleLarge),
        const SizedBox(height: Space.s4),
        Text(l.phoneAddHint, style: t.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: Space.s16),
        for (var i = 0; i < _rows.length; i++) ...[
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 5,
              child: TextField(
                controller: _rows[i].number,
                autofocus: i == _rows.length - 1,
                keyboardType: TextInputType.phone,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l.phoneNumberN(f.num(i + 1)),
                  hintText: '01XXXXXXXXX',
                  // Say what is wrong after a save attempt, or as soon as a full-length number is typed.
                  errorText: _tried || _rows[i].number.text.trim().length >= 11 ? _errorText(l, check.errors[i]) : null,
                  errorMaxLines: 2,
                ),
              ),
            ),
            const SizedBox(width: Space.s8),
            Expanded(
              flex: 4,
              child: TextField(
                controller: _rows[i].label,
                textCapitalization: TextCapitalization.sentences,
                inputFormatters: [LengthLimitingTextInputFormatter(30)],
                decoration: InputDecoration(labelText: l.phoneWhose, hintText: l.phoneWhoseHint),
              ),
            ),
            if (_rows.length > 1)
              IconButton(
                tooltip: l.phoneDropRow(f.num(i + 1)),
                onPressed: () => setState(() => _dropped.add(_rows.removeAt(i))),
                icon: const Icon(Icons.close_rounded),
              ),
          ]),
          const SizedBox(height: Space.s12),
        ],
        if (_rows.length < room)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => setState(() => _rows.add(_Row())),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.phoneAnother),
            ),
          ),
        if (_tried && !check.hasError && check.phones.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.s8),
            child: Text(l.phoneErrEmpty, style: t.bodyMedium!.copyWith(color: cs.error)),
          ),
        const SizedBox(height: Space.s4),
        Text(l.phoneKeptHere, style: t.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: Space.s16),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(Sizes.primaryButton)),
          child: Text(l.phoneSave),
        ),
      ]),
    );
  }
}
