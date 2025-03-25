import 'package:flutter/material.dart';
import 'package:flutter_provider/Responsive/Responsive_helper.dart';
import 'package:flutter_provider/screens/Technician/reports/ReportDetailsPage.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final List<Map<String, dynamic>> reports = [
    {
      'carPlate': 'ABC-123',
      'problem': 'مشكلة في المحرك',
      'date': DateTime(2023, 10, 1),
      'owner': 'أحمد محمد',
      'cost': '150 دينار',
      'images': ['assets/car1.jpg', 'assets/car2.jpg']
    },
    {
      'carPlate': 'ABC-123',
      'problem': 'مشكلة في المحرك',
      'date': DateTime(2023, 10, 1),
      'owner': 'أحمد محمد',
      'cost': '150 دينار',
      'images': ['assets/car1.jpg', 'assets/car2.jpg']
    },
    {
      'carPlate': 'ABC-123',
      'problem': 'مشكلة في المحرك',
      'date': DateTime(2023, 10, 1),
      'owner': 'أحمد محمد',
      'cost': '150 دينار',
      'images': ['assets/car1.jpg', 'assets/car2.jpg']
    },
    {
      'carPlate': 'ABC-123',
      'problem': 'مشكلة في المحرك',
      'date': DateTime(2023, 10, 1),
      'owner': 'أحمد محمد',
      'cost': '150 دينار',
      'images': ['assets/car1.jpg', 'assets/car2.jpg']
    },
    {
      'carPlate': 'ABC-123',
      'problem': 'مشكلة في المحرك',
      'date': DateTime(2023, 10, 1),
      'owner': 'أحمد محمد',
      'cost': '150 دينار',
      'images': ['assets/car1.jpg', 'assets/car2.jpg']
    },
    {
      'carPlate': 'ABC-123',
      'problem': 'مشكلة في المحرك',
      'date': DateTime(2023, 10, 1),
      'owner': 'أحمد محمد',
      'cost': '150 دينار',
      'images': ['assets/car1.jpg', 'assets/car2.jpg']
    },
    {
      'carPlate': 'ABC-123',
      'problem': 'مشكلة في المحرك',
      'date': DateTime(2023, 10, 1),
      'owner': 'أحمد محمد',
      'cost': '150 دينار',
      'images': ['assets/car1.jpg', 'assets/car2.jpg']
    },
    // إضافة تقارير أخرى هنا
  ];

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025, 12, 31),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[200]!,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث...',
                        prefixIcon: Icon(Icons.search, color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              _selectedDate == null
                                  ? 'اختر التاريخ'
                                  : DateFormat('yyyy-MM-dd')
                                      .format(_selectedDate!),
                              style: TextStyle(color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          ResponsiveHelper.isDesktop(context)
              ? SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildReportCard(
                        reports[index], screenWidth,
                        isGrid: true),
                    childCount: reports.length,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildReportCard(reports[index], screenWidth),
                    childCount: reports.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, "/report");
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, double screenWidth,
      {bool isGrid = false}) {
    Widget card = Hero(
      tag: report['carPlate'],
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 5,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => ReportDetailsPage(report: report),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report['carPlate'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd').format(report['date']),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Divider(color: Colors.orange.withOpacity(0.3)),
                SizedBox(height: 10),
                Text(
                  report['problem'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(report['cost']),
                      backgroundColor: Colors.orange.withOpacity(0.2),
                    ),
                    Text(
                      report['owner'],
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isGrid) {
      return card;
    } else {
      double cardWidth = ResponsiveHelper.isDesktop(context)
          ? screenWidth * 0.4
          : screenWidth * 0.9;
      return Center(
        child: SizedBox(
          width: cardWidth,
          child: card,
        ),
      );
    }
  }
}
