import 'package:flutter/material.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> employee;

  EmployeeDetailScreen({required this.employee});

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController attendanceController;
  late TextEditingController absencesController;
  late TextEditingController salaryController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.employee['name']);
    attendanceController =
        TextEditingController(text: widget.employee['attendance'].toString());
    absencesController =
        TextEditingController(text: widget.employee['absences'].toString());
    salaryController =
        TextEditingController(text: widget.employee['salary'].toString());
  }

  void _showDiscardChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تنبيه'),
          content: Text('سوف تفقد التعديلات التي قمت بها. هل أنت متأكد؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق التنبيه
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
                Navigator.of(context).pop(); // إغلاق التنبيه
              },
              child: Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الموظف'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          labelStyle: TextStyle(color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        enabled: isEditing,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: attendanceController,
                        decoration: InputDecoration(
                          labelText: 'عدد أيام الحضور',
                          labelStyle: TextStyle(color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: isEditing,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: absencesController,
                        decoration: InputDecoration(
                          labelText: 'عدد أيام الغياب',
                          labelStyle: TextStyle(color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: isEditing,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: salaryController,
                        decoration: InputDecoration(
                          labelText: 'الراتب',
                          labelStyle: TextStyle(color: Colors.orange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.orange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        enabled: isEditing,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              if (isEditing) {
                                setState(() {
                                  widget.employee['name'] = nameController.text;
                                  widget.employee['attendance'] =
                                      int.parse(attendanceController.text);
                                  widget.employee['absences'] =
                                      int.parse(absencesController.text);
                                  widget.employee['salary'] =
                                      double.parse(salaryController.text);
                                  isEditing = false;
                                });
                              } else {
                                setState(() {
                                  isEditing = true;
                                });
                              }
                            },
                            icon: Icon(isEditing ? Icons.save : Icons.edit),
                            label: Text(isEditing ? 'حفظ' : 'تعديل'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isEditing ? Colors.green : Colors.orange,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                            ),
                          ),
                          if (isEditing)
                            ElevatedButton.icon(
                              onPressed: _showDiscardChangesDialog,
                              icon: Icon(Icons.close),
                              label: Text('إغلاق'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
