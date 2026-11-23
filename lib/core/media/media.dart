import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../location/location_engine.dart';
import '../providers.dart';
import '../theme/tokens.dart';

/// Camera-only capture (FR-M-009). There is deliberately NO gallery / file
/// picker anywhere in the app (CLAUDE.md §2.5).
abstract class PhotoCapturer {
  Future<Uint8List?> capture(BuildContext context, {bool front = false});
}

class CameraPhotoCapturer implements PhotoCapturer {
  @override
  Future<Uint8List?> capture(BuildContext context, {bool front = false}) =>
      Navigator.of(context).push<Uint8List>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => _CameraScreen(front: front)));
}

/// Demo / test capturer: a generated image (no camera hardware needed).
class FakePhotoCapturer implements PhotoCapturer {
  @override
  Future<Uint8List?> capture(BuildContext context, {bool front = false}) async {
    final im = img.Image(width: 960, height: 720);
    img.fill(im, color: img.ColorRgb8(0x2C, 0x44, 0xCC));
    img.fillRect(im, x1: 0, y1: 480, x2: 960, y2: 720, color: img.ColorRgb8(0x8E, 0xA8, 0xFF));
    img.fillCircle(im, x: 720, y: 200, radius: 90, color: img.ColorRgb8(0xFB, 0xBF, 0x24));
    return Uint8List.fromList(img.encodeJpg(im, quality: 85));
  }
}

