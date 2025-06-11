import 'package:flutter/material.dart';

class TitlePro extends StatelessWidget {
  const TitlePro({super.key});

  @override
  Widget build(BuildContext context) {
    final onBackground = Theme.of(context).colorScheme.onBackground;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Mechanic',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: const Color(0xffe46b10),
        ),
        children: [
          TextSpan(
            text: 'Workshop',
            style: TextStyle(
              color: onBackground,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }
}
