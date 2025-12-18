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
    final url = Uri.parse('$baseUrl/profile/$userId');

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

  /// Upload profile avatar
  Future<bool> uploadAvatar({
    required int userId,
    required File imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/profile/$userId/avatar');

    try {
      final request = http.MultipartRequest('PUT', url);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to upload avatar: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error uploading avatar: $e');
    }
  }
}