import 'package:cloudinary/cloudinary.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String apiUrl = '${dotenv.env['API_URL']}/users';

final checkVerificationProvider =
    StreamProvider.family<bool, String>((ref, email) {
  return Stream.periodic(const Duration(seconds: 5), (_) async {
    final response = await Dio()
        .get('$apiUrl/check-verification', queryParameters: {'email': email});

    return response.data['isVerified'] == true;
  }).asyncMap((event) => event); // تحويل Future إلى قيمة في Stream
});
