import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/language_provider.dart';

class LanguageSelectionPage extends ConsumerStatefulWidget {
  final String currentLanguageCode;
  final Function(String) onLanguageSelected;

  const LanguageSelectionPage({
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  @override
  ConsumerState<LanguageSelectionPage> createState() =>
      _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends ConsumerState<LanguageSelectionPage> {
  late String _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = widget.currentLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isArabic =
        ref.read(languageProvider.notifier).currentLanguageCode == 'ar';

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? null
          : _buildMobileAppBar(context, lang, isArabic),
      body: ResponsiveHelper.isDesktop(context)
          ? _buildDesktopContent(context, lang, isArabic)
          : _buildMobileContent(context, lang, isArabic),
      bottomNavigationBar: ResponsiveHelper.isDesktop(context)
          ? null
          : _buildMobileBottomBar(context, lang, isArabic),
    );
  }

  PreferredSizeWidget _buildMobileAppBar(
      BuildContext context, Map<String, String> lang, bool isArabic) {
    return AppBar(
      title: Text(
        lang['choose_language'] ??
            (isArabic ? 'اختر اللغة' : 'Choose Language'),
        style: const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.orange.shade800, Colors.orange.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildMobileContent(
      BuildContext context, Map<String, String> lang, bool isArabic) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildLanguageTile(
          context,
          languageCode: 'ar',
          title: 'العربية',
          subtitle: lang['arabic_language'] ?? 'اللغة العربية',
          isMobile: true,
        ),
        const SizedBox(height: 15),
        _buildLanguageTile(
          context,
          languageCode: 'en',
          title: 'English',
          subtitle: lang['english_language'] ?? 'English Language',
          isMobile: true,
        ),
      ],
    );
  }

  Widget _buildDesktopContent(
      BuildContext context, Map<String, String> lang, bool isArabic) {
    return Column(
      children: [
        _buildDesktopHeader(context, lang, isArabic),
        Expanded(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLanguageTile(
                    context,
                    languageCode: 'ar',
                    title: 'العربية',
                    subtitle: lang['arabic_language'] ?? 'اللغة العربية',
                    isMobile: false,
                  ),
                  _buildLanguageTile(
                    context,
                    languageCode: 'en',
                    title: 'English',
                    subtitle: lang['english_language'] ?? 'English Language',
                    isMobile: false,
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildDesktopBottomBar(context, lang, isArabic),
      ],
    );
  }

  Widget _buildLanguageTile(BuildContext context,
      {required String languageCode,
      required String title,
      required String subtitle,
      required bool isMobile}) {
    final isSelected = _selectedLanguageCode == languageCode;
    final isArabic = languageCode == 'ar';

    return SizedBox(
      width: isMobile ? null : 450,
      child: Card(
        elevation: 6,
        margin: isMobile
            ? const EdgeInsets.symmetric(vertical: 8)
            : const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected ? Colors.teal.shade600 : Colors.grey.shade200,
              width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _selectedLanguageCode = languageCode),
          child: Padding(
            padding: isMobile
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
            child: Row(
              children: [
                Text(isArabic ? '🇵🇸' : '🇺🇸',
                    style: TextStyle(fontSize: isMobile ? 36 : 42)),
                SizedBox(width: isMobile ? 20 : 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title,
                              style: TextStyle(
                                  fontSize: isMobile ? 18 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800)),
                          if (isSelected) ...[
                            const Spacer(),
                            Icon(Icons.check_circle_rounded,
                                color: Colors.teal.shade600,
                                size: isMobile ? 24 : 32),
                          ],
                        ],
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: isMobile ? 14 : 18,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(
      BuildContext context, Map<String, String> lang, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Text(
            lang['choose_language'] ??
                (isArabic ? 'اختر اللغة' : 'Choose Language'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            indent: 100,
            endIndent: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBottomBar(
      BuildContext context, Map<String, String> lang, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close, size: 20),
              label: Text(lang['cancel'] ?? (isArabic ? 'إلغاء' : 'Cancel')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade800,
                side: BorderSide(color: Colors.red.shade100),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 20),
              label: Text(lang['save_changes'] ??
                  (isArabic ? 'حفظ التغييرات' : 'Save Changes')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 2,
              ),
              onPressed: () {
                widget.onLanguageSelected(_selectedLanguageCode);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBottomBar(
      BuildContext context, Map<String, String> lang, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDesktopButton(
            context,
            icon: Icons.close,
            label: lang['cancel'] ?? (isArabic ? 'إلغاء' : 'Cancel'),
            color: Colors.red.shade600,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 40),
          _buildDesktopButton(
            context,
            icon: Icons.check,
            label: lang['save_changes'] ??
                (isArabic ? 'حفظ التغييرات' : 'Save Changes'),
            color: Colors.teal.shade600,
            onPressed: () {
              widget.onLanguageSelected(_selectedLanguageCode);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          shadowColor: color.withOpacity(0.3),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
