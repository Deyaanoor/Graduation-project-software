import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // إضافة shared_preferences

const String apiUrl = 'http://localhost:5000/users';

// دالة لحفظ التوكن في SharedPreferences
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('auth_token', token); // حفظ التوكن
}

// دالة لاسترجاع التوكن من SharedPreferences
Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token'); // استرجاع التوكن
}

// بروفايدر تسجيل المستخدم
final registerUserProvider = FutureProvider.autoDispose
    .family<String, Map<String, String>>((ref, userData) async {
  final response = await http.post(
    Uri.parse('$apiUrl/register'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(userData),
  );

  if (response.statusCode == 201) {
    return 'تم الإنشاء بنجاح';
  } else {
    throw Exception('فشل في إنشاء المستخدم');
  }
});

// بروفايدر تسجيل الدخول
final loginUserProvider = FutureProvider.autoDispose
    .family<String, Map<String, String>>((ref, credentials) async {
  final response = await http.post(
    Uri.parse('$apiUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(credentials),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    final token = responseData['token'];

    // حفظ التوكن في SharedPreferences
    await saveToken(token);

    return token; // إرجاع التوكن
  } else {
    throw Exception('فشل في تسجيل الدخول');
  }
});

// بروفايدر تحديث الصورة الشخصية
final updateAvatarProvider = FutureProvider.autoDispose
    .family<String, Map<String, String>>((ref, avatarData) async {
  final response = await http.post(
    Uri.parse('$apiUrl/update-avatar'),
    body: avatarData,
    headers: {'Content-Type': 'multipart/form-data'},
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    return responseData['avatarUrl'];
  } else {
    throw Exception('فشل في تحديث الصورة');
  }
});

final getUserInfoProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, userId) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('لا يوجد توكن');
  }

  final response = await http.get(
    Uri.parse('$apiUrl/get-user-info/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    return responseData;
  } else {
    print('❌ Response error: ${response.statusCode}, ${response.body}');
    throw Exception('فشل في جلب معلومات المستخدم');
  }
});

// بروفايدر تحديث معلومات المستخدم (اسم، كلمة مرور، رقم هاتف)
final updateUserInfoProvider = FutureProvider.autoDispose
    .family<String, Map<String, String>>((ref, updateData) async {
  final token = await getToken(); // جلب التوكن من SharedPreferences
  if (token == null) {
    throw Exception('لا يوجد توكن');
  }

  final response = await http.put(
    Uri.parse('$apiUrl/update-user-info'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // إرسال التوكن هنا
    },
    body: json.encode(updateData),
  );

  if (response.statusCode == 200) {
    return 'تم تحديث المعلومات بنجاح';
  } else {
    throw Exception('فشل في تحديث معلومات المستخدم');
  }
});

String? extractUserIdFromToken(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;

  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final Map<String, dynamic> payloadMap = json.decode(payload);

  return payloadMap['userId'];
}
