import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/core/utils/formatters.dart';
import 'package:youtube_downloader/domain/download_task.dart';
import 'package:youtube_downloader/features/downloads/downloads_controller.dart';

class DownloadTile extends ConsumerWidget {
  const DownloadTile({super.key, required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final controller = ref.read(downloadsControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onTap(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 64,
                    child: task.thumbnailUrl == null
                        ? _fallback(scheme)
                        : CachedNetworkImage(
                            imageUrl: task.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _fallback(scheme),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${task.platform} · ${task.optionLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusText(task),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: task.status == DownloadStatus.failed
                              ? scheme.error
                              : scheme.primary,
                        ),
                      ),
                      if (task.isActive) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            minHeight: 6,
                            value: task.status == DownloadStatus.downloading &&
                                    task.progress > 0
                                ? task.progress
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                task.isActive
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallback(ColorScheme scheme) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Icon(task.audioOnly ? Icons.audiotrack : Icons.videocam),
      );

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    switch (task.status) {
      case DownloadStatus.completed:
        final uri = task.savedUri;
        if (uri == null) return;
        final opened = await ref.read(nativeStorageProvider).open(
              uri: uri,
              mimeType:
                  task.mimeType ?? (task.audioOnly ? 'audio/mp4' : 'video/mp4'),
            );
        if (!opened && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open the file. It may have been moved or deleted.',
              ),
            ),
          );
        }
      case DownloadStatus.failed || DownloadStatus.canceled:
        ref.read(downloadsControllerProvider.notifier).retry(task.id);
      default:
        break;
    }
  }

  String _statusText(DownloadTask task) {
    return switch (task.status) {
      DownloadStatus.queued => 'Waiting…',
      DownloadStatus.downloading => [
          task.progress > 0
              ? 'Downloading ${(task.progress * 100).toStringAsFixed(0)}%'
              : 'Starting…',
          if (task.etaSeconds != null && task.etaSeconds! > 0)
            '${formatDuration(Duration(seconds: task.etaSeconds!))} left',
        ].join(' · '),
      DownloadStatus.saving => 'Saving to Downloads…',
      DownloadStatus.completed => 'Saved · tap to open',
      DownloadStatus.failed =>
        '${task.error ?? 'Failed'} · tap to retry',
      DownloadStatus.canceled => 'Canceled · tap to retry',
    };
  }
}
