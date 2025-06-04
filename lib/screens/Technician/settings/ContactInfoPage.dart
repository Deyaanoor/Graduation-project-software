import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ContactInfoPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider).value;
    final garageInfoAsync = ref.watch(garageInfoByUserIdProvider(userId!));
    final lang = ref.watch(languageProvider);

    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text(lang['infoContactUs'] ?? 'معلومات التواصل',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: true,
              flexibleSpace: _buildAppBarGradient(),
              elevation: 5,
            )
          : null,
      body: garageInfoAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
            child: Text('${lang['errorOccurred'] ?? 'حدث خطأ'}: $error')),
        data: (garageInfo) {
          print('garageInfo: $garageInfo');

          final ownerInfo = garageInfo['ownerInfo'];

          final String email = ownerInfo != null && ownerInfo['email'] != null
              ? ownerInfo['email']
              : (lang['notAvailable'] ?? 'غير متوفر');

          final String phone =
              ownerInfo != null && ownerInfo['phoneNumber'] != null
                  ? ownerInfo['phoneNumber']
                  : (lang['notAvailable'] ?? 'غير متوفر');

          final Map<String, dynamic> address =
              jsonDecode(garageInfo['location']);

          final children = [
            _buildContactCard(
              context,
              lang: lang,
              icon: Icons.email_rounded,
              title: lang['email'] ?? 'Email',
              subtitle: email,
              iconColor: Colors.blue.shade800,
              actions: [
                _buildActionButton(
                  icon: Icons.content_copy_rounded,
                  onPressed: () => _copyToClipboard(context, email, lang),
                ),
              ],
              onTap: () => _launchEmail(context, email, lang),
              isMobile: isMobile,
            ),
            _buildContactCard(
              context,
              lang: lang,
              icon: Icons.phone_rounded,
              title: lang['phone'] ?? 'Phone',
              subtitle: phone,
              iconColor: Colors.green.shade800,
              actions: [
                _buildActionButton(
                  icon: Icons.content_copy_rounded,
                  onPressed: () => _copyToClipboard(context, phone, lang),
                ),
                _buildActionButton(
                  icon: Icons.call_rounded,
                  onPressed: () => _launchPhone(context, phone, lang),
                ),
                _buildActionButton(
                  icon: Icons.sms_rounded,
                  onPressed: () => _launchSMS(context, phone, lang),
                ),
              ],
              onTap: () => _launchPhone(context, phone, lang),
              isMobile: isMobile,
            ),
            _buildContactCard(
              context,
              lang: lang,
              icon: Icons.location_on_rounded,
              title: lang['map'] ?? 'Map',
              subtitle: lang['location'] ?? 'location',
              iconColor: Colors.purple.shade800,
              actions: [
                _buildActionButton(
                  icon: Icons.content_copy_rounded,
                  onPressed: () {},
                ),
                _buildActionButton(
                  icon: Icons.map_rounded,
                  onPressed: () => _launchMaps(context, address, lang),
                ),
              ],
              onTap: () => _launchMaps(context, address, lang),
              isMobile: isMobile,
            ),
          ];

          return Padding(
            padding: EdgeInsets.all(isMobile ? 20.0 : 40.0),
            child: isDesktop
                ? GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2,
                    children: children,
                  )
                : ListView.separated(
                    itemBuilder: (_, index) => children[index],
                    separatorBuilder: (_, __) =>
                        SizedBox(height: isMobile ? 15 : 20),
                    itemCount: children.length,
                  ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade800, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required Map<String, dynamic> lang,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required List<Widget> actions,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: theme.cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 30),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: isMobile ? 28 : 32),
              ),
              SizedBox(width: isMobile ? 20 : 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 20,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isMobile ? 14 : 18,
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Row(children: actions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 24, color: Colors.grey.shade700),
      onPressed: onPressed,
    );
  }

  void _copyToClipboard(
      BuildContext context, String text, Map<String, dynamic> lang) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.teal.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(lang['copiedToClipboard'] ?? 'تم النسخ إلى الحافظة',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchPhone(
      BuildContext context, String phone, Map<String, dynamic> lang) async {
    if (!_isValidPhone(phone)) {
      _showErrorSnackBar(
          context, lang['invalidPhone'] ?? 'رقم الهاتف غير صالح');
      return;
    }

    final Uri uri = Uri.parse('tel:$phone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        _showAlternativeOptions(context, phone, lang);
      }
    } catch (e) {
      _showErrorSnackBar(
          context, '${lang['callError'] ?? 'خطأ في الاتصال'}: ${e.toString()}');
    }
  }

  Future<void> _launchSMS(
      BuildContext context, String phone, Map<String, dynamic> lang) async {
    if (!_isValidPhone(phone)) {
      _showErrorSnackBar(
          context, lang['invalidPhone'] ?? 'رقم الهاتف غير صالح');
      return;
    }

    final Uri uri = Uri.parse('sms:$phone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar(
            context, lang['noSmsApp'] ?? 'لا يوجد تطبيق رسائل مثبت على الجهاز');
      }
    } catch (e) {
      _showErrorSnackBar(context,
          '${lang['smsError'] ?? 'خطأ في فتح الرسائل'}: ${e.toString()}');
    }
  }

  Future<void> _launchMaps(
      BuildContext context, dynamic location, Map<String, dynamic> lang) async {
    try {
      Uri uri;

      if (location is String) {
        final encodedAddress = Uri.encodeComponent(location);
        uri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$encodedAddress&hl=ar');
      } else if (location is Map<String, dynamic>) {
        final latitude = location['latitude'];
        final longitude = location['longitude'];

        if (latitude == null || longitude == null) {
          _showErrorSnackBar(context,
              lang['coordinatesNotAvailable'] ?? 'الإحداثيات غير متوفرة');
          return;
        }

        uri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&hl=ar');
      } else {
        _showErrorSnackBar(context,
            lang['unsupportedLocationFormat'] ?? 'تنسيق الموقع غير مدعوم');
        return;
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar(
            context, lang['cantOpenMaps'] ?? 'تعذر فتح تطبيق الخرائط');
      }
    } catch (e) {
      _showErrorSnackBar(context,
          '${lang['mapsError'] ?? 'خطأ في فتح الخرائط'}: ${e.toString()}');
    }
  }

  Future<void> _launchEmail(
      BuildContext context, String email, Map<String, dynamic> lang) async {
    if (!_isValidEmail(email)) {
      _showErrorSnackBar(
          context, lang['invalidEmail'] ?? 'بريد إلكتروني غير صالح');
      return;
    }

    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar(
            context, lang['cantOpenEmail'] ?? 'تعذر فتح تطبيق البريد');
      }
    } catch (e) {
      _showErrorSnackBar(context,
          '${lang['emailError'] ?? 'خطأ في فتح البريد'}: ${e.toString()}');
    }
  }

  void _showAlternativeOptions(
      BuildContext context, String phone, Map<String, dynamic> lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang['chooseContactMethod'] ?? 'اختر طريقة الاتصال'),
        content: Text(
            lang['noDefaultDialer'] ?? 'لم يتم العثور على تطبيق اتصال افتراضي'),
        actions: [
          TextButton(
            child: Text(lang['openAppStore'] ?? 'فتح متجر التطبيقات'),
            onPressed: () => _launchAppStore(context, lang),
          ),
          TextButton(
            child: Text(lang['copyNumber'] ?? 'نسخ الرقم'),
            onPressed: () {
              _copyToClipboard(context, phone, lang);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchAppStore(
      BuildContext context, Map<String, dynamic> lang) async {
    const String appStoreUrl = 'market://details?id=com.google.android.dialer';
    final Uri uri = Uri.parse(appStoreUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar(
            context, lang['cantOpenStore'] ?? 'تعذر فتح متجر التطبيقات');
      }
    } catch (e) {
      _showErrorSnackBar(context,
          '${lang['storeError'] ?? 'خطأ في فتح المتجر'}: ${e.toString()}');
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final regex = RegExp(r'^\+?\d{6,15}$'); // يقبل أرقام دولية ومحلية
    return regex.hasMatch(phone);
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Expanded(
                child: Text(message, style: TextStyle(color: Colors.white))),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
