import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/employee_provider.dart';
import './screens/employees_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (ctx) => EmployeeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmployeesScreen(),
    );
  }
}
