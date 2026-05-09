import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';
import '../../domain/entities/running_session.dart';

class RunningRemoteDataSource {
  /// POST /api/running/session — Lưu buổi chạy GPS
  Future<int> saveSession(String token, RunningSession session) async {
    final url = Uri.parse(ApiEndpoints.runningSession);

    print('🏃 [RUNNING API] Đang lưu session: ${jsonEncode(session.toJson())}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(session.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.trim().isEmpty) {
        return 0;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final sessionId = decoded['sessionId'] ?? decoded['id'];
        if (sessionId is int) return sessionId;
        if (sessionId is num) return sessionId.toInt();
      } else if (decoded is num) {
        return decoded.toInt();
      }

      return 0;
    } else {
      throw Exception(
        'Lưu buổi chạy thất bại: ${response.statusCode} — ${response.body}',
      );
    }
  }

  /// GET /api/running/history — Lịch sử buổi chạy
  Future<List<RunningSession>> getHistory(
    String token,
    int userId, {
    int limit = 10,
  }) async {
    final url = Uri.parse(ApiEndpoints.runningHistory(userId, limit: limit));

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => RunningSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Lấy lịch sử chạy thất bại: ${response.statusCode}');
    }
  }

  /// GET /api/running/weekly-summary — Tổng kết tuần
  Future<RunningWeeklySummary> getWeeklySummary(
    String token,
    int userId,
    String startDate, // yyyy-MM-dd (ngày đầu tuần)
  ) async {
    final url = Uri.parse(ApiEndpoints.runningWeeklySummary(userId, startDate));

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return RunningWeeklySummary.fromJson(body);
    } else {
      throw Exception('Lấy tổng kết tuần thất bại: ${response.statusCode}');
    }
  }
}
