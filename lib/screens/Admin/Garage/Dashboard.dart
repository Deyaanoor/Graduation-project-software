import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/admin_StaticProvider.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(staticAdminProvider);
    print("static : $statsAsync");

    final Color mainColor = Colors.orange;
    final double cardElevation = 6;

    return statsAsync.when(
      data: (data) {
        final garagesCount = data['garagesCount'] ?? 0;
        final subscriptionRequestsCount =
            data['subscriptionRequestsCount'] ?? 0;
        final contactMessagesCount = data['contactMessagesCount'] ?? 0;
        final trialGaragesCount = data['trialGaragesCount'] ?? 0;
        final garagesCountInactive = data['garagesCountInactive'] ?? 0;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildSummaryCard(
                      context,
                      title: 'عدد الكراجات',
                      icon: Icons.garage_outlined,
                      value: garagesCount.toString(),
                      mainColor: mainColor,
                      elevation: cardElevation,
                    ),
                    _buildSummaryCard(
                      context,
                      title: 'طلبات الاشتراك',
                      icon: Icons.person_add_alt_1,
                      value: subscriptionRequestsCount.toString(),
                      mainColor: mainColor,
                      elevation: cardElevation,
                    ),
                    _buildSummaryCard(
                      context,
                      title: 'الرسائل المرسلة',
                      icon: Icons.message_outlined,
                      value: contactMessagesCount.toString(),
                      mainColor: mainColor,
                      elevation: cardElevation,
                    ),
                    _buildSummaryCard(
                      context,
                      title: 'الكراجات التجريبية',
                      icon: Icons.science_outlined,
                      value: trialGaragesCount.toString(),
                      mainColor: mainColor,
                      elevation: cardElevation,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Center(child: const CircularProgressIndicator()),
      error: (error, stack) => Text('خطأ: $error'),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String value,
    required Color mainColor,
    required double elevation,
  }) {
    return SizedBox(
      width: 300,
      height: 120,
      child: Card(
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: mainColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: mainColor),
                  const SizedBox(width: 10),
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
