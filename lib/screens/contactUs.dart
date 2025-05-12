import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/contactUs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactUsPage extends ConsumerStatefulWidget {
  const ContactUsPage({super.key});

  @override
  ConsumerState<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends ConsumerState<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();

  String issueType = 'تطبيق لا يعمل';
  final List<String> issueTypes = [
    'تطبيق لا يعمل',
    'مشكلة في الدفع',
    'خطأ في البيانات',
    'اقتراح ميزة جديدة',
    'أخرى'
  ];

  final TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    if (_formKey.currentState!.validate()) {
      final userId = ref.watch(userIdProvider).value;

      try {
        await ref.read(addContactMessageProvider)(
          userId: userId ?? '',
          type: issueType,
          message: messageController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال المشكلة بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        messageController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إرسال المشكلة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تواصل معنا",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "نوع المشكلة",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                value: issueType,
                items: issueTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() {
                  issueType = value!;
                }),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "وصف المشكلة",
                  prefixIcon: const Icon(Icons.message),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'يرجى كتابة الرسالة' : null,
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.send),
                label: const Text("إرسال", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
