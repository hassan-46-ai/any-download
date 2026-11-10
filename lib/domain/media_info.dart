/// One quality / format the user can pick for a link.
class QualityOption {
  const QualityOption({
    required this.label,
    required this.formatSelector,
    this.audioOnly = false,
    this.height,
    this.sizeBytes,
  });

  final String label;

  /// A yt-dlp format selector, e.g. `bv*[height<=720]+ba/b[height<=720]`.
  final String formatSelector;
  final bool audioOnly;
  final int? height;
  final int? sizeBytes;

  String get id => audioOnly ? 'audio' : '${height ?? 'best'}';
}

/// Details of a link, read by yt-dlp before downloading.
class MediaInfo {
  const MediaInfo({
    required this.url,
    required this.title,
    required this.author,
    required this.platform,
    required this.options,
    this.thumbnailUrl,
    this.duration,
  });

  final String url;
  final String title;
  final String author;
  final String platform;
  final String? thumbnailUrl;
  final Duration? duration;
  final List<QualityOption> options;
}
