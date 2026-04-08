import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/responses/profile_response_model.dart';
import '../../core/constants/api_endpoints.dart';

/// Nguồn dữ liệu từ xa cho hồ sơ người dùng
/// Xử lý các API calls trực tiếp liên quan đến profile
class ProfileRemoteDataSource {
  final String baseUrl;

  // Default for Android emulator; adjust per platform if needed
  ProfileRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  String _resolveBaseUrl() {
    // Always use production server
    return ApiEndpoints.baseUrl;
  }

  /// Fetch profile by ID
  Future<ProfileResponseModel> fetchProfileById(String token, int userId) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/info/$userId');
    print('[ProfileRemote] GET $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
    required String token,
    required int userId,
    required File imageFile,
  }) async {
    // Endpoint expects JSON body: { "base64Image": "data:image/png;base64,..." }
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/avatar/base64');
    print('[ProfileRemote] POST $url (avatar base64)');

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
      print('Dang tai anh dai dien len: $url');
      print('Duong dan file: ${imageFile.path}');

      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final mimeType = _mimeFromPath(imageFile.path);
      final dataUri = 'data:$mimeType;base64,$base64String';

      print('Kich thuoc file: ${bytes.length} bytes');
      print('Do dai Base64: ${base64String.length} ky tu');
      print('Loai MIME: $mimeType');

      final requestBody = {'base64Image': dataUri};

      print('Dang gui yeu cau...');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      final responseBody = response.body;
      print('Phan hoi tu server: ${response.statusCode}');
      print('Noi dung phan hoi: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Tai anh dai dien thanh cong');
        return true;
      } else {
        throw Exception(
          'Failed to upload avatar: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      print('Loi khi tai anh dai dien: $e');
      throw Exception('Error uploading avatar: $e');
    }
  }

  /// Update user's fullname
  Future<bool> updateFullname({
    required String token,
    required int userId,
    required String fullname,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/fullname');
    print('[ProfileRemote] PUT $url body={fullname: $fullname}');

    try {
      http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fullname': fullname}),
      );
      print(
        '[ProfileRemote] Response ${response.statusCode}: ${response.body}',
      );

      bool ok =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      if (!ok) {
        // Fallback: try POST if PUT not supported
        print('[ProfileRemote] PUT failed, trying POST $url');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'fullname': fullname}),
        );
        print(
          '[ProfileRemote] POST Response ${response.statusCode}: ${response.body}',
        );
        ok =
            response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204;
      }

      if (ok) return true;

      throw Exception(
        'Failed to update fullname: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error updating fullname: $e');
    }
  }

  /// Update user's gender
  Future<bool> updateGender({
    required String token,
    required int userId,
    required String gender,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/gender');
    print('[ProfileRemote] PUT $url body={gender: $gender}');

    try {
      http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'gender': gender}),
      );
      print(
        '[ProfileRemote] Response ${response.statusCode}: ${response.body}',
      );

      bool ok =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      if (!ok) {
        print('[ProfileRemote] PUT failed, trying POST $url');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'gender': gender}),
        );
        print(
          '[ProfileRemote] POST Response ${response.statusCode}: ${response.body}',
        );
        ok =
            response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204;
      }

      if (ok) return true;

      throw Exception(
        'Failed to update gender: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error updating gender: $e');
    }
  }

  /// Update user's age
  Future<bool> updateAge({
    required String token,
    required int userId,
    required int age,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/age');
    print('[ProfileRemote] PUT $url body={age: $age}');

    try {
      http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'age': age}),
      );
      print(
        '[ProfileRemote] Response ${response.statusCode}: ${response.body}',
      );

      bool ok =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      if (!ok) {
        print('[ProfileRemote] PUT failed, trying POST $url');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'age': age}),
        );
        print(
          '[ProfileRemote] POST Response ${response.statusCode}: ${response.body}',
        );
        ok =
            response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204;
      }

      if (ok) return true;

      throw Exception(
        'Failed to update age: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error updating age: $e');
    }
  }

  /// Update user's height
  Future<bool> updateHeight({
    required String token,
    required int userId,
    required int height,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/height');
    print('[ProfileRemote] PUT $url body={height: $height}');

    try {
      http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'height': height}),
      );
      print(
        '[ProfileRemote] Response ${response.statusCode}: ${response.body}',
      );

      bool ok =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      if (!ok) {
        print('[ProfileRemote] PUT failed, trying POST $url');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'height': height}),
        );
        print(
          '[ProfileRemote] POST Response ${response.statusCode}: ${response.body}',
        );
        ok =
            response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204;
      }

      if (ok) return true;

      throw Exception(
        'Failed to update height: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error updating height: $e');
    }
  }

  Future<bool> updateWeight({
    required String token,
    required int userId,
    required int weight,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/weight');
    print('[ProfileRemote] PUT $url body={weight: $weight}');

    try {
      http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'weight': weight}),
      );
      print(
        '[ProfileRemote] Response ${response.statusCode}: ${response.body}',
      );

      bool ok =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      if (!ok) {
        print('[ProfileRemote] PUT failed, trying POST $url');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'weight': weight}),
        );
        print(
          '[ProfileRemote] POST Response ${response.statusCode}: ${response.body}',
        );
        ok =
            response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204;
      }

      if (ok) return true;

      throw Exception(
        'Failed to update weight: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error updating weight: $e');
    }
  }

  Future<bool> updateGoal({
    required String token,
    required int userId,
    required String goal,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/goal');
    print('[ProfileRemote] PUT $url body={goal: $goal}');

    try {
      http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'goal': goal}),
      );
      print(
        '[ProfileRemote] Response ${response.statusCode}: ${response.body}',
      );

      bool ok =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      if (!ok) {
        print('[ProfileRemote] PUT failed, trying POST $url');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'goal': goal}),
        );
        print(
          '[ProfileRemote] POST Response ${response.statusCode}: ${response.body}',
        );
        ok =
            response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204;
      }

      if (ok) return true;

      throw Exception(
        'Failed to update goal: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error updating goal: $e');
    }
  }

  Future<bool> updateActivityLevel({
    required String token,
    required int userId,
    required String activityLevel,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/activity-level');
    print('[ProfileRemote] PUT $url body={activityLevel: $activityLevel}');

    try {
      http.Response response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'activityLevel': activityLevel}),
      );
      print(
        '[ProfileRemote] Response ${response.statusCode}: ${response.body}',
      );

      bool ok =
          response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
      if (!ok) {
        print('[ProfileRemote] PUT failed, trying POST $url');
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'activityLevel': activityLevel}),
        );
        print(
          '[ProfileRemote] POST Response ${response.statusCode}: ${response.body}',
        );
        ok =
            response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 204;
      }

      if (ok) return true;

      throw Exception(
        'Failed to update activityLevel: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      throw Exception('Error updating activityLevel: $e');
    }
  }


  /// Update Water Reminder Settings
  /// POST /api/profile/{userId}/water-reminder-settings?enabled=...&startHour=...&endHour=...&intervalHours=...&intervalMinutes=...
  Future<bool> updateWaterReminderSettings({
    required String token,
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
      print('Dang cap nhat thiet lap nhac nuoc: $url');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Phan hoi tu server: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to update water reminder settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Loi khi cap nhat thiet lap nhac nuoc: $e');
      throw Exception('Error updating water reminder settings: $e');
    }
  }
}
