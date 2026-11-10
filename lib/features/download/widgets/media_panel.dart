import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/utils/formatters.dart';
import 'package:youtube_downloader/core/widgets/error_view.dart';
import 'package:youtube_downloader/core/widgets/gradient_button.dart';
import 'package:youtube_downloader/domain/media_info.dart';
import 'package:youtube_downloader/domain/video_item.dart';
import 'package:youtube_downloader/features/download/media_providers.dart';
import 'package:youtube_downloader/features/downloads/download_actions.dart';

/// Reads [url] and lets the user pick a quality, then download.
/// Shared by the Download tab and the video details page.
class MediaPanel extends ConsumerStatefulWidget {
  const MediaPanel({super.key, required this.url, this.placeholder});

  final String url;

  /// Shown while the link is being read (e.g. the card the user tapped).
  final VideoItem? placeholder;

  @override
  ConsumerState<MediaPanel> createState() => _MediaPanelState();
}

class _MediaPanelState extends ConsumerState<MediaPanel> {
  String? _selectedId;

  @override
  void didUpdateWidget(MediaPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _selectedId = null;
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(mediaInfoProvider(widget.url));

    return info.when(
      loading: () => _Loading(placeholder: widget.placeholder),
      error: (error, _) => SizedBox(
        height: 260,
        child: ErrorView(
          message: describeError(error),
          onRetry: () => ref.invalidate(mediaInfoProvider(widget.url)),
        ),
      ),
      data: (media) {
        final selected = media.options.firstWhere(
          (o) => o.id == _selectedId,
          orElse: () => media.options.first,
        );
        return _Loaded(
          media: media,
          selected: selected,
          onSelect: (option) => setState(() => _selectedId = option.id),
          onDownload: () =>
              startDownloadWithFeedback(context, ref, media, selected),
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({this.placeholder});

  final VideoItem? placeholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (placeholder != null) ...[
          _Thumbnail(url: placeholder!.thumbnailUrl),
          const SizedBox(height: 16),
          Text(placeholder!.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 12),
            Text(
              'Reading link…',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ],
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    required this.media,
    required this.selected,
    required this.onSelect,
    required this.onDownload,
  });

  final MediaInfo media;
  final QualityOption selected;
  final ValueChanged<QualityOption> onSelect;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final duration = formatDuration(media.duration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Thumbnail(
          url: media.thumbnailUrl,
          badge: media.platform,
          duration: duration,
        ),
        const SizedBox(height: 16),
        Text(
          media.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          media.author,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Text('Quality', style: theme.textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in media.options)
              ChoiceChip(
                avatar: option.audioOnly
                    ? const Icon(Icons.audiotrack, size: 18)
                    : null,
                label: Text(
                  option.sizeBytes == null
                      ? option.label
                      : '${option.label} · ${formatBytes(option.sizeBytes!)}',
                ),
                selected: option.id == selected.id,
                onSelected: (_) => onSelect(option),
              ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            label: 'Download',
            icon: Icons.download_rounded,
            onPressed: onDownload,
          ),
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.url, this.badge, this.duration});

  final String? url;
  final String? badge;
  final String? duration;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url == null)
              ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: const Icon(Icons.movie_outlined, size: 48),
              )
            else
              CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: const Icon(Icons.movie_outlined, size: 48),
                ),
              ),
            if (badge != null)
              Positioned(left: 12, top: 12, child: _Pill(badge!)),
            if (duration != null && duration!.isNotEmpty)
              Positioned(right: 12, bottom: 12, child: _Pill(duration!)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
