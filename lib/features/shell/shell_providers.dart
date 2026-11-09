import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the selected bottom-navigation tab.
class ShellIndex extends Notifier<int> {
  static const home = 0;
  static const download = 1;
  static const library = 2;

  @override
  int build() => home;

  void select(int index) => state = index;
}

final shellIndexProvider = NotifierProvider<ShellIndex, int>(ShellIndex.new);
