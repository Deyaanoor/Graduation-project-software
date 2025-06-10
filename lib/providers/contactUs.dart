import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final baseUrl = '${dotenv.env['API_URL']}';
final contactMessagesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await http.get(Uri.parse('$baseUrl/contactMessages'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('فشل في جلب الرسائل');
  }
});
final addContactMessageProvider = Provider<
    Future<void> Function({
      required String userId,
      required String type,
      required String message,
    })>((ref) {
  return ({
    required String userId,
    required String type,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contactMessages/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'type': type,
        'message': message,
      }),
    );

    if (response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'فشل في إرسال الرسالة');
    }
  };
});
final updateContactMessageStatusProvider = Provider<
    Future<void> Function({
      required String messageId,
      required String status,
    })>((ref) {
  return ({
    required String messageId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/contactMessages/update/$messageId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'فشل في تحديث الحالة');
    }
  };
});
final deleteContactMessageProvider =
    Provider<Future<void> Function(String messageId)>((ref) {
  return (String messageId) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/contactMessages/delete/$messageId'));

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'فشل في حذف الرسالة');
    }
  };
});

final getcontactMessagesByIdProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final response =
      await http.get(Uri.parse('$baseUrl/contactMessages/user/$userId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('فشل في جلب الرسائل');
  }
});

final deletecontactMessagesByIdProvider =
    Provider.family<Future<void>, String>((ref, userId) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/contactMessages/delete/$userId'),
  );

  if (response.statusCode != 200) {
    final body = json.decode(response.body);
    throw Exception(body['message'] ?? 'فشل في حذف الرسائل');
  }
});
