import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

String apiUrl = '${dotenv.env['API_URL']}/requests';

final requestsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, garageId) async {
  final response = await http.get(Uri.parse('$apiUrl/$garageId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load requests');
  }
});

// ✅ Add Request
final addRequestProvider =
    Provider((ref) => (Map<String, dynamic> newRequest) async {
          final response = await http.post(
            Uri.parse('$apiUrl/add-request'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(newRequest),
          );

          if (response.statusCode != 201 && response.statusCode != 200) {
            throw Exception('Failed to add request');
          }
        });

// ✅Get Requests
final getRequestsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, ownerId) async {
  final response = await http.get(Uri.parse('$apiUrl/$ownerId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load requests');
  }
});
// ✅ Get Requests by User and Garage ID
final requestsByUserAndGarageProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, ({String userId, String garageId})>(
  (ref, params) async {
    try {
      print('User ID: ${params.userId}');
      print('Garage ID: ${params.garageId}');
      final response = await http.get(
        Uri.parse('$apiUrl/${params.userId}/${params.garageId}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];

        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load requests: $e');
    }
  },
);

// ✅ Get Request by ID
final getRequestByIdProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, requestId) async {
  final response = await http.get(Uri.parse('$apiUrl/request/$requestId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load request');
  }
});

// ✅ Update Request Status
final updateRequestStatusProvider =
    Provider((ref) => (String requestId, String status) async {
          final response = await http.put(
            Uri.parse('$apiUrl/update-status/$requestId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'status': status}),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to update request status');
          }
        });
final addMessageToRequestProvider = Provider(
    (ref) => (String requestId, Map<String, dynamic> messageData) async {
          final response = await http.post(
            Uri.parse('$apiUrl/requests/$requestId/messages'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(messageData),
          );

          if (response.statusCode != 200) {
            throw Exception('❌ Failed to add message');
          }
        });

// ✅ Delete Request
final deleteRequestProvider = Provider(
  (ref) => (String requestId) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/requests/$requestId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('❌ Failed to delete request');
    }
  },
);

final messagesStreamProvider = StreamProvider.family<List<dynamic>, String>(
    (ref, String requestId) async* {
  while (true) {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/requests/$requestId/messages'),
      );

      if (response.statusCode == 200) {
        final messages = json.decode(response.body) as List;
        yield messages;
      } else {
        throw Exception('❌ Failed to fetch messages');
      }
    } catch (e) {
      print('❌ Error in stream: $e');
      yield [];
    }

    // انتظر ثانية أو ثانيتين قبل إعادة الجلب
    await Future.delayed(const Duration(seconds: 2));
  }
});
