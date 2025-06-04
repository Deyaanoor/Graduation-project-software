import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/language_provider.dart';

class AddCard extends ConsumerWidget {
  final VoidCallback onTap;

  const AddCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.orange, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 40, color: Colors.orange),
                const SizedBox(height: 8),
                Text(
                  lang['addGarage'] ?? 'Add Garage',
                  style: const TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
