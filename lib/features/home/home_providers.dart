import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/domain/feed_category.dart';
import 'package:youtube_downloader/domain/video_item.dart';

class SelectedCategory extends Notifier<FeedCategory> {
  @override
  FeedCategory build() => FeedCategory.trending;

  void select(FeedCategory category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategory, FeedCategory>(SelectedCategory.new);

/// Suggested videos for a category. Cached per category while the app runs.
final feedProvider = FutureProvider.family<List<VideoItem>, FeedCategory>(
  (ref, category) =>
      ref.watch(youtubeRepositoryProvider).search(category.query),
);
