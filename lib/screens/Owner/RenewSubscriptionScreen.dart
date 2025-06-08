import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/plan_provider.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/payment_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RenewSubscriptionScreen extends ConsumerStatefulWidget {
  const RenewSubscriptionScreen({super.key});

  @override
  ConsumerState<RenewSubscriptionScreen> createState() =>
      _RenewSubscriptionScreenState();
}

class _RenewSubscriptionScreenState
    extends ConsumerState<RenewSubscriptionScreen> {
  Map<String, dynamic>? selectedPlan;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final plansAsync = ref.watch(allPlansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang['renewSubscription'] ?? "تجديد الاشتراك",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: plansAsync.when(
        data: (plans) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  lang['chooseSubscription'] ?? "اختر نوع الاشتراك المناسب لك",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final isSelected = selectedPlan?['_id'] == plan['_id'];

                      return GestureDetector(
                        onTap: () => setState(() {
                          selectedPlan = plan;
                        }),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : const Color.fromARGB(255, 65, 56, 56),
                              width: 2,
                            ),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          color: isDark ? Colors.grey[900] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan['name'] ??
                                      (lang['planNoName'] ?? 'باقة بدون اسم'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const SizedBox(height: 4),
                                Text(
                                    "${lang['price'] ?? 'السعر'}: ${plan['price']} \$"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: lang['confirmSubscription'] ?? "تأكيد الاشتراك",
                  backgroundColor: Colors.orange.shade600,
                  onPressed: () {
                    if (selectedPlan != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            selectedSubscription: selectedPlan!['name'],
                            currency: 'USD',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            "${lang['plansLoadError'] ?? 'فشل تحميل الباقات'}: $err",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
