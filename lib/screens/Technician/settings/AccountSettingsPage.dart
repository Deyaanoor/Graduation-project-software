import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/widgets/avatar_section.dart';
import 'package:flutter_provider/widgets/edit_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      final extractedUserId = extractUserIdFromToken(token);
      setState(() {
        userId = extractedUserId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userInfoAsync = ref.watch(getUserInfoProvider(userId!));

    return userInfoAsync.when(
      data: (userData) {
        return Scaffold(
          body: ResponsiveHelper.isMobile(context)
              ? _buildMobileLayout(context, userData, lang)
              : _buildDesktopLayout(context, userData, lang),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        body: Center(child: Text('❌ خطأ: $err')),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Map<String, dynamic> userData,
    Map<String, String> lang,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          AvatarSection(
            userData: userData,
            userId: userId!,
          ),
          SizedBox(height: 30),
          _buildProfileCard(context,
              isMobile: true, userData: userData, lang: lang),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Map<String, dynamic> userData,
    Map<String, String> lang,
  ) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                    padding: EdgeInsets.only(right: 40),
                    child: AvatarSection(
                      userData: userData,
                      desktopMode: true,
                      userId: userId!,
                    )),
              ),
              Expanded(
                flex: 2,
                child: _buildProfileCard(context,
                    isMobile: false, userData: userData, lang: lang),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required bool isMobile,
    required Map<String, dynamic> userData,
    required Map<String, String> lang,
  }) {
    return Card(
      elevation: isMobile ? 4 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 30),
        child: Column(
          children: [
            _buildEditableField(
              context,
              label: lang['fullName'] ?? 'Full Name',
              key: 'name',
              value: userData['name'] ?? 'غير معروف',
              icon: Icons.person_outline_rounded,
              isMobile: isMobile,
            ),
            Divider(height: isMobile ? 30 : 40, color: Colors.grey.shade200),
            _buildEditableField(
              context,
              label: lang['email'] ?? 'Email',
              key: 'email',
              value: userData['email'] ?? 'غير معروف',
              icon: Icons.email_outlined,
              isMobile: isMobile,
            ),
            Divider(height: isMobile ? 30 : 40, color: Colors.grey.shade200),
            _buildEditableField(
              context,
              label: lang['phone'] ?? 'Phone Number',
              key: 'phoneNumber',
              value: userData['phoneNumber'] ?? 'غير متوفر',
              icon: Icons.phone_android_outlined,
              isMobile: isMobile,
            ),
            Divider(height: isMobile ? 30 : 40, color: Colors.grey.shade200),
            _buildEditableField(
              context,
              label: 'Password',
              key: 'password',
              value: '',
              icon: Icons.password_outlined,
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(BuildContext context,
      {required String label,
      required String key,
      required String value,
      required IconData icon,
      required bool isMobile}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final labelColor = isDark ? Colors.grey[300] : Colors.grey[800];
    final valueColor = isDark ? Colors.grey[100] : Colors.grey[900];
    final dividerColor = isDark ? Colors.grey[800] : Colors.grey.shade200;

    return Row(
      children: [
        Icon(icon, color: Colors.orange.shade800, size: isMobile ? 28 : 32),
        SizedBox(width: isMobile ? 15 : 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: isMobile ? 14 : 16,
                  )),
              SizedBox(height: isMobile ? 4 : 8),
              Text(
                label.toLowerCase() == 'password' ? '•' * value.length : value,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit_outlined,
              color: Colors.orange.shade600, size: isMobile ? 26 : 30),
          onPressed: () => showEditDialog(
              context, label, key, value, isMobile, userId!, ref),
        ),
      ],
    );
  }
}
