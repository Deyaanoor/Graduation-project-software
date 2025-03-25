import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/theamDark_mode.dart';
import 'package:flutter_provider/providers/language_provider.dart';

class DarkModeCard extends ConsumerWidget {
  const DarkModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lang = ref.watch(languageProvider);
    final isArabic =
        ref.watch(languageProvider.notifier).currentLanguageCode == 'ar';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade800,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(Icons.dark_mode, size: 30, color: Colors.white),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang['dark_mode'] ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    lang['change_app_theme'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                right: isArabic ? 0 : 16, left: isArabic ? 16 : 0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Switch(
                key: ValueKey<bool>(themeMode == ThemeMode.dark),
                activeColor: Colors.orange.shade700,
                value: themeMode == ThemeMode.dark,
                onChanged: (value) => ref
                    .read(themeModeProvider.notifier)
                    .state = value ? ThemeMode.dark : ThemeMode.light,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
