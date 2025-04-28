import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_provider/screens/Owner/Invoices/Add_invoice.dart';
import 'package:flutter_provider/screens/Owner/Invoices/EditInvoiceScreen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:url_launcher/url_launcher.dart';

class InvoicesScreen extends StatefulWidget {
  @override
  _InvoicesScreenState createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final List<Map<String, dynamic>> invoices = [
    {
      'id': '001',
      'customer': 'Ali Ahmed',
      'carModel': 'Toyota Camry 2020',
      'carPlate': 'ABC123',
      'date': '2023-10-01',
      'dueDate': '2023-10-08',
      'amount': 1200.0,
      'paidAmount': 1200.0,
      'status': 'Paid',
      'services': [
        {'name': 'Oil Change', 'price': 300},
        {'name': 'Brake Pads Replacement', 'price': 900}
      ],
      'parts': [
        {'name': 'Oil Filter', 'price': 50},
        {'name': 'Brake Pads', 'price': 250}
      ]
    },
    {
      'id': '002',
      'customer': 'Mona Khaled',
      'carModel': 'Honda Civic 2018',
      'carPlate': 'XYZ789',
      'date': '2023-10-02',
      'amount': 1500.0,
      'status': 'Pending',
      'services': [
        {'name': 'Engine Tune-up', 'price': 800},
        {'name': 'Wheel Alignment', 'price': 700}
      ],
    },
    {
      'id': '003',
      'customer': 'Omar Ali',
      'date': '2023-10-03',
      'amount': 1000.0,
      'status': 'Paid',
    },
    {
      'id': '004',
      'customer': 'Sara Nabil',
      'carModel': 'Nissan Sunny 2021',
      'date': '2023-10-04',
      'amount': 1100.0,
      'status': 'Pending',
      'parts': [
        {'name': 'Air Filter', 'price': 60},
        {'name': 'Battery', 'price': 350}
      ],
    },
  ];

  bool _isLoading = false;
  String _filterStatus = 'All';
  String _sortBy = 'date';
  bool _sortAscending = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> get filteredInvoices {
    var filtered = invoices.where((invoice) {
      if (_filterStatus != 'All' && invoice['status'] != _filterStatus)
        return false;

      if (_searchQuery.isNotEmpty) {
        return invoice['id'].contains(_searchQuery) ||
            invoice['customer']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (invoice['carPlate']?.toString() ?? '').contains(_searchQuery);
      }
      return true;
    }).toList();

    filtered.sort((a, b) {
      var aValue = a[_sortBy];
      var bValue = b[_sortBy];

      if (_sortBy == 'amount') {
        aValue = aValue as double;
        bValue = bValue as double;
      }

      return _sortAscending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });

    return filtered;
  }

