import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:staff_app/app/app.dart';
import 'package:staff_app/app/router.dart';
import 'package:staff_app/core/api/fake/fake_field_api.dart' show isRfc3339;
import 'package:staff_app/core/db/app_database.dart';
import 'package:staff_app/core/media/media.dart';
import 'package:staff_app/core/providers.dart';
import 'package:staff_app/features/sync/sync.dart';
import 'package:staff_app/l10n/app_localizations.dart';

import 'helpers.dart';

/// Photos stayed "upload pending" (owner report 2026-11-23, FR-M-069). The fake API answers the media
/// endpoints the way field-api does (RFC 3339 `capturedAt`, signed `/api/v1/storage/o` PUT checked against
/// type, size and sha256, confirm only after the bytes arrived).
void main() {
  late Harness h;
  Future<String> queue() async {
    final p = await processPhoto(testJpeg(), watermark: 'test');
    return h.read(mediaServiceProvider).enqueue(photo: p, kind: 'selfie', ownerEntity: 'nothing', ownerClientId: 'x-1');
  }

  Future<MediaQueueRow> row(String id) {
    final db = h.read(databaseProvider);
    return (db.select(db.mediaQueue)..where((t) => t.clientId.equals(id))).getSingle();
  }

  group('uploader', () {
    setUp(() => h = Harness());
    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await h.dispose();
    });

    test('the cause: capturedAt as drift reads it back has no offset, which the server refuses', () async {
      await h.signIn();
      final id = await queue();
      final r = await row(id);
      // drift returns local time: the old code sent this string.
      expect(r.capturedAt.isUtc, isFalse);
      expect(isRfc3339(r.capturedAt.toIso8601String()), isFalse);
      expect(isRfc3339(r.capturedAt.toUtc().toIso8601String()), isTrue);
    });

    test('presign → signed PUT → confirm: the photo reaches the server with an RFC 3339 time', () async {
      await h.signIn();
      final id = await queue();
      await h.read(mediaServiceProvider).uploadPending();
      final r = await row(id);
      expect(r.state, 'confirmed', reason: 'lastError: ${r.lastError}');
      expect(r.serverMediaId, isNotNull);
      expect(r.lastError, isNull);
      expect(h.api.uploadedMedia, [r.serverMediaId]);
      final b = h.api.presignBodies.single;
      expect(isRfc3339(b['capturedAt']), isTrue, reason: '${b['capturedAt']}');
      expect(DateTime.parse(b['capturedAt'] as String), r.capturedAt.toUtc());
      final put = h.api.storagePuts.single;
      expect(put.contentType, 'image/jpeg');
      expect(put.contentLength, '${r.sizeBytes}');
      expect(put.bodyLength, r.sizeBytes);
      expect(put.hadAuth, isFalse, reason: 'the signature is the permission');
    });

    test('a relative uploadUrl (/api/v1/storage/o?t=…) is sent to the API origin, not glued to /api/v1', () async {
      h.api.relativeUploadUrl = true;
      await h.signIn();
      final id = await queue();
      await h.read(mediaServiceProvider).uploadPending();
      expect((await row(id)).state, 'confirmed');
      expect(resolveUploadUrl('https://api.example.com/api/v1', '/api/v1/storage/o?t=a.b-c_d'), 'https://api.example.com/api/v1/storage/o?t=a.b-c_d');
      expect(resolveUploadUrl('https://api.example.com/api/v1', 'https://res.cloudinary.com/x?sig=1'), 'https://res.cloudinary.com/x?sig=1');
    });

    test('a refused upload keeps the photo with its reason and next try; Retry sends it at once', () async {
      await h.signIn();
      final id = await queue();
      h.api.uploadsFail = true;
      await h.read(mediaServiceProvider).uploadPending();
      var r = await row(id);
      expect(r.state, 'failed');
      expect(r.attempts, 1);
      expect(r.lastError, 'upload:UNAVAILABLE');
      expect(r.nextAttemptAt!.toUtc(), h.clock.nowUtc().add(const Duration(seconds: 30)));
      // The backoff holds it back from an ordinary run…
      h.api.uploadsFail = false;
      await h.read(mediaServiceProvider).uploadPending();
      expect((await row(id)).state, 'failed');
      // …but Retry ignores it.
      await h.read(mediaServiceProvider).retryNow(id);
      r = await row(id);
      expect(r.state, 'confirmed');
      expect(r.lastError, isNull);
    });

    test('offline: the reason is NETWORK, the photo stays, and it backs off up to 15 minutes', () async {
      await h.signIn();
      final id = await queue();
      h.api.offline = true;
      final m = h.read(mediaServiceProvider);
      await m.uploadPending();
      expect((await row(id)).lastError, 'presign:NETWORK');
      expect(mediaBackoff(1), const Duration(seconds: 30));
      expect(mediaBackoff(3), const Duration(seconds: 270));
      expect(mediaBackoff(50), const Duration(minutes: 15));
      expect(await h.read(outboxReaderProvider).unsyncedCount(), greaterThanOrEqualTo(1));
    });

    test('a photo file that is gone says so (file:MISSING) and is never deleted', () async {
      await h.signIn();
      final db = h.read(databaseProvider);
      await db
          .into(db.mediaQueue)
          .insert(
            MediaQueueCompanion.insert(
              clientId: 'gone-1',
              kind: 'visit_photo',
              localPath: '/nonexistent/gone-1.jpg',
              sha256: 'a' * 64,
              sizeBytes: 10,
              capturedAt: h.clock.nowUtc(),
              ownerEntity: 'visit',
              ownerClientId: 'v-1',
              nextAttemptAt: const Value(null),
            ),
          );
      await h.read(mediaServiceProvider).uploadPending();
      final r = await row('gone-1');
      expect([r.state, r.lastError], ['failed', 'file:MISSING']);
    });

    test('server answers become words (bn and en)', () async {
      final en = lookupAppLocalizations(const Locale('en'));
      final bn = lookupAppLocalizations(const Locale('bn'));
      DioException err(int status, Object? data) => DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: status,
          data: data,
        ),
      );
      expect(MediaFailure.from('presign', err(400, {'code': 'VALIDATION_FAILED'})).wire, 'presign:VALIDATION_FAILED');
      expect(
        MediaFailure.from(
          'presign',
          err(409, {
            'code': 'INVALID_STATE',
            'details': {'reason': 'MEDIA_DELETED'},
          }),
        ).wire,
        'presign:MEDIA_DELETED',
      );
      expect(MediaFailure.from('upload', err(403, '<xml/>')).wire, 'upload:HTTP_403');
      expect(
        MediaFailure.from(
          'upload',
          DioException.connectionError(
            requestOptions: RequestOptions(path: '/x'),
            reason: 'x',
          ),
        ).wire,
        'upload:NETWORK',
      );
      expect(mediaFailureText(en, 'presign:VALIDATION_FAILED'), "the server did not accept the photo's details (getting the upload link)");
      expect(mediaFailureText(en, 'upload:HTTP_403'), 'the upload link was refused or had expired (sending the photo)');
      expect(mediaFailureText(en, 'presign:MEDIA_DELETED'), 'the office deleted this photo on the server (getting the upload link)');
      expect(mediaFailureText(en, 'file:MISSING'), 'the photo file is no longer on this phone');
      expect(mediaFailureText(en, 'confirm:SOMETHING'), 'the server answered SOMETHING (confirming)');
      expect(mediaFailureText(bn, 'upload:NETWORK'), 'সার্ভারের সাথে সংযোগ নেই (ছবি পাঠানোর সময়)');
    });
  });

  testWidgets('sync centre lists each waiting photo with its state, reason and a Retry button', (t) async {
    h = Harness();
    await t.runAsync(h.signIn);
    t.view.physicalSize = const Size(412, 892) * 2;
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    final id = await t.runAsync(() async {
      h.api.uploadsFail = true;
      final id = await queue();
      await h.read(mediaServiceProvider).uploadPending();
      return id;
    });
    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await t.pump(const Duration(milliseconds: 100));
      }
    }

    await t.pumpWidget(UncontrolledProviderScope(container: h.container, child: const FieldApp(watchConnectivity: false)));
    await settle();
    h.read(routerProvider).go('/sync');
    await settle();
    expect(find.byType(MediaQueueCard), findsOneWidget);
    final reason = find.text('এখনো আপলোড হয়নি: সার্ভার এখন উত্তর দিচ্ছে না (ছবি পাঠানোর সময়)', skipOffstage: false);
    await t.ensureVisible(reason);
    await settle();
    expect(reason, findsOneWidget);
    expect(find.text('হাজিরার ছবি'), findsOneWidget);
    final retry = find.descendant(of: find.byType(MediaQueueCard), matching: find.byType(TextButton));
    expect(t.getSize(retry).height, greaterThanOrEqualTo(48));
    h.api.uploadsFail = false;
    await t.ensureVisible(retry);
    await settle();
    await t.tap(retry);
    await settle();
    final r = await t.runAsync(() => row(id!));
    expect(r!.state, 'confirmed', reason: '${r.lastError} ${r.attempts}');
    expect(find.byType(MediaQueueCard), findsNothing);
  });
}
