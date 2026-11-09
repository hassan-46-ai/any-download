import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/utils/formatters.dart';
import 'package:youtube_downloader/core/utils/mime.dart';
import 'package:youtube_downloader/domain/download_task.dart';
import 'package:youtube_downloader/domain/media_info.dart';

/// Owns every download: starts them, reports progress and keeps the history.
class DownloadsController extends Notifier<List<DownloadTask>> {
  final Set<String> _cancelRequests = {};

  @override
  List<DownloadTask> build() => ref.read(downloadsStoreProvider).load();

  void start(MediaInfo media, QualityOption option) {
    final task = DownloadTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      url: media.url,
      title: media.title,
      author: media.author,
      platform: media.platform,
      thumbnailUrl: media.thumbnailUrl,
      optionLabel: option.label,
      formatSelector: option.formatSelector,
      audioOnly: option.audioOnly,
      createdAt: DateTime.now(),
    );
    state = [task, ...state];
    unawaited(_run(task));
  }

  void retry(String id) {
    final task = state.firstWhere((t) => t.id == id);
    final fresh = task.restarted();
    _update(id, (_) => fresh);
    unawaited(_run(fresh));
  }

  void cancel(String id) {
    _cancelRequests.add(id);
    unawaited(ref.read(ytDlpServiceProvider).cancel(id));
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
    _persist();
  }

  void clearFinished() {
    state = state.where((t) => t.isActive).toList();
    _persist();
  }

  Future<void> _run(DownloadTask task) async {
    final service = ref.read(ytDlpServiceProvider);
    final storage = ref.read(nativeStorageProvider);
    File? output;

    final progressSub = service.progress
        .where((p) => p.taskId == task.id && p.percent >= 0)
        .listen((p) {
      _update(
        task.id,
        (t) => t.copyWith(
          progress: (p.percent / 100).clamp(0.0, 1.0),
          etaSeconds: p.etaSeconds,
        ),
      );
    });

    try {
      _update(task.id, (t) => t.copyWith(status: DownloadStatus.downloading));

      final file = await service.download(
        taskId: task.id,
        url: task.url,
        formatSelector: task.formatSelector,
        audioOnly: task.audioOnly,
      );
      output = File(file.path);

      _update(
        task.id,
        (t) => t.copyWith(status: DownloadStatus.saving, progress: 1),
      );
      final mime = mimeForExtension(file.extension);
      final uri = await storage.saveToDownloads(
        sourcePath: file.path,
        fileName: '${sanitizeFileName(task.title)}.${file.extension}',
        mimeType: mime,
      );
      _update(
        task.id,
        (t) => t.copyWith(
          status: DownloadStatus.completed,
          savedUri: uri,
          mimeType: mime,
        ),
      );
    } catch (error) {
      final canceled = _cancelRequests.contains(task.id);
      _update(
        task.id,
        (t) => t.copyWith(
          status: canceled ? DownloadStatus.canceled : DownloadStatus.failed,
          error: canceled ? null : describeError(error),
        ),
      );
    } finally {
      await progressSub.cancel();
      _cancelRequests.remove(task.id);
      try {
        if (output != null && await output.exists()) await output.delete();
      } catch (_) {
        // Temp-file cleanup is best effort.
      }
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
