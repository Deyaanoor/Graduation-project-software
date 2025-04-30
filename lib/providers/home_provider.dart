import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedIndexProvider = StateProvider<int>((ref) {
  return 0;
});
final isEditModeProvider = StateProvider<bool>((ref) => false);

final isSidebarExpandedProvider = StateProvider<bool>((ref) => true);
