import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:youtube_downloader/data/media_info_parser.dart';
import 'package:youtube_downloader/domain/media_info.dart';

class DownloadProgress {
  const DownloadProgress({
    required this.taskId,
    required this.percent,
    this.etaSeconds,
  });

  final String taskId;

  /// 0-100, or negative while yt-dlp has not reported anything yet.
  final double percent;
  final int? etaSeconds;
}

class DownloadedFile {
  const DownloadedFile({required this.path, required this.extension});

  final String path;
  final String extension;
}

/// Dart side of the yt-dlp bridge (see YtDlpBridge.kt).
///
/// yt-dlp supports YouTube (and Shorts), Facebook, Instagram, TikTok, X and
/// well over a thousand other sites.
class YtDlpService {
  YtDlpService() {
    _channel.setMethodCallHandler(_onNativeCall);
  }

  static const _channel = MethodChannel('com.example.youtube_downloader/ytdlp');

  final _progress = StreamController<DownloadProgress>.broadcast();
  Future<void>? _ready;

  Stream<DownloadProgress> get progress => _progress.stream;

  /// Starts the engine in the background so the first request is fast.
  void warmUp() => unawaited(_ensureReady().catchError((Object _) {}));

  Future<MediaInfo> fetchInfo(String url) async {
    await _ensureReady();
    final raw = await _channel.invokeMethod<String>('getInfo', {'url': url});
    final json = jsonDecode(raw!) as Map<String, dynamic>;
    return parseMediaInfo(json, url);
  }

  Future<DownloadedFile> download({
    required String taskId,
    required String url,
    required String formatSelector,
    required bool audioOnly,
  }) async {
    await _ensureReady();
    final result = await _channel.invokeMapMethod<String, String>('download', {
      'taskId': taskId,
      'url': url,
      'format': formatSelector,
      'audioOnly': audioOnly,
    });
    return DownloadedFile(
      path: result!['path']!,
      extension: result['extension']!,
    );
  }

  Future<void> cancel(String taskId) async {
    await _channel.invokeMethod<bool>('cancel', {'taskId': taskId});
  }

  /// Downloads the newest yt-dlp. Sites change often; this fixes most breakage.
  Future<String> updateEngine() async {
    await _ensureReady();
    final status = await _channel.invokeMethod<String>('update');
    return status ?? 'UNKNOWN';
  }

  void dispose() {
    _channel.setMethodCallHandler(null);
    _progress.close();
  }

  Future<void> _ensureReady() {
    return _ready ??= _channel.invokeMethod<void>('init').catchError(
      (Object error) {
        _ready = null; // allow a retry on the next call
        throw error;
      },
    );
  }

  Future<void> _onNativeCall(MethodCall call) async {
    if (call.method != 'progress') return;
    final args = call.arguments as Map;
    _progress.add(
      DownloadProgress(
        taskId: args['taskId'] as String,
        percent: (args['percent'] as num).toDouble(),
        etaSeconds: (args['eta'] as num?)?.toInt(),
      ),
    );
  }
}
