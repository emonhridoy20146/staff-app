import 'dart:convert';

import '../../../core/db/app_database.dart';

/// Staff requests (FR-M-075, contract 1.48.0): the rules, without the database or the UI.
///
/// A staff member reports, tells or asks something. `normal` goes to the area manager, `important` to the super
/// admin. The office forwards it, assigns it (it can come back to a staff member), comments and resolves it; every
/// step is on the server's timeline.

const requestTitleMax = 120;
const requestDetailsMax = 2000;
const requestCommentMax = 1000;
const requestMaxPhotos = 3;

/// What kind of item it is (contract `type`).
enum RequestType {
  request('request'),
  report('report'),
  inform('inform'),
  complaint('complaint');

  const RequestType(this.wire);
  final String wire;

  static RequestType? fromWire(String? w) => values.where((t) => t.wire == w).firstOrNull;
}

/// Who it goes to (contract `priority`): `normal` → area manager, `important` → super admin.
enum RequestPriority {
  normal('normal'),
  important('important');

  const RequestPriority(this.wire);
  final String wire;

  static RequestPriority fromWire(String? w) => w == 'important' ? important : normal;
}

enum RequestError { titleMissing, titleTooLong, detailsMissing, detailsTooLong, tooManyPhotos, commentMissing, commentTooLong, notOpen }

class RequestInvalid implements Exception {
  const RequestInvalid(this.error);
  final RequestError error;
  @override
  String toString() => 'RequestInvalid($error)';
}

/// What the form holds, checked by [validateRequest].
typedef RequestDraft = ({RequestType type, RequestPriority priority, String title, String details, String? customerId, String? customerName, int photoCount});

/// The draft cleaned (trimmed), or the first problem.
({RequestDraft? draft, RequestError? error}) validateRequest(RequestDraft d) {
  final title = d.title.trim();
  if (title.isEmpty) return (draft: null, error: RequestError.titleMissing);
  if (title.length > requestTitleMax) return (draft: null, error: RequestError.titleTooLong);
  final details = d.details.trim();
  if (details.isEmpty) return (draft: null, error: RequestError.detailsMissing);
  if (details.length > requestDetailsMax) return (draft: null, error: RequestError.detailsTooLong);
  if (d.photoCount > requestMaxPhotos) return (draft: null, error: RequestError.tooManyPhotos);
  final cid = d.customerId?.trim();
  return (
    draft: (type: d.type, priority: d.priority, title: title, details: details, customerId: cid == null || cid.isEmpty ? null : cid, customerName: d.customerName, photoCount: d.photoCount),
    error: null,
  );
}

/// A comment cleaned, or the problem.
({String? text, RequestError? error}) validateComment(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return (text: null, error: RequestError.commentMissing);
  if (t.length > requestCommentMax) return (text: null, error: RequestError.commentTooLong);
  return (text: t, error: null);
}

/// The `request` mutation's payload (planned contract 1.48.0 `RequestCreate`, idempotent by clientId).
/// `photoMediaIds` is added when the photos are on the server (the mutation waits `held` until then).
Map<String, dynamic> requestPayload(String clientId, RequestDraft d) => {
      'clientId': clientId,
      'type': d.type.wire,
      'priority': d.priority.wire,
      'title': d.title,
      'details': d.details,
      if (d.customerId != null) 'customerId': d.customerId,
    };

/// Statuses that mean the office has finished with it.
const closedRequestStatuses = {'resolved', 'closed'};

/// One step on a request's timeline.
class RequestEvent {
  const RequestEvent({required this.type, required this.at, this.byId, this.byName, this.toId, this.toName, this.note, this.clientId, this.pending = false, this.failed = false});

  /// `created`, `forwarded`, `assigned`, `comment`, `resolved`, `reopened` (unknown kept as sent).
  final String type;
  final DateTime at;
  final String? byId;
  final String? byName;
  final String? toId;
  final String? toName;
  final String? note;

  /// A comment's clientId (to match my own comment once the server has it).
  final String? clientId;

  /// My own comment, still on this phone.
  final bool pending;

  /// My own comment, refused by the server.
  final bool failed;

  static String? _name(Object? o) {
    if (o is! Map) return null;
    final n = o['name'];
    if (n is String) return n;
    if (n is Map) return (n['bn'] ?? n['en']) as String?;
    return null;
  }

