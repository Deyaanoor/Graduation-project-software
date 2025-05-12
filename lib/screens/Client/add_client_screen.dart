import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/clientProvider.dart';
import 'package:flutter_provider/screens/Client/client_screen.dart';
import 'package:flutter_provider/widgets/custom_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddClientScreen extends ConsumerStatefulWidget {
  const AddClientScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends ConsumerState<AddClientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitClient() async {
    final userId = ref.watch(userIdProvider).value;
    if (!_formKey.currentState!.validate()) return;

    final newClient = {
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "phoneNumber": phoneController.text.trim(),
    };

    try {
      await ref.read(addClientProvider)(newClient, userId!);
      ref.invalidate(clientsProvider(userId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تمت إضافة  client")),
      );
      Navigator.pop(context);
      ref.watch(clientsProvider(userId));
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
        title: const Text('Add Client'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                label: 'Name',
                controller: nameController,
                hint: 'Enter name',
                icon: Icons.person,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                controller: emailController,
                hint: 'Enter email',
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone Number',
                controller: phoneController,
                hint: 'Enter phone number',
                icon: Icons.phone,
                inputType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Phone Number is required'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitClient,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text(
                  'Add Client',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
