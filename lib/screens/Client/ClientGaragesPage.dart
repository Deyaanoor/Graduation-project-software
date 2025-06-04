import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/clientProvider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class ClientGaragesPage extends ConsumerWidget {
  const ClientGaragesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdValue = ref.watch(userIdProvider).value;
    final searchQuery = ref.watch(searchQueryProvider);
    final isMobile = (ResponsiveHelper.isMobile(context));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = ref.watch(languageProvider);

    if (userIdValue == null) {
      return Center(child: Text(lang['noUserId'] ?? 'No user ID available.'));
    }

    final garagesAsync = ref.watch(clientGaragesProvider(userIdValue));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 🔍 Search box
              TextField(
                decoration: InputDecoration(
                  hintText: lang['searchGarage'] ?? 'ابحث عن كراج...',
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () =>
                              ref.read(searchQueryProvider.notifier).state = '',
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).state = value,
              ),
              const SizedBox(height: 16),

              // هذه الجزئية تأخذ كل المساحة المتبقية وتعرض القائمة
              Expanded(
                child: garagesAsync.when(
                  data: (garages) {
                    final filteredGarages = garages
                        .where((garage) => (garage['name'] ?? '')
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();

                    if (filteredGarages.isEmpty) {
                      return Center(
                        child: Text(
                          lang['noGaragesFound'] ??
                              'لا توجد كراجات تطابق البحث.',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 420,
                        mainAxisExtent: 180,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredGarages.length,
                      itemBuilder: (context, index) {
                        final garage = filteredGarages[index];
                        final garageId = garage['garageId'];

                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              if (!isDark)
                                const BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                garage['name'] ??
                                    (lang['noName'] ?? 'اسم غير متوفر'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onBackground,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      garage['ownerName'] ??
                                          (lang['unknown'] ?? 'غير معروف'),
                                      style: const TextStyle(fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email,
                                      color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      garage['ownerEmail'] ??
                                          (lang['unknown'] ?? 'غير معروف'),
                                      style: const TextStyle(fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ref.read(garageIdProvider.notifier).state =
                                        garageId;
                                    ref
                                        .read(selectedIndexProvider.notifier)
                                        .state = 5;
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                  ),
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      size: 18),
                                  label: Text(
                                      lang['viewDetails'] ?? 'عرض التفاصيل'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('${lang['error'] ?? 'حدث خطأ'}: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
