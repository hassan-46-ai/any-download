/// A video as shown in lists. Independent from any networking package.
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'durationSeconds': duration?.inSeconds,
        'viewCount': viewCount,
        'publishedLabel': publishedLabel,
      };

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    final seconds = json['durationSeconds'] as int?;
    return VideoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      duration: seconds == null ? null : Duration(seconds: seconds),
      viewCount: json['viewCount'] as int?,
      publishedLabel: json['publishedLabel'] as String?,
    );
  }
}
