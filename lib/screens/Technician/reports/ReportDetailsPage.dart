import 'package:flutter/material.dart';
import 'package:flutter_provider/providers/auth/auth_provider.dart';
import 'package:flutter_provider/providers/home_provider.dart';
import 'package:flutter_provider/providers/language_provider.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_provider/screens/Technician/reports/components/pdf_page.dart';
import 'package:flutter_provider/widgets/custom_button.dart';
import 'package:flutter_provider/widgets/top_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_provider/providers/reports_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> report;

  const ReportDetailsPage({super.key, required this.report});

  @override
  _ReportDetailsPageState createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends ConsumerState<ReportDetailsPage> {
  Map<String, dynamic> get report => widget.report;

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider).value;
    final lang = ref.watch(languageProvider);

    final userInfo =
        userId != null ? ref.watch(getUserInfoProvider(userId)).value : null;
    final userRole =
        userInfo != null ? userInfo['role'] ?? 'بدون اسم' : 'جاري التحميل...';
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final date = _parseDate(report['date']);
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_SA',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang['reportDetails'] ?? 'تفاصيل التقرير',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: lang['generatePdf'] ?? 'إنشاء PDF',
            onPressed: () {
              generatePdf(context, report, lang);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 16,
          vertical: 24,
        ),
        child: Column(
          children: [
            _buildHeaderSection(lang),
            const SizedBox(height: 24),
            Expanded(
              child: isDesktop
                  ? _buildDesktopLayout(
                      date, currencyFormat, context, userRole, lang)
                  : _buildMobileLayout(
                      date, currencyFormat, context, userRole, lang),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    Map<String, dynamic> lang,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMobileHeaderItem(
                          Icons.car_repair,
                          lang['vehicleModel'] ?? 'موديل المركبة',
                          '${report['year']} ${report['make']} ${report['model']}'),
                      const SizedBox(height: 16),
                      _buildMobileHeaderItem(
                          Icons.confirmation_number,
                          lang['plateNumber'] ?? 'رقم اللوحة',
                          report['plateNumber'] ?? 'N/A'),
                      const SizedBox(height: 16),
                      _buildMobileHeaderItem(Icons.person,
                          lang['owner'] ?? 'المالك', report['owner'] ?? 'N/A'),
                      _buildMobileHeaderItem(
                          Icons.person,
                          lang['mechanicName'] ?? 'Mechanic Name',
                          report['mechanicName'] ?? 'N/A'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderItem(
                          Icons.car_repair,
                          lang['vehicleModel'] ?? 'موديل المركبة',
                          '${report['year']} ${report['make']} ${report['model']}'),
                      _buildHeaderItem(
                          Icons.confirmation_number,
                          lang['plateNumber'] ?? 'رقم اللوحة',
                          report['plateNumber'] ?? 'N/A'),
                      _buildHeaderItem(Icons.person, lang['owner'] ?? 'المالك',
                          report['owner'] ?? 'N/A'),
                      _buildHeaderItem(
                          Icons.person,
                          lang['mechanicName'] ?? 'Mechanic Name',
                          report['mechanicName'] ?? 'N/A'),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMobileHeaderItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: Colors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.orange), // Changed to orange
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange), // Changed to orange
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    DateTime date,
    NumberFormat format,
    BuildContext context,
    String userRole,
    Map<String, dynamic> lang,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildDetailsColumn(date, format, lang),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _buildMediaSection(context, userRole, lang),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(DateTime date, NumberFormat format,
      BuildContext context, String userRole, Map<String, dynamic> lang) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDetailsColumn(date, format, lang),
          const SizedBox(height: 24),
          _buildMediaSection(context, userRole, lang),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn(
    DateTime date,
    NumberFormat format,
    Map<String, dynamic> lang,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionCard(
            title: lang['reportDetails'] ?? 'تفاصيل التقرير',
            icon: Icons.build,
            children: [
              _buildDetailRow(
                lang['reportDate'] ?? 'تاريخ الاصلاح',
                DateFormat('dd/MM/yyyy - HH:mm').format(date),
              ),
              _buildDetailRow(
                  lang['symptoms'] ?? 'الأعراض', report['symptoms'] ?? 'N/A'),
              _buildDetailRow(
                  lang['issue'] ?? 'المشكلة', report['issue'] ?? 'N/A'),
              _buildDetailRow(lang['repairDescription'] ?? 'وصف الاصلاح',
                  report['repairDescription'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: lang['usedParts'] ?? 'قطع المستخدمة',
            icon: Icons.inventory_2,
            children: [_buildPartsGrid(lang)],
          ),
          const SizedBox(height: 16),
          _buildCostCard(format, lang),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange), // Changed to orange
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange), // Changed to orange
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                  color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsGrid(
    Map<String, dynamic> lang,
  ) {
    final parts = List<String>.from(report['usedParts'] ?? []);

    return parts.isEmpty
        ? _buildEmptyState(
            lang['noPartsUsed'] ?? 'لا توجد قطع مستخدمة', Icons.construction)
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: parts
                .map((part) => Chip(
                      label: Text(part),
                      backgroundColor:
                          Colors.orange.withOpacity(0.1), // Changed to orange
                      labelStyle: const TextStyle(
                          color: Colors.orange), // Changed to orange
                    ))
                .toList(),
          );
  }

  Widget _buildCostCard(
    NumberFormat format,
    Map<String, dynamic> lang,
  ) {
    final costString = report['cost']?.toString() ?? '0';
    final costValue = double.tryParse(costString) ?? 0.0;

    return Card(
      color: const Color.fromARGB(255, 248, 214, 160), // Changed to orange
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.attach_money,
                color: Colors.orange, size: 32), // Changed to orange
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang['totalCost'] ?? 'التكلفة الإجمالية',
                    style: TextStyle(
                      color: Colors.orange, // Changed to orange
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    format.format(costValue),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange, // Changed to orange
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection(
    BuildContext context,
    String userRole,
    Map<String, dynamic> lang,
  ) {
    final images = List<String>.from(report['imageUrls'] ?? []);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_library,
                      color: Colors.orange), // Changed to orange
                  const SizedBox(width: 8),
                  Text(
                    lang['attachedImages'] ?? 'الصور المرفقة',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange), // Changed to orange
                  ),
                  const Spacer(),
                  Text(
                    '${images.length} صورة',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                ],
              ),
              const Divider(color: Colors.grey),
              const SizedBox(height: 5),
              images.isEmpty
                  ? _buildEmptyState(
                      lang['noImagesAttached'] ?? 'لا توجد صور مرفقة',
                      Icons.photo_camera)
                  : ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: isDesktop ? 200 : 200, // حد أقصى للارتفاع
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () =>
                              _showFullScreenImage(context, images[index]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      ),
                    ),
              if (userRole == 'owner')
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: isDesktop ? 200 : double.infinity,
                        height: 60,
                        child: CustomButton(
                          key: UniqueKey(),
                          onPressed: () => _deleteReport(lang),
                          text: lang['deleteReport'] ?? 'حذف التقرير',
                          backgroundColor: Colors.red,
                        ),
                      ),
                      SizedBox(
                        width: isDesktop ? 200 : double.infinity,
                        height: 60,
                        child: CustomButton(
                          key: UniqueKey(),
                          onPressed: () =>
                              _navigateToEditReport(context, report),
                          text: lang['editReport'] ?? 'تعديل التقرير',
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ]),
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            text,
            style:
                TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ));
  }

  DateTime _parseDate(dynamic date) {
    try {
      return date is DateTime ? date : DateTime.parse(date.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  void _navigateToEditReport(
      BuildContext context, Map<String, dynamic> report) {
    final ref = ProviderScope.containerOf(context); // الحصول على الـ ref

    // حفظ التقرير ووضع التعديل في الـ Providers
    ref.read(selectedReportProvider.notifier).state = report;
    ref.read(isEditModeProvider.notifier).state = true; // تفعيل وضع التعديل

    // الانتقال إلى صفحة ReportPage (state = 5)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pop(context);
      ref.read(selectedIndexProvider.notifier).state = 3;
    });
  }

  _deleteReport(
    Map<String, dynamic> lang,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang['confirmDelete'] ?? 'تأكيد الحذف'),
        content: Text(
            lang['deleteReportMessage'] ?? 'هل أنت متأكد من حذف هذا التقرير؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(lang['cancel'] ?? 'إلغاء',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(lang['delete'] ?? 'حذف',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final String reportId = report['_id'];
        final ref = ProviderScope.containerOf(context);
        await ref.read(reportsProvider.notifier).deleteReport(reportId);

        TopSnackBar.show(
          context: context,
          title: lang['success'] ?? 'نجاح',
          message: lang['reportDeleted'] ?? 'تم حذف التقرير بنجاح',
          icon: Icons.check_circle,
          color: Colors.green,
        );
        Navigator.pop(context);
      } catch (e) {
        TopSnackBar.show(
          context: context,
          title: lang['error'] ?? 'خطأ',
          message: "${e.toString()}",
          icon: Icons.error,
          color: Colors.red,
        );
      }
    }
  }
}
