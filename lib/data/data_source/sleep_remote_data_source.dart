import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wello_frontend/core/constants/api_endpoints.dart';
import 'package:wello_frontend/data/models/responses/sleep_today_response.dart';
import 'package:wello_frontend/domain/entities/sleep_log.dart';

class SleepRemoteDataSource {
  final http.Client client = http.Client();

  // 1. Log Bedtime
  Future<SleepLog> logBedtime({
    required int userId,
    required String bedtime, // ISO format: "2026-01-01T21:00:00"
  }) async {
    final url = Uri.parse(ApiEndpoints.sleepLogBedtime);
    print('[SLEEP API] 🛏️ POST $url');
    print('[SLEEP API] Body: userId=$userId, bedtime=$bedtime');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'bedtime': bedtime,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SleepLog.fromJson(data);
    } else if (response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Bad request');
    } else {
      throw Exception('Failed to log bedtime: ${response.statusCode}');
    }
  }

  // 2. Complete Sleep
  Future<SleepLog> completeSleep({
    required int userId,
    required String wakeTime, // ISO format
    required int quality, // 1-5 (Mandatory per spec)
    String? notes,
  }) async {
    final url = Uri.parse(ApiEndpoints.sleepComplete);
    print('[SLEEP API] ☀️ PUT $url');
    print('[SLEEP API] Body: userId=$userId, wakeTime=$wakeTime, quality=$quality');

    final body = {
      'userId': userId,
      'wakeTime': wakeTime,
      'quality': quality,
      'notes': notes ?? "", // Luôn gửi notes, ít nhất là chuỗi rỗng
    };

    final response = await client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('[SLEEP API] 📥 Response: ${response.statusCode}');
    print('[SLEEP API] Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SleepLog.fromJson(data);
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error completing sleep');
    } else {
      throw Exception('Failed to complete sleep: ${response.statusCode}');
    }
  }

  // 3. Get Today's Sleep
  Future<SleepTodayResponse> getTodaySleep({
    required int userId,
    required String date, // Format: "2026-01-02"
  }) async {
    final url = Uri.parse(ApiEndpoints.sleepToday(userId, date));
    print('[SLEEP API] 📅 GET $url');

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SleepTodayResponse.fromJson(data);
    } else {
      throw Exception('Failed to get today\'s sleep: ${response.statusCode}');
    }
  }

  // 4. Update Sleep
  Future<SleepLog> updateSleep({
    required int sleepId,
    required int userId,
    required String sleepTime,
    required String wakeTime,
    required int quality,
    String? notes,
  }) async {
    final url = Uri.parse(ApiEndpoints.sleepUpdate(sleepId, userId));
    
    final body = {
      'userId': userId,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'quality': quality,
      'notes': (notes == null || notes.isEmpty) ? null : notes,
    };

    print('[SLEEP API] 🔄 PUT $url');
    print('[SLEEP API] Body: $body');

    final response = await client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('[SLEEP API] 📥 Response: ${response.statusCode}');
    print('[SLEEP API] Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SleepLog.fromJson(data);
    } else if (response.statusCode == 404 || response.statusCode == 400) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error updating sleep');
    } else {
      throw Exception('Failed to update sleep: ${response.statusCode}');
    }
  }

  // 5. Delete Sleep
  Future<void> deleteSleep({
    required int sleepId,
    required int userId,
  }) async {
    final url = Uri.parse(ApiEndpoints.sleepDelete(sleepId, userId));

    final response = await client.delete(url);

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Sleep tracker not found');
    } else {
      throw Exception('Failed to delete sleep: ${response.statusCode}');
    }
  }
}
