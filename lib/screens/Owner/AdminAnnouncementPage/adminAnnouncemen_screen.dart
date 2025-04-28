import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/widgets/top_snackbar.dart';

class AdminAnnouncementPage extends StatefulWidget {
  const AdminAnnouncementPage({Key? key}) : super(key: key);

  @override
  State<AdminAnnouncementPage> createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String selectedEmployee = "إرسال للجميع";

  final List<String> employees = [
    "إرسال للجميع",
    "عمر",
    "سامي",
    "ليلى",
    "خالد",
  ];

  void sendAnnouncement() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      TopSnackBar.show(
        context: context,
        title: "خطأ",
        message: "الرجاء تعبئة جميع الحقول",
        icon: Icons.warning,
        color: Colors.orange,
      );
      return;
    }

    String target = selectedEmployee == "إرسال للجميع"
        ? "جميع الموظفين"
        : "الموظف $selectedEmployee";

    // إضافة الإعلان في قاعدة البيانات أو API هنا

    TopSnackBar.show(
      context: context,
      title: "تم الإرسال",
      message: "تم إرسال الإعلان إلى $target",
      icon: Icons.check_circle,
      color: Colors.green,
    );

    _titleController.clear();
    _messageController.clear();
    setState(() {
      selectedEmployee = "إرسال للجميع";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "إرسال إعلان جديد",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الإعلان',
                  prefixIcon: Icon(Icons.title, color: Colors.orange),
                  hintText: 'اكتب عنوان الإعلان...',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.orange.shade200, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'محتوى الرسالة',
                  prefixIcon: Icon(Icons.message, color: Colors.orange),
                  hintText: 'اكتب تفاصيل الإعلان...',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.orange.shade200, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedEmployee,
                decoration: InputDecoration(
                  labelText: "اختر الموظف",
                  prefixIcon: Icon(Icons.person, color: Colors.orange),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.orange.shade200, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: employees.map((String name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEmployee = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: sendAnnouncement,
                icon: Icon(Icons.send),
                label: Text("إرسال"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // البرتقالي
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
