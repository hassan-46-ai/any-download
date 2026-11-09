import 'package:youtube_downloader/domain/video_item.dart';

enum DownloadStatus { queued, downloading, saving, completed, failed, canceled }

class DownloadTask {
  const DownloadTask({
    required this.id,
    required this.video,
    required this.optionLabel,
    required this.fileName,
    required this.mimeType,
    required this.createdAt,
    this.status = DownloadStatus.queued,
    this.progress = 0,
    this.error,
    this.savedUri,
  });

  final String id;
  final VideoItem video;
  final String optionLabel;
  final String fileName;
  final String mimeType;
  final DateTime createdAt;
  final DownloadStatus status;
  final double progress;
  final String? error;
  final String? savedUri;

  bool get isActive =>
      status == DownloadStatus.queued ||
      status == DownloadStatus.downloading ||
      status == DownloadStatus.saving;

  bool get isAudio => mimeType.startsWith('audio');

  DownloadTask copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
    String? savedUri,
  }) {
    return DownloadTask(
      id: id,
      video: video,
      optionLabel: optionLabel,
      fileName: fileName,
      mimeType: mimeType,
      createdAt: createdAt,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      savedUri: savedUri ?? this.savedUri,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'video': video.toJson(),
        'optionLabel': optionLabel,
        'fileName': fileName,
        'mimeType': mimeType,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'progress': progress,
        'error': error,
        'savedUri': savedUri,
      };

  factory DownloadTask.fromJson(Map<String, dynamic> json) {
    return DownloadTask(
      id: json['id'] as String,
      video: VideoItem.fromJson(json['video'] as Map<String, dynamic>),
      optionLabel: json['optionLabel'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: DownloadStatus.values.byName(json['status'] as String),
      progress: (json['progress'] as num).toDouble(),
      error: json['error'] as String?,
      savedUri: json['savedUri'] as String?,
    );
  }
}
