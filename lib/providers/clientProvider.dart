import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

String apiUrl = '${dotenv.env['API_URL']}/clients';

final clientsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, ownerId) async {
  final response = await http.get(Uri.parse('$apiUrl?owner_id=$ownerId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load clients');
  }
});
// ✅ Add Client
final addClientProvider =
    Provider((ref) => (Map<String, dynamic> newClient, String ownerId) async {
          final response = await http.post(
            Uri.parse('$apiUrl/add-client?owner_id=$ownerId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(newClient),
          );

          if (response.statusCode != 201 && response.statusCode != 200) {
            throw Exception('Failed to add client');
          }
        });

// ✅ Delete Client
final deleteClientProvider =
    Provider((ref) => (String email, String ownerId) async {
          final response = await http.delete(
            Uri.parse('$apiUrl/client/$email?owner_id=$ownerId'),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to delete client');
          }
        });

final clientGaragesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, clientId) async {
  final response =
      await http.get(Uri.parse('$apiUrl/client-garages/$clientId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load garages');
  }
});
