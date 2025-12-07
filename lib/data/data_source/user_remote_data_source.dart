import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requests/register_request_model.dart';
import '../models/responses/register_response_model.dart';

/// Remote data source for user
/// Handles direct API calls related to user operations
class UserRemoteDataSource {
  final String baseUrl;

  UserRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Register a new user
  Future<RegisterResponseModel> register({
    required RegisterRequestModel request,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        return RegisterResponseModel.fromJson(bodyJson);
      } catch (e) {
        // If response is not JSON, return a generic success
        return RegisterResponseModel(success: true, message: response.body);
      }
    } else {
      // Try to parse error message from JSON
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        return RegisterResponseModel(
          success: false,
          message: errorJson['message'] ?? 'Đăng ký thất bại',
        );
      } catch (e) {
        // If can't parse JSON, return status code
        return RegisterResponseModel(
          success: false,
          message: 'Lỗi ${response.statusCode}',
        );
      }
    }
  }
}
