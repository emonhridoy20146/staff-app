import '../api/api_models.dart';
import '../db/app_database.dart';

/// Pull side: applies server changes for one `SyncChange.entity`.
/// Called inside one transaction per pull page.
abstract class PullHandler {
  String get entity;
  Future<void> upsert(AppDatabase db, String id, Json data);
  Future<void> delete(AppDatabase db, String id, {String? reason});
}

/// Push side: updates the local entity after the server answered for one
/// mutation of a type this feature owns.
abstract class PushResultHandler {
  /// Mutation entity types handled (`SyncMutation.entity`).
  Set<String> get mutationTypes;

  Future<void> onResult(AppDatabase db, OutboxRow mutation, SyncPushResult result);
}

/// Registry built from feature manifests (`lib/app/features.dart`).
class SyncHandlerRegistry {
  SyncHandlerRegistry({List<PullHandler> pull = const [], List<PushResultHandler> push = const []}) {
    for (final h in pull) {
      if (_pull.containsKey(h.entity)) throw StateError('Duplicate pull handler for ${h.entity}');
      _pull[h.entity] = h;
    }
    for (final h in push) {
      for (final t in h.mutationTypes) {
        if (_push.containsKey(t)) throw StateError('Duplicate push handler for $t');
        _push[t] = h;
      }
    }
  }

  final Map<String, PullHandler> _pull = {};
  final Map<String, PushResultHandler> _push = {};

  PullHandler? pullFor(String entity) => _pull[entity];
  PushResultHandler? pushFor(String mutationType) => _push[mutationType];

  Iterable<String> get pullEntities => _pull.keys;
}
