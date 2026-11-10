import 'package:flutter/material.dart';
import 'package:youtube_downloader/domain/video_item.dart';
import 'package:youtube_downloader/features/download/widgets/media_panel.dart';

void openVideoDetails(BuildContext context, VideoItem video) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => MediaDetailsPage(video: video)),
  );
}

/// Opened from the home feed / search: pick a quality and download.
class MediaDetailsPage extends StatelessWidget {
  const MediaDetailsPage({super.key, required this.video});

  final VideoItem video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [MediaPanel(url: video.watchUrl, placeholder: video)],
      ),
    );
  }
}
