import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => NotificationsNotifier(),
);

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  NotificationsNotifier() : super(const AsyncValue.loading());

  static const String _baseUrl = 'http://localhost:5000/notifications';

  Future<void> fetchNotifications({required String adminId}) async {
    try {
      state = const AsyncValue.loading();
      final response = await http.get(Uri.parse('$_baseUrl/$adminId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> notifications =
            List<Map<String, dynamic>>.from(data['notifications'] ?? []);

        state = AsyncValue.data(notifications);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendNotification({
    required String adminId,
    required String reportId,
    required String senderName,
  }) async {
    if (adminId.length != 24) {
      print('❌ adminId is not a valid ObjectId: $adminId');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reportId': reportId,
          'adminId': adminId,
          'senderName': senderName,
        }),
      );

      if (response.statusCode == 201) {
        await sendFCMNotification(adminId, reportId, senderName);
      } else {
        throw Exception('Failed to send notification: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> sendFCMNotification(
      String adminId, String reportId, String senderName) async {
    try {
      String adminToken = await getAdminToken(adminId);

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=YOUR_SERVER_KEY',
        },
        body: jsonEncode({
          'to': adminToken,
          'notification': {
            'title': 'New Report Submitted',
            'body': 'A new report has been submitted by $senderName.',
          },
          'data': {
            'reportId': reportId,
            'senderName': senderName,
          },
        }),
      );

      if (response.statusCode == 200) {
        print("FCM notification sent successfully!");
      } else {
        print("Failed to send FCM notification: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to send FCM notification: $e");
    }
  }

  Future<String> getAdminToken(String adminId) async {
    return 'ADMIN_FCM_TOKEN';
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/read/$notificationId'),
      );

      if (response.statusCode == 200) {
      } else {
        throw Exception(
            'Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete/$notificationId'),
      );

      if (response.statusCode == 200) {
      } else {
        throw Exception(
            'Failed to delete notification: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  int getUnreadCount() {
    final currentState = state;
    if (currentState is AsyncData<List<Map<String, dynamic>>>) {
      return currentState.value
          .where((notification) => notification['isRead'] == false)
          .length;
    }
    return 0;
  }
}
