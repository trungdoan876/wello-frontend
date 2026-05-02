import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requests/register_request_model.dart';
import '../models/responses/register_response_model.dart';
import '../models/responses/verify_user_response.dart';
import '../../core/constants/api_endpoints.dart';

/// Nguồn dữ liệu từ xa cho người dùng
/// Xử lý các API calls liên quan đến thao tác người dùng
class UserRemoteDataSource {
  final String baseUrl;

  UserRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  /// Đăng ký người dùng mới
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

  /// Verify userId và email có khớp nhau không
  Future<VerifyUserResponse> verifyUser({
    required int userId,
    required String email,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/user/verify?userId=$userId&email=${Uri.encodeComponent(email)}');
    print('Dang goi GET: $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return VerifyUserResponse.fromJson(bodyJson);
    } else {
      // Nếu API trả về lỗi, throw exception
      print('Loi server (VerifyUser): ${response.body}');
      throw Exception('Không thể verify user: ${response.statusCode}');
    }
  }
  
  /// Cập nhật FCM Token
  Future<bool> updateFcmToken({
    required String token,
    required String fcmToken,
  }) async {
    final url = Uri.parse('$baseUrl/user/fcm-token');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'token': fcmToken}),
    );

    return response.statusCode == 200;
  }
}
