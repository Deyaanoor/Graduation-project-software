import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فحص رخصة القيادة',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LicenseChecker(),
    );
  }
}

class LicenseChecker extends StatefulWidget {
  @override
  _LicenseCheckerState createState() => _LicenseCheckerState();
}

class _LicenseCheckerState extends State<LicenseChecker> {
  Uint8List? _imageBytes;
  String? _result;
  bool _loading = false;

  Future<void> _pickAndCheckLicense() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _result = "🔄 جارٍ فحص الرخصة...";
        _loading = true;
      });

      try {
        // قراءة الصورة على الويب كـ Uint8List
        _imageBytes = await pickedFile.readAsBytes();
        final base64Image = base64Encode(_imageBytes!);

        // إرسال الطلب إلى Cloud Function
        final response = await http.post(
          Uri.parse(
              'https://your-cloud-function-url/checkLicense'), // ✅ عدّل هذا الرابط
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'imageBase64': base64Image}),
        );

        print("Status code: ${response.statusCode}");
        print("Response body: ${response.body}");

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final result = json['result'];
          if (result != null) {
            _result = "✅ الرخصة صالحة\n"
                "الاسم: ${result['name'] ?? 'غير معروف'}\n"
                "الدولة: ${result['country'] ?? 'غير معروف'}";
          } else {
            _result = "❌ الرخصة غير صالحة أو لم يتم التعرف عليها.";
          }
        } else {
          _result = "❌ فشل الفحص. الكود: ${response.statusCode}";
        }
      } catch (e) {
        _result = "❌ حدث خطأ: $e";
      }

      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildImageWidget() {
    if (kIsWeb && _imageBytes != null) {
      return Image.memory(_imageBytes!, height: 200);
    } else {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: Center(child: Text("لم يتم اختيار صورة")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("فحص رخصة القيادة")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildImageWidget(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickAndCheckLicense,
              icon: Icon(Icons.photo),
              label: Text("اختر صورة الرخصة"),
            ),
            const SizedBox(height: 20),
            if (_loading) CircularProgressIndicator(),
            if (_result != null && !_loading)
              Text(
                _result!,
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
