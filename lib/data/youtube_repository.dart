import 'package:youtube_downloader/core/utils/formatters.dart';
import 'package:youtube_downloader/domain/stream_option.dart';
import 'package:youtube_downloader/domain/video_item.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

/// The only class that talks to `youtube_explode_dart`.
///
/// If YouTube changes and downloads stop working, this is the file to look at
/// (and `flutter pub upgrade youtube_explode_dart` is the first thing to try).
class YoutubeRepository {
  YoutubeRepository() : _yt = yt.YoutubeExplode();

  final yt.YoutubeExplode _yt;

  /// Returns the video id contained in [input] (a URL or an id), or null.
  static String? parseVideoId(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    return yt.VideoId.parseVideoId(trimmed);
  }

  Future<List<VideoItem>> search(String query) async {
    final results = await _yt.search.search(query);
    return results.map(_toVideoItem).toList();
  }

  Future<VideoItem> getVideo(String idOrUrl) async {
    final video = await _yt.videos.get(idOrUrl);
    return _toVideoItem(video);
  }

  Future<List<StreamOption>> getStreamOptions(String videoId) async {
    final manifest = await _yt.videos.streams.getManifest(videoId);

    final muxed = manifest.muxed.toList()
      ..sort(
        (a, b) => b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond),
      );
    final videoOptions = muxed.map((s) {
      final container = s.container.name;
      return StreamOption(
        info: s,
        kind: StreamKind.video,
        label: '${s.videoQualityLabel} · ${container.toUpperCase()}',
        sizeBytes: s.size.totalBytes,
        extension: container,
        mimeType: 'video/$container',
      );
    });

    // Keep only the best audio stream of each container.
    final audio = manifest.audioOnly.toList()
      ..sort(
        (a, b) => b.bitrate.bitsPerSecond.compareTo(a.bitrate.bitsPerSecond),
      );
    final seenContainers = <String>{};
    final audioOptions = <StreamOption>[];
    for (final s in audio) {
      final container = s.container.name;
      if (!seenContainers.add(container)) continue;
      final isMp4 = container == 'mp4';
      audioOptions.add(
        StreamOption(
          info: s,
          kind: StreamKind.audio,
          label: 'Audio · ${isMp4 ? 'M4A' : container.toUpperCase()} · '
              '${s.bitrate.kiloBitsPerSecond.round()} kbps',
          sizeBytes: s.size.totalBytes,
          extension: isMp4 ? 'm4a' : container,
          mimeType: isMp4 ? 'audio/mp4' : 'audio/$container',
        ),
      );
    }

    return [...videoOptions, ...audioOptions];
  }

  Stream<List<int>> openStream(StreamOption option) =>
      _yt.videos.streams.get(option.info);

  void dispose() => _yt.close();

  VideoItem _toVideoItem(yt.Video video) {
    final uploaded = video.uploadDate;
    return VideoItem(
      id: video.id.value,
      title: video.title,
      author: video.author,
      duration: video.duration,
      viewCount: video.engagement.viewCount,
      publishedLabel:
          video.uploadDateRaw ?? (uploaded == null ? null : timeAgo(uploaded)),
    );
  }
}
