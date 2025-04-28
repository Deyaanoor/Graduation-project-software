import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_provider/screens/Technician/reports/ReportDetailsPage.dart';

class ReportsPageList extends ConsumerStatefulWidget {
  const ReportsPageList({super.key});

  @override
  ConsumerState<ReportsPageList> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPageList> {
  String _searchText = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider);
    final userId = ref.watch(userIdProvider).value;
    print('User ID: $userId');
    final userInfo =
        userId != null ? ref.watch(getUserInfoProvider(userId)).value : null;
    final userRole =
        userInfo != null ? userInfo['role'] ?? 'بدون اسم' : 'جاري التحميل...';
    print('User Role: $userRole');
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(selectedIndexProvider.notifier).state = 4,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                final filteredReports = reports
                    .where((report) =>
                        report['plateNumber']
                            ?.toString()
                            .contains(_searchText) ??
                        false)
                    .toList();

                _sortData(filteredReports);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ResponsiveHelper.isMobile(context)
                        ? _buildMobileTable(filteredReports, userRole)
                        : _buildDesktopTable(filteredReports, userRole),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) =>
                  Center(child: Text("Error: ${err.toString()}")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(
      List<Map<String, dynamic>> reports, String userRole) {
    final isOwner = userRole == 'owner';

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      showCheckboxColumn: false,
      minWidth: isOwner ? 700 : 600,
      columns: [
        _buildDataColumn('Plate', Icons.directions_car, 0),
        _buildDataColumn('Issue', Icons.warning, 1),
        _buildDataColumn('Owner', Icons.person, 2),
        _buildDataColumn('Price', Icons.attach_money, 2, true),
        _buildDataColumn('Date', Icons.calendar_today, 2),
        if (isOwner) _buildDataColumn('Mechanic', Icons.build, 2),
      ],
      rows: reports.map((report) => _buildDesktopRow(report, isOwner)).toList(),
    );
  }

  Widget _buildMobileTable(
      List<Map<String, dynamic>> reports, String userRole) {
    final isOwner = userRole == 'owner';

    final columns = [
      _buildDataColumn('Plate', Icons.directions_car, 0),
      _buildDataColumn('Owner', Icons.person, 1),
      _buildDataColumn('Date', Icons.calendar_today, 4),
    ];

    if (isOwner) {
      columns.add(_buildDataColumn('Mechanic', Icons.build, 5));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 16,
          showCheckboxColumn: false,
          columns: columns,
          rows: reports
              .map((report) => _buildMobileRow(report, isOwner))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildMobileRow(Map<String, dynamic> report, [bool isOwner = false]) {
    final cells = [
      _buildDataCell(report['plateNumber'] ?? '-', Icons.directions_car),
      _buildDataCell(report['owner'] ?? '-', Icons.person),
      _buildDataCell(_formatDate(report['date']), Icons.calendar_today),
    ];

    if (isOwner) {
      cells.add(_buildDataCell(report['mechanicName'] ?? '-', Icons.build));
    }

    return DataRow(
      color: _getRowColor(),
      cells: cells,
      onSelectChanged: (selected) {
        if (selected == true) {
          _navigateToDetails(report);
        }
      },
    );
  }

  DataColumn2 _buildDataColumn(String label, IconData icon, int columnIndex,
      [bool isNumeric = false]) {
    return DataColumn2(
      size: columnIndex == 3 ? ColumnSize.S : ColumnSize.L,
      label: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.orange),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          if (_sortColumnIndex == columnIndex)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: Colors.orange,
            ),
        ],
      ),
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _sortAscending = ascending;
        });
      },
      numeric: isNumeric,
    );
  }

  DataRow _buildDesktopRow(Map<String, dynamic> report,
      [bool isOwner = false]) {
    final cells = [
      _buildDataCell(report['plateNumber'] ?? '-', Icons.directions_car),
      _buildDataCell(report['issue'] ?? '-', Icons.warning),
      _buildDataCell(report['owner'] ?? '-', Icons.person),
      _buildDataCell(_parseCost(report['cost']), Icons.attach_money),
      _buildDataCell(_formatDate(report['date']), Icons.calendar_today),
    ];

    if (isOwner) {
      cells.add(
        _buildDataCell(report['mechanicName'] ?? '-', Icons.build),
      );
    }

    return DataRow(
      color: _getRowColor(),
      cells: cells,
      onSelectChanged: (selected) {
        if (selected == true) {
          _navigateToDetails(report);
        }
      },
    );
  }

  DataCell _buildDataCell(String text, IconData icon) {
    return DataCell(
      Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchText = value),
          decoration: InputDecoration(
            hintText: 'Search by plate number...',
            prefixIcon: const Icon(Icons.search, color: Colors.orange),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  void _sortData(List<Map<String, dynamic>> data) {
    if (_sortColumnIndex == null) return;

    String getKey(int index, Map<String, dynamic> report) {
      switch (index) {
        case 0:
          return report['plateNumber'] ?? '';
        case 1:
          return report['issue'] ?? '';
        case 2:
          return report['owner'] ?? '';
        case 3:
          return report['cost']?.toString() ?? '0';
        case 4:
          return report['date']?.toString() ?? '';
        default:
          return '';
      }
    }

    data.sort((a, b) {
      final aValue = getKey(_sortColumnIndex!, a);
      final bValue = getKey(_sortColumnIndex!, b);
      return _sortAscending
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
    });
  }

  String _formatDate(dynamic date) {
    try {
      return DateFormat('yyyy-MM-dd').format(
        date is DateTime ? date : DateTime.parse(date.toString()),
      );
    } catch (e) {
      return 'Invalid Date';
    }
  }

  String _parseCost(dynamic cost) {
    try {
      final formatter = NumberFormat('#,###');
      return '${formatter.format(int.parse(cost.toString()))} DA';
    } catch (e) {
      return 'N/A';
    }
  }

  WidgetStateProperty<Color?> _getRowColor() {
    return WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          // ignore: deprecated_member_use
          return Colors.orange.withOpacity(0.05);
        }
        if (states.contains(WidgetState.selected)) {
          // ignore: deprecated_member_use
          return Colors.orange.withOpacity(0.1);
        }
        return Colors.white;
      },
    );
  }

  void _navigateToDetails(Map<String, dynamic> report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailsPage(report: report),
      ),
    );
  }
}
