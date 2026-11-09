import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_downloader/domain/download_task.dart';

/// Persists the download history between app launches.
class DownloadsStore {
  DownloadsStore(this._prefs);

  static const _key = 'downloads_history';

  final SharedPreferences _prefs;

  List<DownloadTask> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map(DownloadTask.fromJson).map((task) {
        // A task that was running when the app was closed can't be resumed.
        return task.isActive
            ? task.copyWith(
                status: DownloadStatus.failed,
                error: 'Interrupted',
              )
            : task;
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<DownloadTask> tasks) {
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    return _prefs.setString(_key, encoded);
  }
}
