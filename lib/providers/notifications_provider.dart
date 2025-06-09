import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final String _baseUrl = '${dotenv.env['API_URL']}/notifications';

// بروفايدر الإشعارات
final notificationsProvider = StateNotifierProvider<NotificationsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => NotificationsNotifier(ref),
);

// بروفايدر عدد الإشعارات غير المقروءة (يُجلب تلقائيًا من السيرفر)
final unreadCountProvider =
    FutureProvider.family<int, String>((ref, adminId) async {
  final response = await http.get(Uri.parse('$_baseUrl/count-unread/$adminId'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['unreadCount'] ?? 0;
  } else {
    throw Exception('فشل تحميل عدد الإشعارات غير المقروءة');
  }
});

class NotificationsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final Ref ref;
  NotificationsNotifier(this.ref) : super(const AsyncValue.loading());

  // جلب الإشعارات
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

  // إرسال إشعار جديد
  Future<void> sendNotification({
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
    String? requestTitle,
  }) async {
    if (adminId.length != 24) return;
    try {
      final Map<String, dynamic> body = {
        'adminId': adminId,
        'senderName': senderName,
        'type': type,
      };
      if (type == 'report') {
        body['reportId'] = reportId;
        body['newsbody'] = 'New Report from $senderName';
      } else if (type == 'news') {
        body['newsId'] = newsId;
        body['newsTitle'] = newsTitle;
        body['newsbody'] = newsbody;
      } else if (type == 'message') {
        body['messageTitle'] = messageTitle;
        body['messageBody'] = messageBody;
        body['garageId'] = garageId;
      } else if (type == 'request') {
        body['requestTitle'] = 'New Request from $senderName';
      }
      final response = await http.post(
        Uri.parse('$_baseUrl/send-notification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      // بعد الإرسال، جلب الإشعارات وتحديث العدد
      await fetchNotifications(adminId: adminId);
      ref.invalidate(unreadCountProvider(adminId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // حذف إشعار
  Future<void> deleteNotification(String notificationId, String adminId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete/$notificationId'),
      );
      if (response.statusCode == 200) {
        await fetchNotifications(adminId: adminId);
        ref.invalidate(unreadCountProvider(adminId));
      } else {
        throw Exception(
            'Failed to delete notification: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  // تعليم إشعار كمقروء
  Future<void> markNotificationAsRead(
      String notificationId, String adminId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/read/$notificationId'),
      );
      if (response.statusCode == 200) {
        await fetchNotifications(adminId: adminId);
        ref.invalidate(unreadCountProvider(adminId));
      } else {
        throw Exception(
            'Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
