import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/utils/formatters.dart';
import 'package:youtube_downloader/domain/download_task.dart';
import 'package:youtube_downloader/domain/stream_option.dart';
import 'package:youtube_downloader/domain/video_item.dart';

class _DownloadCanceled implements Exception {
  const _DownloadCanceled();
}

/// Owns every download: starts them, reports progress and keeps the history.
class DownloadsController extends Notifier<List<DownloadTask>> {
  final Set<String> _cancelRequests = {};

  @override
  List<DownloadTask> build() => ref.read(downloadsStoreProvider).load();

  void start(VideoItem video, StreamOption option) {
    final task = DownloadTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      video: video,
      optionLabel: option.label,
      fileName: '${sanitizeFileName(video.title)}.${option.extension}',
      mimeType: option.mimeType,
      createdAt: DateTime.now(),
    );
    state = [task, ...state];
    unawaited(_run(task, option));
  }

  void cancel(String id) => _cancelRequests.add(id);

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
    _persist();
  }

  void clearFinished() {
    state = state.where((t) => t.isActive).toList();
    _persist();
  }

  Future<void> _run(DownloadTask task, StreamOption option) async {
    final repository = ref.read(youtubeRepositoryProvider);
    final storage = ref.read(nativeStorageProvider);
    File? tempFile;
    IOSink? sink;

    try {
      _update(task.id, (t) => t.copyWith(status: DownloadStatus.downloading));

      final dir = await getTemporaryDirectory();
      tempFile = File('${dir.path}/${task.id}.part');
      sink = tempFile.openWrite();

      final total = option.sizeBytes;
      var received = 0;
      var lastReported = 0.0;

      await for (final chunk in repository.openStream(option)) {
        if (_cancelRequests.remove(task.id)) throw const _DownloadCanceled();
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          final progress = (received / total).clamp(0.0, 1.0);
          if (progress - lastReported >= 0.01) {
            lastReported = progress;
            _update(task.id, (t) => t.copyWith(progress: progress));
          }
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      _update(
        task.id,
        (t) => t.copyWith(status: DownloadStatus.saving, progress: 1),
      );
      final uri = await storage.saveToDownloads(
        sourcePath: tempFile.path,
        fileName: task.fileName,
        mimeType: task.mimeType,
      );
      _update(
        task.id,
        (t) => t.copyWith(status: DownloadStatus.completed, savedUri: uri),
      );
    } on _DownloadCanceled {
      _update(task.id, (t) => t.copyWith(status: DownloadStatus.canceled));
    } catch (error) {
      _update(
        task.id,
        (t) => t.copyWith(
          status: DownloadStatus.failed,
          error: describeError(error),
        ),
      );
    } finally {
      try {
        await sink?.close();
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {
        // Temp-file cleanup is best effort.
      }
      _cancelRequests.remove(task.id);
      _persist();
    }
  }

  void _update(String id, DownloadTask Function(DownloadTask) change) {
    state = [
      for (final task in state)
        if (task.id == id) change(task) else task,
    ];
  }

  void _persist() => ref.read(downloadsStoreProvider).save(state);
}

final downloadsControllerProvider =
    NotifierProvider<DownloadsController, List<DownloadTask>>(
  DownloadsController.new,
);
