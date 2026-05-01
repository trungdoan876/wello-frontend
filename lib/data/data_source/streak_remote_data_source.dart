import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wello_frontend/core/constants/api_endpoints.dart';
import 'package:wello_frontend/domain/entities/daily_streak_model.dart';
   // 👈 BẮT BUỘC cho jsonDecode
import 'package:flutter/foundation.dart'; // 👈 BẮT BUỘC cho debugPrint


class StreakRemoteDataSource {
  final http.Client client = http.Client();

  Future<List<DailyStreakModel>> getMonthlyStreak({
    required String token,
    required int userId,
    required int year,
    required int month,
  }) async {
    final url = Uri.parse(
      ApiEndpoints.streakMonthly(userId, year, month),
    );

    print('[STREAK API] 📅 GET $url');

    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map(
            (e) => DailyStreakModel.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList();
    } else {
      String message = 'Không thể tải dữ liệu streak';

      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {}

      debugPrint('[STREAK API] Error ${response.statusCode}: $message');
      throw Exception(message);
    }
  }
}
