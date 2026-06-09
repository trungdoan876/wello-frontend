import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';

class NotificationRemoteDataSource {
  final String baseUrl;

  NotificationRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  /// Lấy danh sách tất cả thông báo
  Future<List<Map<String, dynamic>>> getNotifications(String token) async {
    final url = Uri.parse('$baseUrl/notifications');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Không thể tải thông báo: ${response.statusCode}');
    }
  }

  /// Lấy số lượng thông báo chưa đọc
  Future<int> getUnreadCount(String token) async {
    final url = Uri.parse('$baseUrl/notifications/unread-count');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Không thể tải số lượng thông báo chưa đọc: ${response.statusCode}');
    }
  }

  /// Đánh dấu thông báo đã đọc
  Future<bool> markAsRead(String token, int id) async {
    final url = Uri.parse('$baseUrl/notifications/$id/read');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}
