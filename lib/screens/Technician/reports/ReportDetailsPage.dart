import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Technician/reports/components/pdf_page.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReportDetailsPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailsPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
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
          'تقرير الإصلاح #${report['_id']?.substring(0, 6) ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'تحميل PDF',
            onPressed: () {
              generatePdf(context, report);
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
            _buildHeaderSection(),
            const SizedBox(height: 24),
            Expanded(
              child: isDesktop
                  ? _buildDesktopLayout(date, currencyFormat, context)
                  : _buildMobileLayout(date, currencyFormat, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHeaderItem(Icons.car_repair, 'موديل المركبة',
                '${report['year']} ${report['make']} ${report['model']}'),
            _buildHeaderItem(Icons.confirmation_number, 'رقم اللوحة',
                report['plateNumber'] ?? 'N/A'),
            _buildHeaderItem(Icons.person, 'المالك', report['owner'] ?? 'N/A'),
          ],
        ),
      ),
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
      DateTime date, NumberFormat format, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildDetailsColumn(date, format),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 3,
          child: _buildMediaSection(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      DateTime date, NumberFormat format, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDetailsColumn(date, format),
          const SizedBox(height: 24),
          _buildMediaSection(context),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn(DateTime date, NumberFormat format) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionCard(
            title: 'تفاصيل الإصلاح',
            icon: Icons.build,
            children: [
              _buildDetailRow(
                'تاريخ الإصلاح',
                DateFormat('dd/MM/yyyy - HH:mm').format(date),
              ),
              _buildDetailRow('الأعراض الأولية', report['symptoms'] ?? 'N/A'),
              _buildDetailRow('المشكله', report['issue'] ?? 'N/A'),
              _buildDetailRow(
                  'الإجراءات المتخذة', report['repairDescription'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'القطع المستخدمة',
            icon: Icons.inventory_2,
            children: [_buildPartsGrid()],
          ),
          const SizedBox(height: 16),
          _buildCostCard(format),
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

  Widget _buildPartsGrid() {
    final parts = List<String>.from(report['usedParts'] ?? []);

    return parts.isEmpty
        ? _buildEmptyState('لم يتم استخدام قطع غيار', Icons.construction)
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

  Widget _buildCostCard(NumberFormat format) {
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
                  const Text(
                    'التكلفة الإجمالية',
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

  Widget _buildMediaSection(BuildContext context) {
    final images = List<String>.from(report['imageUrls'] ?? []);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library,
                    color: Colors.orange), // Changed to orange
                const SizedBox(width: 8),
                const Text(
                  'الملفات المرفقة',
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
            const SizedBox(height: 12),
            images.isEmpty
                ? _buildEmptyState('لا توجد صور مرفقة', Icons.photo_camera)
                : GridView.builder(
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
                      onTap: () => _showFullScreenImage(context, images[index]),
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
}
