import 'package:youtube_downloader/domain/media_info.dart';

/// Converts the JSON printed by `yt-dlp --dump-single-json` into [MediaInfo].
MediaInfo parseMediaInfo(Map<String, dynamic> json, String url) {
  // Some sites (e.g. X posts with several videos) answer with a playlist.
  final entries = json['entries'];
  final data = json['_type'] == 'playlist' && entries is List && entries.isNotEmpty
      ? Map<String, dynamic>.from(entries.first as Map)
      : json;

  final platform = _platformName(data['extractor_key'] as String?, url);
  final formats = (data['formats'] as List? ?? const [])
      .whereType<Map>()
      .map((f) => Map<String, dynamic>.from(f))
      .toList();

  return MediaInfo(
    url: url,
    title: (data['title'] as String?)?.trim().isNotEmpty == true
        ? (data['title'] as String).trim()
        : 'video',
    author: (data['uploader'] ?? data['channel'] ?? platform) as String,
    platform: platform,
    thumbnailUrl: data['thumbnail'] as String?,
    duration: (data['duration'] as num?) == null
        ? null
        : Duration(seconds: (data['duration'] as num).round()),
    options: _buildOptions(formats),
  );
}

List<QualityOption> _buildOptions(List<Map<String, dynamic>> formats) {
  final videoFormats = formats.where(_hasVideo).toList();
  final audioFormats =
      formats.where((f) => _hasAudio(f) && !_hasVideo(f)).toList();

  final audioSize = _maxSize(audioFormats);
  final heights = videoFormats
      .map((f) => (f['height'] as num?)?.toInt())
      .whereType<int>()
      .where((h) => h >= 144)
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  return [
    QualityOption(
      label: heights.isEmpty ? 'Best quality' : 'Best (${heights.first}p)',
      formatSelector: 'bv*+ba/b',
      height: null,
    ),
    for (final height in heights.take(7))
      QualityOption(
        label: '${height}p',
        formatSelector: 'bv*[height<=$height][ext=mp4]+ba[ext=m4a]/'
            'bv*[height<=$height]+ba/b[height<=$height]',
        height: height,
        sizeBytes: _estimate(videoFormats, height, audioSize),
      ),
    QualityOption(
      label: 'Audio only',
      formatSelector: 'ba[ext=m4a]/ba/b',
      audioOnly: true,
      sizeBytes: audioSize == 0 ? null : audioSize,
    ),
  ];
}

bool _hasVideo(Map<String, dynamic> f) {
  final codec = f['vcodec'];
  return codec != null && codec != 'none';
}

bool _hasAudio(Map<String, dynamic> f) {
  final codec = f['acodec'];
  return codec != null && codec != 'none';
}

int _size(Map<String, dynamic> f) =>
    ((f['filesize'] ?? f['filesize_approx']) as num?)?.toInt() ?? 0;

int _maxSize(List<Map<String, dynamic>> formats) =>
    formats.fold(0, (max, f) => _size(f) > max ? _size(f) : max);

int? _estimate(List<Map<String, dynamic>> video, int height, int audioSize) {
  final atHeight = video.where((f) => (f['height'] as num?)?.toInt() == height);
  final videoSize = _maxSize(atHeight.toList());
  return videoSize == 0 ? null : videoSize + audioSize;
}

String _platformName(String? extractorKey, String url) {
  if (extractorKey == null) return 'Web';
  switch (extractorKey.toLowerCase()) {
    case 'youtube':
      return url.contains('/shorts/') ? 'YouTube Shorts' : 'YouTube';
    case 'twitter':
      return 'X (Twitter)';
    case 'tiktok':
      return 'TikTok';
    case 'facebook':
      return 'Facebook';
    case 'instagram':
      return 'Instagram';
    case 'generic':
      return 'Web';
    default:
      return extractorKey;
  }
}