class _CameraScreen extends StatefulWidget {
  const _CameraScreen({required this.front});
  final bool front;
  @override
  State<_CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<_CameraScreen> {
  CameraController? _c;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      final cam = cams.firstWhere(
        (c) => c.lensDirection == (widget.front ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => cams.first,
      );
      final c = CameraController(cam, ResolutionPreset.high, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _c = c);
    } catch (e) {
      setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  Future<void> _shoot() async {
    final c = _c;
    if (c == null || _busy) return;
    setState(() => _busy = true);
    try {
      final f = await c.takePicture();
      final bytes = await f.readAsBytes();
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (_) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(fit: StackFit.expand, children: [
        if (_c != null) Center(child: CameraPreview(_c!)) else if (_error != null) const Center(child: Icon(Icons.no_photography_rounded, color: Colors.white, size: 48)) else const Center(child: CircularProgressIndicator()),
        // Framing guide.
        IgnorePointer(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.82,
              heightFactor: 0.5,
              child: DecoratedBox(decoration: BoxDecoration(border: Border.all(color: Colors.white70, width: 2), borderRadius: Radii.brXl)),
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(color: Colors.white, icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Space.s32),
              child: Semantics(
                button: true,
                label: 'shutter',
                child: GestureDetector(
                  onTap: _shoot,
                  child: Container(
                    width: Sizes.shutter,
                    height: Sizes.shutter,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.white54, width: 6)),
                    child: _busy ? const Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator(strokeWidth: 3)) : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class ProcessedPhoto {
  const ProcessedPhoto(this.bytes, this.sha256);
  final Uint8List bytes;
  final String sha256;
}

/// Resize to ≤ 1280 px, burn a watermark (time, staff code, lat/lng),
/// re-encode JPEG ≤ 250 KB (re-encoding drops EXIF). Runs in an isolate.
Future<ProcessedPhoto> processPhoto(Uint8List raw, {required String watermark}) => compute(_process, (raw, watermark));

ProcessedPhoto _process((Uint8List, String) a) {
  var im = img.decodeImage(a.$1)!;
  im = img.bakeOrientation(im);
  final longest = im.width > im.height ? im.width : im.height;
  if (longest > 1280) {
    im = im.width >= im.height ? img.copyResize(im, width: 1280) : img.copyResize(im, height: 1280);
  }
  final barH = 34;
  img.fillRect(im, x1: 0, y1: im.height - barH, x2: im.width, y2: im.height, color: img.ColorRgba8(0, 0, 0, 150));
  img.drawString(im, a.$2, font: img.arial24, x: 10, y: im.height - barH + 5, color: img.ColorRgb8(255, 255, 255));
  var q = 82;
  var out = img.encodeJpg(im, quality: q);
  while (out.length > 250 * 1024 && q > 35) {
    q -= 10;
    out = img.encodeJpg(im, quality: q);
  }
  if (out.length > 250 * 1024) {
    im = img.copyResize(im, width: (im.width * 0.75).round());
    out = img.encodeJpg(im, quality: 60);
  }
  return ProcessedPhoto(out, sha256.convert(out).toString());
}

/// Called when a media item is confirmed on the server, so the owning
/// feature can enqueue the linking mutation (e.g. visit update).
typedef MediaOwnerHook = Future<void> Function(AppDatabase db, String ownerClientId, List<String> serverMediaIds);

final mediaOwnerHooksProvider = Provider<Map<String, MediaOwnerHook>>((ref) => const {});
final photoCapturerProvider = Provider<PhotoCapturer>((ref) => CameraPhotoCapturer());

class MediaService {
  MediaService(this._ref);
  final Ref _ref;
  Future<void>? _running;
  bool _again = false;
  bool _againForce = false;

  AppDatabase get _db => _ref.read(databaseProvider);

  Future<Directory> _dir() async {
    final d = Directory(p.join((await getApplicationSupportDirectory()).path, 'media'));
    if (!d.existsSync()) d.createSync(recursive: true);
    return d;
  }

  /// Saves a processed photo and queues it. Returns the media clientId.
  Future<String> enqueue({required ProcessedPhoto photo, required String kind, required String ownerEntity, required String ownerClientId, GeoFix? fix}) async {
    final id = const Uuid().v7();
    String path;
    try {
      final f = File(p.join((await _dir()).path, '$id.jpg'));
      await f.writeAsBytes(photo.bytes, flush: true);
      path = f.path;
    } catch (_) {
      path = 'memory://$id'; // tests / demo without a filesystem plugin
      _memory[id] = photo.bytes;
    }
    await _db.into(_db.mediaQueue).insert(MediaQueueCompanion.insert(
          clientId: id,
          kind: kind,
          localPath: path,
          sha256: photo.sha256,
          sizeBytes: photo.bytes.length,
          capturedAt: _ref.read(clockProvider).nowUtc(),
          ownerEntity: ownerEntity,
          ownerClientId: ownerClientId,
        ));
    return id;
  }

  static final _memory = <String, Uint8List>{};

  /// The photo as saved on this phone, e.g. for a thumbnail; null once purged or unreadable.
  Future<Uint8List?> localBytes(MediaQueueRow m) async {
    if (m.localPath.startsWith('memory://')) return _memory[m.clientId];
    try {
      return await File(m.localPath).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// Uploads pending media (independent of data sync; Wi-Fi not required): presign → PUT → confirm (FR-M-069).
  ///
  /// Each failure is written to the row in words-ready form (`<step>:<code>`, see [MediaFailure]) with the next
  /// try after a backoff (30 s · attempts², at most 15 min). A row is never deleted here (CLAUDE.md §2.3).
  /// [force] ignores the backoff (the Retry button).
  /// A call while a run is going is not dropped: it runs again right after (a Retry tap must never be lost).
  Future<void> uploadPending({bool force = false}) {
    if (_running != null) {
      _again = true;
      _againForce |= force;
      return _running!;
    }
    final run = _loop(force).whenComplete(() => _running = null);
    _running = run;
    return run;
  }

  Future<void> _loop(bool force) async {
    var f = force;
    do {
      _again = false;
      await _uploadOnce(force: f);
      f = _againForce;
      _againForce = false;
    } while (_again);
  }

  Future<void> _uploadOnce({required bool force}) async {
    {
      final dio = _ref.read(dioProvider);
      final now = _ref.read(clockProvider).nowUtc();
      final rows =
          await (_db.select(_db.mediaQueue)
                ..where(
                  (t) =>
                      t.state.isIn(['pending', 'failed']) &
                      (force ? const Constant(true) : (t.nextAttemptAt.isNull() | t.nextAttemptAt.isSmallerOrEqualValue(now))),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
              .get();
      final confirmedByOwner = <String, List<String>>{};
      for (final m in rows) {
        var step = 'file';
        try {
          final bytes = await localBytes(m);
          if (bytes == null) throw const MediaFailure('file', 'MISSING');
          step = 'presign';
          final r = await dio.post<dynamic>(
            '/media/upload-url',
            data: {
              'kind': m.kind,
              'contentType': 'image/jpeg',
              'sizeBytes': m.sizeBytes,
              'sha256': m.sha256,
              // drift reads a DateTime back in local time; without toUtc() this went out as
              // "2026-11-23T16:00:00.000" (no offset), which is not an RFC 3339 date-time, and field-api
              // answered 400 VALIDATION_FAILED, so no photo ever left the phone (owner report 2026-11-23).
              'capturedAt': m.capturedAt.toUtc().toIso8601String(),
            },
          );
          final j = r.data as Map<String, dynamic>;
          final mediaId = j['mediaId'] as String;
          if (j['alreadyExists'] != true) {
            step = 'upload';
            await dio.put<dynamic>(
              resolveUploadUrl(dio.options.baseUrl, j['uploadUrl'] as String),
              data: bytes,
              options: Options(
                headers: {
                  ...((j['headers'] as Map?) ?? const {}).cast<String, dynamic>(),
                  Headers.contentLengthHeader: bytes.length,
                  Headers.contentTypeHeader: 'image/jpeg',
                },
                // The signature in the URL is the permission: no bearer token, and a large-ish body on a slow line.
                extra: {'skipAuth': true},
                sendTimeout: const Duration(minutes: 2),
                receiveTimeout: const Duration(minutes: 2),
              ),
            );
          }
          step = 'confirm';
          await dio.post<dynamic>('/media/$mediaId/confirm');
          await (_db.update(_db.mediaQueue)..where((t) => t.clientId.equals(m.clientId))).write(
            MediaQueueCompanion(state: const Value('confirmed'), serverMediaId: Value(mediaId), lastError: const Value(null), lastAttemptAt: Value(now)),
          );
          (confirmedByOwner['${m.ownerEntity}|${m.ownerClientId}'] ??= []).add(mediaId);
        } catch (e) {
          final failure = e is MediaFailure ? e : MediaFailure.from(step, e);
          final attempts = m.attempts + 1;
          await (_db.update(_db.mediaQueue)..where((t) => t.clientId.equals(m.clientId))).write(
            MediaQueueCompanion(
              state: const Value('failed'),
              attempts: Value(attempts),
              lastError: Value(failure.wire),
              lastAttemptAt: Value(now),
              nextAttemptAt: Value(now.add(mediaBackoff(attempts))),
            ),
          );
        }
      }
      final hooks = _ref.read(mediaOwnerHooksProvider);
      for (final e in confirmedByOwner.entries) {
        final parts = e.key.split('|');
        final all = await (_db.select(
          _db.mediaQueue,
        )..where((t) => t.ownerEntity.equals(parts[0]) & t.ownerClientId.equals(parts[1]) & t.state.equals('confirmed'))).get();
        await hooks[parts[0]]?.call(_db, parts[1], [for (final r in all) r.serverMediaId!]);
      }
    }
  }

  /// Retry button: try this photo (or every waiting photo when [clientId] is null) now, ignoring the backoff.
  Future<void> retryNow([String? clientId]) async {
    if (clientId != null) {
      await (_db.update(
        _db.mediaQueue,
      )..where((t) => t.clientId.equals(clientId) & t.state.isIn(['pending', 'failed']))).write(const MediaQueueCompanion(nextAttemptAt: Value(null)));
    }
    await uploadPending(force: clientId == null);
  }

  /// Purges confirmed media files older than 7 days.
  Future<void> purgeOld() async {
    final cutoff = _ref.read(clockProvider).nowUtc().subtract(const Duration(days: 7));
    final rows = await (_db.select(_db.mediaQueue)..where((t) => t.state.equals('confirmed') & t.capturedAt.isSmallerThanValue(cutoff))).get();
    for (final r in rows) {
      if (!r.localPath.startsWith('memory://')) {
        try {
          await File(r.localPath).delete();
        } catch (_) {}
      }
    }
  }
}

final mediaServiceProvider = Provider<MediaService>(MediaService.new);

/// Photos not yet on the server, oldest first (sync centre, FR-M-069).
final waitingMediaProvider = StreamProvider<List<MediaQueueRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.mediaQueue)
        ..where((t) => t.state.isIn(['pending', 'failed']))
        ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
      .watch();
});

/// 30 s · attempts², at least 30 s, at most 15 minutes.
Duration mediaBackoff(int attempts) => Duration(seconds: (30 * attempts * attempts).clamp(30, 900));

/// `uploadUrl` as the server sent it. An absolute URL (S3, Cloudinary) is used as is; a path such as
/// `/api/v1/storage/o?t=…` (field-api's own store) is resolved against the API's origin. dio would otherwise
/// glue it to the base URL and PUT to `/api/v1/api/v1/storage/o`.
String resolveUploadUrl(String apiBaseUrl, String uploadUrl) {
  final u = Uri.parse(uploadUrl);
  if (u.hasScheme) return uploadUrl;
  return Uri.parse(apiBaseUrl).resolveUri(u).toString();
}

/// Why a photo upload failed, kept on the row as `<step>:<code>`.
/// step: `file` (the photo on this phone), `presign` (`POST /media/upload-url`), `upload` (the PUT to the
/// signed URL), `confirm` (`POST /media/{id}/confirm`). code: the server's problem `code` (or `details.reason`
/// when it names one, e.g. `MEDIA_DELETED`), `HTTP_<status>` without one, `NETWORK`, `TIMEOUT`, `MISSING`.
class MediaFailure implements Exception {
  const MediaFailure(this.step, this.code);
  final String step;
  final String code;
  String get wire => '$step:$code';

  static MediaFailure parse(String? wire) {
    final w = wire ?? '';
    final i = w.indexOf(':');
    return i < 0 ? MediaFailure('upload', w.isEmpty ? 'UNKNOWN' : w) : MediaFailure(w.substring(0, i), w.substring(i + 1));
  }

  factory MediaFailure.from(String step, Object e) {
    if (e is! DioException) return MediaFailure(step, 'UNKNOWN');
    switch (e.type) {
      case DioExceptionType.connectionError:
        return MediaFailure(step, 'NETWORK');
      case DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout:
        return MediaFailure(step, 'TIMEOUT');
      default:
    }
    final r = e.response;
    if (r == null) return MediaFailure(step, 'NETWORK');
    final d = r.data;
    if (d is Map) {
      final reason = (d['details'] is Map) ? (d['details'] as Map)['reason'] : null;
      if (reason is String && reason.isNotEmpty) return MediaFailure(step, reason);
      final code = d['code'];
      if (code is String && code.isNotEmpty) return MediaFailure(step, code);
    }
    return MediaFailure(step, 'HTTP_${r.statusCode}');
  }

  @override
  String toString() => wire;
}
