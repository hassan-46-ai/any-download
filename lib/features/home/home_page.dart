import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/theme/app_theme.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/widgets/error_view.dart';
import 'package:youtube_downloader/core/widgets/video_card.dart';
import 'package:youtube_downloader/features/download/media_details_page.dart';
import 'package:youtube_downloader/features/home/home_providers.dart';
import 'package:youtube_downloader/features/home/widgets/category_bar.dart';
import 'package:youtube_downloader/features/search/search_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

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
            const SliverToBoxAdapter(child: _Header()),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, topPadding + 20, 20, 4),
          child: ShaderMask(
            shaderCallback: (bounds) => AppColors.gradient.createShader(bounds),
            child: Text(
              'Save anything',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'YouTube, Facebook, Instagram, TikTok, X and more',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Material(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SearchPage()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      'Search videos',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const CategoryBar(),
        const SizedBox(height: 16),
      ],
    );
  }
}
