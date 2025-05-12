import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/news_provider.dart';
import 'package:flutter_provider/providers/notifications_provider.dart';
import 'package:flutter_provider/widgets/top_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminAnnouncementPage extends ConsumerStatefulWidget {
  final bool isUpdate;
  final Map<String, dynamic>? news;
  final String? userId;
  const AdminAnnouncementPage(
      {super.key, this.news, required this.userId, required this.isUpdate});

  @override
  ConsumerState<AdminAnnouncementPage> createState() =>
      _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends ConsumerState<AdminAnnouncementPage> {
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  bool _isLoading = false;
  bool _isEditing = true;
  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      _isEditing = false;

      _titleController =
          TextEditingController(text: widget.news?['title'] ?? '');
      _messageController =
          TextEditingController(text: widget.news?['content'] ?? '');
    } else {
      _titleController = TextEditingController();
      _messageController = TextEditingController();
    }
  }

  Future<void> sendAnnouncement() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final userId = ref.read(userIdProvider).value;

    if (title.isEmpty || message.isEmpty || userId == null) {
      TopSnackBar.show(
        context: context,
        title: "خطأ",
        message: "الرجاء تعبئة جميع الحقول",
        icon: Icons.warning,
        color: Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newsId = await ref.read(newsProvider.notifier).addNews(
            title: title,
            content: message,
            admin: 'Owner',
            userId: userId,
          );

      await ref.read(notificationsProvider.notifier).sendNotification(
            adminId: userId,
            newsId: newsId,
            newsTitle: title,
            senderName: "Owner",
            type: 'news',
          );

      TopSnackBar.show(
        context: context,
        title: "تم الإرسال",
        message: "تم نشر الإعلان بنجاح",
        icon: Icons.check_circle,
        color: Colors.green,
      );

      _titleController.clear();
      _messageController.clear();
      await ref.read(newsProvider.notifier).refreshNews(widget.userId!);
      Navigator.pop(context);
    } catch (e) {
      TopSnackBar.show(
        context: context,
        title: "خطأ",
        message: "فشل في إرسال الإعلان: ${e.toString()}",
        icon: Icons.error,
        color: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNews() async {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    try {
      setState(() => _isLoading = true);

      await ref.read(newsProvider.notifier).updateNews(
            newsId: widget.news!['_id'],
            title: _titleController.text,
            content: _messageController.text,
          );

      TopSnackBar.show(
        // ignore: use_build_context_synchronously
        context: context,
        title: "تم التحديث",
        message: "تم تحديث الخبر بنجاح",
        icon: Icons.check_circle,
        color: Colors.green,
      );
      await ref.read(newsProvider.notifier).refreshNews(widget.userId!);
      Navigator.pop(context);
    } catch (e) {
      debugPrint("exception $e");
      TopSnackBar.show(
        context: context,
        title: "خطأ",
        message: "فشل في التحديث: ${e.toString()}",
        icon: Icons.error,
        color: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });
    }
  }

  Future<void> _deleteNews() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الخبر'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا الخبر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        setState(() => _isLoading = true);
        await ref.read(newsProvider.notifier).deleteNews(widget.news?['_id']);

        TopSnackBar.show(
          context: context,
          title: "تم الحذف",
          message: "تم حذف الخبر بنجاح",
          icon: Icons.check_circle,
          color: Colors.green,
        );
        await ref.read(newsProvider.notifier).refreshNews(widget.userId!);
        Navigator.pop(context);
      } catch (e) {
        TopSnackBar.show(
          context: context,
          title: "خطأ",
          message: "فشل في الحذف: ${e.toString()}",
          icon: Icons.error,
          color: Colors.red,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isUpdate ? Text('التعديل إعلان') : Text('إضافة إعلان'),
        backgroundColor: Colors.orange,
        actions: widget.isUpdate
            ? [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: _isLoading ? null : _deleteNews,
                  ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "إرسال إعلان جديد",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'عنوان الإعلان',
                  prefixIcon: const Icon(Icons.title, color: Colors.orange),
                  hintText: 'اكتب عنوان الإعلان...',
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.orange.shade200, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 4,
                enabled: _isEditing,
                decoration: InputDecoration(
                  labelText: 'محتوى الرسالة',
                  prefixIcon: const Icon(Icons.message, color: Colors.orange),
                  hintText: 'اكتب تفاصيل الإعلان...',
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.orange.shade200, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: widget.isUpdate
                    ? _isLoading
                        ? null
                        : _updateNews
                    : _isLoading
                        ? null
                        : sendAnnouncement,
                icon: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Icon(widget.isUpdate
                        ? _isEditing
                            ? Icons.save
                            : Icons.edit
                        : Icons.send),
                label: Text(widget.isUpdate
                    ? _isEditing
                        ? 'حفظ التعديلات'
                        : 'تعديل'
                    : _isLoading
                        ? "جاري الإرسال..."
                        : "إرسال"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
