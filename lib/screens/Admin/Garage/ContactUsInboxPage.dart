import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/admin_StaticProvider.dart';
import 'package:flutter_provider/providers/contactUs.dart';
import 'package:flutter_provider/providers/language_provider.dart';
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
    final lang = ref.watch(languageProvider);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerColor =
        isDarkMode ? Colors.orange.shade700 : Colors.orange.shade500;
    final textColor = isDarkMode ? Colors.white : Colors.grey[900];
    final rowColor = isDarkMode ? Colors.grey[850] : Colors.orange[50];
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      body: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${lang['error'] ?? 'حدث خطأ'}: $error',
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => ref.refresh(contactMessagesProvider),
                child: Text(lang['retry'] ?? 'إعادة المحاولة'),
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
              _buildSearchAndFilter(headerColor, isDarkMode, lang),
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
                          child: DataTable2(
                            showCheckboxColumn: false,
                            columnSpacing: 10,
                            horizontalMargin: 5,
                            // ❌ احذف minWidth حتى لا يفرض عرض زائد
                            // minWidth: constraints.maxWidth,
                            dataRowHeight: 70,
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
                                label: Center(
                                  child: _buildSortableHeader(
                                      lang['problemType'] ?? 'المشكلة',
                                      headerColor,
                                      0),
                                ),
                                onSort: (columnIndex, ascending) =>
                                    _onSort(columnIndex, ascending),
                                size: ColumnSize.S, // ⬅️ خلي الحجم صغير
                              ),
                              DataColumn2(
                                label: Center(
                                  child: _buildSortableHeader(
                                      lang['sender'] ?? "Sender",
                                      headerColor,
                                      1),
                                ),
                                onSort: (columnIndex, ascending) =>
                                    _onSort(columnIndex, ascending),
                                size: ColumnSize.S,
                              ),
                              DataColumn2(
                                label: Center(
                                  child: _buildSortableHeader(
                                      lang['status'] ?? 'الحالة',
                                      headerColor,
                                      2),
                                ),
                                onSort: (columnIndex, ascending) =>
                                    _onSort(columnIndex, ascending),
                                size: ColumnSize.S,
                              ),
                            ],
                            rows: List<DataRow2>.generate(
                              filteredMessages.length,
                              (index) {
                                final msg = filteredMessages[index];
                                return DataRow2(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
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
                                      _onMessageTap(context, msg, lang);
                                    }
                                  },
                                  cells: [
                                    DataCell(
                                      Text(
                                        msg['type'] ?? 'بدون نوع',
                                        softWrap: true,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        msg['userName']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode
                                              ? Colors.grey[200]
                                              : Colors
                                                  .grey[800], // متجاوب مع الثيم
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: DropdownButton<String>(
                                          value: msg['status'] ?? 'pending',
                                          underline: const SizedBox(),
                                          style: const TextStyle(fontSize: 14),
                                          onChanged: (value) {
                                            if (value != null &&
                                                msg['_id'] != null) {
                                              _updateMessageStatus(
                                                  msg['_id'], value, lang);
                                            }
                                          },
                                          items: [
                                            DropdownMenuItem(
                                              value: 'pending',
                                              child: Text(lang['pending'] ??
                                                  'قيد الانتظار'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'in progress',
                                              child: Text(lang['inProgress'] ??
                                                  'قيد المعالجة'),
                                            ),
                                            DropdownMenuItem(
                                              value: 'resolved',
                                              child: Text(lang['resolved'] ??
                                                  'تم الحل'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
      final userName = msg['userName']?.toString() ?? '';
      // Debug print for each message
      print("userName    :$userName");

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

  Widget _buildSearchAndFilter(
    Color headerColor,
    bool isDarkMode,
    Map<String, dynamic> lang,
  ) {
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
                hintText:
                    lang['searchProblem'] ?? 'ابحث بنوع المشكلة أو نصها...',
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
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                items: [
                  DropdownMenuItem(
                      value: 'All', child: Text(lang['all'] ?? 'الكل')),
                  DropdownMenuItem(
                      value: 'pending',
                      child: Text(lang['pending'] ?? 'قيد الانتظار')),
                  DropdownMenuItem(
                      value: 'in progress',
                      child: Text(lang['inProgress'] ?? 'قيد المعالجة')),
                  DropdownMenuItem(
                      value: 'resolved',
                      child: Text(lang['resolved'] ?? 'تم الحل')),
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
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 2),
          Icon(icon, size: 14, color: color),
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

  void _onMessageTap(BuildContext context, Map<String, dynamic> message,
      Map<String, String> lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.amber),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lang['problemDetails'] ?? 'تفاصيل المشكلة',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(lang['problemType'] ?? "نوع المشكلة",
                  message['type'] ?? 'غير محدد'),
              const SizedBox(height: 10),
              _buildDetailRow(lang['problemText'] ?? "نص المشكلة",
                  message['message'] ?? 'بدون محتوى'),
              const SizedBox(height: 10),
              _buildDetailRow(lang['status'] ?? "الحالة",
                  _getStatusText(message['status'], lang)),
            ],
          ),
        ),
        actions: [
          Center(
            child: Row(children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: Text(lang['close'] ?? 'إغلاق'),
              ),
              SizedBox(
                width: 20,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => {
                  _deleteMessage(context, message['_id'], lang),
                  ref.invalidate(staticAdminProvider),
                },
                icon: const Icon(Icons.delete),
                label: Text(lang['delete'] ?? 'حذف'),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label:\n',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status, Map<String, String> lang) {
    switch (status) {
      case 'pending':
        return lang['pending'] ?? 'قيد الانتظار';
      case 'in progress':
        return lang['inProgress'] ?? 'قيد المعالجة';
      case 'resolved':
        return lang['resolved'] ?? 'تم الحل';
      default:
        return lang['notSpecified'] ?? 'غير محدد';
    }
  }

  Future<void> _deleteMessage(
    BuildContext contextScaffold, // <-- هذا هو context الصفحة الرئيسية
    String messageId,
    Map<String, dynamic> lang,
  ) async {
    final confirmed = await showDialog<bool>(
      context: contextScaffold,
      builder: (context) => AlertDialog(
          // ... باقي الكود ...
          ),
    );

    if (confirmed == true) {
      try {
        await ref.read(deletecontactMessagesByIdProvider(messageId));
        ref.invalidate(contactMessagesProvider);
        if (mounted) {
          Navigator.pop(contextScaffold, true); // أغلق نافذة التفاصيل فقط
          // بعد الإغلاق مباشرة أظهر SnackBar على context الصفحة الرئيسية
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              ScaffoldMessenger.of(contextScaffold).showSnackBar(
                SnackBar(
                  content:
                      Text(lang['messageDeleted'] ?? 'تم حذف الرسالة بنجاح'),
                ),
              );
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(contextScaffold).showSnackBar(
            SnackBar(
              content:
                  Text('${lang['deleteFailed'] ?? 'فشل في حذف الرسالة'}: $e'),
            ),
          );
        }
      }
    }
  }

  Future<void> _updateMessageStatus(
    String messageId,
    String newStatus,
    Map<String, String> lang,
  ) async {
    try {
      await ref.read(updateContactMessageStatusProvider)(
        messageId: messageId,
        status: newStatus,
      );
      // ignore: unused_result
      ref.refresh(contactMessagesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${lang['statusUpdated'] ?? 'تم تحديث الحالة'}: ${_getStatusText(newStatus, lang)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${lang['statusUpdateFailed'] ?? 'فشل في تحديث الحالة'}: $e')),
        );
      }
    }
  }
}
