import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Expanded(child: Divider(thickness: 1)),
          const Text('or'),
          const Expanded(child: Divider(thickness: 1)),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
