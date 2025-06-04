import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String _apiUrl = '${dotenv.env['API_URL']}/admin_dashboard_stats';
/* http://localhost:5000*/
// final String _apiUrl = 'http://localhost:5000/admin_dashboard_stats';

final staticAdminProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final response = await http.get(
    Uri.parse('$_apiUrl/dashboard-stats'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
  } else {
    throw Exception('فشل تحميل بيانات لوحة التحكم');
  }
});
