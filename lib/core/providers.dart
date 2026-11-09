import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_downloader/data/downloads_store.dart';
import 'package:youtube_downloader/data/native_storage.dart';
import 'package:youtube_downloader/data/youtube_repository.dart';

/// Overridden in `main()` once the preferences have been loaded.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) {
  final repository = YoutubeRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final nativeStorageProvider = Provider<NativeStorage>(
  (ref) => const NativeStorage(),
);

final downloadsStoreProvider = Provider<DownloadsStore>(
  (ref) => DownloadsStore(ref.watch(sharedPreferencesProvider)),
);
