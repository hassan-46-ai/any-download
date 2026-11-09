/// A YouTube video shown in the home feed and search results.
class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    required this.author,
    this.duration,
    this.viewCount,
    this.publishedLabel,
  });

  final String id;
  final String title;
  final String author;
  final Duration? duration;
  final int? viewCount;
  final String? publishedLabel;

  String get thumbnailUrl => 'https://img.youtube.com/vi/$id/hqdefault.jpg';
  String get watchUrl => 'https://www.youtube.com/watch?v=$id';
}
