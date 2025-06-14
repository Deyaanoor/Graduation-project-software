import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final String apiBaseUrl = dotenv.env['API_URL'] ?? '';

// GET plan by name
final getPlanByNameProvider =
    FutureProvider.family<double, String>((ref, name) async {
  final url = Uri.parse('$apiBaseUrl/plans/plans/$name');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    return double.parse(response.body);
  } else {
    throw Exception('Failed to load plan price');
  }
});
// DELETE plan by ID
final deletePlanProvider = Provider<Future<void> Function(String id)>((ref) {
  return (String id) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/plans/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Failed to delete plan');
    }
  };
});

// Add a new plan
final addPlanProvider =
    Provider<Future<void> Function(String name, double price)>((ref) {
  return (String name, double price) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/plans/add');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'price': price}),
    );

    if (response.statusCode != 201) {
      throw Exception(
          jsonDecode(response.body)['message'] ?? 'Failed to add plan');
    }
  };
});

// Update plan price by name
final updatePlanProvider = Provider<Future<void> Function(String, double)>(
  (ref) {
    return (String name, double price) async {
      final url = Uri.parse('$apiBaseUrl/plans/plans/$name');
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'price': price}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update plan');
      }
    };
  },
);

final allPlansProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final url = Uri.parse('$apiBaseUrl/plans');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to fetch plans');
  }
});
