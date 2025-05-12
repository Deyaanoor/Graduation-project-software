import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/screens/Client/GarageRequestsPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/clientProvider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class ClientGaragesPage extends ConsumerWidget {
  const ClientGaragesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdValue = ref.watch(userIdProvider).value;
    final searchQuery = ref.watch(searchQueryProvider);

    if (userIdValue == null) {
      return const Center(child: Text('No user ID available.'));
    }

    final garagesAsync = ref.watch(clientGaragesProvider(userIdValue));

    return Scaffold(
      appBar: ResponsiveHelper.isMobile(context)
          ? AppBar(title: const Text('Client Garages'))
          : null,
      body: garagesAsync.when(
        data: (garages) {
          final filteredGarages = garages
              .where((garage) => (garage['name'] ?? '')
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن كراج...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => ref
                                .read(searchQueryProvider.notifier)
                                .state = '',
                          )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
                ),
              ),
              Expanded(
                child: filteredGarages.isEmpty
                    ? const Center(child: Text('لا توجد كراجات تطابق البحث.'))
                    : ListView.builder(
                        itemCount: filteredGarages.length,
                        itemBuilder: (context, index) {
                          final garage = filteredGarages[index];
                          final garageId = garage['garageId'];

                          return Card(
                            color: Theme.of(context).cardColor,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ResponsiveHelper.isMobile(context)
                                  ? Column(
                                      // شكل الموبايل
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.garage,
                                                color: Colors.orange, size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                garage['name'] ?? 'No name',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                color: Colors.orange, size: 18),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                garage['location'] ??
                                                    'No location',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                color: Colors.orange, size: 18),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                garage['ownerName'] ??
                                                    'No owner',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.email,
                                                color: Colors.orange, size: 18),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                garage['ownerEmail'] ??
                                                    'No email',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                      garageIdProvider.notifier)
                                                  .state = garageId;
                                              ref
                                                  .read(selectedIndexProvider
                                                      .notifier)
                                                  .state = 5;
                                            },
                                            icon: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 16,
                                                color: Colors.orange),
                                            label: const Text('عرض التفاصيل',
                                                style: TextStyle(
                                                    color: Colors.orange)),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      // شكل الدسكتوب
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(garage['name'] ?? 'No name',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                              const SizedBox(height: 6),
                                              Text(
                                                  'الموقع: ${garage['location'] ?? 'غير معروف'}'),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'المالك: ${garage['ownerName'] ?? 'غير معروف'}'),
                                              const SizedBox(height: 6),
                                              Text(
                                                  'الإيميل: ${garage['ownerEmail'] ?? 'غير معروف'}'),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            ref
                                                .read(garageIdProvider.notifier)
                                                .state = garageId;
                                            ref
                                                .read(selectedIndexProvider
                                                    .notifier)
                                                .state = 5;
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                          child: const Text('عرض التفاصيل'),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
