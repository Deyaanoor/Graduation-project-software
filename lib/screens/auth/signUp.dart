import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/widgets/custom_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_provider/screens/auth/logIn.dart';
import 'package:flutter_provider/screens/auth/Title_Project.dart';
import 'package:flutter_provider/widgets/back_button.dart';
import 'package:flutter_provider/widgets/bezierContainer.dart';
import 'package:flutter_provider/screens/auth/divider_widget.dart';
import 'package:flutter_provider/screens/auth/register_label.dart';

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (width < 900) {
            return _buildMobileView(context, nameController, emailController,
                passwordController, phoneController, height, ref, _formKey);
          } else {
            return _buildDesktopView(
                context,
                nameController,
                emailController,
                passwordController,
                phoneController,
                height,
                width,
                ref,
                _formKey);
          }
        },
      ),
    );
  }

  Widget _buildMobileView(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController phoneController,
      double height,
      WidgetRef ref,
      GlobalKey<FormState> _formKey) {
    return Scaffold(
      body: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -height * 0.15,
              right: -MediaQuery.of(context).size.width * 0.4,
              child: BezierContainer(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey, // إضافة نموذج
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * 0.2),
                      TitlePro(),
                      SizedBox(height: 50),
                      CustomTextField(
                        label: "Full Name",
                        hint: "Enter your full name",
                        icon: Icons.person,
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: "Email",
                        hint: "Enter your email",
                        icon: Icons.email,
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                                  r"^[a-zA-Z0-9._%+-]+@[a-zAA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: "Password",
                        hint: "Enter your password",
                        icon: Icons.lock,
                        isPassword: true,
                        controller: passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: "Sign Up",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            handleSignUp(
                                context,
                                ref,
                                nameController,
                                emailController,
                                passwordController,
                                phoneController);
                          }
                        },
                        isGradient: true,
                      ),
                      const SizedBox(height: 20),
                      _loginAccountLabel(context),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(top: 40, left: 0, child: BackButtonWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController emailController,
      TextEditingController passwordController,
      TextEditingController phoneController,
      double height,
      double width,
      WidgetRef ref,
      GlobalKey<FormState> _formKey) {
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
                    key: _formKey, // إضافة نموذج هنا
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitlePro(),
                        SizedBox(height: 10),
                        CustomTextField(
                          label: "Full Name",
                          hint: "Enter your full name",
                          icon: Icons.person,
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          label: "Email Address",
                          hint: "Enter your email",
                          icon: Icons.email,
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                                    r"^[a-zA-Z0-9._%+-]+@[a-zAA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          label: "Phone Number",
                          hint: "Enter Phone Number",
                          icon: Icons.phone,
                          controller: phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          label: "Password",
                          hint: "Enter your password",
                          icon: Icons.lock,
                          isPassword: true,
                          controller: passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomButton(
                          text: "Sign Up",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              handleSignUp(
                                  context,
                                  ref,
                                  nameController,
                                  emailController,
                                  passwordController,
                                  phoneController);
                            }
                          },
                          isGradient: true,
                        ),
                        DividerWidget(),
                        LoginLabel(),
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

  Widget _loginAccountLabel(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text(
          "تسجيل الدخول",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void handleSignUp(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController phoneController,
  ) {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, "Please fill in all fields.");
      return;
    }

    final userData = {
      'name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'phoneNumber': phoneController.text,
    };

    try {
      final result = ref.read(registerUserProvider(userData).future);
      CustomSnackBar.showSuccessSnackBar(context, "Registration successful.");
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      CustomSnackBar.showErrorSnackBar(context, "Registration failed.");
    }
  }
}
