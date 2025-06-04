import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/contactUs.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactUsPage extends ConsumerStatefulWidget {
  const ContactUsPage({super.key});

  @override
  ConsumerState<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends ConsumerState<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();

  String? issueType; // اجعلها nullable

  final TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    final lang = ref.read(languageProvider);
    if (_formKey.currentState!.validate()) {
      final userId = ref.watch(userIdProvider).value;

      try {
        await ref.read(addContactMessageProvider)(
          userId: userId ?? '',
          type: issueType ?? '',
          message: messageController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang['messageSent'] ?? 'تم إرسال المشكلة بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        messageController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang['messageFailed'] ?? 'فشل في إرسال المشكلة'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    final List<String> issueTypes = [
      lang['appNotWorking'] ?? 'تطبيق لا يعمل',
      lang['paymentIssue'] ?? 'مشكلة في الدفع',
      lang['dataError'] ?? 'خطأ في البيانات',
      lang['featureSuggestion'] ?? 'اقتراح ميزة جديدة',
      lang['other'] ?? 'أخرى',
    ];

    // الحل: تأكد أن القيمة دائماً موجودة في القائمة
    if (issueType == null || !issueTypes.contains(issueType)) {
      issueType = issueTypes.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang['contactUs'] ?? "تواصل معنا",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                  labelText: lang['issueType'] ?? "نوع المشكلة",
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
                  labelText: lang['issueDescription'] ?? "وصف المشكلة",
                  prefixIcon: const Icon(Icons.message),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                validator: (value) => value!.isEmpty
                    ? (lang['enterMessage'] ?? 'يرجى كتابة الرسالة')
                    : null,
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
                label: Text(lang['send'] ?? "إرسال",
                    style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
