import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => NotificationsNotifier(),
);
final unreadCountStateProvider = StateProvider<int>((ref) => 0);

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  NotificationsNotifier() : super(const AsyncValue.loading());

  static String _baseUrl = '${dotenv.env['API_URL']}/notifications';
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
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

  Future<String?> sendNotification({
    required String adminId,
    required String senderName,
    String? reportId,
    String? newsId,
    String? newsTitle,
    String? messageTitle,
    String? newsbody,
    String? messageBody,
    String? garageId,
    String type = 'report',
  }) async {
    if (adminId.length != 24) {
      return null;
    }

    try {
      final Map<String, dynamic> body = {
        'adminId': adminId,
        'senderName': senderName,
        'type': type,
      };

      if (type == 'report') {
        body['reportId'] = reportId;
        body['newsbody'] = 'تقرير جديد من $senderName';
      } else if (type == 'news') {
        body['newsId'] = newsId;
        body['newsTitle'] = newsTitle;
        body['newsbody'] = newsbody;
      } else if (type == 'message') {
        body['messageTitle'] = messageTitle;
        body['messageBody'] = messageBody;
        body['garageId'] = garageId;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
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

  Future<void> fetchUnreadCount({
    required String adminId,
    required WidgetRef ref,
  }) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/count-unread/$adminId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final count = data['unreadCount'] ?? 0;
        _unreadCount = count;
        ref.read(unreadCountStateProvider.notifier).state = count;
      } else {
        throw Exception('فشل تحميل عدد الإشعارات غير المقروءة');
      }
    } catch (e) {
      print('❌ خطأ في جلب عدد الإشعارات: $e');
      _unreadCount = 0;
      ref.read(unreadCountStateProvider.notifier).state = 0;
    }
  }
}
