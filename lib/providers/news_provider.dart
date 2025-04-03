import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final newsProvider = StateNotifierProvider.autoDispose<NewsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return NewsNotifier();
});

class NewsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  NewsNotifier() : super(const AsyncValue.loading()) {
    fetchNews();
  }

  final String _apiUrl = 'http://localhost:5000/news';

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

        state = AsyncValue.data(items);
      } else {
        throw Exception('فشل في جلب البيانات');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshNews() async => await fetchNews();
}
