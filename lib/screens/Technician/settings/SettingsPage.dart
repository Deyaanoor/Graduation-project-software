import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/screens/Admin/Garage/theamDark_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/screens/Technician/settings/navigation_helper.dart';
import 'package:flutter_provider/screens/Technician/settings/settings_card.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/screens/Technician/settings/AccountSettingsPage.dart';
import 'package:flutter_provider/screens/Technician/settings/ContactInfoPage.dart';
import 'package:flutter_provider/screens/Technician/settings/LanguageSelectionPage.dart';

final selectedIndexProviderSitting = StateProvider<int>((ref) => 0);

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    if (ResponsiveHelper.isMobile(context)) {
      return _buildMobileLayout(lang, context, ref);
    } else {
      return _buildDesktopLayout(lang, ref, context);
    }
  }

  Widget _buildMobileLayout(lang, BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang['settings'] ?? ''),
        backgroundColor: Colors.orange.shade800,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SettingsCard(
                icon: Icons.person,
                title: lang['account'] ?? '',
                subtitle: lang['edit_account_info'] ?? '',
                color: Colors.orange.shade700,
                onTap: () =>
                    NavigationHelper.navigateTo(context, AccountSettingsPage()),
              ),
              _buildThemeToggle(context, ref),
              SettingsCard(
                icon: Icons.language,
                title: lang['change_language'] ?? '',
                subtitle:
                    '${lang['current_language'] ?? ''}: ${lang['language_name']}',
                color: Colors.green.shade600,
                onTap: () => _navigateToLanguagePage(context, ref),
              ),
              SettingsCard(
                icon: Icons.contact_support,
                title: lang['contact_info'] ?? '',
                subtitle: lang['support_contact'] ?? '',
                color: Colors.red.shade600,
                onTap: () =>
                    NavigationHelper.navigateTo(context, ContactInfoPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(lang, WidgetRef ref, BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProviderSitting);
    final currentLangCode =
        ref.read(languageProvider.notifier).currentLanguageCode;

    return Scaffold(
      body: Row(children: [
        // Side Navigation Bar
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 30),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(
                    Icons.settings_rounded,
                    size: 40,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildSidebarItem(
                      0,
                      Icons.person_rounded,
                      lang['account'] ?? 'Account',
                      selectedIndex,
                      ref,
                    ),
                    _buildSidebarItem(
                      2,
                      Icons.language_rounded,
                      lang['change_language'] ?? 'Language',
                      selectedIndex,
                      ref,
                    ),
                    _buildSidebarItem(
                      3,
                      Icons.contact_support_rounded,
                      lang['contact_info'] ?? 'Contact',
                      selectedIndex,
                      ref,
                    ),
                    _buildThemeToggle(context, ref),
                    const SizedBox(height: 10), // مسافة بين الزرين
                    _buildHomeButton(context, ref),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Main Content Area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
              ),
              child: IndexedStack(
                index: selectedIndex,
                children: [
                  AccountSettingsPage(),
                  _buildThemeToggle(context, ref),
                  LanguageSelectionPage(
                    currentLanguageCode: currentLangCode,
                    onLanguageSelected: (newLangCode) {
                      ref
                          .read(languageProvider.notifier)
                          .toggleLanguage(newLangCode);
                      _showSuccessSnackbar(
                        context,
                        ref,
                        ref.read(languageProvider)['language_name'] ?? '',
                      );
                    },
                  ),
                  ContactInfoPage(),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title,
      int selectedIndex, WidgetRef ref) {
    final isSelected = index == selectedIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  Colors.orange.shade100,
                  Colors.orange.shade50,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        borderRadius: BorderRadius.circular(15),
        border: isSelected
            ? Border.all(
                color: Colors.orange.shade300,
                width: 1.5,
              )
            : null,
      ),
      child: ListTile(
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange.shade800 : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.orange.shade800,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.orange.shade800 : Colors.grey.shade800,
            letterSpacing: 0.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onTap: () =>
            ref.read(selectedIndexProviderSitting.notifier).state = index,
      ),
    );
  }

  void _navigateToLanguagePage(BuildContext context, WidgetRef ref) {
    if (ResponsiveHelper.isMobile(context)) {
      final currentLangCode =
          ref.read(languageProvider.notifier).currentLanguageCode;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LanguageSelectionPage(
            currentLanguageCode: currentLangCode,
            onLanguageSelected: (newLangCode) {
              ref.read(languageProvider.notifier).toggleLanguage(newLangCode);
              _showSuccessSnackbar(
                context,
                ref,
                ref.read(languageProvider)['language_name'] ?? '',
              );
            },
          ),
        ),
      );
    }
  }

  void _showSuccessSnackbar(
      BuildContext context, WidgetRef ref, String language) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(
                '${ref.read(languageProvider)['language_changed'] ?? ''} $language'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final lang = ref.watch(languageProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blueGrey.shade800, Colors.blueGrey.shade700]
              : [Colors.grey.shade200, Colors.grey.shade100],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? Colors.blueGrey.shade600 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.orange.shade800 : Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
            color: isDark ? Colors.white : Colors.orange.shade800,
            size: 24,
          ),
        ),
        title: Text(
          lang['dark_mode'] ?? 'Dark Mode',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey.shade800,
            letterSpacing: 0.5,
          ),
        ),
        trailing: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? Colors.blueGrey.shade600 : Colors.grey.shade300,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutBack,
                left: isDark ? 22 : 4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                    size: 14,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        onTap: () => ref.read(themeModeProvider.notifier).state =
            isDark ? ThemeMode.light : ThemeMode.dark,
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final lang = ref.watch(languageProvider);
    bool _isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            transform: Matrix4.identity()
              ..translate(
                0.0,
                _isHovered ? -2.0 : 0.0,
              ),
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isHovered
                    ? [
                        isDark
                            ? Colors.blueGrey.shade700
                            : Colors.orange.shade100,
                        isDark
                            ? Colors.blueGrey.shade600
                            : Colors.orange.shade50,
                      ]
                    : [
                        isDark
                            ? Colors.blueGrey.shade800
                            : Colors.grey.shade200,
                        isDark
                            ? Colors.blueGrey.shade700
                            : Colors.grey.shade100,
                      ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _isHovered
                    ? (isDark ? Colors.orange.shade600 : Colors.orange.shade300)
                    : (isDark
                        ? Colors.blueGrey.shade600
                        : Colors.grey.shade300),
                width: _isHovered ? 2.0 : 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.orange.withOpacity(isDark ? 0.3 : 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => Navigator.pop(context),
                splashColor: Colors.orange.withOpacity(0.2),
                highlightColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 400),
                        turns: _isHovered ? -0.1 : 0.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isHovered
                                ? Colors.orange.shade800
                                : (isDark
                                    ? Colors.blueGrey.shade600
                                    : Colors.orange.shade100),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.home_rounded,
                            size: 24,
                            color: _isHovered
                                ? Colors.white
                                : (isDark
                                    ? Colors.orange.shade300
                                    : Colors.orange.shade800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isHovered
                              ? (isDark ? Colors.white : Colors.orange.shade800)
                              : (isDark ? Colors.white : Colors.grey.shade800),
                          shadows: _isHovered
                              ? [
                                  Shadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(lang['home'] ?? 'الرئيسية'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
