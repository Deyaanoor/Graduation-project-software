import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/requestRegister.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RegistrationRequests extends ConsumerStatefulWidget {
  const RegistrationRequests({Key? key}) : super(key: key);

  @override
  _RegistrationRequestsState createState() => _RegistrationRequestsState();
}

class _RegistrationRequestsState extends ConsumerState<RegistrationRequests> {
  String selectedFilterStatus = 'All';
  String searchQuery = '';
  int? sortColumnIndex;
  bool sortAscending = true;
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> garageRequests = [{}];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final getAllRequests = ref.watch(getAllRequestsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerColor =
        isDarkMode ? Colors.orange.shade700 : Colors.orange.shade500;
    final textColor = isDarkMode ? Colors.white : Colors.grey[900];
    final rowColor = isDarkMode ? Colors.grey[850] : Colors.orange[50];
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات تسجيل الكراجات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(getAllRequestsProvider),
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: getAllRequests.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('حدث خطأ: $error')),
        data: (requests) {
          List<Map<String, dynamic>> filteredRequests =
              _getFilteredRequests(requests);
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
                              columnSpacing:
                                  ResponsiveHelper.isMobile(context) ? 0 : 2,
                              horizontalMargin:
                                  ResponsiveHelper.isMobile(context) ? 2 : 15,
                              minWidth: constraints.maxWidth,
                              dataRowHeight: 60,
                              headingRowHeight: 60,
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
                                        'اسم الكراج', headerColor, 0),
                                  ),
                                  onSort: (columnIndex, ascending) =>
                                      _onSort(columnIndex, ascending),
                                  size: ColumnSize.M,
                                ),
                                DataColumn2(
                                  label: Center(
                                    child: _buildSortableHeader(
                                        'صاحب الكراج', headerColor, 1),
                                  ),
                                  onSort: (columnIndex, ascending) =>
                                      _onSort(columnIndex, ascending),
                                  size: ColumnSize.M,
                                ),
                                DataColumn2(
                                  label: Center(
                                      child:
                                          _SimpleHeader('الحالة', headerColor)),
                                  size: ColumnSize.L,
                                ),
                              ],
                              rows: List<DataRow2>.generate(
                                filteredRequests.length,
                                (index) {
                                  final request = filteredRequests[index];
                                  final userInfo = request['userInfo']
                                      as Map<String, dynamic>;

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
                                        _showRequestDetails(context, request);
                                      }
                                    },
                                    cells: [
                                      DataCell(
                                        Center(
                                          child: Text(
                                            request['garageName'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: textColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            userInfo['name'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  textColor?.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                            child: _buildStatusWidget(request)),
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

  Widget _buildStatusWidget(Map<String, dynamic> request) {
    final isResolved = request['status'] == 'accepted';
    final isRejected = request['status'] == 'rejected';

    if (isResolved || isRejected) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isResolved ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isResolved ? 'تم القبول' : 'مرفوض',
          style: TextStyle(
            color: isResolved ? Colors.green.shade800 : Colors.red.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () => _updateRequestStatus(request['_id'], 'accepted'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade400,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('قبول', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _updateRequestStatus(request['_id'], 'rejected'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('رفض', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildSortableHeader(String title, Color color, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Icon(
          sortColumnIndex == index
              ? (sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
              : Icons.unfold_more,
          size: 16,
          color: color,
        ),
      ],
    );
  }

  Widget _SimpleHeader(String title, Color color) {
    return Text(title,
        style: TextStyle(color: color, fontWeight: FontWeight.bold));
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      sortAscending = ascending;
    });
  }

  void _updateRequestStatus(String id, String status) async {
    final url = Uri.parse('http://localhost:5000/request_register/$id/status');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        ref.invalidate(getAllRequestsProvider);
        final refreshGarages = ref.read(refreshGaragesProvider);
        refreshGarages(ref);
        print("Status updated successfully");
      } else {
        print("Failed to update status: ${response.body}");
      }
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  List<Map<String, dynamic>> _getFilteredRequests(
      List<Map<String, dynamic>> allRequests) {
    final query = searchQuery.toLowerCase();

    List<Map<String, dynamic>> requests = allRequests.where((req) {
      final userInfo = req['userInfo'] as Map<String, dynamic>? ?? {};
      final garageName = req['garageName']?.toString().toLowerCase() ?? '';
      final ownerName = userInfo['name']?.toString().toLowerCase() ?? '';
      final status = req['status']?.toString().toLowerCase() ?? 'pending';

      final matchStatus =
          selectedFilterStatus == 'All' || status == selectedFilterStatus;
      final matchSearch =
          garageName.contains(query) || ownerName.contains(query);

      return matchStatus && matchSearch;
    }).toList();

    if (sortColumnIndex != null) {
      final keys = ['garageName', 'userInfo.name', 'status'];
      final key = keys[sortColumnIndex!];

      requests.sort((a, b) {
        dynamic aVal;
        dynamic bVal;

        if (key.contains('.')) {
          final parts = key.split('.');
          aVal =
              (a[parts[0]] as Map<String, dynamic>?)?[parts[1]]?.toString() ??
                  '';
          bVal =
              (b[parts[0]] as Map<String, dynamic>?)?[parts[1]]?.toString() ??
                  '';
        } else {
          aVal = a[key]?.toString() ?? '';
          bVal = b[key]?.toString() ?? '';
        }

        return sortAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      });
    }

    return requests;
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
                fillColor: isDarkMode
                    ? Colors.grey[800]
                    : Colors.orange.withOpacity(0.1),
                hintText: 'ابحث باسم الكراج أو صاحبه...',
                hintStyle: const TextStyle(color: Colors.orange),
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: selectedFilterStatus,
            items: ['All', 'pending', 'accepted', 'rejected']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(_translateStatus(status),
                          style: TextStyle(color: headerColor)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedFilterStatus = value!;
              });
            },
            underline: const SizedBox(),
            dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
          ),
        ],
      ),
    );
  }

  String _translateStatus(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'تم القبول';
      case 'rejected':
        return 'مرفوض';
      case 'All':
      default:
        return 'الكل';
    }
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> request) {
    final userInfo = request['userInfo'] as Map<String, dynamic>;
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final orangeColor =
        isDarkMode ? Colors.orange.shade700 : Colors.orange.shade500;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: isWideScreen ? 600 : double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.garage, color: orangeColor, size: 40),
              const SizedBox(height: 12),
              Text(
                request['garageName'] ?? 'اسم الكراج',
                style: TextStyle(
                  fontSize: isWideScreen ? 22 : 20,
                  fontWeight: FontWeight.bold,
                  color: orangeColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _infoTile(
                        label: 'المالك',
                        value: userInfo['name'],
                        icon: Icons.person,
                      ),
                      _infoTile(
                        label: 'البريد الإلكتروني',
                        value: userInfo['email'],
                        icon: Icons.email,
                      ),
                      _infoTile(
                        label: 'رقم الهاتف',
                        value: userInfo['phoneNumber'],
                        icon: Icons.phone_android,
                      ),
                      _infoTile(
                        label: 'الموقع',
                        value: request['garageLocation'],
                        icon: Icons.location_on,
                      ),
                      _infoTile(
                        label: 'الحالة',
                        value: request['status'],
                        icon: Icons.info_outline,
                      ),
                      if (request['subscriptionType'] != null)
                        _infoTile(
                          label: 'نوع الاشتراك',
                          value: request['subscriptionType'],
                          icon: Icons.subscriptions,
                        ),
                      if (request['createdAt'] != null)
                        _infoTile(
                          label: 'تاريخ الإنشاء',
                          value:
                              request['createdAt'].toString().substring(0, 10),
                          icon: Icons.calendar_today,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text("إغلاق"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required String? value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? 'غير متوفر',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
