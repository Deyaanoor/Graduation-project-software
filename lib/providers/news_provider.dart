import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

const String _baseUrl = 'http://localhost:5000/news';
// http://localhost:5000/news/addNew
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
  NewsNotifier() : super(const AsyncValue.loading());

  Future<void> fetchNews({required String userId}) async {
    try {
      state = const AsyncValue.loading();
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final items = data.cast<Map<String, dynamic>>()
          ..sort((a, b) {
            final aTime = a['time'] ?? '1970-01-01T00:00:00Z';
            final bTime = b['time'] ?? '1970-01-01T00:00:00Z';

            try {
              return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
            } catch (e) {
              print('Error parsing date: $e');
              return 0;
            }
          });
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

  Future<void> refreshNews(String userId) async {
    try {
      await fetchNews(userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addNews({
    required String title,
    required String content,
    required String admin,
    required String userId,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await http.post(
        Uri.parse('$_baseUrl/addNew'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'content': content,
          'admin': admin,
          'userId': userId,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final newsId = responseBody['id'];
        return newsId;
      } else {
        throw Exception('Failed to add news: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateNews({
    required String newsId,
    required String title,
    required String content,
  }) async {
    try {
      state = const AsyncValue.loading();
      final response = await http.put(
        Uri.parse('$_baseUrl/update/$newsId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'content': content}),
      );
      log('response:$response');

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body.isNotEmpty &&
            (response.body.trim().startsWith('{') ||
                response.body.trim().startsWith('['))) {
          final updatedNews = jsonDecode(response.body);
          state.whenData((newsList) {
            final index = newsList.indexWhere((n) => n['_id'] == newsId);
            if (index != -1) {
              newsList[index] = updatedNews;
              state = AsyncValue.data([...newsList]);
            }
          });
        } else {
          log('Update successful but response is not JSON.');
        }
      } else {
        throw Exception(
            'Failed to update news with status code ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteNews(String newsId) async {
    try {
      state = const AsyncValue.loading();
      final response = await http.delete(Uri.parse('$_baseUrl/$newsId'));

      if (response.statusCode == 200) {
        state.whenData((newsList) {
          final newList = newsList.where((n) => n['_id'] != newsId).toList();
          state = AsyncValue.data(newList);
        });
      } else {
        throw Exception('Failed to delete news');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