  static RequestEvent? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final at = DateTime.tryParse('${raw['at'] ?? raw['createdAt'] ?? ''}');
    final type = raw['type'];
    if (at == null || type is! String) return null;
    final by = raw['by'] ?? raw['actor'];
    final to = raw['to'] ?? raw['assignee'];
    return RequestEvent(
      type: type,
      at: at.toUtc(),
      byId: by is Map ? by['id'] as String? : null,
      byName: _name(by),
      toId: to is Map ? to['id'] as String? : null,
      toName: _name(to),
      note: (raw['note'] ?? raw['text'] ?? raw['body']) as String?,
      clientId: raw['clientId'] as String?,
    );
  }
}

/// A request on the phone.
class StaffRequest {
  const StaffRequest(this.row, {required this.me, this.myComments = const [], this.localPhotos = 0});
  final StaffRequestRow row;

  /// My user id (null before sign-in finished: then everything on the phone counts as mine).
  final String? me;
  final List<RequestCommentRow> myComments;

  /// Photos of it still on this phone (not yet on the server).
  final int localPhotos;

  String get key => row.clientId;
  RequestType? get type => RequestType.fromWire(row.type);
  RequestPriority get priority => RequestPriority.fromWire(row.priority);

  bool get mine => row.createdById == null || row.createdById == me;

  /// The office gave it to me (forwarded or assigned) and I did not make it.
  bool get assignedToMe => !mine && me != null && row.assigneeId == me;

  bool get isClosed => closedRequestStatuses.contains(row.status);
  bool get waiting => row.syncState == 'queued';
  bool get refused => row.syncState == 'failed';

  /// Comments are possible once it can reach the server (offline too) and while the office has not closed it.
  bool get canComment => !refused && !isClosed;

  int get photoCount => (jsonDecode(row.photoIdsJson) as List).length + localPhotos;

  List<RequestEvent> get serverEvents {
    try {
      return [for (final e in jsonDecode(row.eventsJson) as List) ?RequestEvent.fromJson(e)];
    } catch (_) {
      return const [];
    }
  }

  /// The whole timeline, oldest first: "created" (from the row when the server has not sent one yet), the
  /// server's steps, and my comments the server's timeline does not hold yet.
  List<RequestEvent> get timeline {
    final server = serverEvents;
    final known = {for (final e in server) ?e.clientId};
    final out = <RequestEvent>[
      if (!server.any((e) => e.type == 'created')) RequestEvent(type: 'created', at: row.createdAt.toUtc(), byId: row.createdById ?? me, byName: row.createdByName),
      ...server,
      for (final c in myComments)
        if (!known.contains(c.clientId))
          RequestEvent(type: 'comment', at: c.createdAt.toUtc(), byId: me, note: c.body, clientId: c.clientId, pending: c.syncState == 'queued', failed: c.syncState == 'failed'),
    ];
    out.sort((a, b) => a.at.compareTo(b.at));
    return out;
  }

  /// The last step someone else made after I last opened it (my own steps never count).
  RequestEvent? get unseenChange {
    final seen = row.seenAt;
    RequestEvent? last;
    for (final e in serverEvents) {
      if (e.byId != null && e.byId == me) continue;
      if (e.type == 'created' && mine) continue;
      if (seen != null && !e.at.isAfter(seen)) continue;
      if (last == null || e.at.isAfter(last.at)) last = e;
    }
    // Given to me with no timeline yet: the item itself is news until I open it.
    if (last == null && assignedToMe && seen == null) {
      return RequestEvent(type: 'assigned', at: (row.updatedAt ?? row.createdAt).toUtc(), toId: me);
    }
    return last;
  }
}

/// Filter of the list.
enum RequestFilter { open, resolved, all }

/// Mine (made by me), split by the filter; newest first.
List<StaffRequest> filterRequests(List<StaffRequest> all, RequestFilter f) => [
      for (final r in all)
        if (r.mine && (f == RequestFilter.all || (f == RequestFilter.resolved) == r.isClosed)) r,
    ];

/// Given to me by the office, still open first.
List<StaffRequest> assignedRequests(List<StaffRequest> all) => [
      for (final r in all)
        if (r.assignedToMe && !r.isClosed) r,
      for (final r in all)
        if (r.assignedToMe && r.isClosed) r,
    ];
