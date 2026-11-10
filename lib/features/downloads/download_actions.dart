import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/domain/media_info.dart';
import 'package:youtube_downloader/features/downloads/downloads_controller.dart';
import 'package:youtube_downloader/features/shell/shell_providers.dart';

/// Starts a download and shows a snackbar with a shortcut to the Library tab.
void startDownloadWithFeedback(
  BuildContext context,
  WidgetRef ref,
  MediaInfo media,
  QualityOption option,
) {
  ref.read(downloadsControllerProvider.notifier).start(media, option);

  // Read everything from `ref` before navigating: the calling widget may be
  // disposed as soon as a page is popped.
  final shell = ref.read(shellIndexProvider.notifier);
  final navigator = Navigator.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Download started'),
      action: SnackBarAction(
        label: 'View',
        onPressed: () {
          shell.select(ShellIndex.library);
          navigator.popUntil((route) => route.isFirst);
        },
      ),
    ),
  );
}
