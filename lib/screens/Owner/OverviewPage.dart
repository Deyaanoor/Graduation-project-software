import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_provider/Responsive/responsive_helper.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/overviewProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  final Color _mainColor = Colors.orange;
  final double _cardElevation = 6;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userId = ref.read(userIdProvider).value;
    if (userId != null) {
      ref.invalidate(monthlyReportsCountProvider(userId));

      ref.invalidate(monthlySummaryProvider(userId));

      ref.invalidate(topEmployeesProvider(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final userIdAsync = ref.watch(userIdProvider);

    return userIdAsync.when(
      data: (userId) {
        if (userId != null) {
          final monthlyReportsCount =
              ref.watch(monthlyReportsCountProvider(userId));
          final employeeCount = ref.watch(employeeCountProvider(userId));
          final employeeSalary = ref.watch(employeeSalaryProvider(userId));
          final monthlySummary = ref.watch(monthlySummaryProvider(userId));
          final modelsSummaryAsync = ref.watch(modelsSummaryProvider(userId));
          final topEmployeesAsync = ref.watch(topEmployeesProvider(userId));
          final reports = ref.watch(reportsProviderOverview(userId));

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Summary Cards
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildSummaryCard(
                          lang['monthlyRepairs'] ?? 'عدد التصليحات هذا الشهر',
                          Icons.build,
                          monthlyReportsCount.value?.toString() ?? '-',
                          context,
                        ),
                        _buildSummaryCard(
                          lang['employeeCount'] ?? 'عدد الموظفين',
                          Icons.engineering,
                          employeeCount.value?.toString() ?? '-',
                          context,
                        ),
                        _buildSummaryCard(
                          lang['totalSalaries'] ?? 'مجموع الرواتب',
                          Icons.attach_money,
                          '${employeeSalary.value?.toString() ?? '-'} \$',
                          context,
                        ),
                        _buildSummaryCard(
                          lang['TotalCost'] ?? 'إجمالي التكاليف الكاملة',
                          Icons.bar_chart,
                          '${monthlySummary.value?.toString() ?? '-'} \$',
                          context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Charts
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 600) {
                          return Row(
                            children: [
                              Expanded(
                                child: modelsSummaryAsync.when(
                                  data: (modelsSummary) => _buildChartCard(
                                    lang['carModels'] ?? 'موديلات السيارات',
                                    _buildPieChart(modelsSummary, lang),
                                    context,
                                  ),
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (err, stack) => Center(
                                      child: Text(
                                          '${lang['modelsLoadError'] ?? 'خطأ في تحميل بيانات الموديلات'}: $err')),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const SizedBox(width: 16),
                              Expanded(
                                child: topEmployeesAsync.when(
                                  data: (topEmployees) {
                                    return _buildChartCard(
                                      lang['employeeActivity'] ??
                                          'نشاط الموظفين',
                                      _buildBarChart(topEmployees, lang),
                                      context,
                                    );
                                  },
                                  loading: () => const Center(
                                      child: CircularProgressIndicator()),
                                  error: (err, stack) => Center(
                                      child: Text(
                                          '${lang['employeeActivityLoadError'] ?? 'خطأ في تحميل نشاط الموظفين'}: $err')),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              modelsSummaryAsync.when(
                                data: (modelsSummary) => _buildChartCard(
                                  lang['carModels'] ?? 'موديلات السيارات',
                                  _buildPieChart(modelsSummary, lang),
                                  context,
                                ),
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (err, stack) => Center(
                                    child: Text(
                                        '${lang['modelsLoadError'] ?? 'خطأ في تحميل بيانات الموديلات'}: $err')),
                              ),
                              const SizedBox(height: 16),
                              topEmployeesAsync.when(
                                data: (topEmployees) {
                                  return _buildChartCard(
                                    lang['employeeActivity'] ?? 'نشاط الموظفين',
                                    _buildBarChart(topEmployees, lang),
                                    context,
                                  );
                                },
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (err, stack) => Center(
                                    child: Text(
                                        '${lang['employeeActivityLoadError'] ?? 'خطأ في تحميل نشاط الموظفين'}: $err')),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Repairs Table
                    reports.when(
                      data: (report) {
                        print('Building UI with ${report.length} items');
                        return _buildRepairTable(
                            context, report.take(5).toList(), lang);
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(
                          child: Text('${lang['error'] ?? 'خطأ'}: $err')),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return Center(
              child:
                  Text(lang['userNotFound'] ?? 'لم يتم العثور على المستخدم.'));
        }
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
          child: Text(
              '${lang['userIdLoadError'] ?? 'خطأ في تحميل معرف المستخدم'}: $err')),
    );
  }

  Widget _buildPieChart(
      List<Map<String, dynamic>> modelsSummary, Map<String, String> lang) {
    if (modelsSummary.isEmpty) {
      return Center(
          child: Text(lang['noDataToShow'] ?? 'لا توجد بيانات لعرضها.'));
    }
    return PieChart(
      PieChartData(
        sections: modelsSummary.map((model) {
          return PieChartSectionData(
            value: (model['value'] as num).toDouble(),
            color: _getRandomColor(),
            title: model['title'],
          );
        }).toList(),
      ),
    );
  }

  Color _getRandomColor() {
    final random = Random();
    double hue = random.nextDouble() * 30 + 15;
    double saturation = random.nextDouble() * 0.5 + 0.5;
    double brightness = random.nextDouble() * 0.4 + 0.6;

    return HSVColor.fromAHSV(1.0, hue, saturation, brightness).toColor();
  }

  Widget _buildBarChart(
      List<Map<String, dynamic>> data, Map<String, String> lang) {
    if (data.isEmpty) {
      return Center(
          child: Text(lang['noDataToShow'] ?? 'لا توجد بيانات لعرضها.'));
    }
    final maxValue = data
        .map((e) => e['value'] as num)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data[index]['label'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          barTouchData: BarTouchData(enabled: false),
          barGroups: data.asMap().entries.map((entry) {
            final index = entry.key;
            final value = (entry.value['value'] as num).toDouble();

            return BarChartGroupData(
              x: index,
              barsSpace: 16,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: Colors.orange,
                  width: 30,
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(show: false),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, IconData icon, String value, BuildContext context) {
    return SizedBox(
      width: 300,
      height: 120,
      child: Card(
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _mainColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: _mainColor),
                  const SizedBox(width: 10),
                  Text(value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(
      String title, Widget chartWidget, BuildContext context) {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _mainColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(child: chartWidget),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      String dateOnly = dateString.split('T').first;
      return dateOnly;
    } catch (e) {
      print("Error parsing date: $e");
      return 'تاريخ غير صالح';
    }
  }

  Widget _buildRepairTable(BuildContext context,
      List<Map<String, dynamic>> repairs, Map<String, String> lang) {
    if (repairs.isEmpty) {
      return Center(
          child: Text(lang['noRepairsToShow'] ?? 'لا توجد تصليحات لعرضها.'));
    }
    return Card(
      elevation: _cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: ResponsiveHelper.isDesktop(context)
            ? MediaQuery.of(context).size.width * 0.5
            : double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _mainColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang['recentRepairs'] ?? 'آخر التصليحات',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: _mainColor)),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth,
                    ),
                    child: DataTable(
                      columnSpacing: 0,
                      horizontalMargin: 0,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 40,
                      columns: [
                        DataColumn(
                          label: Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(lang['customerName'] ?? 'اسم الزبون',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(lang['repairType'] ?? 'نوع التصليح',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(lang['repairDate'] ?? 'تاريخ التصليح',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                      rows: repairs.map((repair) {
                        return DataRow(cells: [
                          DataCell(
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(repair['owner'] ?? ''),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.center,
                              child: Text(repair['issue'] ?? ''),
                            ),
                          ),
                          DataCell(
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(_formatDate(repair['date'])),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
