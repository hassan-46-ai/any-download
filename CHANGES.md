# Media Saver 2.0

## Engine
Downloads now run on yt-dlp (youtubedl-android 0.18.1) bundled in the app.
Supports YouTube, YouTube Shorts, Facebook, Instagram, TikTok, X (Twitter) and ~1000 other sites,
with merged HD video (ffmpeg) and audio-only (M4A).
The old YouTube-only engine is only used for the home feed / search.

## Design
New violet/pink Material 3 design, 3 tabs (Home, Download, Library), rounded cards,
gradient buttons, animated splash.

## Files to copy over your project
lib/                      (delete your old lib/ first)
pubspec.yaml, analysis_options.yaml
android/app/build.gradle.kts
android/app/src/main/AndroidManifest.xml
android/app/src/main/kotlin/com/example/youtube_downloader/MainActivity.kt
android/app/src/main/kotlin/com/example/youtube_downloader/YtDlpBridge.kt
android/settings.gradle.kts
android/gradle/wrapper/gradle-wrapper.properties

Then:
  flutter clean
  flutter pub get
  dart run flutter_native_splash:create
  flutter run          (first launch unpacks python: takes a few seconds)
Release: flutter build apk --split-per-abi   (the engine makes a full APK ~100 MB+)

## Notes
- When a site stops working: Download tab > update icon (downloads the newest yt-dlp).
- Private / login-only videos (many Instagram & Facebook posts) can't be downloaded.
- youtubedl-android is GPL-3.0: distributing the app means releasing its source under GPL.
