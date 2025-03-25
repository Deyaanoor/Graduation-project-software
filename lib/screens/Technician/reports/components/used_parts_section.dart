import 'package:flutter/material.dart';

class UsedPartsSection extends StatelessWidget {
  final TextEditingController controller;
  final List<String> selectedParts;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final String hint;
  final String title;

  const UsedPartsSection({
    super.key,
    required this.controller,
    required this.selectedParts,
    required this.onAdd,
    required this.onRemove,
    required this.hint,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: hint,
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      onPressed: onAdd,
                    ),
                  ],
                ),
                if (selectedParts.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      selectedParts.length,
                      (index) => Container(
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(selectedParts[index]),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => onRemove(index),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.orange[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
