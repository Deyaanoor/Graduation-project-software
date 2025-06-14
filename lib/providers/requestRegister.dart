import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final String apiUrl = '${dotenv.env['API_URL']}/request_register';

final applyGarageProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, garageData) async {
  final response = await http.post(
    Uri.parse('$apiUrl/add_request'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(garageData),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to apply: ${response.body}');
  }
});

final getAllRequestsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await http.get(Uri.parse('$apiUrl/'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body)['requests'] as List;
    return data.map((request) => request as Map<String, dynamic>).toList();
  } else {
    throw Exception('فشل في جلب طلبات التسجيل');
  }
});
final existRequestProvider = Provider(
  (ref) => (String email) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/status/$email'));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed data: $data');
        return data['statusPending'] == true;
      } else if (response.statusCode == 404) {
        // User not found, so no pending request
        return false;
      } else {
        throw Exception('فشل في التحقق من وجود طلب قيد الانتظار');
      }
    } catch (e) {
      print('Error checking request status: $e');
      return false;
    }
  },
);
