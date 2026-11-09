import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_downloader/domain/feed_category.dart';
import 'package:youtube_downloader/features/home/home_providers.dart';

class CategoryBar extends ConsumerWidget {
  const CategoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    const categories = FeedCategory.values;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final category = categories[i];
          return ChoiceChip(
            avatar: Icon(category.icon, size: 18),
            label: Text(category.label),
            selected: category == selected,
            onSelected: (_) =>
                ref.read(selectedCategoryProvider.notifier).select(category),
          );
        },
      ),
    );
  }
}
