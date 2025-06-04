import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/screens/Owner/AdminAnnouncementPage/adminAnnouncemen_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_provider/Responsive/Responsive_helper.dart';
import 'package:flutter_provider/providers/news_provider.dart';

// ...existing imports...

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

    final lang = ref.watch(languageProvider);

    if (userId != null && newsAsync.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(newsProvider.notifier).fetchNews(userId: userId);
      });
    }

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
                  lang['instantNews'] ?? 'الأخبار الفورية',
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
                if (userId != null) {
                  return ref
                      .read(newsProvider.notifier)
                      .fetchNews(userId: userId);
                }
                return Future.value();
              },
              child: newsAsync.when(
                loading: () => Center(
                    child: CircularProgressIndicator(color: Colors.orange)),
                error: (error, _) => _buildErrorUI(error, ref, lang),
                data: (newsItems) => newsItems.isEmpty
                    ? _buildEmptyState(lang)
                    : _buildNewsList(context, screenWidth, newsItems, userRole,
                        userId!, lang),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildNewsList(
  BuildContext context,
  double screenWidth,
  List<Map<String, dynamic>> newsItems,
  String userRole,
  String userId,
  Map<String, dynamic> lang,
) {
  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: newsItems.length,
    itemBuilder: (context, index) => _buildNewsCard(
        context, screenWidth, newsItems[index], userRole, userId, lang),
  );
}

Widget _buildNewsCard(
  BuildContext context,
  double screenWidth,
  Map<String, dynamic> news,
  String userRole,
  String userId,
  Map<String, dynamic> lang,
) {
  final title = news['title'] ?? (lang['noTitle'] ?? 'بدون عنوان');
  final content = news['content'] ?? (lang['noContent'] ?? 'لا يوجد محتوى');
  final admin = news['admin'] ?? (lang['unknownUser'] ?? 'مستخدم غير معروف');
  final time = news['time'] ?? '';

  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Center(
    child: SizedBox(
      width: ResponsiveHelper.isDesktop(context)
          ? screenWidth * 0.6
          : screenWidth * 0.9,
      child: Card(
        elevation: 2,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                          userId: userId,
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
                    Icon(
                      Icons.campaign,
                      color: theme.colorScheme.secondary,
                      size: 28,
                    ),
                    Text(
                      _formatTime(time, lang),
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 15),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: theme.colorScheme.secondary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${lang['sentBy'] ?? 'مرسل بواسطة'}: $admin',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.hintColor,
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

Widget _buildEmptyState(Map<String, dynamic> lang) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.article, size: 60, color: Colors.grey[400]),
        const SizedBox(height: 20),
        Text(
          lang['noNews'] ?? 'لا توجد أخبار متاحة حالياً',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorUI(dynamic error, WidgetRef ref, Map<String, dynamic> lang) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 10),
        Text(
          '${lang['errorOccurred'] ?? 'حدث خطأ'}: ${error.toString()}',
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
          child: Text(
            lang['retry'] ?? 'إعادة المحاولة',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

String _formatTime(String? time, Map<String, dynamic> lang) {
  if (time == null || time.isEmpty)
    return lang['unknownTime'] ?? 'وقت غير معروف';

  try {
    final dateTime = DateTime.parse(time);
    return timeago.format(dateTime, locale: 'ar');
  } catch (e) {
    return lang['unknownTime'] ?? 'وقت غير معروف';
  }
}
