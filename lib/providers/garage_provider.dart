import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

String baseUrl = '${dotenv.env['API_URL']}/garages';

// ✅ Get All Garages
final garagesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await http.get(Uri.parse(baseUrl));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load garages');
  }
});
// ✅ Add Garage (POST)
final addGarageProvider = Provider<
    Future<void> Function(
        {required String name,
        required String location,
        required String ownerName,
        required String ownerEmail,
        required String cost})>((ref) {
  return (
      {required String name,
      required String location,
      required String ownerName,
      required String ownerEmail,
      required String cost}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'location': location,
        'ownerName': ownerName,
        'ownerEmail': ownerEmail,
        'cost': cost,
      }),
    );

    if (response.statusCode != 201) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to add garage');
    }
  };
});

// ✅ Get Garage by ID
final garageByIdProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, id) async {
  final response = await http.get(Uri.parse('$baseUrl/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to fetch garage with ID $id');
  }
});

// ✅ Delete Garage by ID
final deleteGarageProvider = Provider<Future<void> Function(String)>((ref) {
  return (String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to delete garage');
    }
  };
});

// ✅ Update Garage by ID
final updateGarageProvider = Provider<
    Future<void> Function({
      required String id,
      required String name,
      required String location,
      required String ownerName,
      required String ownerEmail,
      required String cost,
    })>((ref) {
  return ({
    required String id,
    required String name,
    required String location,
    required String ownerName,
    required String ownerEmail,
    required String cost,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'location': location,
        'ownerName': ownerName,
        'ownerEmail': ownerEmail,
        'cost': cost,
      }),
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to update garage');
    }
  };
});

// To use this function, pass the WidgetRef as an argument.
Future<void> updateGarageStatus(String garageId, String newStatus) async {
  final response = await http.put(
    Uri.parse('$baseUrl/$garageId/status'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'status': newStatus}),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to update garage status');
  }
}

// ✅ Refresh Garages
final refreshGaragesProvider = Provider<void Function(WidgetRef)>((ref) {
  return (WidgetRef ref) {
    ref.invalidate(garagesProvider);
  };
});

// ✅ Provider for Garage Locations
final garageLocationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final response = await http.get(Uri.parse('$baseUrl/locations'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to fetch garage locations');
  }
});

// ✅ Get Garage Info by User ID
final garageInfoByUserIdProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, String>((ref, userId) async {
  final response = await http.get(Uri.parse('$baseUrl/garage/info/$userId'));

  if (response.statusCode == 200) {
    return json.decode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Failed to fetch garage info for user ID $userId');
  }
});

final garageIdProvider = StateProvider<String?>((ref) => null);

final getGarageIdProvider =
    FutureProvider.family<String, String>((ref, userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/garage/$userId'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['garage_id'] as String;
  } else {
    throw Exception('Failed to fetch garage ID');
  }
});
