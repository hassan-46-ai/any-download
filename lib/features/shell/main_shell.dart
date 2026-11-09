import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/features/downloads/downloads_controller.dart';
import 'package:youtube_downloader/features/downloads/downloads_page.dart';
import 'package:youtube_downloader/features/home/home_page.dart';
import 'package:youtube_downloader/features/link/paste_link_page.dart';
import 'package:youtube_downloader/features/search/search_page.dart';
import 'package:youtube_downloader/features/shell/shell_providers.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(shellIndexProvider);
    final activeDownloads = ref.watch(
      downloadsControllerProvider.select(
        (tasks) => tasks.where((t) => t.isActive).length,
      ),
    );
    final shell = ref.read(shellIndexProvider.notifier);

    return PopScope(
      canPop: index == ShellIndex.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) shell.select(ShellIndex.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: index,
          children: [
            HomePage(onSearchTap: () => shell.select(ShellIndex.search)),
            const SearchPage(),
            const PasteLinkPage(),
            const DownloadsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: shell.select,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            const NavigationDestination(
              icon: Icon(Icons.link),
              label: 'Paste link',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: activeDownloads > 0,
                label: Text('$activeDownloads'),
                child: const Icon(Icons.download_outlined),
              ),
              selectedIcon: const Icon(Icons.download),
              label: 'Downloads',
            ),
          ],
        ),
      ),
    );
  }
}
