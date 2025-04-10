import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String apiUrl = 'http://localhost:5000/users';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('auth_token', token);
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
    .family<String, Map<String, String>>((ref, credentials) async {
  final response = await http.post(
    Uri.parse('$apiUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(credentials),
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    final token = responseData['token'];

    await saveToken(token);

    return token;
  } else {
    throw Exception('failed to login user');
  }
});

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
    throw Exception('failed to update avatar');
  }
});

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
    .family<void, Map<String, dynamic>>((ref, userData) async {
  final token = await getToken();

  if (token == null) {
    throw Exception('لا يوجد توكن');
  }

  final response = await http.put(
    Uri.parse('$apiUrl/update-user-info'),
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
    throw Exception(error['message'] ?? 'failed to update user info');
  }
});

String? extractUserIdFromToken(String token) {
  final parts = token.split('.');
  if (parts.length != 3) return null;

  final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
  final Map<String, dynamic> payloadMap = json.decode(payload);

  return payloadMap['userId'];
}
