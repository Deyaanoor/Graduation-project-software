import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedIndexProvider = StateProvider<int>((ref) {
  return 0;
});
final isSidebarExpandedProvider = StateProvider<bool>((ref) => true);
