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
  bool _uploading = false;

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

  /// Uploads pending media (independent of data sync; Wi-Fi not required).
  Future<void> uploadPending() async {
    if (_uploading) return;
    _uploading = true;
    try {
      final dio = _ref.read(dioProvider);
      final now = _ref.read(clockProvider).nowUtc();
      final rows = await (_db.select(_db.mediaQueue)
            ..where((t) => t.state.isIn(['pending', 'failed']) & (t.nextAttemptAt.isNull() | t.nextAttemptAt.isSmallerOrEqualValue(now))))
          .get();
      final confirmedByOwner = <String, List<String>>{};
      for (final m in rows) {
        try {
          final bytes = m.localPath.startsWith('memory://') ? _memory[m.clientId]! : await File(m.localPath).readAsBytes();
          final r = await dio.post<dynamic>('/media/upload-url', data: {
            'kind': m.kind,
            'contentType': 'image/jpeg',
            'sizeBytes': m.sizeBytes,
            'sha256': m.sha256,
            'capturedAt': m.capturedAt.toIso8601String(),
          });
          final j = r.data as Map<String, dynamic>;
          final mediaId = j['mediaId'] as String;
          if (j['alreadyExists'] != true) {
            await dio.put<dynamic>(
              j['uploadUrl'] as String,
              data: Stream.fromIterable([bytes]),
              options: Options(headers: {
                ...((j['headers'] as Map?) ?? const {}).cast<String, dynamic>(),
                Headers.contentLengthHeader: bytes.length,
                Headers.contentTypeHeader: 'image/jpeg',
              }, extra: {'skipAuth': true}),
            );
          }
          await dio.post<dynamic>('/media/$mediaId/confirm');
          await (_db.update(_db.mediaQueue)..where((t) => t.clientId.equals(m.clientId))).write(
            MediaQueueCompanion(state: const Value('confirmed'), serverMediaId: Value(mediaId)),
          );
          (confirmedByOwner['${m.ownerEntity}|${m.ownerClientId}'] ??= []).add(mediaId);
        } catch (_) {
          final attempts = m.attempts + 1;
          await (_db.update(_db.mediaQueue)..where((t) => t.clientId.equals(m.clientId))).write(
            MediaQueueCompanion(
              state: const Value('failed'),
              attempts: Value(attempts),
              nextAttemptAt: Value(now.add(Duration(seconds: (30 * attempts * attempts).clamp(30, 900)))),
            ),
          );
        }
      }
      final hooks = _ref.read(mediaOwnerHooksProvider);
      for (final e in confirmedByOwner.entries) {
        final parts = e.key.split('|');
        final all = await (_db.select(_db.mediaQueue)..where((t) => t.ownerEntity.equals(parts[0]) & t.ownerClientId.equals(parts[1]) & t.state.equals('confirmed'))).get();
        await hooks[parts[0]]?.call(_db, parts[1], [for (final r in all) r.serverMediaId!]);
      }
    } finally {
      _uploading = false;
    }
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
