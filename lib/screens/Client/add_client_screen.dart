import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/clientProvider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
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
    final lang = ref.read(languageProvider);
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
        SnackBar(
            content:
                Text(lang['clientAdded'] ?? "✅ Client added successfully")),
      );
      Navigator.pop(context);
      ref.watch(clientsProvider(userId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "${lang['addClientError'] ?? "❌ Error adding client"}: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang['addClient'] ?? 'Add Client'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(
                label: lang['name'] ?? 'Name',
                controller: nameController,
                hint: lang['enterName'] ?? 'Enter name',
                icon: Icons.person,
                validator: (value) => value == null || value.isEmpty
                    ? (lang['nameRequired'] ?? 'Name is required')
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: lang['email'] ?? 'Email',
                controller: emailController,
                hint: lang['enterEmail'] ?? 'Enter email',
                icon: Icons.email,
                inputType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty
                    ? (lang['emailRequired'] ?? 'Email is required')
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: lang['phoneNumber'] ?? 'Phone Number',
                controller: phoneController,
                hint: lang['enterPhoneNumber'] ?? 'Enter phone number',
                icon: Icons.phone,
                inputType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? (lang['phoneRequired'] ?? 'Phone Number is required')
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitClient,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15)),
                child: Text(
                  lang['addClient'] ?? 'Add Client',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
