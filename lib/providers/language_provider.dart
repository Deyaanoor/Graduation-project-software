import 'dart:ui';
import 'package:flutter_provider/lang/ar.dart';
import 'package:flutter_provider/lang/en.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final languageProvider =
    StateNotifierProvider<LanguageNotifier, Map<String, String>>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Map<String, String>> {
  LanguageNotifier() : super(english) {
    loadSavedLanguage();
  }

  static const String _languageKey = 'app_language';

  Future<void> toggleLanguage(String langCode) async {
    state = langCode == 'ar' ? arabic : english;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, langCode);
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey) ?? 'en';
    state = savedLang == 'ar' ? arabic : english;
  }

  String get currentLanguageCode => state == arabic ? 'ar' : 'en';
  TextDirection get textDirection =>
      state == arabic ? TextDirection.rtl : TextDirection.ltr;
}
