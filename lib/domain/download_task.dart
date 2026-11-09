enum DownloadStatus { queued, downloading, saving, completed, failed, canceled }

class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.url,
    required this.title,
    required this.author,
    required this.platform,
    required this.optionLabel,
    required this.formatSelector,
    required this.audioOnly,
    required this.createdAt,
    this.thumbnailUrl,
    this.status = DownloadStatus.queued,
    this.progress = 0,
    this.etaSeconds,
    this.error,
    this.savedUri,
    this.mimeType,
  });

  final String id;
  final String url;
  final String title;
  final String author;
  final String platform;
  final String optionLabel;
  final String formatSelector;
  final bool audioOnly;
  final DateTime createdAt;
  final String? thumbnailUrl;
  final DownloadStatus status;
  final double progress;
  final int? etaSeconds;
  final String? error;
  final String? savedUri;
  final String? mimeType;

  bool get isActive =>
      status == DownloadStatus.queued ||
      status == DownloadStatus.downloading ||
      status == DownloadStatus.saving;

  DownloadTask copyWith({
    DownloadStatus? status,
    double? progress,
    int? etaSeconds,
    String? error,
    String? savedUri,
    String? mimeType,
  }) {
    return DownloadTask(
      id: id,
      url: url,
      title: title,
      author: author,
      platform: platform,
      optionLabel: optionLabel,
      formatSelector: formatSelector,
      audioOnly: audioOnly,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      error: error ?? this.error,
      savedUri: savedUri ?? this.savedUri,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  /// The same task, reset so it can be run again.
  DownloadTask restarted() {
    return DownloadTask(
      id: id,
      url: url,
      title: title,
      author: author,
      platform: platform,
      optionLabel: optionLabel,
      formatSelector: formatSelector,
      audioOnly: audioOnly,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'author': author,
        'platform': platform,
        'optionLabel': optionLabel,
        'formatSelector': formatSelector,
        'audioOnly': audioOnly,
        'createdAt': createdAt.toIso8601String(),
        'thumbnailUrl': thumbnailUrl,
        'status': status.name,
        'progress': progress,
        'error': error,
        'savedUri': savedUri,
        'mimeType': mimeType,
      };

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] as String,
      url: json['url'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      platform: json['platform'] as String,
      optionLabel: json['optionLabel'] as String,
      formatSelector: json['formatSelector'] as String,
      audioOnly: json['audioOnly'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      status: DownloadStatus.values.byName(json['status'] as String),
      progress: (json['progress'] as num).toDouble(),
      error: json['error'] as String?,
      savedUri: json['savedUri'] as String?,
      mimeType: json['mimeType'] as String?,
    );
  }
}
