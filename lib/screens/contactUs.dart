import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/admin_StaticProvider.dart';
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
  bool _isSending = false; // أضف هذا المتغير
  bool _sent = false;
  final TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    final lang = ref.read(languageProvider);
    if (_formKey.currentState!.validate()) {
      setState(() => _isSending = true);
      final userId = ref.watch(userIdProvider).value;

      try {
        await ref.read(addContactMessageProvider)(
          userId: userId ?? '',
          type: issueType ?? '',
          message: messageController.text,
        );
        ref.invalidate(getcontactMessagesByIdProvider(userId ?? ''));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang['messageSent'] ?? 'تم إرسال المشكلة بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        messageController.clear();
        setState(() {
          _sent = true;
        });
        // انتظر ثانية ثم أخفِ رسالة النجاح
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _sent = false;
        });
        // إذا تحتاج تحديث بيانات أخرى أضف هنا
        // ref.invalidate(staticAdminProvider);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang['messageFailed'] ?? 'فشل في إرسال المشكلة'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final userId = ref.watch(userIdProvider).value ?? '';

    final List<String> issueTypes = [
      lang['appNotWorking'] ?? 'تطبيق لا يعمل',
      lang['paymentIssue'] ?? 'مشكلة في الدفع',
      lang['dataError'] ?? 'خطأ في البيانات',
      lang['featureSuggestion'] ?? 'اقتراح ميزة جديدة',
      lang['other'] ?? 'أخرى',
    ];

    if (issueType == null || !issueTypes.contains(issueType)) {
      issueType = issueTypes.first;
    }

    final messagesAsyncValue =
        ref.watch(getcontactMessagesByIdProvider(userId));

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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
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
                  _sent
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 30),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            lang['messageSent'] ?? 'تم الإرسال',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: _isSending ? null : sendMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _isSending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _isSending
                                ? (lang['sending'] ?? "جاري الإرسال...")
                                : (lang['send'] ?? "إرسال"),
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              lang['previousMessages'] ?? 'الرسائل السابقة',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            messagesAsyncValue.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Text(lang['noMessages'] ?? 'لا توجد رسائل');
                }
                // إذا كان على موبايل، اعرض كـ Cards
                if (MediaQuery.of(context).size.width < 600) {
                  return Column(
                    children: messages.map<Widget>((msg) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.report_problem,
                              color: Colors.orange.shade700),
                          title: Text(
                            msg['type'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                  '${lang['message'] ?? 'الرسالة'}: ${msg['message'] ?? '-'}'),
                              const SizedBox(height: 4),
                              Text(
                                  '${lang['status'] ?? 'الحالة'}: ${msg['status'] ?? '-'}'),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                // إذا كان على شاشة كبيرة، اعرض جدول
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: 600,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowHeight: 48,
                      dataRowHeight: 48,
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(
                          label: Center(
                            child: Text(
                              lang['issueType'] ?? 'نوع المشكلة',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              lang['message'] ?? 'الرسالة',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              lang['status'] ?? 'الحالة',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                      rows: messages.map<DataRow>((msg) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Center(
                                child: Text(
                                  msg['type'] ?? '-',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  msg['message'] ?? '-',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  msg['status'] ?? '-',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Text(lang['fetchError'] ?? 'خطأ في جلب البيانات: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
