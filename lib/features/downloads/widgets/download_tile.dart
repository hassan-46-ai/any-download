import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/domain/download_task.dart';
import 'package:youtube_downloader/features/downloads/downloads_controller.dart';
import 'package:youtube_downloader/features/video/video_details_page.dart';

class DownloadTile extends ConsumerWidget {
  const DownloadTile({super.key, required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.read(downloadsControllerProvider.notifier);

    return ListTile(
      onTap: () => _onTap(context, ref),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 96,
          height: 54,
          child: CachedNetworkImage(
            imageUrl: task.video.thumbnailUrl,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(task.isAudio ? Icons.audiotrack : Icons.videocam),
            ),
          ),
        ),
      ),
      title: Text(task.video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            '${task.optionLabel} · ${_statusText(task)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: task.status == DownloadStatus.failed
                  ? theme.colorScheme.error
                  : null,
            ),
          ),
          if (task.isActive) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: task.status == DownloadStatus.downloading &&
                      task.progress > 0
                  ? task.progress
                  : null,
            ),
          ],
        ],
      ),
      trailing: task.isActive
          ? IconButton(
              tooltip: 'Cancel',
              icon: const Icon(Icons.close),
              onPressed: () => controller.cancel(task.id),
            )
          : IconButton(
              tooltip: 'Remove from list',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => controller.remove(task.id),
            ),
    );
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    switch (task.status) {
      case DownloadStatus.completed:
        final uri = task.savedUri;
        if (uri == null) return;
        final opened = await ref
            .read(nativeStorageProvider)
            .open(uri: uri, mimeType: task.mimeType);
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the file. It may have been moved or deleted.'),
            ),
          );
        }
      case DownloadStatus.failed || DownloadStatus.canceled:
        // Let the user pick a quality again to retry.
        openVideoDetails(context, task.video);
      default:
        break;
    }
  }

  String _statusText(DownloadTask task) {
    return switch (task.status) {
      DownloadStatus.queued => 'Waiting…',
      DownloadStatus.downloading =>
        'Downloading ${(task.progress * 100).toStringAsFixed(0)}%',
      DownloadStatus.saving => 'Saving to Downloads…',
      DownloadStatus.completed => 'Saved · tap to open',
      DownloadStatus.failed =>
        'Failed${task.error == null ? '' : ': ${task.error}'} · tap to retry',
      DownloadStatus.canceled => 'Canceled · tap to retry',
    };
  }
}