  Future<void> _exportToPDF() async {
    setState(() => _isLoading = true);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'تقرير الفواتير - مركز تصليح السيارات',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text('تاريخ التقرير: ${DateTime.now().toString()}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('رقم الفاتورة',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('العميل',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('السيارة',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('التاريخ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('المبلغ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('الحالة',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  ...filteredInvoices.map(
                    (invoice) => pw.TableRow(
                      children: [
                        pw.Text(invoice['id']),
                        pw.Text(invoice['customer']),
                        pw.Text(
                            '${invoice['carModel'] ?? ''} (${invoice['carPlate'] ?? ''})'),
                        pw.Text(invoice['date']),
                        pw.Text('\$${invoice['amount'].toString()}'),
                        pw.Text(invoice['status']),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('تم التصدير إلى PDF')));
  }

  Future<void> _exportToExcel(BuildContext context) async {
    setState(() => _isLoading = true);
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      // TextCellValue('ID'),
      // TextCellValue('العميل'),
      // TextCellValue('موديل السيارة'),
      // TextCellValue('رقم اللوحة'),
      // TextCellValue('التاريخ'),
      // TextCellValue('المبلغ'),
      // TextCellValue('الحالة'),
    ]);

    for (final invoice in filteredInvoices) {
      sheet.appendRow([
        // TextCellValue(invoice['id']),
        // TextCellValue(invoice['customer']),
        // TextCellValue(invoice['carModel'] ?? ''),
        // TextCellValue(invoice['carPlate'] ?? ''),
        // TextCellValue(invoice['date']),
        // TextCellValue(invoice['amount'].toString()),
        // TextCellValue(invoice['status']),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إنشاء الملف')),
      );
      return;
    }

    try {
      if (kIsWeb) {
        final blob = html.Blob([
          bytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..download = 'invoices.xlsx'
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          final result = await FilePicker.platform.getDirectoryPath();
          if (result != null) {
            final filePath = '$result/invoices.xlsx';
            await File(filePath).writeAsBytes(bytes);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم الحفظ في: $filePath')),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editInvoice(Map<String, dynamic> invoice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInvoiceScreen(
          invoice: invoice,
          onSave: (updatedInvoice) {
            setState(() {
              int index = invoices
                  .indexWhere((inv) => inv['id'] == updatedInvoice['id']);
              if (index != -1) invoices[index] = updatedInvoice;
            });
          },
        ),
      ),
    );
  }

  void _deleteInvoice(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الفاتورة'),
        content: Text('هل أنت متأكد من حذف الفاتورة ${invoice['id']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() =>
                  invoices.removeWhere((inv) => inv['id'] == invoice['id']));
              Navigator.pop(context);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDetails(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الفاتورة #${invoice['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('العميل: ${invoice['customer']}'),
              if (invoice['carModel'] != null)
                Text('الموديل: ${invoice['carModel']}'),
              if (invoice['carPlate'] != null)
                Text('رقم اللوحة: ${invoice['carPlate']}'),
              Text('التاريخ: ${invoice['date']}'),
              if (invoice['dueDate'] != null)
                Text('تاريخ الاستحقاق: ${invoice['dueDate']}'),
              Text('المبلغ الإجمالي: \$${invoice['amount']}'),
              if (invoice['paidAmount'] != null)
                Text('المبلغ المدفوع: \$${invoice['paidAmount']}'),
              Text('الحالة: ${invoice['status']}'),
              if (invoice['services'] != null) ...[
                SizedBox(height: 10),
                Text('الخدمات:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...invoice['services']
                    .map((s) => Text('- ${s['name']}: \$${s['price']}'))
                    .toList(),
              ],
              if (invoice['parts'] != null) ...[
                SizedBox(height: 10),
                Text('قطع الغيار:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ...invoice['parts']
                    .map((p) => Text('- ${p['name']}: \$${p['price']}'))
                    .toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
          if (invoice['status'] == 'Pending')
            TextButton(
              onPressed: () => {},
              child: Text('إرسال تذكير بالدفع',
                  style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
    );
  }

  // Future<void> _sendPaymentReminder(Map<String, dynamic> invoice) async {
  //   final emailUrl = 'mailto:${invoice['customer']}?'
  //       'subject=تذكير بدفع الفاتورة #${invoice['id']}&'
  //       'body=عزيزي ${invoice['customer']}،%0D%0A%0D%0A'
  //       'نذكرك بأن الفاتورة رقم ${invoice['id']} بقيمة \$${invoice['amount']} '
  //       'ما زالت معلقة.%0D%0A%0D%0A'
  //       'شكراً لتعاملك معنا.%0D%0A'
  //       'مركز تصليح السيارات';

  //   if (await canLaunch(emailUrl)) {
  //     await launch(emailUrl);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('تعذر فتح تطبيق البريد')),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الفواتير',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _exportToPDF,
          ),
          IconButton(
            icon: Icon(Icons.save_alt, color: Colors.white),
            onPressed: () => _exportToExcel(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: SpinKitFadingCircle(color: Colors.orange, size: 50.0))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'ابحث برقم الفاتورة أو اسم العميل...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              setState(() => _searchQuery = value),
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: _filterStatus,
                        items: ['All', 'Paid', 'Pending'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _filterStatus = value!),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: DataTable2(
                      columnSpacing: 12,
                      horizontalMargin: 12,
                      minWidth: 600,
                      columns: [
                        DataColumn(
                          label: Text('ID'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortBy = 'id';
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(
                          label: Text('العميل'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortBy = 'customer';
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(label: Text('التاريخ')),
                        DataColumn(
                          label: Text('المبلغ'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortBy = 'amount';
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        DataColumn(label: Text('الحالة')),
                        DataColumn(label: Text('إجراءات')),
                      ],
                      rows: filteredInvoices
                          .map(
                            (invoice) => DataRow(
                              cells: [
                                DataCell(
                                  Text(invoice['id']),
                                  onTap: () => _showInvoiceDetails(invoice),
                                ),
                                DataCell(
                                  Text(invoice['customer']),
                                  onTap: () => _showInvoiceDetails(invoice),
                                ),
                                DataCell(Text(invoice['date'])),
                                DataCell(
                                    Text('\$${invoice['amount'].toString()}')),
                                DataCell(
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: invoice['status'] == 'Paid'
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      invoice['status'],
                                      style: TextStyle(
                                        color: invoice['status'] == 'Paid'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () => _editInvoice(invoice),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _deleteInvoice(invoice),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddInvoiceScreen(
                onAdd: (newInvoice) {
                  setState(() {
                    invoices.add(newInvoice);
                  });
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
