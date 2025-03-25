import 'package:flutter/material.dart';

Widget buildNavItem(IconData icon, String label, int index, int selectedIndex) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        size: 30,
        color: selectedIndex == index ? Colors.white : Colors.white60,
      ),
      SizedBox(height: 4),
      if (selectedIndex != index)
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
    ],
  );
}
