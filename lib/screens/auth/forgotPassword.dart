import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/screens/auth/Title_Project.dart';
import 'package:flutter_provider/widgets/back_button.dart';
import 'package:flutter_provider/widgets/bezierContainer.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool sent = false;

  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = ref.watch(
      forgotPasswordProvider(emailController.text.trim()),
    );
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (ResponsiveHelper.isMobile(context)) {
            return _buildMobileView(
                context, emailController, height, forgotPasswordState);
          } else {
            return _buildDesktopView(
                context, emailController, height, width, forgotPasswordState);
          }
        },
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  Widget _buildMobileView(
      BuildContext context,
      TextEditingController emailController,
      double height,
      AsyncValue<String> forgotPasswordState) {
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
                    label: "Email",
                    hint: "Enter your email",
                    icon: Icons.email,
                    controller: emailController,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Send Reset Link',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          sent = true;
                        });
                      }
                    },
                    isGradient: true,
                  ),
                  SizedBox(height: height * .055),
                  if (sent)
                    forgotPasswordState.when(
                      data: (msg) => Text(msg,
                          style: const TextStyle(color: Colors.green)),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text(e.toString(),
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(top: 40, left: 0, child: BackButtonWidget()),
      ],
    );
  }

  Widget _buildDesktopView(
    BuildContext context,
    TextEditingController emailController,
    double height,
    double width,
    AsyncValue<String> forgotPasswordState,
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
                    key: _formKey, // إضافة الـ GlobalKey هنا
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlePro(),
                        SizedBox(height: 10),
                        CustomTextField(
                          label: "Email Address",
                          hint: "Enter your email",
                          icon: Icons.email,
                          controller: emailController,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: true,
                                  onChanged: (v) {},
                                  activeColor: Colors.orange.shade700,
                                ),
                                Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          text: 'Send Reset Link',
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                sent = true;
                              });
                            }
                          },
                          isGradient: true,
                        ),
                        SizedBox(height: 10),
                        if (sent)
                          forgotPasswordState.when(
                            data: (msg) => Text(msg,
                                style:
                                    TextStyle(color: Colors.orange.shade700)),
                            loading: () => const CircularProgressIndicator(),
                            error: (e, _) => Text(e.toString(),
                                style: const TextStyle(color: Colors.red)),
                          )
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
}
