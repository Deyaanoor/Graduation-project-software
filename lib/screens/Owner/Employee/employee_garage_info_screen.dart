import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/employeeProvider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class EmployeeGarageInfoPage extends ConsumerWidget {
  const EmployeeGarageInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider).value;
    final lang = ref.watch(languageProvider);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final garageInfoAsync = ref.watch(getEmployeeGarageInfoProvider(userId!));

    return Scaffold(
      body: garageInfoAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
            strokeWidth: 2.5,
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 20),
                Text(
                  lang['errorLoadingData'] ?? 'حدث خطأ في تحميل البيانات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.orange[300] : Colors.orange[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () =>
                      ref.refresh(getEmployeeGarageInfoProvider(userId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(lang['retry'] ?? 'إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (data) => SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.orange,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.garage_rounded,
                        size: 40,
                        color: Colors.orange[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      data['garage']['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.orange[200]
                            : Colors.orange[800],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      lang['garageName'] ?? 'كراج الصيانة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              _buildInfoCard(
                context: context,
                icon: Icons.attach_money_rounded,
                title: lang['salary'] ?? "الراتب الشهري",
                value: "${data['salary']} دينار",
                iconColor: Colors.green,
                bgColor: isDarkMode
                    ? Colors.green[900]!.withOpacity(0.2)
                    : Colors.green[50]!,
              ),
              SizedBox(height: 30),
              _buildInfoCard(
                context: context,
                icon: Icons.build,
                title: lang['numberOfRepairs'] ?? "عدد التصليحات",
                value: "${data['reportCount']} ",
                iconColor: Colors.green,
                bgColor: isDarkMode
                    ? const Color.fromARGB(255, 210, 245, 11)!.withOpacity(0.2)
                    : Colors.green[50]!,
              ),
              SizedBox(height: 20),
              _buildInfoCard(
                context: context,
                icon: Icons.business_rounded,
                title: lang['garageInformation'] ?? "معلومات الكراج",
                value: data['garage']['name'],
                iconColor: Colors.blue,
                bgColor: isDarkMode
                    ? Colors.blue[900]!.withOpacity(0.2)
                    : Colors.blue[50]!,
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      color: Colors.orange[700], size: 24),
                  SizedBox(width: 10),
                  Text(
                    lang['ownerInformation'] ?? "معلومات المالك",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode ? Colors.orange[300] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              _buildContactItem(
                context: context,
                icon: Icons.person_rounded,
                label: lang['owner'] ?? "اسم المالك",
                value: data['ownerInfo']['name'],
                iconColor: Colors.purple,
                onCopy: () =>
                    _copyToClipboard(context, data['ownerInfo']['name'], lang),
              ),
              _buildContactItem(
                context: context,
                icon: Icons.email_rounded,
                label: lang['email'] ?? "البريد الإلكتروني",
                value: data['ownerInfo']['email'],
                iconColor: Colors.blue,
                onCopy: () =>
                    _copyToClipboard(context, data['ownerInfo']['email'], lang),
                onTap: () =>
                    _launchEmail(context, data['ownerInfo']['email'], lang),
              ),
              _buildContactItem(
                context: context,
                icon: Icons.phone_rounded,
                label: lang['phoneNumber'] ?? "رقم الهاتف",
                value: data['ownerInfo']['phoneNumber'],
                iconColor: Colors.green,
                onCopy: () => _copyToClipboard(
                    context, data['ownerInfo']['phoneNumber'], lang),
                onTap: () => _launchPhone(
                    context, data['ownerInfo']['phoneNumber'], lang),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      )),
                  SizedBox(height: 8),
                  Text(value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    VoidCallback? onCopy,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      )),
                  SizedBox(height: 5),
                  Text(value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      )),
                ],
              ),
            ),
            if (onCopy != null)
              IconButton(
                icon: Icon(Icons.content_copy, size: 20),
                color: Colors.grey,
                onPressed: onCopy,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  void _copyToClipboard(
    BuildContext context,
    String value,
    Map<String, String> lang,
  ) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(lang['copiedToClipboard'] ?? 'تم النسخ إلى الحافظة')),
    );
  }

  void _launchPhone(BuildContext context, String phoneNumber,
      Map<String, String> lang) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError(context, lang['openPhoneError'] ?? 'تعذر فتح تطبيق الاتصال');
    }
  }

  void _launchEmail(
      BuildContext context, String email, Map<String, String> lang) async {
    final Uri url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        _showError(context,
            lang['openEmailError'] ?? 'تعذر فتح تطبيق البريد الإلكتروني');
      }
    }
  }

  void _launchSMS(BuildContext context, String phoneNumber,
      Map<String, String> lang) async {
    final Uri url = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      _showError(context, lang['openSMSError'] ?? 'تعذر فتح تطبيق الرسائل');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
