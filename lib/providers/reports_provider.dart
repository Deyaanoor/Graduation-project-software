import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

final reportsProvider = StateNotifierProvider<ReportsNotifier,
    AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ReportsNotifier();
});

class ReportsNotifier
    extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  ReportsNotifier() : super(const AsyncValue.loading());

  static const String _baseUrl = 'http://localhost:5000/reports';

  Future<void> fetchReports({required String userId}) async {
    try {
      state = const AsyncValue.loading();
      final response = await http.get(
        Uri.parse('$_baseUrl/$userId'), // أضف userId هنا
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<Map<String, dynamic>> reports = data
            .map((item) => _parseReportItem(item))
            .where((item) => item.isNotEmpty)
            .toList()
          ..sort((a, b) =>
              (b['date'] as DateTime).compareTo(a['date'] as DateTime));

        state = AsyncValue.data(reports);
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Map<String, dynamic> _parseReportItem(dynamic item) {
    try {
      return {
        '_id': item['_id']?.toString() ?? '',
        'owner': item['owner']?.toString() ?? 'غير معروف',
        'cost': item['cost']?.toString() ?? '0',
        'plateNumber': item['plateNumber']?.toString() ?? 'بدون رقم',
        'issue': item['issue']?.toString() ?? 'لا توجد معلومات',
        'make': item['make']?.toString() ?? 'غير محدد',
        'model': item['model']?.toString() ?? 'غير محدد',
        'year': item['year']?.toString() ?? 'غير معروف',
        'symptoms': item['symptoms']?.toString() ?? 'لا توجد أعراض',
        'repairDescription':
            item['repairDescription']?.toString() ?? 'لا يوجد وصف',
        'usedParts': _parseUsedParts(item['usedParts']),
        'date': _parseDate(item['date']),
        'imageUrls': _parseImageUrls(item['imageUrls']),
        'status': item['status']?.toString() ?? 'غير محدد',
        'mechanicName': item['mechanicName']?.toString() ?? 'غير معروف',
      };
    } catch (e, stack) {
      print('Error parsing item: $e\nStack trace: $stack');
      return {};
    }
  }

  List<String> _parseImageUrls(dynamic rawUrls) {
    if (rawUrls == null) return [];

    if (rawUrls is String) {
      try {
        return List<String>.from(jsonDecode(rawUrls));
      } catch (_) {
        return [rawUrls];
      }
    }
    if (rawUrls is List) {
      return rawUrls
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  List<String> _parseUsedParts(dynamic rawParts) {
    if (rawParts == null) return [];

    if (rawParts is String) {
      try {
        return List<String>.from(jsonDecode(rawParts));
      } catch (_) {
        return [rawParts];
      }
    }
    if (rawParts is List) {
      return rawParts.map((e) => e?.toString() ?? '').toList();
    }

    return [];
  }

  DateTime _parseDate(dynamic date) {
    try {
      return date != null ? DateTime.parse(date.toString()) : DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<String> addReport({
    required String owner,
    required String cost,
    required String plateNumber,
    required String issue,
    required String make,
    required String model,
    required String year,
    required String symptoms,
    required String repairDescription,
    required List<String> usedParts,
    required List<Uint8List> imageBytesList,
    required List<String> fileNames,
    required String status,
    required String mechanicName,
    required String userId,
  }) async {
    try {
      state = const AsyncValue.loading();

      final request = http.MultipartRequest('POST', Uri.parse(_baseUrl))
        ..fields.addAll({
          'owner': owner,
          'cost': cost,
          'plateNumber': plateNumber,
          'issue': issue,
          'make': make,
          'model': model,
          'year': year,
          'symptoms': symptoms,
          'repairDescription': repairDescription,
          'usedParts': jsonEncode(usedParts),
          'date': DateTime.now().toIso8601String(),
          'status': status,
          'mechanicName': mechanicName,
          'user_id': userId,
        });

      for (int i = 0; i < imageBytesList.length; i++) {
        request.files.add(http.MultipartFile.fromBytes(
          'images',
          imageBytesList[i],
          filename: fileNames[i],
          contentType: MediaType('image', _getFileExtension(fileNames[i])),
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        final reportId = jsonResponse['reportId'];

        return reportId;
      } else {
        throw Exception('Failed to add report: ${response.statusCode}');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last : 'jpeg';
  }

  Future<void> refreshReports(String userId) async {
    try {
      await fetchReports(userId: userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchReportById(String reportId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/report/$reportId'));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        return _parseReportItem(data);
      } else {
        throw Exception('Failed to load report: ${response.statusCode}');
      }
    } catch (e, stack) {
      ('Error fetching report by ID: $e\nStack trace: $stack');
      return null; // Return null if error occurs
    }
  }
}

final selectedReportProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);
