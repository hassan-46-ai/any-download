import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/widgets/error_view.dart';
import 'package:youtube_downloader/core/widgets/video_card.dart';
import 'package:youtube_downloader/features/search/search_providers.dart';
import 'package:youtube_downloader/features/video/video_details_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search YouTube',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (value) => setState(() => _query = value.trim()),
        ),
      ),
      body: _query.isEmpty
          ? const Center(child: Text('Search for a video to download.'))
          : _Results(query: _query),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider(query));
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorView(
        message: describeError(error),
        onRetry: () => ref.invalidate(searchResultsProvider(query)),
      ),
      data: (videos) => videos.isEmpty
          ? const Center(child: Text('No results.'))
          : ListView.builder(
              itemCount: videos.length,
              itemBuilder: (_, i) => VideoCard(
                video: videos[i],
                onTap: () => openVideoDetails(context, videos[i]),
              ),
            ),
    );
  }
}
