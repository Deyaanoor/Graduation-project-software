import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/screens/auth/Title_Project.dart';
import 'package:flutter_provider/screens/auth/divider_widget.dart';
import 'package:flutter_provider/screens/auth/forgot_password.dart';
import 'package:flutter_provider/screens/auth/register_label.dart';
import 'package:flutter_provider/widgets/bezierContainer.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/custom_snackbar.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final lang = ref.watch(languageProvider);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (ResponsiveHelper.isMobile(context)) {
            return _buildMobileView(context, emailController,
                passwordController, height, ref, lang);
          } else {
            return _buildDesktopView(context, emailController,
                passwordController, height, width, ref, lang);
          }
        },
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget _buildMobileView(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    double height,
    WidgetRef ref,
    Map<String, dynamic> lang,
  ) {
    return Stack(
      children: [
        Positioned(
          top: -height * .15,
          right: -MediaQuery.of(context).size.width * .4,
          child: BezierContainer(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height * .2),
                  TitlePro(),
                  const SizedBox(height: 50),
                  CustomTextField(
                    label: lang['email'] ?? "Email",
                    hint: lang['enterEmail'] ?? "Enter your email",
                    icon: Icons.email,
                    controller: emailController,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return lang['emailRequired'] ??
                            'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: lang['password'] ?? "Password",
                    hint: lang['enterPassword'] ?? "Enter your password",
                    icon: Icons.lock,
                    isPassword: true,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return lang['passwordRequired'] ??
                            'Please enter your password';
                      }
                      if (value.length < 6) {
                        return lang['passwordShort'] ??
                            'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      ForgotPassword(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: lang['login'] ?? 'Login',
                    onPressed: () async {
                      handleLogin(context, emailController, passwordController,
                          ref, lang);
                    },
                    isGradient: true,
                  ),
                  DividerWidget(),
                  SizedBox(height: height * .055),
                  RegisterLabel(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController passwordController,
    double height,
    double width,
    WidgetRef ref,
    Map<String, dynamic> lang,
  ) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: height * 0.85,
          maxWidth: width * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: width * 0.3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade700,
                      Colors.orange.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: height * 0.4,
                          maxWidth: width * 0.2,
                        ),
                        child: Image.network(
                          'https://i.postimg.cc/65vkqwg3/cleaned-image-3-removebg-preview.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                      SizedBox(height: 30),
                      TitlePro(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlePro(),
                        SizedBox(
                          height: 10,
                        ),
                        CustomTextField(
                          label: lang['email'] ?? "Email",
                          hint: lang['enterEmail'] ?? "Enter your email",
                          icon: Icons.email,
                          controller: emailController,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return lang['emailRequired'] ??
                                  'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        CustomTextField(
                          label: lang['password'] ?? "Password",
                          hint: lang['enterPassword'] ?? "Enter your password",
                          icon: Icons.lock,
                          isPassword: true,
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return lang['passwordRequired'] ??
                                  'Please enter your password';
                            }
                            if (value.length < 6) {
                              return lang['passwordShort'] ??
                                  'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(),
                            ForgotPassword(),
                          ],
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          text: lang['login'] ?? 'Login',
                          onPressed: () async {
                            handleLogin(context, emailController,
                                passwordController, ref, lang);
                          },
                          isGradient: true,
                        ),
                        SizedBox(height: 10),
                        DividerWidget(),
                        RegisterLabel(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    if (_formKey.currentState?.validate() ?? false) {
      try {
        ref.read(selectedIndexProvider.notifier).state = 0;

        String? fcmToken;

        // ✅ طلب إذن الإشعارات وتوليد التوكن
        NotificationSettings settings =
            await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          if (kIsWeb) {
            fcmToken = await FirebaseMessaging.instance.getToken(
              vapidKey:
                  "BGZEIrp8Oc46VWd92gmyEdP3UnQkfOOmAMVpRKSey09EkKn66cKNPnApwTMA7j49E2y-0QggAzx1J2qhiY418xE",
            );
          } else {
            fcmToken = await FirebaseMessaging.instance.getToken();
          }

          print("✅ FCM Token: $fcmToken");
        } else {
          print("❌ Notification permission not granted");
          fcmToken = "";
        }

        final credentials = {
          'email': emailController.text,
          'password': passwordController.text,
          'fcmToken': fcmToken ?? "",
        };

        final result = await ref.read(loginUserProvider(credentials).future);
        final role = result['role'];
        print("rooooole $role");

        ref.invalidate(userIdProvider);
        if (role == null || role == "") {
          Navigator.pushNamed(context, '/Apply_Request');
        } else {
          Navigator.pushNamed(context, '/home');
        }
      } catch (e) {
        print("❌ Login error: $e");
        CustomSnackBar.showErrorSnackBar(
          context,
          lang['loginFailed'] ?? 'Login failed',
        );
      }
    }
  }
}
