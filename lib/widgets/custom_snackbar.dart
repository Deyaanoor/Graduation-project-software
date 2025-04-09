import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showCustomSnackBar(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black,
    IconData icon = Icons.info_outline,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showCustomSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showCustomSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error_outline,
    );
  }
}
