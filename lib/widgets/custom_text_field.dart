import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType? inputType;
  final Color? borderColor;
  final bool showBorder;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? Function(String?)? validator;

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
    this.validator,
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
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: inputType,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(icon, color: iconColor ?? Colors.orange)
                : null,
            enabledBorder: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: borderColor ?? Colors.orange,
                      width: 2,
                    ),
                  )
                : InputBorder.none,
            focusedBorder: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: borderColor ?? Colors.orange,
                      width: 2,
                    ),
                  )
                : InputBorder.none,
            errorBorder: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.red,
                      width: 2,
                    ),
                  )
                : InputBorder.none,
            focusedErrorBorder: showBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.red, // تغيير اللون عند التركيز ووجود خطأ
                      width: 2,
                    ),
                  )
                : InputBorder.none,
            fillColor: backgroundColor ?? const Color(0xfff3f3f4),
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
