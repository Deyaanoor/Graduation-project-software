import 'package:flutter/material.dart';

class RegisterLabel extends StatelessWidget {
  const RegisterLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/signup'),
      child: const Text(
        "Don't have an account? Register",
        style: TextStyle(
            color: Color(0xfff79c4f),
            fontSize: 13,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
