import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the selected bottom-navigation tab.
class ShellIndex extends Notifier<int> {
  static const home = 0;
  static const search = 1;
  static const link = 2;
  static const downloads = 3;

  @override
  int build() => home;

  void select(int index) => state = index;
}

final shellIndexProvider = NotifierProvider<ShellIndex, int>(ShellIndex.new);
