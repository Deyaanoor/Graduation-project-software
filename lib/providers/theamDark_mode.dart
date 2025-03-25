import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});
