import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String apiUrl = 'http://localhost:5000/users';
final avatarFileProvider = StateProvider<File?>((ref) => null);

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
  print("Token saved: $token");
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}

final registerUserProvider = FutureProvider.autoDispose
    .family<String, Map<String, String>>((ref, userData) async {
  final response = await http.post(
    Uri.parse('$apiUrl/register'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(userData),
  );

  if (response.statusCode == 201) {
    return 'created';
  } else {
    throw Exception('failed to register user');
  }
});

final loginUserProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, String>>(
        (ref, credentials) async {
  final response = await http.post(
    Uri.parse('$apiUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(credentials),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    final token = responseData['token'];
    final role = responseData['role'];

    await saveToken(token);

    return {
      'token': token,
      'role': role,
    };
  } else {
    throw Exception('failed to login user');
  }
});

final forgotPasswordProvider =
    FutureProvider.autoDispose.family<String, String>((ref, email) async {
  final response = await http.post(
    Uri.parse('$apiUrl/forgot-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  if (response.statusCode == 200) {
    return 'Password reset link sent successfully';
  } else {
    throw Exception('Failed to send password reset link');
  }
});

Future<void> updateAvatar({
  required String userId,
  required dynamic imageFile,
  required bool isWeb,
}) async {
  try {
    final uri = Uri.parse('$apiUrl/updateAvatar/$userId');
    final request = http.MultipartRequest('PUT', uri);

    if (isWeb) {
      request.files.add(http.MultipartFile.fromBytes(
        'avatar',
        imageFile,
        filename: 'avatar.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('فشل في رفع الصورة: $responseData');
    }
  } catch (e) {
    throw Exception('خطأ أثناء رفع الصورة: $e');
  }
}

Future<void> refreshAvatar({
  required String userId,
  required dynamic imageFile,
  required bool isWeb,
  required Function onSuccess,
  required Function onError,
}) async {
  try {
    await updateAvatar(
      userId: userId,
      imageFile: imageFile,
      isWeb: isWeb,
    );

    onSuccess();
  } catch (e) {
    onError(e);
  }
}

final getUserInfoProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, userId) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('no token found');
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
    throw Exception('failed to fetch user info');
  }
});

final updateUserInfoProvider = FutureProvider.autoDispose
    .family<void, Map<String, dynamic>>((ref, originalUserData) async {
  final token = await getToken();
  if (token == null) {
    throw Exception('لا يوجد توكن');
  }

  final userData = Map<String, dynamic>.from(originalUserData);
  final userId = userData.remove('userId');

  if (userId == null) {
    throw Exception('لا يوجد userId');
  }

  final response = await http.put(
    Uri.parse('$apiUrl/update-user-info/$userId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode(userData),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    final error = json.decode(response.body);
    throw Exception(error['message'] ?? 'فشل في التحديث');
  }
});

String? extractUserIdFromToken(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;

  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final Map<String, dynamic> payloadMap = json.decode(payload);

  return payloadMap['userId'];
}

final userIdProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  print('Retrieved token: $token');
  if (token != null) {
    final userId = extractUserIdFromToken(token);
    print('Extracted userId: $userId');
    return userId;
  }
  return null;
});

final logoutProvider = Provider((ref) => () async {
      await removeToken();
      ref.refresh(userIdProvider); // إعادة تحميل التوكن الجديد بعد logout
    });

Future<void> removeToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  print("Token removed");
}
