import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class TopSnackBar {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    Flushbar(
      title: title,
      message: message,
      icon: Icon(icon, color: Colors.white),
      backgroundColor: color,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: Duration(milliseconds: 500),
    ).show(context);
  }
}
