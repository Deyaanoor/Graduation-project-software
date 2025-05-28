import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://localhost:5000/request_register';

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
