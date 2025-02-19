import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/add_employee_popup.dart';

class EmployeesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);

    // استدعاء الدالة جلب البيانات مرة واحدة

    employeeProvider.fetchEmployees();

    return Scaffold(
      appBar: AppBar(title: Text("قائمة الموظفين")),
      body: Consumer<EmployeeProvider>(
        builder: (context, employeeProvider, child) {
          if (employeeProvider.employees.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: employeeProvider.employees.length,
            itemBuilder: (context, index) {
              final employee = employeeProvider.employees[index];
              return ListTile(
                title: Text(employee.name),
                subtitle: Text(employee.position),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => employeeProvider.deleteEmployee(employee.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddEmployeePopup(),
          );
        },
      ),
    );
  }
}
