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

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'تقرير إصلاح المركبة',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 16),
                pw.Text("التاريخ: ${report['date'] ?? ''}",
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("المالك: ${report['owner'] ?? ''}",
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("رقم اللوحة: ${report['plateNumber'] ?? ''}",
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("التكلفة: \$${report['cost'] ?? ''}",
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("النوع: ${report['make'] ?? ''}",
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("الموديل: ${report['model'] ?? ''}",
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("سنة الصنع: ${report['year'] ?? ''}",
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.SizedBox(height: 16),
                pw.Text("المشكلة:",
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(report['issue'] ?? '',
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text("الأعراض:",
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(report['symptoms'] ?? '',
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text("وصف الإصلاح:",
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(report['repairDescription'] ?? '',
                    style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text("القطع المستخدمة:",
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  (report['usedParts'] as List<dynamic>?)?.join(", ") ?? '',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
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
