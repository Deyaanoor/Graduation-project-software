import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  final bool hasShadow;
  final bool isGradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.blue,
    this.borderColor = Colors.transparent,
    this.hasShadow = true,
    this.isGradient = false, // Flag to switch between the two styles
  });

  @override
  Widget build(BuildContext context) {
    if (isGradient) {
      // Style similar to the second code (gradient button)
      return InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xfffbb448), Color(0xfff7892b)],
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      );
    } else {
      // Style similar to the first code (colored button with border and shadow)
      return InkWell(
        onTap: onPressed,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: borderColor, width: 2),
            color: backgroundColor,
            boxShadow: hasShadow
                ? [
                    BoxShadow(
                      color: backgroundColor.withAlpha(100),
                      offset: const Offset(2, 4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 20, color: textColor),
          ),
        ),
      );
    }
  }
}
