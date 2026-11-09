# What changed

## Fixed
- Downloads now work: files are saved through Android MediaStore into
  Downloads/YouTube Downloader (no storage permission, works on Android 10 - 16).
- INTERNET permission added to the main manifest (release builds had no network).
- Removed the MANAGE_EXTERNAL_STORAGE / READ / WRITE storage permissions.
- Removed the old youtube_player_flutter player screen (it only played videos).
- Removed hard-coded sample data; the home feed is now live.

## New
- Home feed with category chips (Trending, Music, Gaming, News, Sports, Learning, Movies) + pull to refresh
- Search page
- Paste-link page with clipboard button, link validation and preview
- Video page with a quality / format picker (video + sound, audio only M4A/WebM)
- Downloads page: live progress, cancel, tap to open, retry, history that survives restarts
- Badge on the Downloads tab showing how many downloads are running
- Light / dark theme following the system, Material 3, predictive back

## Structure
lib/
  core/      theme, formatters, shared widgets, providers
  data/      YoutubeRepository, NativeStorage (MediaStore), DownloadsStore
  domain/    plain models (VideoItem, StreamOption, DownloadTask, FeedCategory)
  features/  home, search, link, video, downloads, shell

## Where the files go
Copy lib/ and pubspec.yaml + analysis_options.yaml over your project, then:
  android/app/src/main/AndroidManifest.xml
  android/app/build.gradle.kts
  android/settings.gradle.kts
  android/gradle/wrapper/gradle-wrapper.properties
  android/app/src/main/kotlin/com/example/youtube_downloader/MainActivity.kt
(delete any old MainActivity.kt / MainActivity.java so there is only one)
Then delete the old files in lib/ (data.dart, main_page.dart, home_page.dart,
download_screen.dart, video_screen.dart, widgits/).
