import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final String baseUrl = '${dotenv.env['API_URL']}/subscription';

final activateGarageSubscriptionProvider =
    FutureProvider.family<void, ActivateSubscriptionParams>(
        (ref, params) async {
  final url = Uri.parse('$baseUrl/activate/${params.userId}');
  final response = await http.patch(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'subscriptionType': params.subscriptionType}),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('فشل في تفعيل الاشتراك: ${response.body}');
  }
});

class ActivateSubscriptionParams {
  final String userId;
  final String subscriptionType;

  ActivateSubscriptionParams(
      {required this.userId, required this.subscriptionType});
}

final refreshsubProvider = Provider<void Function(WidgetRef)>((ref) {
  return (WidgetRef ref) {
    ref.invalidate(activateGarageSubscriptionProvider);
  };
});
