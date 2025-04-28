import 'package:flutter/material.dart';

class GarageForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<TextEditingController> controllers;
  final VoidCallback onSubmit;
  final String buttonText;
  final bool isLoading;

  final Widget Function({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType,
    String? Function(String?)? validator,
  }) buildTextFormField;

  const GarageForm({
    required this.formKey,
    required this.controllers,
    required this.onSubmit,
    required this.buildTextFormField,
    required this.buttonText,
    this.isLoading = false, // ✅ مرر القيمة هنا
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          buildTextFormField(
            context: context,
            controller: controllers[0],
            label: 'اسم الجراج',
            icon: Icons.business,
            validator: (val) => val!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            context: context,
            controller: controllers[1],
            label: 'الموقع',
            icon: Icons.location_on,
            validator: (val) => val!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            context: context,
            controller: controllers[2],
            label: 'اسم المالك',
            icon: Icons.person,
            validator: (val) => val!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            context: context,
            controller: controllers[3],
            label: 'البريد الإلكتروني',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (val) =>
                !val!.contains('@') ? 'بريد إلكتروني غير صالح' : null,
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            context: context,
            controller: controllers[4],
            label: 'التكلفة',
            icon: Icons.numbers,
            keyboardType: TextInputType.number,
            validator: (val) => val!.isEmpty ? 'هذا الحقل مطلوب' : null,
          ),
          const SizedBox(height: 30),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator()) // ✅ صحح الاستخدام
              : ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(buttonText,
                      style: const TextStyle(color: Colors.white)),
                ),
        ],
      ),
    );
  }
}
