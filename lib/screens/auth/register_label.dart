import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/language_provider.dart';

class RegisterLabel extends ConsumerWidget {
  const RegisterLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/signup'),
      child: Text(
        lang['noAccountRegister'] ?? "Don't have an account? Register",
        style: const TextStyle(
            color: Color(0xfff79c4f),
            fontSize: 13,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class LoginLabel extends ConsumerWidget {
  const LoginLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: Text(
        lang['alreadyAccountLogin'] ?? "Already have an account? Login",
        style: const TextStyle(
            color: Color(0xfff79c4f),
            fontSize: 13,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
