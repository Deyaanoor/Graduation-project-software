import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> generatePdf(
    BuildContext context, Map<String, dynamic> report) async {
  final pdf = pw.Document();

  final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
  final ttf = pw.Font.ttf(fontData);

  final borderColor = PdfColors.blueGrey700;
  final headerColor = PdfColors.blue800;
  final boxColor = PdfColors.grey200;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // العنوان الرئيسي
                pw.Center(
                  child: pw.Text(
                    'تقرير إصلاح المركبة',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Divider(thickness: 1.2, color: PdfColors.grey700),

                // معلومات عامة داخل صندوق
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: boxColor,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  margin: const pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Column(
                    children: [
                      if (report['garageName'] != null)
                        _buildInfoRow(ttf, 'اسم الورشة:', report['garageName']),
                      if (report['garagePhone'] != null)
                        _buildInfoRow(
                            ttf, 'رقم الهاتف:', report['garagePhone']),
                      _buildInfoRow(
                          ttf, 'التاريخ:', _formatDate(report['date'])),
                      _buildInfoRow(ttf, 'المالك:', report['owner']),
                      _buildInfoRow(ttf, 'رقم اللوحة:', report['plateNumber']),
                      _buildInfoRow(ttf, 'النوع:', report['make']),
                      _buildInfoRow(ttf, 'الموديل:', report['model']),
                      _buildInfoRow(ttf, 'سنة الصنع:', report['year']),
                      _buildInfoRow(
                          ttf, 'التكلفة:', '\$${report['cost'] ?? ''}'),
                    ],
                  ),
                ),

                // قسم المشكلة
                pw.SizedBox(height: 8),
                _buildSectionTitle(ttf, 'المشكلة:'),
                _buildParagraph(ttf, report['issue']),
                pw.SizedBox(height: 8),

                _buildSectionTitle(ttf, 'الأعراض:'),
                _buildParagraph(ttf, report['symptoms']),
                pw.SizedBox(height: 8),

                _buildSectionTitle(ttf, 'وصف الإصلاح:'),
                _buildParagraph(ttf, report['repairDescription']),
                pw.SizedBox(height: 12),

                // جدول القطع
                _buildSectionTitle(ttf, 'القطع المستخدمة:'),
                _buildPartsTable(ttf, report['usedParts'] as List<dynamic>?),
              ],
            ),
          ),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

String _formatDate(dynamic dateInput) {
  try {
    final dateTime = DateTime.parse(dateInput.toString());
    return '${dateTime.day.toString().padLeft(2, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.year}';
  } catch (e) {
    return dateInput.toString(); // fallback في حال فشل التحويل
  }
}

pw.Widget _buildInfoRow(pw.Font font, String label, dynamic value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(label,
              style: pw.TextStyle(
                font: font,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              )),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text(value?.toString() ?? '',
              style: pw.TextStyle(font: font, fontSize: 14)),
        ),
      ],
    ),
  );
}

pw.Widget _buildSectionTitle(pw.Font font, String text) {
  return pw.Text(
    text,
    style: pw.TextStyle(
      font: font,
      fontSize: 16,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueGrey800,
    ),
  );
}

pw.Widget _buildParagraph(pw.Font font, String? text) {
  return pw.Text(
    text ?? '',
    style: pw.TextStyle(font: font, fontSize: 14),
    textAlign: pw.TextAlign.justify,
  );
}

pw.Widget _buildPartsTable(pw.Font font, List<dynamic>? parts) {
  if (parts == null || parts.isEmpty) {
    return pw.Text('لا يوجد قطع مدخلة',
        style: pw.TextStyle(font: font, fontSize: 14));
  }

  return pw.Table.fromTextArray(
    border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
    headerStyle: pw.TextStyle(
        font: font, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: pw.BoxDecoration(color: PdfColors.blueGrey700),
    cellStyle: pw.TextStyle(font: font, fontSize: 12),
    cellAlignment: pw.Alignment.centerRight,
    columnWidths: {
      0: const pw.FlexColumnWidth(1),
    },
    headers: ['اسم القطعة'],
    data: parts.map((e) => [e.toString()]).toList(),
  );
}
