import 'package:flutter/material.dart';

AlertDialog AlertToDelete({
  required BuildContext context,
  required String title,
  required String content,
  String cancelText = 'إلغاء',
  String confirmText = 'نعم، احذف',
  Color primaryColor = Colors.orange,
}) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    backgroundColor: Colors.white,
    elevation: 24,
    title: Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    ),
    content: Text(
      content,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black54,
        height: 1.5,
      ),
    ),
    actionsAlignment: MainAxisAlignment.end,
    actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[700],
        ),
        child: Text(
          cancelText,
          style: TextStyle(fontSize: 15),
        ),
      ),
      ElevatedButton(
        onPressed: () => Navigator.pop(context, true),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          confirmText,
          style: TextStyle(fontSize: 15),
        ),
      ),
    ],
  );
}
