import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/notifications_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_provider/screens/Technician/reports/ReportDetailsPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy hh:mm a').format(date);
    } catch (_) {
      return 'تاريخ غير معروف';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIdAsync = ref.watch(userIdProvider);
    final lang = ref.watch(languageProvider);

    userIdAsync.when(
      data: (userId) {
        if (userId != null) {
          // ✅ استدعِ جلب الإشعارات إذا لم تكن محملة
          final notificationsAsync = ref.watch(notificationsProvider);
          if (notificationsAsync is AsyncLoading) {
            // جلب الإشعارات مرة واحدة فقط عند أول تحميل
            Future.microtask(() {
              ref
                  .read(notificationsProvider.notifier)
                  .fetchNotifications(adminId: userId);
            });
          }
        }
      },
      loading: () {},
      error: (err, stack) {},
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(lang['notifications'] ?? 'الإشعارات'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final userId = ref.read(userIdProvider);
              userId.when(
                data: (userId) {
                  if (userId != null) {
                    ref
                        .read(notificationsProvider.notifier)
                        .fetchNotifications(adminId: userId);
                  }
                },
                loading: () {},
                error: (error, stack) {},
              );
            },
          ),
        ],
      ),
      body: userIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child: Text(
                '${lang['errorLoadingUserId'] ?? 'Error loading user ID'}')),
        data: (userId) {
          if (userId == null) {
            return Center(
                child: Text(
                    lang['pleaseLoginFirst'] ?? 'يرجى تسجيل الدخول أولاً'));
          }

          final notificationsAsync = ref.watch(notificationsProvider);

          return notificationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('${lang['error'] ?? 'حدث خطأ'}: $error')),
            data: (notifications) {
              if (notifications.isEmpty) {
                return Center(
                    child: Text(lang['noNotifications'] ??
                        'لا توجد إشعارات حالياً 💤'));
              }

              notifications.sort((a, b) {
                final dateA =
                    DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(2000);
                final dateB =
                    DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(2000);
                return dateB.compareTo(dateA);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['isRead'] == true;

                  final card = Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    color: isRead ? Colors.grey.shade300 : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: notification['type'] == 'report'
                            ? Colors.blue
                            : notification['type'] == 'message'
                                ? Colors.green
                                : notification['type'] == 'request'
                                    ? const Color(
                                        0xFFFF7043) // برتقالي مائل للأحمر
                                    : const Color(0xFFFFA726),
                        child: Icon(
                          notification['type'] == 'report'
                              ? Icons.assignment
                              : notification['type'] == 'message'
                                  ? Icons.message
                                  : notification['type'] == 'request'
                                      ? Icons
                                          .assignment_ind // أيقونة مناسبة للطلبات
                                      : Icons.article,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        notification['title'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            notification['body'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(notification['timestamp']),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isRead)
                            const Icon(
                              Icons.circle,
                              color: Colors.blue,
                              size: 10,
                            ),
                          if (ResponsiveHelper.isMobile(context))
                            Dismissible(
                              key: Key(notification['_id']),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                        lang['confirmDelete'] ?? "تأكيد الحذف"),
                                    content: Text(
                                        lang['deleteNotificationMsg'] ??
                                            "هل تريد حذف هذا الإشعار؟"),
                                    actions: [
                                      TextButton(
                                        child: Text(lang['cancel'] ?? "إلغاء"),
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                      ),
                                      TextButton(
                                        child: Text(lang['delete'] ?? "حذف"),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await ref
                                      .read(notificationsProvider.notifier)
                                      .deleteNotification(
                                          notification['_id'], userId);

                                  ref
                                      .read(notificationsProvider.notifier)
                                      .fetchNotifications(adminId: userId);
                                }

                                return confirmed ?? false;
                              },
                              child: const SizedBox(),
                            ),
                          if (ResponsiveHelper.isDesktop(context))
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await ref
                                    .read(notificationsProvider.notifier)
                                    .deleteNotification(
                                        notification['_id'], userId);

                                ref
                                    .read(notificationsProvider.notifier)
                                    .fetchNotifications(adminId: userId);
                              },
                            ),
                        ],
                      ),
                      onTap: () async {
                        final reportId = notification['reportId'];
                        final newsId = notification['newsId'];
                        if (!isRead) {
                          await ref
                              .read(notificationsProvider.notifier)
                              .markNotificationAsRead(
                                  notification['_id'], userId);
                        }
                        if (reportId != null) {
                          final report = await ref
                              .read(reportsProvider.notifier)
                              .fetchReportById(reportId);

                          if (notification['type'] == 'report' &&
                              report != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReportDetailsPage(report: report),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(lang['reportNotFound'] ??
                                      'التقرير غير موجود')),
                            );
                          }
                        } else if (newsId != null) {
                          ref.read(selectedIndexProvider.notifier).state = 0;
                        }
                      },
                    ),
                  );

                  if (ResponsiveHelper.isMobile(context)) {
                    return Dismissible(
                      key: Key(notification['_id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(lang['confirmDelete'] ?? "تأكيد الحذف"),
                            content: Text(lang['deleteNotificationMsg'] ??
                                "هل تريد حذف هذا الإشعار؟"),
                            actions: [
                              TextButton(
                                child: Text(lang['cancel'] ?? "إلغاء"),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: Text(lang['delete'] ?? "حذف"),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await ref
                              .read(notificationsProvider.notifier)
                              .deleteNotification(notification['_id'], userId);

                          ref
                              .read(notificationsProvider.notifier)
                              .fetchNotifications(adminId: userId);
                        }

                        return confirmed ?? false;
                      },
                      child: card,
                    );
                  } else {
                    return card;
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
