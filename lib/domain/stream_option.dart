import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum StreamKind { video, audio }

/// One downloadable variant of a video (a quality / format choice).
class StreamOption {
  const StreamOption({
    required this.info,
    required this.kind,
    required this.label,
    required this.sizeBytes,
    required this.extension,
    required this.mimeType,
  });

  final StreamInfo info;
  final StreamKind kind;
  final String label;
  final int sizeBytes;
  final String extension;
  final String mimeType;
}
