import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/contactUs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

class ContactUsInboxPage extends ConsumerStatefulWidget {
  const ContactUsInboxPage({Key? key}) : super(key: key);

  @override
  _ContactUsInboxPageState createState() => _ContactUsInboxPageState();
}

class _ContactUsInboxPageState extends ConsumerState<ContactUsInboxPage> {
  String selectedFilterStatus = 'All';
  String searchQuery = '';
  int? sortColumnIndex;
  bool sortAscending = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(contactMessagesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerColor =
        isDarkMode ? Colors.orange.shade700 : Colors.orange.shade500;
    final textColor = isDarkMode ? Colors.white : Colors.grey[900];
    final rowColor = isDarkMode ? Colors.grey[850] : Colors.orange[50];
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('صندوق الوارد'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(contactMessagesProvider),
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('حدث خطأ: $error',
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.refresh(contactMessagesProvider),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (allMessages) {
          List<Map<String, dynamic>> filteredMessages =
              _getFilteredMessages(allMessages);

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildSearchAndFilter(headerColor, isDarkMode),
              const SizedBox(height: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: constraints.maxWidth,
                          color: backgroundColor,
                          child: Scrollbar(
                            child: DataTable2(
                              showCheckboxColumn: false,
                              columnSpacing: 20,
                              horizontalMargin: 20,
                              minWidth: constraints.maxWidth,
                              dataRowHeight: 60,
                              headingRowHeight: 70,
                              sortColumnIndex: sortColumnIndex,
                              sortAscending: sortAscending,
                              border: TableBorder(
                                verticalInside: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              columns: [
                                DataColumn2(
                                  label: _buildSortableHeader(
                                      'نوع المشكلة', headerColor, 0),
                                  onSort: (columnIndex, ascending) =>
                                      _onSort(columnIndex, ascending),
                                  size: ColumnSize.M,
                                ),
                                DataColumn2(
                                  label: _buildSortableHeader(
                                      'نص المشكلة', headerColor, 1),
                                  onSort: (columnIndex, ascending) =>
                                      _onSort(columnIndex, ascending),
                                  size: ColumnSize.L,
                                ),
                                DataColumn2(
                                  label: _buildSortableHeader(
                                      'الحالة', headerColor, 2),
                                  onSort: (columnIndex, ascending) =>
                                      _onSort(columnIndex, ascending),
                                  size: ColumnSize.S,
                                ),
                                DataColumn2(
                                  label:
                                      _SimpleHeader('الإجراءات', headerColor),
                                  size: ColumnSize.M,
                                ),
                              ],
                              rows: List<DataRow2>.generate(
                                filteredMessages.length,
                                (index) {
                                  final msg = filteredMessages[index];
                                  return DataRow2(
                                    color: MaterialStateProperty.resolveWith<
                                        Color?>(
                                      (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.hovered)) {
                                          return Colors.orange.withOpacity(0.3);
                                        }
                                        return index.isEven
                                            ? rowColor!.withOpacity(0.8)
                                            : Colors.transparent;
                                      },
                                    ),
                                    onSelectChanged: (selected) {
                                      if (selected == true) {
                                        _onMessageTap(context, msg);
                                      }
                                    },
                                    cells: [
                                      DataCell(
                                        Text(
                                          msg['type'] ?? 'بدون نوع',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: textColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          msg['message'] ?? 'بدون محتوى',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textColor?.withOpacity(0.8),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        DropdownButton<String>(
                                          value: msg['status'] ?? 'pending',
                                          underline: const SizedBox(),
                                          style: const TextStyle(fontSize: 14),
                                          onChanged: (value) {
                                            if (value != null &&
                                                msg['_id'] != null) {
                                              _updateMessageStatus(
                                                  msg['_id'], value);
                                            }
                                          },
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'pending',
                                              child: Text('قيد الانتظار'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'in progress',
                                              child: Text('قيد المعالجة'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'resolved',
                                              child: Text('تم الحل'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.reply,
                                                color: Colors.blue.shade300,
                                                size: 28,
                                              ),
                                              onPressed: () =>
                                                  _replyToMessage(context, msg),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_forever,
                                                color: Colors.red.shade300,
                                                size: 28,
                                              ),
                                              onPressed: () => _deleteMessage(
                                                  context, msg['_id']),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredMessages(
      List<Map<String, dynamic>> allMessages) {
    final query = searchQuery.toLowerCase();

    List<Map<String, dynamic>> msgs = allMessages.where((msg) {
      final type = msg['type']?.toString() ?? '';
      final message = msg['message']?.toString() ?? '';
      final status = msg['status']?.toString() ?? 'pending';

      final matchStatus =
          selectedFilterStatus == 'All' || status == selectedFilterStatus;
      final matchSearch = type.toLowerCase().contains(query) ||
          message.toLowerCase().contains(query);
      return matchStatus && matchSearch;
    }).toList();

    if (sortColumnIndex != null) {
      final key = ['type', 'message', 'status'][sortColumnIndex!];
      msgs.sort((a, b) {
        final aVal = a[key]?.toString().toLowerCase() ?? '';
        final bVal = b[key]?.toString().toLowerCase() ?? '';
        return sortAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      });
    }

    return msgs;
  }

  Widget _buildSearchAndFilter(Color headerColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.9),
                hintText: 'ابحث بنوع المشكلة أو نصها...',
                hintStyle:
                    const TextStyle(color: Color.fromARGB(255, 235, 186, 112)),
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              style: const TextStyle(color: Colors.orange),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode
                    ? Colors.orange.shade700
                    : Colors.orange.shade400,
                width: 1.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilterStatus,
                dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('الكل')),
                  DropdownMenuItem(
                      value: 'pending', child: Text('قيد الانتظار')),
                  DropdownMenuItem(
                      value: 'in progress', child: Text('قيد المعالجة')),
                  DropdownMenuItem(value: 'resolved', child: Text('تم الحل')),
                ],
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDarkMode ? Colors.orange : Colors.orange.shade700,
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedFilterStatus = value);
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _SimpleHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildSortableHeader(String title, Color color, int columnIndex) {
    final isCurrentSort = sortColumnIndex == columnIndex;
    final icon = isCurrentSort
        ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.swap_vert;

    return InkWell(
      onTap: () => _onSort(
          columnIndex, sortColumnIndex == columnIndex ? !sortAscending : true),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 6),
          Icon(icon, size: 16, color: color),
        ],
      ),
    );
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
    });
  }

  void _onMessageTap(BuildContext context, Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المشكلة: ${message['type'] ?? 'بدون نوع'}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('نوع المشكلة: ${message['type'] ?? 'غير محدد'}'),
              const SizedBox(height: 10),
              Text('نص المشكلة: ${message['message'] ?? 'بدون محتوى'}'),
              const SizedBox(height: 10),
              Text('الحالة: ${_getStatusText(message['status'])}'),
              const SizedBox(height: 10),
              Text('رقم المعرف: ${message['_id'] ?? 'غير متوفر'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in progress':
        return 'قيد المعالجة';
      case 'resolved':
        return 'تم الحل';
      default:
        return 'غير محدد';
    }
  }

  void _replyToMessage(BuildContext context, Map<String, dynamic> message) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الرد على مشكلة: ${message['type'] ?? 'غير محدد'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نص المشكلة: ${message['message']}'),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'اكتب ردك هنا...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // يمكنك إضافة منطق إرسال الرد هنا
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال الرد بنجاح')),
              );
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMessage(BuildContext context, String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسالة'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذه الرسالة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(deleteContactMessageProvider)(messageId);
        ref.refresh(contactMessagesProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الرسالة بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل في حذف الرسالة: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateMessageStatus(String messageId, String newStatus) async {
    try {
      await ref.read(updateContactMessageStatusProvider)(
        messageId: messageId,
        status: newStatus,
      );
      ref.refresh(contactMessagesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('تم تحديث الحالة إلى ${_getStatusText(newStatus)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في تحديث الحالة: $e')),
        );
      }
    }
  }
}
