import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/utils/formatters.dart';
import 'package:youtube_downloader/core/widgets/error_view.dart';
import 'package:youtube_downloader/domain/stream_option.dart';
import 'package:youtube_downloader/domain/video_item.dart';
import 'package:youtube_downloader/features/downloads/downloads_controller.dart';
import 'package:youtube_downloader/features/shell/shell_providers.dart';
import 'package:youtube_downloader/features/video/video_providers.dart';

void openVideoDetails(BuildContext context, VideoItem video) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => VideoDetailsPage(video: video)),
  );
}

/// Shows a video and lets the user pick the quality / format to download.
class VideoDetailsPage extends ConsumerWidget {
  const VideoDetailsPage({super.key, required this.video});

  final VideoItem video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final options = ref.watch(streamOptionsProvider(video.id));

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: CachedNetworkImage(
              imageUrl: video.thumbnailUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  [
                    video.author,
                    if (formatDuration(video.duration).isNotEmpty)
                      formatDuration(video.duration),
                    if (video.viewCount != null)
                      '${formatCount(video.viewCount!)} views',
                  ].join(' · '),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          options.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SizedBox(
              height: 240,
              child: ErrorView(
                message: describeError(error),
                onRetry: () => ref.invalidate(streamOptionsProvider(video.id)),
              ),
            ),
            data: (list) => _OptionsList(video: video, options: list),
          ),
        ],
      ),
    );
  }
}

class _OptionsList extends ConsumerWidget {
  const _OptionsList({required this.video, required this.options});

  final VideoItem video;
  final List<StreamOption> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videos = options.where((o) => o.kind == StreamKind.video);
    final audios = options.where((o) => o.kind == StreamKind.audio);

    if (options.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('No downloadable streams for this video.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (videos.isNotEmpty) ...[
          const _SectionHeader('Video with sound'),
          for (final option in videos) _OptionTile(video, option),
        ],
        if (audios.isNotEmpty) ...[
          const _SectionHeader('Audio only'),
          for (final option in audios) _OptionTile(video, option),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _OptionTile extends ConsumerWidget {
  const _OptionTile(this.video, this.option);

  final VideoItem video;
  final StreamOption option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        option.kind == StreamKind.video
            ? Icons.videocam_outlined
            : Icons.audiotrack_outlined,
      ),
      title: Text(option.label),
      subtitle: Text(formatBytes(option.sizeBytes)),
      trailing: const Icon(Icons.download),
      onTap: () => _startDownload(context, ref),
    );
  }

  void _startDownload(BuildContext context, WidgetRef ref) {
    ref.read(downloadsControllerProvider.notifier).start(video, option);

    // Read everything from `ref` before navigating: this widget is disposed
    // as soon as the page is popped.
    final shell = ref.read(shellIndexProvider.notifier);
    final navigator = Navigator.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Download started'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            shell.select(ShellIndex.downloads);
            navigator.popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }
}
