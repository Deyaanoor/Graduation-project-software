import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddEmployee;

  AddEmployeeScreen({required this.onAddEmployee});

  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController attendanceController = TextEditingController();
  final TextEditingController absencesController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة موظف',
            style:
                GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: attendanceController,
                decoration: InputDecoration(
                  labelText: 'عدد أيام الحضور',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: absencesController,
                decoration: InputDecoration(
                  labelText: 'عدد أيام الغياب',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: salaryController,
                decoration: InputDecoration(
                  labelText: 'الراتب',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final newEmployee = {
                    'name': nameController.text,
                    'id':
                        'EMP${DateTime.now().millisecondsSinceEpoch}', // ID فريد لكل موظف
                    'attendance': int.parse(attendanceController.text),
                    'absences': int.parse(absencesController.text),
                    'salary': double.parse(salaryController.text),
                  };

                  // تمرير البيانات إلى الشاشة الرئيسية
                  widget.onAddEmployee(newEmployee);

                  Navigator.pop(context); // العودة إلى الصفحة الرئيسية
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text('إضافة الموظف'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
