import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/auth/check_verification_provider.dart';
import 'package:flutter_provider/widgets/custom_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/language_provider.dart';

class CheckVerificationPage extends ConsumerStatefulWidget {
  final String email;
  final String password;

  const CheckVerificationPage({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  ConsumerState<CheckVerificationPage> createState() =>
      _CheckVerificationPageState();
}

class _CheckVerificationPageState extends ConsumerState<CheckVerificationPage> {
  bool hasLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isVerifiedAsync = ref.watch(checkVerificationProvider(widget.email));

    isVerifiedAsync.whenData((isVerified) {
      if (isVerified && !hasLoggedIn) {
        hasLoggedIn = true;
        handleLogin(
          context,
          TextEditingController(text: widget.email),
          TextEditingController(text: widget.password),
          ref,
          lang,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(lang['emailVerification'] ?? 'Email Verification'),
      ),
      body: Center(
        child: isVerifiedAsync.when(
          data:
              (isVerified) => Text(
                isVerified
                    ? (lang['verifiedLoggingIn'] ?? '✅ Verified. Logging in...')
                    : (lang['notVerifiedYet'] ?? '❌ Not Verified yet.'),
                style: const TextStyle(fontSize: 20),
              ),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text(''),
        ),
      ),
    );
  }

  void handleLogin(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    WidgetRef ref,
    Map<String, dynamic> lang,
  ) async {
    final credentials = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    try {
      final result = await ref.read(loginUserProvider(credentials).future);
      final role = result['role'];
      print(role);

      // بعد حفظ التوكن داخل loginUserProvider، نعيد تهيئة الـ userIdProvider
      ref.invalidate(userIdProvider);
      if (role == null) {
        Navigator.pushNamed(context, '/Apply_Request');
      } else {
        Navigator.pushNamed(context, '/home');
      }
    } catch (e) {
      CustomSnackBar.showErrorSnackBar(
        context,
        lang['loginFailed'] ?? 'Login failed',
      );
    }
  }
}
