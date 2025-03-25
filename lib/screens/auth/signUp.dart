import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/auth/Title_Project.dart';
import 'package:flutter_provider/screens/auth/divider_widget.dart';
import 'package:flutter_provider/screens/auth/logIn.dart';
import 'package:flutter_provider/screens/auth/register_label.dart';
import 'package:flutter_provider/widgets/back_button.dart';
import 'package:flutter_provider/widgets/bezierContainer.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if the screen is smaller than 900 (for mobile)
          if (width < 900) {
            return _buildMobileView(context, nameController, emailController,
                passwordController, height);
          } else {
            return _buildDesktopView(context, nameController, emailController,
                passwordController, height, width);
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
      double height) {
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
                    ),
                    CustomTextField(
                      label: "Email",
                      hint: "Enter your email",
                      icon: Icons.email,
                      controller: emailController,
                    ),
                    CustomTextField(
                      label: "Password",
                      hint: "Enter your password",
                      icon: Icons.lock,
                      isPassword: true,
                      controller: passwordController,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Sign Up",
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      isGradient: true,
                    ),
                    const SizedBox(height: 20),
                    _loginAccountLabel(context),
                  ],
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
      double height,
      double width) {
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
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        label: "Email Address",
                        hint: "Enter your email",
                        icon: Icons.email,
                        controller: emailController,
                      ),
                      SizedBox(height: 10),
                      CustomTextField(
                        label: "Password",
                        hint: "Enter your password",
                        icon: Icons.lock,
                        isPassword: true,
                        controller: passwordController,
                      ),
                      SizedBox(height: 20),
                      CustomButton(
                        text: "Sign Up",
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        isGradient: true,
                      ),
                      DividerWidget(),
                      RegisterLabel(),
                    ],
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
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 10),
            Text(
              'Login',
              style: TextStyle(
                color: Color(0xfff79c4f),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
