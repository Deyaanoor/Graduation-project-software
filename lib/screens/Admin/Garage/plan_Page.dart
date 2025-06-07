import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/plan_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final plansAsync = ref.watch(allPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Plans')),
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
            child:
                isMobile ? _buildMobileList(plans) : _buildDesktopTable(plans),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading plans: $e')),
      ),
    );
  }

  Widget _buildMobileList(List<Map<String, dynamic>> plans) {
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
                Text(name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _updatePlan(name, priceController.text);
                  },
                  child: const Text('Update Price'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<Map<String, dynamic>> plans) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Plan Name')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Actions')),
        ],
        rows: plans.map((plan) {
          final name = plan['name'] as String;
          final priceController = _priceControllers[name]!;

          return DataRow(
            cells: [
              DataCell(Text(name)),
              DataCell(
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ),
              DataCell(
                ElevatedButton(
                  onPressed: () async {
                    await _updatePlan(name, priceController.text);
                  },
                  child: const Text('Update'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _updatePlan(String name, String priceText) async {
    final price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number for price')),
      );
      return;
    }

    try {
      await ref.read(updatePlanProvider)(name, price);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan $name updated successfully!')),
      );
      ref.refresh(allPlansProvider);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update plan: $e')),
      );
    }
  }
}
