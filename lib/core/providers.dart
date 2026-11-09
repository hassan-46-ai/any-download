import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_downloader/data/downloads_store.dart';
import 'package:youtube_downloader/data/native_storage.dart';
import 'package:youtube_downloader/data/youtube_repository.dart';
import 'package:youtube_downloader/data/ytdlp_service.dart';

/// Overridden in `main()` once the preferences have been loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

/// Used only for the home feed and search (suggested videos).
final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) {
  final repository = YoutubeRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

/// The download engine (yt-dlp): reads link details and downloads files.
final ytDlpServiceProvider = Provider<YtDlpService>((ref) {
  final service = YtDlpService();
  ref.onDispose(service.dispose);
  return service;
});

final nativeStorageProvider = Provider<NativeStorage>(
  (ref) => const NativeStorage(),
);

final downloadsStoreProvider = Provider<DownloadsStore>(
  (ref) => DownloadsStore(ref.watch(sharedPreferencesProvider)),
);
