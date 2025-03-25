import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon; // جعل الأيقونة اختيارية
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType? inputType;
  final Color? borderColor; // لون البوردر
  final bool showBorder; // عرض البوردر أو إخفائه
  final Color? backgroundColor; // لون خلفية النص
  final Color? iconColor; // لون الأيقونة

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.isPassword = false,
    required this.controller,
    this.inputType,
    this.borderColor,
    this.showBorder = true,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: iconColor ?? Colors.orange) // لون الأيقونة
                : null,
            enabledBorder: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: borderColor ?? Colors.orange, // لون البوردر
                      width: 2,
                    ),
                  )
                : InputBorder.none, // إخفاء البوردر
            focusedBorder: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color:
                          borderColor ?? Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                : InputBorder.none,
            fillColor:
                backgroundColor ?? const Color(0xfff3f3f4), // لون الخلفية
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }
}
