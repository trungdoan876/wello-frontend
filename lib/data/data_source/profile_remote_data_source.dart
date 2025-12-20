import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/responses/profile_response_model.dart';

/// Remote data source for profile
/// Handles direct API calls related to profile
class ProfileRemoteDataSource {
  final String baseUrl;

  ProfileRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Fetch profile by ID
  Future<ProfileResponseModel> fetchProfileById(int userId) async {
    final url = Uri.parse('$baseUrl/profile/info/$userId');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return ProfileResponseModel.fromJson(jsonData);
      } else {
        throw Exception(
          'Failed to load profile: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  /// Upload profile avatar using base64 payload (data URI)
  Future<bool> uploadAvatar({
    required int userId,
    required File imageFile,
  }) async {
    // Endpoint expects JSON body: { "base64Image": "data:image/png;base64,..." }
    final url = Uri.parse('$baseUrl/profile/$userId/avatar/base64');

    // Pick MIME type from file extension; default to jpeg
    String _mimeFromPath(String path) {
      final lower = path.toLowerCase();
      if (lower.endsWith('.png')) return 'image/png';
      if (lower.endsWith('.webp')) return 'image/webp';
      if (lower.endsWith('.gif')) return 'image/gif';
      if (lower.endsWith('.bmp')) return 'image/bmp';
      return 'image/jpeg';
    }

    try {
      print('📤 Uploading avatar to: $url');
      print('📁 File path: ${imageFile.path}');

      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = _mimeFromPath(imageFile.path);
      final dataUri = 'data:$mimeType;base64,$base64String';

      print('📊 File size: ${bytes.length} bytes');
      print('🔐 Base64 length: ${base64String.length} characters');
      print('🧾 MIME: $mimeType');

      final requestBody = {'base64Image': dataUri};

      print('⏳ Sending request...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseBody = response.body;
      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Avatar uploaded successfully');
        return true;
      } else {
        throw Exception(
          'Failed to upload avatar: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      print('❌ Error uploading avatar: $e');
      throw Exception('Error uploading avatar: $e');
    }
  }

  /// Update FCM Token for user
  /// POST /api/profile/{userId}/fcm-token?fcmToken=...
  Future<bool> updateFcmToken({
    required int userId,
    required String fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/profile/$userId/fcm-token?fcmToken=$fcmToken');

    try {
      print('🌐 Updating FCM Token: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to update FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating FCM token: $e');
      throw Exception('Error updating FCM token: $e');
    }
  }

  /// Update Water Reminder Settings
  /// POST /api/profile/{userId}/water-reminder-settings?enabled=...&startHour=...&endHour=...&intervalHours=...&intervalMinutes=...
  Future<bool> updateWaterReminderSettings({
    required int userId,
    required bool enabled,
    required int startHour,
    required int endHour,
    required int intervalHours,
    required int intervalMinutes,
  }) async {
    final url = Uri.parse(
      '$baseUrl/profile/$userId/water-reminder-settings?'
      'enabled=$enabled&startHour=$startHour&endHour=$endHour&intervalHours=$intervalHours&intervalMinutes=$intervalMinutes',
    );

    try {
      print('🌐 Updating Water Reminder Settings: $url');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to update water reminder settings: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating water reminder settings: $e');
      throw Exception('Error updating water reminder settings: $e');
    }
  }
}
