import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/forgot-password');
        },
        child: const Text(
          'Forgot Password ?',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: Colors.orange),
        ),
      ),
    );
  }
}
