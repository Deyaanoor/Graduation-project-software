import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDetailsPage extends StatelessWidget {
  final Map<String, dynamic> report;

  ReportDetailsPage({required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: report['carPlate'],
                child: Image.asset(
                  report['images'][0],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('رقم اللوحة', report['carPlate']),
                  _buildDetailItem('التاريخ',
                      DateFormat('yyyy-MM-dd').format(report['date'])),
                  _buildDetailItem('المشكلة', report['problem']),
                  _buildDetailItem('وصف التصليح', 'وصف مفصل للتصليح...'),
                  _buildDetailItem('القطع المستخدمة', '1. قطعة 1\n2. قطعة 2'),
                  _buildDetailItem('التكلفة', report['cost']),
                  _buildDetailItem('صاحب السيارة', report['owner']),
                  SizedBox(height: 20),
                  Text(
                    'الصور المرفقة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: report['images'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.orange),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: AspectRatio(
                                aspectRatio: 1.5,
                                child: Image.asset(
                                  report['images'][index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16),
          ),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }
}
