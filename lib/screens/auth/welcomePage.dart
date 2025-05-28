// ignore: file_names
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/auth/Title_Project.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (width < 800) {
      return _buildMobileView(context, height);
    } else {
      return _buildWebView(context, height, width);
    }
  }

  // تصميم الموبايل
  Widget _buildMobileView(BuildContext context, double height) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFA726),
                    Color(0xFFFB8C00)
                  ])), // تدرج برتقالي
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TitlePro(),
              const SizedBox(height: 80),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                backgroundColor: Colors.white,
                textColor: Color(0xFFFB8C00), // لون برتقالي
                borderColor: Colors.transparent,
                hasShadow: true,
                isGradient: false,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Register now',
                onPressed: () {
                  Navigator.pushNamed(context, "/signup");
                },
                backgroundColor:
                    Color(0xFFFB8C00).withOpacity(0.8), // لون برتقالي شفاف
                textColor: Colors.white,
                borderColor: Colors.white,
                hasShadow: true,
                isGradient: false,
              ),
              const SizedBox(height: 20),
              _label()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebView(BuildContext context, double height, double width) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(context),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildLeftPanel(context),
              ),
              Expanded(
                flex: 6,
                child: _buildRightPanel(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFA726),
            Color(0xFFFB8C00),
          ],
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(color: Colors.black.withOpacity(0.1)),
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWelcomeText(),
          SizedBox(height: 30),
          Column(
            children: [
              CustomButton(
                text: 'Login',
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                backgroundColor: Colors.white,
                textColor: Color(0xFFFB8C00),
                borderColor: Colors.transparent,
                hasShadow: true,
                isGradient: false,
              ),
              SizedBox(height: 20),
              CustomButton(
                text: 'Register now',
                onPressed: () {
                  Navigator.pushNamed(context, "/signup");
                },
                backgroundColor:
                    Color(0xFFFB8C00).withOpacity(0.8), // لون برتقالي شفاف
                textColor: Colors.white,
                borderColor: Colors.white,
                hasShadow: true,
                isGradient: false,
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        Text(
          'Mechanic Workshop',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade400,
            height: 1.1,
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Manage and streamline your mechanic workshop efficiently\n'
          'with our powerful management application.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40),
        bottomLeft: Radius.circular(40),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
          image: DecorationImage(
            image: NetworkImage(
              'https://i.postimg.cc/3wy0RfzK/Management-Application-for-Mechanic-Workshop-removebg-preview.png',
            ),
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _label() {
    return Container(
      margin: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: <Widget>[
          const Text(
            'Smart Solutions for Your Workshop',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          const SizedBox(height: 20),
          Image.network(
            'https://i.postimg.cc/prZL3jYb/edit-the-uploaded-image-to-make-it-suitable-for-an-app-icon-removebg-preview.png',
            height: 180,
            width: 160,
          ),
        ],
      ),
    );
  }
}
