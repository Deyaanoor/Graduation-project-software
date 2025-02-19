import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';

class AddEmployeePopup extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("إضافة موظف جديد"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "الاسم"),
          ),
          TextField(
            controller: positionController,
            decoration: InputDecoration(labelText: "المنصب"),
          ),
          TextField(
            controller: salaryController,
            decoration: InputDecoration(labelText: "الراتب"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("إلغاء"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text("إضافة"),
          onPressed: () {
            final name = nameController.text;
            final position = positionController.text;
            final salary = double.tryParse(salaryController.text) ?? 0.0;

            if (name.isNotEmpty && position.isNotEmpty && salary > 0) {
              Provider.of<EmployeeProvider>(context, listen: false)
                  .addEmployee(name, position, salary);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
