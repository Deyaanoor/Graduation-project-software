import 'package:flutter/material.dart';

class TitlePro extends StatelessWidget {
  const TitlePro({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Mechanic',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xffe46b10)),
          children: [
            TextSpan(
              text: 'Workshop',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: '',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }
}
