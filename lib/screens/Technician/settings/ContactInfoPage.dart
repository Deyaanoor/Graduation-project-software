import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ContactInfoPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider).value;
    final garageInfoAsync = ref.watch(garageInfoByUserIdProvider(userId!));

    final bool isMobile = ResponsiveHelper.isMobile(context);
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: Text('معلومات الاتصال',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: true,
              flexibleSpace: _buildAppBarGradient(),
              elevation: 5,
            )
          : null,
      body: garageInfoAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('حدث خطأ: $error')),
        data: (garageInfo) {
          final String email = garageInfo['ownerEmail'] ?? 'غير متوفر';
          final String phone = 'غير متوفر';
          final Map<String, dynamic> address =
              jsonDecode(garageInfo['location']);

          print('Address: $address');

          final children = [
            _buildContactCard(
              context,
              icon: Icons.email_rounded,
              title: 'البريد الإلكتروني',
              subtitle: email,
              iconColor: Colors.blue.shade800,
              actions: [
                _buildActionButton(
                  icon: Icons.content_copy_rounded,
                  onPressed: () => _copyToClipboard(context, email),
                ),
              ],
              onTap: () => _launchEmail(context, email),
              isMobile: isMobile,
            ),
            _buildContactCard(
              context,
              icon: Icons.phone_rounded,
              title: 'رقم الهاتف',
              subtitle: phone,
              iconColor: Colors.green.shade800,
              actions: [
                _buildActionButton(
                  icon: Icons.content_copy_rounded,
                  onPressed: () => _copyToClipboard(context, phone),
                ),
                _buildActionButton(
                  icon: Icons.call_rounded,
                  onPressed: () => _launchPhone(context, phone),
                ),
                _buildActionButton(
                  icon: Icons.sms_rounded,
                  onPressed: () => _launchSMS(context, phone),
                ),
              ],
              onTap: () => _launchPhone(context, phone),
              isMobile: isMobile,
            ),
            _buildContactCard(
              context,
              icon: Icons.location_on_rounded,
              title: 'العنوان',
              subtitle: 'العنوان',
              iconColor: Colors.purple.shade800,
              actions: [
                _buildActionButton(
                  icon: Icons.content_copy_rounded,
                  onPressed: () => {},
                ),
                _buildActionButton(
                  icon: Icons.map_rounded,
                  onPressed: () => _launchMaps(context, address),
                ),
              ],
              onTap: () => _launchMaps(context, address),
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
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required List<Widget> actions,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: isMobile ? 28 : 32),
              ),
              SizedBox(width: isMobile ? 20 : 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        )),
                    SizedBox(height: 5),
                    Text(subtitle,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 18,
                          color: Colors.grey.shade600,
                        )),
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

  void _copyToClipboard(BuildContext context, String text) {
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
            Text('تم النسخ إلى الحافظة', style: TextStyle(color: Colors.white)),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    if (!_isValidPhone(phone)) {
      _showErrorSnackBar(context, 'رقم الهاتف غير صالح');
      return;
    }

    final Uri uri = Uri.parse('tel:$phone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        _showAlternativeOptions(context, phone);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطأ في الاتصال: ${e.toString()}');
    }
  }

  Future<void> _launchSMS(BuildContext context, String phone) async {
    if (!_isValidPhone(phone)) {
      _showErrorSnackBar(context, 'رقم الهاتف غير صالح');
      return;
    }

    final Uri uri = Uri.parse('sms:$phone');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar(context, 'لا يوجد تطبيق رسائل مثبت على الجهاز');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطأ في فتح الرسائل: ${e.toString()}');
    }
  }

  Future<void> _launchMaps(BuildContext context, dynamic location) async {
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
          _showErrorSnackBar(context, 'الإحداثيات غير متوفرة');
          return;
        }

        uri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&hl=ar');
      } else {
        _showErrorSnackBar(context, 'تنسيق الموقع غير مدعوم');
        return;
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar(context, 'تعذر فتح تطبيق الخرائط');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطأ في فتح الخرائط: ${e.toString()}');
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    if (!_isValidEmail(email)) {
      _showErrorSnackBar(context, 'بريد إلكتروني غير صالح');
      return;
    }

    final Uri uri = Uri.parse('mailto:$email');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar(context, 'يرجى تثبيت تطبيق بريد إلكتروني مثل Gmail');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطأ في فتح البريد: ${e.toString()}');
    }
  }

  void _showAlternativeOptions(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر طريقة الاتصال'),
        content: Text('لم يتم العثور على تطبيق اتصال افتراضي'),
        actions: [
          TextButton(
            child: Text('فتح متجر التطبيقات'),
            onPressed: () => _launchAppStore(context),
          ),
          TextButton(
            child: Text('نسخ الرقم'),
            onPressed: () {
              _copyToClipboard(context, phone);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchAppStore(BuildContext context) async {
    const String appStoreUrl = 'market://details?id=com.google.android.dialer';
    final Uri uri = Uri.parse(appStoreUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar(context, 'تعذر فتح متجر التطبيقات');
      }
    } catch (e) {
      _showErrorSnackBar(context, 'خطأ في فتح المتجر: ${e.toString()}');
    }
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^[+0-9]{8,15}$').hasMatch(phone);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
