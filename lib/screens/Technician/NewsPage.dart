import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_provider/Responsive/Responsive_helper.dart';
import 'package:flutter_provider/providers/news_provider.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final newsAsync = ref.watch(newsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // الهيدر
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                const Icon(
                  Icons.new_releases_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  'الأخبار الفورية',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // قائمة الأخبار
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(newsProvider.notifier).refreshNews(),
              child: newsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.orange)),
                error: (error, _) => _buildErrorUI(error, ref),
                data: (newsItems) =>
                    _buildNewsList(context, screenWidth, newsItems),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء قائمة الأخبار
  Widget _buildNewsList(BuildContext context, double screenWidth,
      List<Map<String, dynamic>> newsItems) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: newsItems.length,
      itemBuilder: (context, index) =>
          _buildNewsCard(context, screenWidth, newsItems[index]),
    );
  }

  // بطاقة الخبر الواحد
  Widget _buildNewsCard(
      BuildContext context, double screenWidth, Map<String, dynamic> news) {
    return Center(
      child: SizedBox(
        width: ResponsiveHelper.isDesktop(context)
            ? screenWidth * 0.6
            : screenWidth * 0.9,
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          margin: const EdgeInsets.only(bottom: 20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الهيدر الداخلي (الرمز + الوقت)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.campaign, color: Colors.orange, size: 28),
                    Text(
                      _formatTime(news['time']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // العنوان
                Text(
                  news['title'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),

                // المحتوى
                Text(
                  news['content'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 15),

                // الخط الفاصل
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 10),

                // معلومات المرسل
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        color: Colors.orange, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'مرسل بواسطة: ${news['admin']}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // واجهة الخطأ
  Widget _buildErrorUI(dynamic error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(
            'حدث خطأ: ${error.toString()}',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => ref.refresh(newsProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // تنسيق الوقت
  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      return timeago.format(dateTime, locale: 'ar');
    } catch (e) {
      return 'وقت غير معروف';
    }
  }
}
