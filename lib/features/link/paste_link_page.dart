import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/utils/error_messages.dart';
import 'package:youtube_downloader/core/widgets/error_view.dart';
import 'package:youtube_downloader/core/widgets/video_card.dart';
import 'package:youtube_downloader/data/youtube_repository.dart';
import 'package:youtube_downloader/features/video/video_details_page.dart';
import 'package:youtube_downloader/features/video/video_providers.dart';

/// Paste a YouTube link, preview the video, then choose what to download.
class PasteLinkPage extends ConsumerStatefulWidget {
  const PasteLinkPage({super.key});

  @override
  ConsumerState<PasteLinkPage> createState() => _PasteLinkPageState();
}

class _PasteLinkPageState extends ConsumerState<PasteLinkPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || !mounted) return;
    _controller.text = text.trim();
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text.trim();
    final videoId = YoutubeRepository.parseVideoId(text);
    final isInvalid = text.isNotEmpty && videoId == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Paste link')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'YouTube link',
              prefixIcon: const Icon(Icons.link),
              errorText: isInvalid ? 'This is not a valid YouTube link' : null,
              suffixIcon: text.isEmpty
                  ? IconButton(
                      tooltip: 'Paste',
                      icon: const Icon(Icons.content_paste),
                      onPressed: _paste,
                    )
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: _clear,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          if (videoId != null) _Preview(videoId: videoId),
        ],
      ),
    );
  }
}

class _Preview extends ConsumerWidget {
  const _Preview({required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = ref.watch(videoByIdProvider(videoId));
    return video.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: 200,
        child: ErrorView(
          message: describeError(error),
          onRetry: () => ref.invalidate(videoByIdProvider(videoId)),
        ),
      ),
      data: (item) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: VideoCard(
          video: item,
          onTap: () => openVideoDetails(context, item),
        ),
      ),
    );
  }
}
