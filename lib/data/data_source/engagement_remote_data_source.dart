import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';

class EngagementRemoteDataSource {
  final String baseUrl;

  EngagementRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  /// Điểm danh hằng ngày
  Future<Map<String, dynamic>> dailyCheckIn(String token) async {
    final url = Uri.parse('$baseUrl/engagement/check-in');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể điểm danh: ${response.statusCode}');
    }
  }
}
