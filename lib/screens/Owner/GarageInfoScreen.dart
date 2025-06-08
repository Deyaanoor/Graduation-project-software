import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/userGarage_provider.dart';
import 'package:flutter_provider/screens/Owner/RenewSubscriptionScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GarageInfoScreen extends ConsumerWidget {
  const GarageInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final userId = '6830fcf934c8230afed27604';

    final garageDataAsync = ref.watch(userGarageProvider(userId!));

    final isMobile = ResponsiveHelper.isMobile(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      body: garageDataAsync.when(
        data: (data) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 150 : 16,
              vertical: 24,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                        lang['garageDetails'] ?? 'تفاصيل الجراج', context),
                    const SizedBox(height: 20),
                    _infoItem(lang['garageName'] ?? 'اسم الجراج', data['name'],
                        Icons.home),
                    _infoItem(lang['cost'] ?? 'التكلفة', '${data['cost']} \$',
                        Icons.attach_money),
                    _infoItem(lang['subscriptionType'] ?? 'نوع الاشتراك',
                        data['subscriptionType'], Icons.card_membership),
                    _infoItem(
                        lang['subscriptionEndDate'] ?? 'تاريخ نهاية الاشتراك',
                        _formatDate(data['subscriptionEndDate'], lang),
                        Icons.calendar_month),
                    _infoItem(lang['createdAt'] ?? 'تاريخ الإنشاء',
                        _formatDate(data['createdAt'], lang), Icons.history),
                    const SizedBox(height: 30),

                    // ✅ زر تجديد الاشتراك
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RenewSubscriptionScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label:
                            Text(lang['renewSubscription'] ?? "تجديد الاشتراك"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            '${lang['loadError'] ?? 'فشل في تحميل البيانات'}: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
    );
  }

  Widget _infoItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade400),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate, Map<String, String> lang) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return lang['invalidDate'] ?? 'تاريخ غير صالح';
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
