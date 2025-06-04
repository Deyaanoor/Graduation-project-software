import 'package:flutter/material.dart';

class GarageForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<TextEditingController> controllers;
  final VoidCallback onSubmit;
  final String buttonText;
  final bool isLoading;
  final Map<String, String> lang;

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
    required this.lang,
    this.isLoading = false,
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
            label: lang['garageName'] ?? 'اسم الجراج',
            icon: Icons.business,
            validator: (val) => val!.isEmpty
                ? (lang['fieldRequired'] ?? 'هذا الحقل مطلوب')
                : null,
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            context: context,
            controller: controllers[1],
            label: lang['location'] ?? 'الموقع',
            icon: Icons.location_on,
            validator: (val) => val!.isEmpty
                ? (lang['fieldRequired'] ?? 'هذا الحقل مطلوب')
                : null,
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            context: context,
            controller: controllers[2],
            label: lang['ownerName'] ?? 'اسم المالك',
            icon: Icons.person,
            validator: (val) => val!.isEmpty
                ? (lang['fieldRequired'] ?? 'هذا الحقل مطلوب')
                : null,
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            context: context,
            controller: controllers[3],
            label: lang['ownerEmail'] ?? 'البريد الإلكتروني',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (val) => !val!.contains('@')
                ? (lang['invalidEmail'] ?? 'بريد إلكتروني غير صالح')
                : null,
          ),
          const SizedBox(height: 20),
          buildTextFormField(
            context: context,
            controller: controllers[4],
            label: lang['cost'] ?? 'التكلفة',
            icon: Icons.numbers,
            keyboardType: TextInputType.number,
            validator: (val) => val!.isEmpty
                ? (lang['fieldRequired'] ?? 'هذا الحقل مطلوب')
                : null,
          ),
          const SizedBox(height: 30),
          isLoading
              ? const Center(child: CircularProgressIndicator())
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
