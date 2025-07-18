import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/plan_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlansPage extends ConsumerStatefulWidget {
  const PlansPage({super.key});

  @override
  ConsumerState<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends ConsumerState<PlansPage> {
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showAddPlanDialog(Map<String, String> lang) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(lang['addPlan'] ?? 'Add Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: lang['planName'] ?? 'Plan Name',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: lang['price'] ?? 'Price',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(lang['cancel'] ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text.trim());

                if (name.isEmpty || price == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(lang['validInputs'] ??
                            'Please fill both fields correctly')),
                  );
                  return;
                }

                try {
                  await ref.read(addPlanProvider)(name, price);

                  Navigator.of(context).pop(); // إغلاق النافذة
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            lang['planAdded'] ?? 'Plan added successfully')),
                  );
                  ref.refresh(allPlansProvider);
                } catch (e) {
                  Navigator.of(context).pop(); // إغلاق النافذة
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(lang['planAddError'] ?? 'Error adding plan')),
                  );
                }
              },
              child: Text(lang['add'] ?? 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final plansAsync = ref.watch(allPlansProvider);

    return Scaffold(
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showAddPlanDialog(lang),
              child: const Icon(Icons.add),
              tooltip: lang['addPlan'] ?? 'Add Plan',
            )
          : null,
      body: plansAsync.when(
        data: (plans) {
          for (var plan in plans) {
            final name = plan['name'] as String;
            final price = plan['price'].toString();
            _priceControllers.putIfAbsent(
                name, () => TextEditingController(text: price));
          }

          return Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile) // زر إضافة الخطط (للديسكتوب فقط)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddPlanDialog(lang),
                      icon: const Icon(Icons.add),
                      label: Text(lang['addPlan'] ?? 'Add Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: isMobile
                      ? _buildMobileList(plans, lang)
                      : _buildDesktopTable(plans, lang),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('${lang['plansLoadError'] ?? 'Error loading plans'}: $e'),
        ),
      ),
    );
  }

  Widget _buildMobileList(
      List<Map<String, dynamic>> plans, Map<String, String> lang) {
    return ListView.builder(
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final name = plan['name'] as String;
        final priceController = _priceControllers[name]!;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: lang['deletePlan'] ?? 'Delete Plan',
                      onPressed: () =>
                          _confirmDeletePlan(plan['_id'], name, lang),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: lang['price'] ?? 'Price'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _updatePlan(name, priceController.text, lang);
                  },
                  child: Text(lang['updatePrice'] ?? 'Update Price'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(
      List<Map<String, dynamic>> plans, Map<String, String> lang) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
          minWidth: 600,
        ),
        child: Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(lang['planName'] ?? 'Plan Name')),
                  DataColumn(label: Text(lang['price'] ?? 'Price')),
                  DataColumn(label: Text(lang['actions'] ?? 'Actions')),
                ],
                rows: plans.map((plan) {
                  final name = plan['name'] as String;
                  final priceController = _priceControllers[name]!;

                  return DataRow(
                    cells: [
                      DataCell(Text(name)),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _updatePlan(
                                    name, priceController.text, lang);
                              },
                              child: Text(lang['update'] ?? 'Update'),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: lang['deletePlan'] ?? 'Delete Plan',
                              onPressed: () =>
                                  _confirmDeletePlan(plan['_id'], name, lang),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletePlan(
      String id, String name, Map<String, String> lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isMobile = ResponsiveHelper.isMobile(context);
        return AlertDialog(
          title: Text(lang['confirmDeleteTitle'] ?? 'Confirm Deletion'),
          content: Text(
              lang['confirmDeleteMessage']?.replaceAll('{name}', name) ??
                  'Are you sure you want to delete "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(lang['cancel'] ?? 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(lang['delete'] ?? 'Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref.read(deletePlanProvider)(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang['deleteSuccess'] ?? 'Plan deleted successfully'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
          ),
        );
        ref.refresh(allPlansProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang['deleteError'] ?? 'Failed to delete plan'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
          ),
        );
      }
    }
  }

  Future<void> _updatePlan(
      String name, String priceText, Map<String, String> lang) async {
    final price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                lang['validPrice'] ?? 'Please enter a valid number for price')),
      );
      return;
    }

    try {
      await ref.read(updatePlanProvider)(name, price);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang['validPrice'] ?? 'Please enter a valid number for price',
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
              bottom: 60, left: 16, right: 16), // ارفعها 60 بكسل عن الأسفل
        ),
      );
      ref.refresh(allPlansProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lang['updateSuccess'] ?? 'Plan updated successfully!'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
        ),
      );
    }
  }
}
