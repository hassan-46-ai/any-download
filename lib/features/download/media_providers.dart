import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/core/providers.dart';
import 'package:youtube_downloader/domain/media_info.dart';

/// Reads a link with yt-dlp (title, thumbnail, available qualities).
final mediaInfoProvider = FutureProvider.autoDispose.family<MediaInfo, String>(
  (ref, url) => ref.watch(ytDlpServiceProvider).fetchInfo(url),
);
