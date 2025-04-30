import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/screens/Owner/AdminAnnouncementPage/adminAnnouncemen_screen.dart';
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
    final userId = ref.watch(userIdProvider).value;
    final userInfo =
        userId != null ? ref.watch(getUserInfoProvider(userId)).value : null;
    final userRole =
        userInfo != null ? userInfo['role'] ?? 'بدون اسم' : 'جاري التحميل...';
    bool isUpdate = false;

    return Scaffold(
      floatingActionButton: userRole == 'owner'
          ? FloatingActionButton(
              onPressed: () {
                if (ResponsiveHelper.isDesktop(context)) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 600,
                          child: AdminAnnouncementPage(
                            userId: userId,
                            isUpdate: isUpdate,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminAnnouncementPage(
                        userId: userId,
                        isUpdate: isUpdate,
                      ),
                    ),
                  );
                }
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.add),
            )
          : null,
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                // تحقق من وجود userId قبل التحديث
                if (userId != null) {
                  return ref.read(newsProvider.notifier).refreshNews(userId);
                }
                return Future.value(); // لا تفعل شيئا إذا كان userId فارغًا
              },
              child: newsAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.orange)),
                error: (error, _) => _buildErrorUI(error, ref),
                data: (newsItems) => newsItems.isEmpty
                    ? _buildEmptyState() // حالة عدم وجود أخبار
                    : _buildNewsList(
                        context, screenWidth, newsItems, userRole, userId!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, double screenWidth,
      List<Map<String, dynamic>> newsItems, String userRole, String userId) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: newsItems.length,
      itemBuilder: (context, index) => _buildNewsCard(
          context, screenWidth, newsItems[index], userRole, userId),
    );
  }

  Widget _buildNewsCard(BuildContext context, double screenWidth,
      Map<String, dynamic> news, String userRole, String userId) {
    // استخدام القيم الافتراضية للحقول الفارغة
    final title = news['title'] ?? 'بدون عنوان';
    final content = news['content'] ?? 'لا يوجد محتوى';
    final admin = news['admin'] ?? 'مستخدم غير معروف';
    final time = news['time'] ?? '';

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
          child: InkWell(
            onTap: () {
              if (userRole == 'owner') {
                if (ResponsiveHelper.isDesktop(context)) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 600,
                          child: AdminAnnouncementPage(
                            isUpdate: true,
                            news: news,
                            userId:
                                userId, // Pass userId as a named argument if supported
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminAnnouncementPage(
                        isUpdate: true,
                        news: news,
                        userId: userId,
                      ),
                    ),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.campaign,
                          color: Colors.orange, size: 28),
                      Text(
                        _formatTime(time), // وقت مضمون
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Divider(color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          color: Colors.orange, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'مرسل بواسطة: $admin',
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.article, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'لا توجد أخبار متاحة حالياً',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

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

  String _formatTime(String? time) {
    // دعم القيم الفارغة
    if (time == null || time.isEmpty) return 'وقت غير معروف';

    try {
      final dateTime = DateTime.parse(time);
      return timeago.format(dateTime, locale: 'ar');
    } catch (e) {
      return 'وقت غير معروف';
    }
  }
}
