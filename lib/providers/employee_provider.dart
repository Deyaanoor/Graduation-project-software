import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/employee.dart';
import 'package:http/http.dart' as http;

class EmployeeProvider with ChangeNotifier {
  List<Employee> _employees = [];

  List<Employee> get employees => _employees;

  // جلب جميع الموظفين من الـ API
  Future<void> fetchEmployees() async {
    final response =
        await http.get(Uri.parse("http://localhost:5000/employees"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _employees = data.map((e) => Employee.fromJson(e)).toList();
      notifyListeners();
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  // إضافة موظف جديد
  Future<void> addEmployee(String name, String position, double salary) async {
    final response = await http.post(
      Uri.parse("http://localhost:5000/employees"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'name': name, 'position': position, 'salary': salary}),
    );

    if (response.statusCode == 200) {
      _employees.add(Employee.fromJson(json.decode(response.body)));
      notifyListeners();
    }
  }

  // حذف موظف
  Future<void> deleteEmployee(String id) async {
    final response =
        await http.delete(Uri.parse("http://localhost:5000/employees/$id"));

    if (response.statusCode == 200) {
      _employees.removeWhere((emp) => emp.id == id);
      notifyListeners();
    }
  }
}
