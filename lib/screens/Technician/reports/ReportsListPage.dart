import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/screens/Technician/reports/ReportDetailsPage.dart';
import 'package:flutter_provider/Responsive/Responsive_helper.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsyncValue = ref.watch(reportsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(selectedIndexProvider.notifier).state = 4,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportsProvider.notifier).fetchReports(),
        child: CustomScrollView(
          slivers: [
            _buildSearchBar(),
            _buildReportsList(reportsAsyncValue, context),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'ابحث...',
            prefixIcon: const Icon(Icons.search, color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportsList(
      AsyncValue<List<Map<String, dynamic>>> asyncValue, BuildContext context) {
    return asyncValue.when(
      data: (reports) => _handleReportsData(reports, context),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child:
            Center(child: Text("خطأ في تحميل البيانات: ${error.toString()}")),
      ),
    );
  }

  Widget _handleReportsData(
      List<Map<String, dynamic>> reports, BuildContext context) {
    if (reports.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "لا توجد تقارير متاحة حالياً",
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ),
        ),
      );
    }

    return ResponsiveHelper.isDesktop(context)
        ? SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildReportCard(context, reports[index]),
              childCount: reports.length,
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildReportCard(context, reports[index]),
              childCount: reports.length,
            ),
          );
  }

  Widget _buildReportCard(BuildContext context, Map<String, dynamic> report) {
    final formattedDate = _formatDate(report['date']);
    final cost = _parseCost(report['cost']);

    return Hero(
      tag: report['_id'] ?? UniqueKey().toString(),
      child: Card(
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        child: InkWell(
          onTap: () => _navigateToDetails(context, report),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(report, formattedDate),
                const Divider(color: Colors.orange),
                _buildIssueSection(report),
                const SizedBox(height: 10),
                _buildFooter(report, cost),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    try {
      return DateFormat('yyyy-MM-dd').format(
        date is DateTime ? date : DateTime.parse(date.toString()),
      );
    } catch (e) {
      return 'تاريخ غير معروف';
    }
  }

  String _parseCost(dynamic cost) {
    try {
      return '${int.parse(cost.toString())} دينار';
    } catch (e) {
      return 'السعر غير محدد';
    }
  }

  void _navigateToDetails(BuildContext context, Map<String, dynamic> report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailsPage(report: report),
      ),
    );
  }

  Widget _buildCardHeader(Map<String, dynamic> report, String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          report['plateNumber']?.toString() ?? 'بدون رقم لوحة',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          date,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildIssueSection(Map<String, dynamic> report) {
    return Expanded(
      child: Text(
        report['issue']?.toString() ?? 'لم يتم تحديد المشكلة',
        style: const TextStyle(fontSize: 16),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFooter(Map<String, dynamic> report, String cost) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Chip(
          label: Text(cost),
          backgroundColor: Colors.orange.withOpacity(0.2),
        ),
        Text(
          report['owner']?.toString() ?? 'مالك غير معروف',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
