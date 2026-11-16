import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Permission keys used by the app. Every key must exist in the master
/// catalog (field-api docs/02-requirements.md §3) — `tool/check_permissions.dart`
/// verifies this in CI. Hidden ≠ secure: the server re-checks every call.
abstract final class Perm {
  static const customerView = 'customer.view';
  static const customerLocationPropose = 'customer.location.propose';
  static const tagView = 'tag.view';
  static const tagSet = 'tag.set';
  static const collectionRecord = 'collection.record';
  static const collectionView = 'collection.view';
  static const cashView = 'cash.view';
  static const cashDepositRecord = 'cash.deposit.record';
  static const visitRecord = 'visit.record';
  static const visitView = 'visit.view';
  static const noteCreate = 'note.create';
  static const noteView = 'note.view';
  static const promiseCreate = 'promise.create';
  static const promiseView = 'promise.view';
  static const attendanceRecord = 'attendance.record';
  static const leaveRequest = 'leave.request';
  static const handoverRequest = 'handover.request';
  static const coworkUse = 'cowork.use';

  static const all = [
    customerView, customerLocationPropose, tagView, tagSet, collectionRecord, collectionView, //
    cashView, cashDepositRecord, visitRecord, visitView, noteCreate, noteView, promiseCreate,
    promiseView, attendanceRecord, leaveRequest, handoverRequest, coworkUse,
  ];
}

/// Effective permission keys + feature flags from the server snapshot
/// (login and every pull). Flags default OFF until the server says ON.
@immutable
class AccessSnapshot {
  const AccessSnapshot({this.permissions = const {}, this.flags = const {}});
  final Set<String> permissions;
  final Map<String, bool> flags;

  bool can(String key) => permissions.contains(key);
  bool flag(String? key) => key == null || (flags[key] ?? false);

  AccessSnapshot copyWith({Set<String>? permissions, Map<String, bool>? flags}) =>
      AccessSnapshot(permissions: permissions ?? this.permissions, flags: flags ?? this.flags);
}

class AccessController extends Notifier<AccessSnapshot> {
  @override
  AccessSnapshot build() => const AccessSnapshot();

  void set({Iterable<String>? permissions, Map<String, bool>? flags}) {
    state = state.copyWith(permissions: permissions?.toSet(), flags: flags);
  }

  void clear() => state = const AccessSnapshot();
}

final accessProvider = NotifierProvider<AccessController, AccessSnapshot>(AccessController.new);

/// Shows [child] only when the user holds [permission] (and [flag] is on).
class Can extends ConsumerWidget {
  const Can({super.key, required this.permission, this.flag, required this.child, this.otherwise});
  final String permission;
  final String? flag;
  final Widget child;
  final Widget? otherwise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = ref.watch(accessProvider);
    return a.can(permission) && a.flag(flag) ? child : (otherwise ?? const SizedBox.shrink());
  }
}
