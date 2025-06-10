import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
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
    final userInfo =
        userId != null ? ref.watch(getUserInfoProvider(userId)).value : null;
    final userRole =
        userInfo != null ? userInfo['role'] ?? 'بدون اسم' : 'جاري التحميل...';
    final lang = ref.watch(languageProvider);

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    // final headerColor = theme.colorScheme.primary;
    // final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    // final subTextColor = theme.textTheme.bodyMedium?.color ?? Colors.orange;
    // final rowColor = isDarkMode ? Colors.grey[850]! : Colors.orange[50]!;
    final backgroundColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(selectedIndexProvider.notifier).state = 2,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _buildSearchBar(lang, theme),
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
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black26
                              : Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ResponsiveHelper.isMobile(context)
                        ? _buildMobileTable(
                            filteredReports, userRole, lang, theme)
                        : _buildDesktopTable(
                            filteredReports, userRole, lang, theme),
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
    List<Map<String, dynamic>> reports,
    String userRole,
    Map<String, dynamic> lang,
    ThemeData theme,
  ) {
    final isOwner = userRole == 'owner';

    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 16,
      showCheckboxColumn: false,
      minWidth: isOwner ? 700 : 600,
      columns: [
        _buildDataColumn(lang['plate_number'] ?? 'Plate Number',
            Icons.directions_car, 0, theme),
        _buildDataColumn(lang['issue'] ?? 'Issue', Icons.warning, 1, theme),
        _buildDataColumn(lang['owner'] ?? 'Owner', Icons.person, 2, theme),
        _buildDataColumn(
            lang['cost'] ?? 'Cost', Icons.attach_money, 3, theme, true),
        _buildDataColumn(
            lang['date'] ?? 'Date', Icons.calendar_today, 4, theme),
        if (isOwner)
          _buildDataColumn(
              lang['mechanic_name'] ?? 'Mechanic Name', Icons.build, 5, theme),
      ],
      rows: reports
          .map((report) => _buildDesktopRow(report, isOwner, theme))
          .toList(),
      dataRowColor: _getRowColor(theme),
    );
  }

  Widget _buildMobileTable(
    List<Map<String, dynamic>> reports,
    String userRole,
    Map<String, dynamic> lang,
    ThemeData theme,
  ) {
    final columns = [
      _buildDataColumn(lang['plate_number'] ?? 'Plate Number',
          Icons.directions_car, 0, theme),
      _buildDataColumn(lang['owner'] ?? 'Owner', Icons.person, 1, theme),
      _buildDataColumn(lang['date'] ?? 'Date', Icons.calendar_today, 2, theme),
    ];

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      child: DataTable2(
        columnSpacing: 0,
        horizontalMargin: 8,
        minWidth: 0,
        showCheckboxColumn: false,
        columns: columns,
        rows: reports.map((report) => _buildMobileRow(report, theme)).toList(),
        dataRowColor: _getRowColor(theme),
      ),
    );
  }

  DataRow _buildMobileRow(Map<String, dynamic> report, ThemeData theme) {
    final cells = [
      _buildDataCell(report['plateNumber'] ?? '-', Icons.directions_car, theme),
      _buildDataCell(report['owner'] ?? '-', Icons.person, theme),
      _buildDataCell(_formatDate(report['date']), Icons.calendar_today, theme),
    ];

    return DataRow(
      color: _getRowColor(theme),
      cells: cells,
      onSelectChanged: (selected) {
        if (selected == true) {
          _navigateToDetails(report);
        }
      },
    );
  }

  DataColumn2 _buildDataColumn(
      String label, IconData icon, int columnIndex, ThemeData theme,
      [bool isNumeric = false]) {
    final headerColor = theme.colorScheme.primary;
    return DataColumn2(
      size: ColumnSize.M,
      label: Row(
        children: [
          Icon(icon, size: 16, color: headerColor),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                color: headerColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              )),
          if (_sortColumnIndex == columnIndex)
            Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: headerColor,
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
      [bool isOwner = false, ThemeData? theme]) {
    final cells = [
      _buildDataCell(report['plateNumber'] ?? '-', Icons.directions_car, theme),
      _buildDataCell(report['issue'] ?? '-', Icons.warning, theme),
      _buildDataCell(report['owner'] ?? '-', Icons.person, theme),
      _buildDataCell(_parseCost(report['cost']), Icons.attach_money, theme),
      _buildDataCell(_formatDate(report['date']), Icons.calendar_today, theme),
    ];

    if (isOwner) {
      cells.add(
        _buildDataCell(report['mechanicName'] ?? '-', Icons.build, theme),
      );
    }

    return DataRow(
      color: _getRowColor(theme!),
      cells: cells,
      onSelectChanged: (selected) {
        if (selected == true) {
          _navigateToDetails(report);
        }
      },
    );
  }

  DataCell _buildDataCell(String text, IconData icon, ThemeData? theme) {
    final textColor = theme?.textTheme.bodyLarge?.color ?? Colors.black;
    final iconColor = theme?.iconTheme.color ?? Colors.grey[600];
    return DataCell(
      Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    overflow: TextOverflow.ellipsis)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    Map<String, dynamic> lang,
    ThemeData theme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black26 : Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: TextField(
          onChanged: (value) => setState(() => _searchText = value),
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: lang['search'] ?? 'Search',
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            filled: true,
            fillColor: theme.cardColor,
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

  WidgetStateProperty<Color?> _getRowColor(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.hovered)) {
          return theme.colorScheme.primary.withOpacity(0.05);
        }
        if (states.contains(WidgetState.selected)) {
          return theme.colorScheme.primary.withOpacity(0.1);
        }
        return theme.cardColor;
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
