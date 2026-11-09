import 'package:flutter/services.dart';

/// Bridge to the Android `MediaStore` (see MainActivity.kt).
///
/// Saving through MediaStore needs no storage permission on Android 10+,
/// which is what makes downloads work on current Android versions.
class NativeStorage {
  const NativeStorage();

  static const _channel = MethodChannel(
    'com.example.youtube_downloader/storage',
  );

  /// Copies [sourcePath] into Downloads/YouTube Downloader and returns the
  /// content URI of the saved file.
  Future<String> saveToDownloads({
    required String sourcePath,
    required String fileName,
    required String mimeType,
  }) async {
    final uri = await _channel.invokeMethod<String>('saveToDownloads', {
      'sourcePath': sourcePath,
      'fileName': fileName,
      'mimeType': mimeType,
    });
    if (uri == null) throw PlatformException(code: 'save_failed');
    return uri;
  }

  /// Opens a saved file with the user's default app. False if it can't be opened.
  Future<bool> open({required String uri, required String mimeType}) async {
    final opened = await _channel.invokeMethod<bool>('openUri', {
      'uri': uri,
      'mimeType': mimeType,
    });
    return opened ?? false;
  }
}
