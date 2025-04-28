import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final List<Map<String, dynamic>> reports = [
    {
      'plateNumber': 'ABC123',
      'date': '١٥-١٠-٢٠٢٣',
      'problem': 'فرامل معطلة وتسريب زيت',
      'repairDescription': 'تغيير زيت المحرك وإصلاح الفرامل',
      'usedParts': 'زيت محرك, قطع فرامل, بطارية',
      'cost': '750 ر.س',
      'owner': 'علي حسن',
      'technician': 'محمد أحمد',
      'images': [],
    },
    {
      'plateNumber': 'XYZ789',
      'date': '٢٠-١١-٢٠٢٣',
      'problem': 'مكيف لا يعمل وبطارية ضعيفة',
      'repairDescription': 'تغيير البطارية وإصلاح المكيف',
      'usedParts': 'بطارية, غاز مكيف',
      'cost': '1200 ر.س',
      'owner': 'سعيد محمد',
      'technician': 'خالد يوسف',
      'images': [],
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredReports = [];

  @override
  void initState() {
    super.initState();
    _filteredReports = reports;
    _searchController.addListener(_filterReports);
  }

  void _filterReports() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReports = reports.where((report) {
        return report['plateNumber'].toLowerCase().contains(query) ||
            report['owner'].toLowerCase().contains(query) ||
            report['technician'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        titleSpacing: 0,
        flexibleSpace: Padding(
          padding: const EdgeInsets.all(8.0),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث برقم اللوحة، المالك، أو الفني...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.orange, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.orange, width: 1),
                  ),
                ),
              ),
            ),
            _filteredReports.isEmpty
                ? Center(child: Text('لا توجد نتائج بحث'))
                : Expanded(
                    child: ListView.builder(
                      itemCount: _filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = _filteredReports[index];
                        return ReportCard(report: report);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// باقي الكلاسات (ReportCard و ReportDetailsDialog) تبقى كما هي دون تغيير

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
              Text('📅 التاريخ: ${report['date']}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
              Text('⚠️ المشكلة: ${report['problem']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.red)),
              SizedBox(height: 5),
              Text('💲 التكلفة: ${report['cost']}',
                  style: TextStyle(fontSize: 16, color: Colors.green)),
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
  late TextEditingController _dateController;
  late TextEditingController _problemController;
  late TextEditingController _repairDescriptionController;
  late TextEditingController _usedPartsController;
  late TextEditingController _costController;
  late TextEditingController _ownerController;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
    _plateNumberController =
        TextEditingController(text: widget.report['plateNumber']);
    _dateController = TextEditingController(text: widget.report['date']);
    _problemController = TextEditingController(text: widget.report['problem']);
    _repairDescriptionController =
        TextEditingController(text: widget.report['repairDescription']);
    _usedPartsController =
        TextEditingController(text: widget.report['usedParts']);
    _costController = TextEditingController(text: widget.report['cost']);
    _ownerController = TextEditingController(text: widget.report['owner']);
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _dateController.dispose();
    _problemController.dispose();
    _repairDescriptionController.dispose();
    _usedPartsController.dispose();
    _costController.dispose();
    _ownerController.dispose();
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
            _buildEditableField('🚗 رقم اللوحة', _plateNumberController),
            _buildEditableField('📅 التاريخ', _dateController),
            _buildEditableField('⚠️ المشكلة', _problemController),
            _buildEditableField('📝 وصف التصليح', _repairDescriptionController,
                maxLines: 3),
            _buildEditableField('🔩 القطع المستخدمة', _usedPartsController),
            _buildEditableField('💲 التكلفة', _costController),
            _buildEditableField('👤 صاحب السيارة', _ownerController),
            if (widget.report['images'] != null &&
                widget.report['images'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📷 الصور المرفقة:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.report['images'].length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Image.asset(
                            widget.report['images'][index],
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
            onPressed: () => setState(() => _isEditable = true),
            child: Text('تعديل', style: TextStyle(color: Colors.blue)),
          ),
        if (_isEditable)
          TextButton(
            onPressed: () {
              // حفظ التعديلات
              setState(() {
                widget.report['plateNumber'] = _plateNumberController.text;
                widget.report['date'] = _dateController.text;
                widget.report['problem'] = _problemController.text;
                widget.report['repairDescription'] =
                    _repairDescriptionController.text;
                widget.report['usedParts'] = _usedPartsController.text;
                widget.report['cost'] = _costController.text;
                widget.report['owner'] = _ownerController.text;
                _isEditable = false;
              });
              Navigator.pop(context);
            },
            child: Text('حفظ', style: TextStyle(color: Colors.green)),
          ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: controller,
            enabled: _isEditable,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }
}
