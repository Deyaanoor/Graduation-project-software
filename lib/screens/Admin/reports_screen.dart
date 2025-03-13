import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> reports = [
    {
      'plateNumber': 'ABC123',
      'technician': 'محمد أحمد',
      'description': 'تغيير زيت المحرك وإصلاح الفرامل',
      'image': 'assets/car_repair_1.jpg',
    },
    {
      'plateNumber': 'XYZ789',
      'technician': 'خالد يوسف',
      'description': 'تغيير البطارية وإصلاح المكيف',
      'image': 'assets/car_repair_2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('تقارير الإصلاحات 📑'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return ReportCard(report: report);
          },
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;

  ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => ReportDetailsDialog(report: report),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🚗 رقم اللوحة: ${report['plateNumber']}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('🔧 الفني: ${report['technician']}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text('📝 الوصف: ${report['description']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> report;

  ReportDetailsDialog({required this.report});

  @override
  _ReportDetailsDialogState createState() => _ReportDetailsDialogState();
}

class _ReportDetailsDialogState extends State<ReportDetailsDialog> {
  late TextEditingController _plateNumberController;
  late TextEditingController _technicianController;
  late TextEditingController _descriptionController;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _plateNumberController =
        TextEditingController(text: widget.report['plateNumber']);
    _technicianController =
        TextEditingController(text: widget.report['technician']);
    _descriptionController =
        TextEditingController(text: widget.report['description']);
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _technicianController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('تفاصيل التقرير'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚗 رقم اللوحة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _plateNumberController,
              decoration: InputDecoration(hintText: 'رقم اللوحة'),
              enabled: _isEditable,
            ),
            SizedBox(height: 10),
            Text('🔧 الفني:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _technicianController,
              decoration: InputDecoration(hintText: 'الفني'),
              enabled: _isEditable,
            ),
            SizedBox(height: 10),
            Text('📝 الوصف:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(hintText: 'الوصف'),
              enabled: _isEditable,
              maxLines: 3,
            ),
            SizedBox(height: 10),
            if (widget.report['image'] != null)
              Image.asset(widget.report['image'],
                  height: 150, fit: BoxFit.cover),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إغلاق', style: TextStyle(color: Colors.orange)),
        ),
        if (!_isEditable)
          TextButton(
            onPressed: () {
              setState(() {
                _isEditable = true;
              });
            },
            child: Text('تعديل', style: TextStyle(color: Colors.blue)),
          ),
        if (_isEditable)
          TextButton(
            onPressed: () {
              setState(() {
                widget.report['plateNumber'] = _plateNumberController.text;
                widget.report['technician'] = _technicianController.text;
                widget.report['description'] = _descriptionController.text;
                _isEditable = false;
              });
              Navigator.pop(context);
            },
            child: Text('حفظ', style: TextStyle(color: Colors.green)),
          ),
      ],
    );
  }
}
