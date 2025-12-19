import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/responses/profile_response_model.dart';

/// Remote data source for profile
/// Handles direct API calls related to profile
class ProfileRemoteDataSource {
  final String baseUrl;

  // Default for Android emulator; adjust per platform if needed
  ProfileRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  String _resolveBaseUrl() {
    if (kIsWeb) return 'http://localhost:8080/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
    } catch (_) {
      // Platform may not be available in some contexts
    }
    return 'http://localhost:8080/api';
  }

  /// Fetch profile by ID
  Future<ProfileResponseModel> fetchProfileById(int userId) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/info/$userId');
    print('[ProfileRemote] GET $url');

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

  /// Update user's fullname
  Future<bool> updateFullname({
    required int userId,
    required String fullname,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/fullname');
    print('[ProfileRemote] PUT $url body={fullname: $fullname}');

    try {
      http.Response response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
          headers: {'Content-Type': 'application/json'},
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
    required int userId,
    required String gender,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/gender');
    print('[ProfileRemote] PUT $url body={gender: $gender}');

    try {
      http.Response response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
          headers: {'Content-Type': 'application/json'},
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
  Future<bool> updateAge({required int userId, required int age}) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/age');
    print('[ProfileRemote] PUT $url body={age: $age}');

    try {
      http.Response response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
          headers: {'Content-Type': 'application/json'},
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
  Future<bool> updateHeight({required int userId, required int height}) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/height');
    print('[ProfileRemote] PUT $url body={height: $height}');

    try {
      http.Response response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
          headers: {'Content-Type': 'application/json'},
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

  Future<bool> updateWeight({required int userId, required int weight}) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/weight');
    print('[ProfileRemote] PUT $url body={weight: $weight}');

    try {
      http.Response response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
          headers: {'Content-Type': 'application/json'},
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

  Future<bool> updateGoal({required int userId, required String goal}) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/goal');
    print('[ProfileRemote] PUT $url body={goal: $goal}');

    try {
      http.Response response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
          headers: {'Content-Type': 'application/json'},
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
    required int userId,
    required String activityLevel,
  }) async {
    final resolved = _resolveBaseUrl();
    final url = Uri.parse('$resolved/profile/$userId/activity-level');
    print('[ProfileRemote] PUT $url body={activityLevel: $activityLevel}');

    try {
      http.Response response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
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
          headers: {'Content-Type': 'application/json'},
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
}
