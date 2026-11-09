import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/domain/stream_option.dart';
import 'package:youtube_downloader/domain/video_item.dart';

final streamOptionsProvider =
    FutureProvider.autoDispose.family<List<StreamOption>, String>(
  (ref, videoId) =>
      ref.watch(youtubeRepositoryProvider).getStreamOptions(videoId),
);

final videoByIdProvider = FutureProvider.autoDispose.family<VideoItem, String>(
  (ref, videoId) => ref.watch(youtubeRepositoryProvider).getVideo(videoId),
);
