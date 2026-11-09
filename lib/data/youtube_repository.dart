import 'package:youtube_downloader/core/utils/formatters.dart';
import 'package:youtube_downloader/domain/video_item.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

/// Searches YouTube for the home feed. Downloading is done by [YtDlpService].
class YoutubeRepository {
  YoutubeRepository() : _yt = yt.YoutubeExplode();

  final yt.YoutubeExplode _yt;

  Future<List<VideoItem>> search(String query) async {
    final results = await _yt.search.search(query);
    return results.map(_toVideoItem).toList();
  }

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
