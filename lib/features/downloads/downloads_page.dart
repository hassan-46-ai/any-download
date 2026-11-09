import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/features/downloads/downloads_controller.dart';
import 'package:youtube_downloader/features/downloads/widgets/download_tile.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(downloadsControllerProvider);
    final hasFinished = tasks.any((t) => !t.isActive);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (hasFinished)
            IconButton(
              tooltip: 'Clear finished',
              icon: const Icon(Icons.clear_all),
              onPressed: ref
                  .read(downloadsControllerProvider.notifier)
                  .clearFinished,
            ),
        ],
      ),
      body: tasks.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) => DownloadTile(task: tasks[i]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.download_for_offline_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No downloads yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Files you download appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
