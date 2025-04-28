import 'package:flutter/material.dart';

class AddCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
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
              children: const [
                Icon(Icons.add, size: 40, color: Colors.orange),
                SizedBox(height: 8),
                Text('Add Garage', style: TextStyle(color: Colors.orange)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
