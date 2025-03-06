import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 🔹 مزود للـ API URL
final apiUrlProvider = Provider<String>((ref) {
  return dotenv.env['API_URL'] ?? "http://localhost:5000";
});

// 🔹 كلاس لحالة جلب المستخدمين
class UserNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final String apiUrl;
  UserNotifier(this.apiUrl) : super(const AsyncValue.loading()) {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/users'));

      if (response.statusCode == 200) {
        final users = json.decode(response.body);
        state = AsyncValue.data(users);
      } else {
        throw Exception("Failed to load users");
      }
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

// 🔹 مزود لحالة المستخدمين
final usersProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<List<dynamic>>>((ref) {
  final apiUrl = ref.watch(apiUrlProvider);
  return UserNotifier(apiUrl);
});
