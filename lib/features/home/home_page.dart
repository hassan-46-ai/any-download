import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/widgets/error_view.dart';
import 'package:youtube_downloader/core/widgets/video_card.dart';
import 'package:youtube_downloader/features/home/home_providers.dart';
import 'package:youtube_downloader/features/home/widgets/category_bar.dart';
import 'package:youtube_downloader/features/video/video_details_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(selectedCategoryProvider);
    final feed = ref.watch(feedProvider(category));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(feedProvider(category));
          try {
            await ref.read(feedProvider(category).future);
          } catch (_) {
            // The error is displayed by the feed itself.
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Row(
                children: [
                  Icon(
                    Icons.download_for_offline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text('YouTube Downloader'),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search),
                  onPressed: onSearchTap,
                ),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(CategoryBar.height),
                child: CategoryBar(),
              ),
            ),
            ...feed.when(
              data: (videos) => [
                if (videos.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No videos found.')),
                  )
                else
                  SliverList.builder(
                    itemCount: videos.length,
                    itemBuilder: (_, i) => VideoCard(
                      video: videos[i],
                      onTap: () => openVideoDetails(context, videos[i]),
                    ),
                  ),
              ],
              loading: () => const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    message: describeError(error),
                    onRetry: () => ref.invalidate(feedProvider(category)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
