import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/garage_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_provider/screens/Technician/reports/ReportDetailsPage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ClientReportsPage extends ConsumerStatefulWidget {
  const ClientReportsPage({super.key});

  @override
  ConsumerState<ClientReportsPage> createState() => _ClientReportsPageState();
}

class _ClientReportsPageState extends ConsumerState<ClientReportsPage> {
  List<Map<String, dynamic>> filteredReports = [];
  TextEditingController searchController = TextEditingController();
  String sortColumn = 'date';
  bool sortAscending = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final userId = ref.read(userIdProvider).value;
      final garageId = ref.read(garageIdProvider);
      print("userId: $userId, garageId: $garageId");
      if (userId != null && garageId != null) {
        try {
          final userInfo = await ref.read(getUserInfoProvider(userId).future);
          final ownerName = userInfo['name'] ?? 'بدون اسم';

          await ref
              .read(reportsProvider.notifier)
              .fetchReportsToClient(garageId: garageId, ownerName: ownerName);
        } catch (e) {
          debugPrint('خطأ في تحميل التقارير: $e');
        }
      } else {
        debugPrint("userId أو garageId غير متوفرين بعد");
      }
    });
  }

  void filterReports(List<Map<String, dynamic>> reports) {
    final query = searchController.text.toLowerCase();
    filteredReports = reports.where((report) {
      return (report['mechanicName']?.toString().toLowerCase() ?? '')
              .contains(query) ||
          (report['make']?.toString().toLowerCase() ?? '').contains(query);
    }).toList();

    filteredReports.sort((a, b) {
      var aValue = a[sortColumn];
      var bValue = b[sortColumn];

      if (aValue is DateTime) aValue = aValue.millisecondsSinceEpoch;
      if (bValue is DateTime) bValue = bValue.millisecondsSinceEpoch;

      if (aValue == null) return sortAscending ? 1 : -1;
      if (bValue == null) return sortAscending ? -1 : 1;

      if (aValue is String && bValue is String) {
        return sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else if (aValue is num && bValue is num) {
        return sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      } else {
        return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider).value;
    final garageId = ref.watch(garageIdProvider);
    final lang = ref.watch(languageProvider);

    if (userId == null || garageId == null) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final reportsState = ref.watch(reportsProvider);
    return Scaffold(
      body: reportsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('${lang['error'] ?? 'حدث خطأ'}: $error')),
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
                child: Text(lang['noReports'] ?? 'لا توجد تقارير حالياً'));
          }
          filterReports(reports);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: lang['searchByMechanicOrCar'] ??
                        'بحث باسم الميكانيكي أو نوع المركبة...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (userId != null && garageId != null) {
                        final userInfo =
                            await ref.read(getUserInfoProvider(userId).future);
                        final ownerName = userInfo['name'] ?? 'بدون اسم';
                        await ref
                            .read(reportsProvider.notifier)
                            .fetchReportsToClient(
                                garageId: garageId, ownerName: ownerName);
                      }
                    },
                    child: filteredReports.isEmpty
                        ? Center(
                            child: Text(
                                lang['noReports'] ?? 'لا توجد تقارير حالياً'))
                        : MediaQuery.of(context).size.width < 600
                            ? _buildMobileList(lang)
                            : _buildDesktopTable(lang),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileList(Map<String, dynamic> lang) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return InkWell(
          onTap: () {
            _navigateToDetails(report);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        report['mechanicName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.directions_car,
                          size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                          "${lang['carMake'] ?? 'نوع السيارة'}: ${report['make'] ?? ''}"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          size: 18, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                          "${lang['cost'] ?? 'التكلفة'}: ${report['cost']} \$"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                          "${lang['date'] ?? 'التاريخ'}: ${DateFormat('yyyy-MM-dd').format(report['date'] ?? DateTime.now())}"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(Map<String, dynamic> lang) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.orange.shade100),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                return states.contains(WidgetState.selected)
                    // ignore: deprecated_member_use
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                    : null;
              },
            ),
            columns: [
              DataColumn(
                label: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(lang['mechanicName'] ?? 'الميكانيكي'),
                  ],
                ),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    sortColumn = 'mechanicName';
                    sortAscending = ascending;
                  });
                },
              ),
              DataColumn(
                label: Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(lang['carMake'] ?? 'نوع السيارة'),
                  ],
                ),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    sortColumn = 'make';
                    sortAscending = ascending;
                  });
                },
              ),
              DataColumn(
                label: Row(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(lang['cost'] ?? 'التكلفة'),
                  ],
                ),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    sortColumn = 'cost';
                    sortAscending = ascending;
                  });
                },
              ),
              DataColumn(
                label: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(lang['date'] ?? 'التاريخ'),
                  ],
                ),
                onSort: (columnIndex, ascending) {
                  setState(() {
                    sortColumn = 'date';
                    sortAscending = ascending;
                  });
                },
              ),
            ],
            rows: filteredReports.map((report) {
              return DataRow(
                onSelectChanged: (selected) {
                  if (selected != null && selected) {
                    _navigateToDetails(report);
                  }
                },
                cells: [
                  DataCell(Text(report['mechanicName'] ?? '')),
                  DataCell(Text(report['make'] ?? '')),
                  DataCell(Text('${report['cost']} \$')),
                  DataCell(Text(DateFormat('yyyy-MM-dd')
                      .format(report['date'] ?? DateTime.now()))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
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
