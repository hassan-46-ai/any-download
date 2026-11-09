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
        title: const Text(
          'Library',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (hasFinished)
            IconButton(
              tooltip: 'Clear finished',
              icon: const Icon(Icons.clear_all),
              onPressed:
                  ref.read(downloadsControllerProvider.notifier).clearFinished,
            ),
        ],
      ),
      body: tasks.isEmpty
          ? const _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
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
            Icons.video_library_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('Nothing saved yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Your downloads will appear here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
