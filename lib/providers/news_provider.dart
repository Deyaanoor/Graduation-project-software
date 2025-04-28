import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String _apiUrl = 'http://localhost:5000/news';

final newsProvider = StateNotifierProvider.autoDispose<NewsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final link = ref.keepAlive();
  final notifier = NewsNotifier();

  ref.onDispose(() {
    link.close();
  });

  return notifier;
});

class NewsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  NewsNotifier() : super(const AsyncValue.loading()) {
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final items = data.cast<Map<String, dynamic>>()
          ..sort((a, b) =>
              DateTime.parse(b['time']).compareTo(DateTime.parse(a['time'])));

        if (mounted) {
          state = AsyncValue.data(items);
        }
      } else {
        throw Exception('فشل في جلب البيانات من السيرفر');
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> refreshNews() async => await fetchNews();
}
