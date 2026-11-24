import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/features/requests/requests.dart';

/// Staff requests (FR-M-075): the rules without the database.
void main() {
  RequestDraft draft({String title = 'দোকান বন্ধ', String details = 'গ্রাহকের দোকান তিন দিন বন্ধ', RequestPriority p = RequestPriority.normal, int photos = 0, String? customerId}) =>
      (type: RequestType.report, priority: p, title: title, details: details, customerId: customerId, customerName: null, photoCount: photos);

  StaffRequestRow row({String createdBy = 'me', String? assignee, String status = 'open', List<Map<String, dynamic>> events = const [], DateTime? seenAt, String sync = 'synced'}) => StaffRequestRow(
        clientId: 'rq-1',
        serverId: 'srv-1',
        type: 'report',
        priority: 'normal',
        title: 'দোকান বন্ধ',
        details: 'x',
        customerId: null,
        customerName: null,
        status: status,
        createdById: createdBy,
        createdByName: null,
        assigneeId: assignee,
        assigneeName: null,
        currentQueue: null,
        level: null,
        photoIdsJson: '[]',
        eventsJson: jsonEncode(events),
        createdAt: DateTime.utc(2026, 11, 24, 4),
        updatedAt: null,
        seenAt: seenAt,
        syncState: sync,
        errorCode: null,
      );

  // 1.48.0 `RequestTimelineEntry`: kind, at, actor, note, to { queue, user }.
  Map<String, dynamic> ev(String type, int minute, {String by = 'u-bm-001', String? to, String? note, String? clientId}) => {
        'id': 'e-$minute',
        'kind': type,
        'at': DateTime.utc(2026, 11, 24, 4, minute).toIso8601String(),
        'actor': {'id': by, 'name': 'মোস্তফা কামাল'},
        if (to != null) 'to': {'queue': 'assignee', 'user': {'id': to, 'name': 'রাকিব'}},
        'note': ?note,
        'clientId': ?clientId,
      };

  test('a subject and details are needed; words are trimmed; limits of 1.48.0', () {
    expect(validateRequest(draft(title: '  ')).error, RequestError.titleMissing);
    expect(validateRequest(draft(title: 'ক' * 161)).error, RequestError.titleTooLong);
    expect(validateRequest(draft(details: ' ')).error, RequestError.detailsMissing);
    expect(validateRequest(draft(details: 'ক' * 4001)).error, RequestError.detailsTooLong);
    expect(validateRequest(draft(photos: 6)).error, RequestError.tooManyPhotos);
    final ok = validateRequest(draft(title: ' দোকান বন্ধ ', customerId: ' ')).draft!;
    expect([ok.title, ok.customerId], ['দোকান বন্ধ', null]);
    expect(validateComment('  ').error, RequestError.commentMissing);
    expect(validateComment('ক' * 2001).error, RequestError.commentTooLong);
    expect(validateComment(' ঠিক আছে ').text, 'ঠিক আছে');
    expect(validateReopenNote(' ').error, RequestError.noteMissing);
    expect(validateReopenNote('ক' * 1001).error, RequestError.noteTooLong);
  });

  test('payload: the two choices map to normal (area manager) and important (super admin); customer only when given', () {
    final normal = requestPayload('c-1', validateRequest(draft()).draft!);
    expect(normal, {'clientId': 'c-1', 'type': 'report', 'priority': 'normal', 'title': 'দোকান বন্ধ', 'body': 'গ্রাহকের দোকান তিন দিন বন্ধ'});
    final important = requestPayload('c-2', validateRequest(draft(p: RequestPriority.important, customerId: 'c-1001')).draft!);
    expect([important['priority'], important['customerId']], ['important', 'c-1001']);
    expect(RequestPriority.fromWire('anything'), RequestPriority.normal);
  });

  test('timeline: created from the row until the server sends it; my unsent comment shown until the server has it', () {
    final comment = RequestCommentRow(clientId: 'cm-1', requestClientId: 'rq-1', body: 'আরও জানাই', createdAt: DateTime.utc(2026, 11, 24, 4, 30), syncState: 'queued', errorCode: null);
    var r = StaffRequest(row(), me: 'me', myComments: [comment]);
    expect(r.timeline.map((e) => (e.type, e.pending)).toList(), [('created', false), ('comment', true)]);

    r = StaffRequest(row(events: [ev('created', 0, by: 'me'), ev('forwarded', 10, to: 'u-sa-001'), ev('comment', 30, by: 'me', note: 'আরও জানাই', clientId: 'cm-1')]), me: 'me', myComments: [comment]);
    expect(r.timeline.map((e) => e.type).toList(), ['created', 'forwarded', 'comment'], reason: 'the server holds my comment: shown once');
    expect(r.timeline[1].toName, 'রাকিব');
    final queue = RequestEvent.fromJson({'kind': 'forwarded', 'at': '2026-11-24T04:10:00Z', 'actor': {'id': 'u', 'name': 'ক'}, 'to': {'queue': 'super_admin', 'user': null}, 'status': {'from': 'open', 'to': 'forwarded'}})!;
    expect([queue.toQueue, queue.toId, queue.toStatus], ['super_admin', null, 'forwarded']);
    expect(RequestEvent.fromJson({'kind': 'x'}), isNull, reason: 'no time: dropped, never a crash');
  });

  test('news: the last step by someone else after I opened it; my own steps never count', () {
    var r = StaffRequest(row(events: [ev('created', 0, by: 'me')], seenAt: DateTime.utc(2026, 11, 24, 4)), me: 'me');
    expect(r.unseenChange, isNull);
    r = StaffRequest(row(events: [ev('created', 0, by: 'me'), ev('comment', 20, by: 'me')], seenAt: DateTime.utc(2026, 11, 24, 4)), me: 'me');
    expect(r.unseenChange, isNull);
    r = StaffRequest(row(events: [ev('created', 0, by: 'me'), ev('forwarded', 10), ev('resolved', 20, note: 'হয়ে গেছে')], seenAt: DateTime.utc(2026, 11, 24, 4, 5)), me: 'me');
    expect([r.unseenChange?.type, r.unseenChange?.note], ['resolved', 'হয়ে গেছে']);
    r = StaffRequest(row(events: [ev('resolved', 20)], seenAt: DateTime.utc(2026, 11, 24, 4, 25), status: 'resolved'), me: 'me');
    expect(r.unseenChange, isNull, reason: 'opened after it');
  });

  test('given to me: a colleague\'s request assigned to me is news until opened, and listed apart from mine', () {
    final given = StaffRequest(row(createdBy: 'u-fs-020', assignee: 'me'), me: 'me');
    final mine = StaffRequest(row(), me: 'me');
    final resolved = StaffRequest(row(status: 'resolved'), me: 'me');
    expect([given.mine, given.assignedToMe], [false, true]);
    expect(given.unseenChange?.type, 'assigned');
    expect(StaffRequest(row(createdBy: 'u-fs-020', assignee: 'me', seenAt: DateTime.utc(2026, 11, 24, 5)), me: 'me').unseenChange, isNull);
    expect(filterRequests([given, mine, resolved], RequestFilter.open), [mine]);
    expect(filterRequests([given, mine, resolved], RequestFilter.resolved), [resolved]);
    expect(assignedRequests([given, mine, resolved]), [given]);
  });

  test('comments: none on a refused or closed request; reopen only mine, sent, resolved or closed', () {
    expect(StaffRequest(row(), me: 'me').canComment, isTrue);
    expect(StaffRequest(row(sync: 'queued'), me: 'me').canComment, isTrue, reason: 'offline: waits for the request');
    expect(StaffRequest(row(sync: 'failed'), me: 'me').canComment, isFalse);
    expect(StaffRequest(row(status: 'resolved'), me: 'me').canComment, isTrue);
    expect(StaffRequest(row(status: 'closed'), me: 'me').canComment, isFalse);
    expect(StaffRequest(row(status: 'resolved'), me: 'me').canReopen, isTrue);
    expect(StaffRequest(row(status: 'closed'), me: 'me').canReopen, isTrue);
    expect(StaffRequest(row(), me: 'me').canReopen, isFalse);
    expect(StaffRequest(row(status: 'resolved', createdBy: 'u-fs-020', assignee: 'me'), me: 'me').canReopen, isFalse);
  });
}
