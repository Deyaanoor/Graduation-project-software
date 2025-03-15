import 'package:flutter/material.dart';
import 'package:flutter_provider/screens/Admin/Employee/add_employee_screen.dart';
import 'package:flutter_provider/screens/Admin/Employee/employee_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:excel/excel.dart';
// import 'package:file_saver/file_saver.dart'; // أضف هذه المكتبة
import 'package:universal_io/io.dart'; // أضف هذه المكتبة
import 'package:flutter/foundation.dart'; // أضف هذه المكتبة لفحص المنصة
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart'; // لأجل loadFont
import 'dart:html' as html;

class EmployeeScreen extends StatefulWidget {
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final List<Map<String, dynamic>> employees = [
    {
      'name': 'Ali Ahmed',
      'id': '001',
      'attendance': 22,
      'absences': 3,
      'salary': 1200
    },
    {
      'name': 'Mona Khaled',
      'id': '002',
      'attendance': 25,
      'absences': 0,
      'salary': 1500
    },
    {
      'name': 'Omar Ali',
      'id': '003',
      'attendance': 18,
      'absences': 7,
      'salary': 1000
    },
    {
      'name': 'Sara Nabil',
      'id': '004',
      'attendance': 20,
      'absences': 5,
      'salary': 1100
    },
  ];

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  List<Map<String, dynamic>> get filteredEmployees {
    return employees.where((employee) {
      return employee['name']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          employee['salary'].toString().contains(_searchQuery);
    }).toList();
  }

  void _sort<T>(Comparable<T> Function(Map<String, dynamic> employee) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      employees.sort((a, b) {
        if (!ascending) {
          final temp = a;
          a = b;
          b = temp;
        }
        return Comparable.compare(getField(a), getField(b));
      });
    });
  }

  Future<void> _exportToExcel(BuildContext context) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Append header row
    sheet.appendRow([
      TextCellValue('الاسم'),
      TextCellValue('ID'),
      TextCellValue('الحضور'),
      TextCellValue('الغياب'),
      TextCellValue('الراتب'),
    ]);

    // Add employee data
    for (var employee in employees) {
      sheet.appendRow([
        TextCellValue(employee['name']),
        TextCellValue(employee['id'].toString()),
        TextCellValue(employee['attendance'].toString()),
        TextCellValue(employee['absences'].toString()),
        TextCellValue(employee['salary'].toString()),
      ]);
    }

    final bytes = await excel.encode();
    if (bytes != null) {
      if (!kIsWeb) {
        // Save the Excel file for mobile/desktop
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/employees.xlsx');
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تصدير البيانات إلى Excel بنجاح')),
        );
      } else {
        // Save the Excel file for web
        final blob = html.Blob([
          bytes
        ], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'employees.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('تم تصدير البيانات إلى Excel بنجاح (في الويب)')),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();

    // تحميل الخط العربي
    final arabicFont = pw.Font.ttf(
      await rootBundle.load("assets/fonts/AmiriRegular/AmiriRegular.ttf"),
    );

    // الخط الإنجليزي الافتراضي
    final englishFont = pw.Font.helvetica();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // العنوان بالعربية
              pw.Text(
                'إدارة الموظفين',
                style: pw.TextStyle(
                  fontSize: 24,
                  font: arabicFont, // استخدام الخط العربي
                ),
                textDirection: pw
                    .TextDirection.rtl, // تحديد اتجاه النص من اليمين إلى اليسار
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  // رأس الجدول
                  pw.TableRow(
                    children: [
                      pw.Center(
                        child: pw.Text('الاسم',
                            style: pw.TextStyle(font: arabicFont),
                            textDirection: pw.TextDirection.rtl),
                      ),
                      pw.Center(
                        child: pw.Text('ID',
                            style: pw.TextStyle(
                                font: englishFont)), // استخدام الخط الإنجليزي
                      ),
                      pw.Center(
                        child: pw.Text('الحضور',
                            style: pw.TextStyle(font: arabicFont),
                            textDirection: pw.TextDirection.rtl),
                      ),
                      pw.Center(
                        child: pw.Text('الغياب',
                            style: pw.TextStyle(font: arabicFont),
                            textDirection: pw.TextDirection.rtl),
                      ),
                      pw.Center(
                        child: pw.Text(
                          'الراتب',
                          style: pw.TextStyle(font: arabicFont),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                  // بيانات الموظفين
                  ...employees.map(
                    (employee) => pw.TableRow(
                      children: [
                        pw.Text(employee['name'],
                            style: pw.TextStyle(font: arabicFont)),
                        pw.Text(employee['id'],
                            style: pw.TextStyle(
                                font: englishFont)), // استخدام الخط الإنجليزي
                        pw.Text(employee['attendance'].toString(),
                            style: pw.TextStyle(font: arabicFont)),
                        pw.Text(employee['absences'].toString(),
                            style: pw.TextStyle(font: arabicFont)),
                        pw.Text('\$${employee['salary']}',
                            style: pw.TextStyle(font: arabicFont)),
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

    // حفظ وعرض ملف PDF
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تصدير البيانات إلى PDF بنجاح')),
    );
  }

  void _addEmployee(Map<String, dynamic> newEmployee) {
    setState(() {
      employees.add(newEmployee);
    });
  }

  void _editEmployee(Map<String, dynamic> employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );
  }

  void _confirmDeleteEmployee(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف موظف'),
        content: Text('هل أنت متأكد من حذف الموظف ${employee['name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _deleteEmployee(employee);
              Navigator.pop(context);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteEmployee(Map<String, dynamic> employee) {
    setState(() {
      employees.remove(employee);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'إدارة الموظفين',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن موظف...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: _buildDataTable(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddEmployeeScreen(onAddEmployee: _addEmployee)),
          );
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          columnSpacing: 24.0,
          headingRowColor:
              MaterialStateColor.resolveWith((states) => Colors.orange[300]!),
          dataRowColor:
              MaterialStateColor.resolveWith((states) => Colors.white),
          headingTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          dataTextStyle: TextStyle(fontSize: 14, color: Colors.black87),
          columns: [
            DataColumn(
              label: Text('الاسم'),
              onSort: (columnIndex, ascending) {
                _sort<String>(
                    (employee) => employee['name'], columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Text('ID'),
              onSort: (columnIndex, ascending) {
                _sort<String>(
                    (employee) => employee['id'], columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Text('الحضور'),
              onSort: (columnIndex, ascending) {
                _sort<int>((employee) => employee['attendance'], columnIndex,
                    ascending);
              },
            ),
            DataColumn(
              label: Text('الغياب'),
              onSort: (columnIndex, ascending) {
                _sort<int>(
                    (employee) => employee['absences'], columnIndex, ascending);
              },
            ),
            DataColumn(
              label: Text('الراتب'),
              onSort: (columnIndex, ascending) {
                _sort<int>(
                    (employee) => employee['salary'], columnIndex, ascending);
              },
            ),
            DataColumn(label: Text('إجراءات')),
          ],
          rows: filteredEmployees.map((employee) {
            return DataRow(
              cells: [
                DataCell(Text(employee['name'])),
                DataCell(Text(employee['id'])),
                DataCell(Text(employee['attendance'].toString())),
                DataCell(Text(employee['absences'].toString())),
                DataCell(Text('\$${employee['salary']}')),
                DataCell(Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editEmployee(employee)),
                    IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteEmployee(employee)),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
