import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/employeeProvider.dart';
import 'package:flutter_provider/screens/Owner/Employee/employee_screen.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEmployeeScreen extends ConsumerStatefulWidget {
  const AddEmployeeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends ConsumerState<AddEmployeeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  Future<void> _submitEmployee() async {
    final userId = ref.watch(userIdProvider).value;
    if (!_formKey.currentState!.validate()) return;

    final newEmployee = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phoneNumber": phoneController.text.trim(),
      "salary": double.tryParse(salaryController.text.trim()) ?? 0.0,
    };

    try {
      await ref.read(addEmployeeProvider)(newEmployee, userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تمت إضافة الموظف بنجاح")),
      );
      Navigator.pop(context);
      ref.watch(employeesProvider(userId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ خطأ أثناء الإضافة: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة موظف'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                label: 'الاسم',
                controller: nameController,
                hint: 'أدخل اسم الموظف',
                icon: Icons.person,
                validator: (value) =>
                    value == null || value.isEmpty ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'البريد الإلكتروني',
                controller: emailController,
                hint: 'أدخل الإيميل',
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'الإيميل مطلوب' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'رقم الجوال',
                controller: phoneController,
                hint: 'أدخل رقم الجوال',
                icon: Icons.phone,
                inputType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'رقم الجوال مطلوب' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'الراتب',
                controller: salaryController,
                hint: 'أدخل الراتب',
                icon: Icons.monetization_on,
                inputType: TextInputType.number,
                validator: (value) {
                  final salary = double.tryParse(value ?? '');
                  if (salary == null || salary <= 0) {
                    return 'أدخل راتب صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitEmployee,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text('إضافة الموظف'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
