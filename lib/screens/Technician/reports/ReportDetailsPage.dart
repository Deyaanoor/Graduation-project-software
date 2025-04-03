import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReportDetailsPage extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailsPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    try {
      final String plateNumber =
          report['plateNumber']?.toString() ?? 'غير معروف';
      final DateTime reportDate = _parseDate(report['date']);
      final List<String> imageUrls =
          List<String>.from(report['imageUrls'] ?? []);

      return Scaffold(
        backgroundColor: Colors.grey[900],
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context, plateNumber, imageUrls),
            _buildContent(context, reportDate, imageUrls),
          ],
        ),
      );
    } catch (e) {
      return _buildErrorScreen(context, e);
    }
  }

  SliverAppBar _buildAppBar(
      BuildContext context, String plateNumber, List<String> imageUrls) {
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return SliverAppBar.large(
      expandedHeight: isDesktop ? 400 : 250,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: report['_id']?.toString() ?? UniqueKey().toString(),
          child: _buildDefaultImage(),
        ),
        title: Text(
          'تقرير إصلاح - $plateNumber',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 20,
            color: Colors.white,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, DateTime reportDate, List<String> imageUrls) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 16,
        vertical: 24,
      ),
      sliver: SliverToBoxAdapter(
        child: isDesktop
            ? _buildDesktopLayout(context, reportDate, imageUrls)
            : _buildMobileLayout(context, reportDate, imageUrls),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, DateTime reportDate, List<String> imageUrls) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildDetailsColumn(reportDate),
        ),
        const SizedBox(width: 30),
        Expanded(
          flex: 3,
          child: _buildImageSection(context, imageUrls),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, DateTime reportDate, List<String> imageUrls) {
    return Column(
      children: [
        _buildDetailsColumn(reportDate),
        const SizedBox(height: 20),
        _buildImageSection(context, imageUrls),
      ],
    );
  }

  Widget _buildDetailsColumn(DateTime reportDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          title: 'معلومات السيارة',
          icon: Icons.directions_car,
          children: [
            _buildDetailRow(
                'المالك', report['owner']?.toString() ?? 'غير معروف'),
            _buildDetailRow(
                'رقم اللوحة', report['plateNumber']?.toString() ?? 'غير معروف'),
            _buildDetailRow('Make', report['make']?.toString() ?? 'غير معروف'),
            _buildDetailRow(
                'Model', report['model']?.toString() ?? 'غير معروف'),
            _buildDetailRow('Year', report['year']?.toString() ?? 'غير معروف'),
            _buildDetailRow(
                'Symptoms', report['symptoms']?.toString() ?? 'غير معروف'),
          ],
        ),
        _buildInfoCard(
          title: 'تفاصيل الإصلاح',
          icon: Icons.build,
          children: [
            _buildDetailRow(
                'التاريخ', DateFormat('yyyy-MM-dd – HH:mm').format(reportDate)),
            _buildDetailRow(
                'المشكلة', report['issue']?.toString() ?? 'غير معروف'),
            _buildDetailRow('وصف الإصلاح',
                report['repairDescription']?.toString() ?? 'غير متوفر'),
          ],
        ),
        _buildInfoCard(
          title: 'القطع المستخدمة',
          icon: Icons.inventory,
          children: [_buildPartsList()],
        ),
        _buildCostCard(),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amber),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(color: Colors.amber[300], fontSize: 20),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(
                value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartsList() {
    final List<String> parts = List<String>.from(report['usedParts'] ?? []);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: parts
          .map((part) => Chip(
                label: Text(
                  part,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.amber[800],
              ))
          .toList(),
    );
  }

  Widget _buildCostCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'التكلفة الإجمالية',
            style: TextStyle(color: Colors.amber[100]),
          ),
          Text(
            '${report['cost']?.toString() ?? '0'} ر.س',
            style: TextStyle(color: Colors.amber[100]),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, List<String> imageUrls) {
    final hasImages = imageUrls.isNotEmpty;
    final isSingleImage = imageUrls.length == 1;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصور المرفقة',
          style: TextStyle(
            color: Colors.amber[300],
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 20),
        if (!hasImages) _buildDefaultImage(),
        if (hasImages && isSingleImage)
          GestureDetector(
            onTap: () => _showFullScreenImage(context, imageUrls.first),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrls.first,
                fit: BoxFit.cover,
                height: isDesktop ? 400 : 300,
                placeholder: (context, url) => _buildImagePlaceholder(),
                errorWidget: (context, url, error) => _buildDefaultImage(),
              ),
            ),
          ),
        if (hasImages && !isSingleImage)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
              mainAxisExtent: isDesktop ? 200 : 180,
            ),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _showFullScreenImage(context, imageUrls[index]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildImagePlaceholder(),
                  errorWidget: (context, url, error) => _buildDefaultImage(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: CircularProgressIndicator(color: Colors.amber[300]),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      height: 200,
      color: Colors.grey[800],
      alignment: Alignment.center,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset('assets/logoReport.png'),
            ),
          );
        },
      ),
    );
  }

  DateTime _parseDate(dynamic date) {
    try {
      if (date == null) return DateTime.now();
      return date is DateTime ? date : DateTime.parse(date.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    return Scaffold(
      appBar: AppBar(title: const Text('حدث خطأ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 20),
            Text(
              'خطأ في عرض التفاصيل: ${error.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
