import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

String apiUrl = '${dotenv.env['API_URL']}/employees';

// ✅ Get All Employees
final employeesProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, ownerId) async {
  final response = await http.get(Uri.parse('$apiUrl?owner_id=$ownerId'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to load employees');
  }
});

// ✅ Add Employee
final addEmployeeProvider =
    Provider((ref) => (Map<String, dynamic> newEmployee, String ownerId) async {
          final response = await http.post(
            Uri.parse('$apiUrl/add-employee?owner_id=$ownerId'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(newEmployee),
          );

          if (response.statusCode != 201) {
            throw Exception('Failed to add employee');
          }
        });

// ✅ Delete Employee
final deleteEmployeeProvider =
    Provider((ref) => (String email, String ownerId) async {
          final response = await http.delete(
            Uri.parse('$apiUrl/employee/$email?owner_id=$ownerId'),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to delete employee');
          }
        });

// ✅ Update Employee
final updateEmployeeProvider = Provider((ref) => (
      String email,
      Map<String, dynamic> updatedData,
      String ownerId,
    ) async {
      final response = await http.put(
        Uri.parse('$apiUrl/employee/$email?owner_id=$ownerId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update employee');
      }
    });

final getEmployeeGarageInfoProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final response = await http.get(
    Uri.parse('$apiUrl/employee/$userId/garage-info'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to fetch employee garage info');
  }
});
