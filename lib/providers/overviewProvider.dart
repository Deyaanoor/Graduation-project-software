import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String _apiUrl = '${dotenv.env['API_URL']}/overview';

final monthlyReportsCountProvider =
    FutureProvider.family.autoDispose<int, String>((ref, userId) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/reports-count'),
    body: json.encode({'userId': userId}),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['count'];
  } else {
    throw Exception('Failed to load reports count');
  }
});

// دالة لتحميل عدد الموظفين
final employeeCountProvider =
    FutureProvider.family.autoDispose<int, String>((ref, userId) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/employee-count'),
    body: json.encode({'userId': userId}),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['count'];
  } else {
    throw Exception('Failed to load employee count');
  }
});

// دالة لتحميل راتب الموظفين الإجمالي
final employeeSalaryProvider =
    FutureProvider.family.autoDispose<double, String>((ref, userId) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/employee-salary'),
    body: json.encode({'userId': userId}),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['totalSalary'];
  } else {
    throw Exception('Failed to load employee salary');
  }
});

// دالة لتحميل ملخص الشهر
final monthlySummaryProvider =
    FutureProvider.family.autoDispose<double, String>((ref, userId) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/MonthlySummary'),
    body: json.encode({'userId': userId}),
    headers: {'Content-Type': 'application/json'},
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['netProfit'];
  } else {
    throw Exception('Failed to load monthly summary');
  }
});

final modelsSummaryProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, String>((ref, userId) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/get-models-summary'), // غير الرابط حسب مكانك
    body: json.encode({'userId': userId}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> models = data['data'];
    return models
        .map<Map<String, dynamic>>((item) => {
              'title': item['title'],
              'value': item['value'],
            })
        .toList();
  } else {
    throw Exception('Failed to load models summary');
  }
});

final topEmployeesProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, String>((ref, userId) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/top-employees'),
    body: json.encode({'userId': userId}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> topEmployees = data['data'];
    return topEmployees
        .map<Map<String, dynamic>>((item) => {
              'label': item['label'],
              'value': item['value'],
            })
        .toList();
  } else {
    throw Exception('Failed to load top employees');
  }
});

final reportsProvider = FutureProvider.family
    .autoDispose<List<Map<String, dynamic>>, String>((ref, userId) async {
  final response = await http.post(
    Uri.parse('$_apiUrl/reports'), // غير $_apiUrl حسب متغيرك
    body: json.encode({'userId': userId}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data
        .map<Map<String, dynamic>>((item) => {
              'owner': item['owner'],
              'issue': item['issue'],
              'date': item['date'],
            })
        .toList();
  } else {
    throw Exception('فشل في تحميل التقارير');
  }
});
