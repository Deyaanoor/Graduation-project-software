import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

String garageInfoUrl = '${dotenv.env['API_URL']}/user-garage/user';

final userGarageProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final response = await http.get(Uri.parse('$garageInfoUrl/$userId'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data as Map<String, dynamic>;
  } else {
    throw Exception('فشل في تحميل بيانات الجراج');
  }
});

final refreshsubProvider = Provider<void Function(WidgetRef)>((ref) {
  return (WidgetRef ref) {
    ref.invalidate(userGarageProvider);
  };
});
