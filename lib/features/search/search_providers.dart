import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/domain/video_item.dart';

final searchResultsProvider =
    FutureProvider.autoDispose.family<List<VideoItem>, String>(
  (ref, query) => ref.watch(youtubeRepositoryProvider).search(query),
);
