import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requests/login_request_model.dart';
import '../models/requests/register_request_model.dart';
import '../models/requests/send_otp_request_model.dart';
import '../models/requests/verify_otp_request_model.dart';
import '../models/responses/login_response_model.dart';
import '../models/responses/register_response_model.dart';
import '../models/responses/send_otp_response_model.dart';
import '../models/responses/verify_otp_response_model.dart';

/// Remote data source for authentication
/// Handles direct API calls related to auth (login, register)
class AuthRemoteDataSource {
  final String baseUrl;

  AuthRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Login user
  Future<LoginResponseModel> login({
    required LoginRequestModel request,
  }) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      try {
        final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponseModel.fromJson(bodyJson);
      } catch (e) {
        // If response is not JSON, return a generic success
        return LoginResponseModel(success: true, message: response.body);
      }
    } else {
      // Try to parse error message from JSON
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponseModel(
          success: false,
          message: errorJson['message'] ?? 'Đăng nhập thất bại',
        );
      } catch (e) {
        // If can't parse JSON, return status code
        return LoginResponseModel(
          success: false,
          message: 'Lỗi ${response.statusCode}',
        );
      }
    }
  }

  /// Register new user
  Future<RegisterResponseModel> register({
    required RegisterRequestModel request,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
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

  /// Login with Google ID token
  Future<LoginResponseModel> loginWithGoogle({
    required String idToken,
  }) async {
    final url = Uri.parse('$baseUrl/google-login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      try {
        final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponseModel.fromJson(bodyJson);
      } catch (e) {
        return LoginResponseModel(success: true, message: response.body);
      }
    } else {
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponseModel(
          success: false,
          message: errorJson['message'] ?? 'Google login failed',
        );
      } catch (e) {
        return LoginResponseModel(
          success: false,
          message: 'Error ${response.statusCode}',
        );
      }
    }
  }

  /// Send OTP to email for registration
  Future<SendOtpResponse> sendOtp({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/send-otp');
    final request = SendOtpRequest(email: email, password: password);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        return SendOtpResponse.fromJson(bodyJson);
      } else {
        // Parse error message
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorJson['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  /// Verify OTP and create account
  Future<VerifyOtpResponse> verifyOtp({
    required String verificationToken,
    required String otp,
  }) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    final request = VerifyOtpRequest(
      verificationToken: verificationToken,
      otp: otp,
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        return VerifyOtpResponse.fromJson(bodyJson);
      } else {
        // Parse error message
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorJson['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  /// Resend OTP to email
  Future<SendOtpResponse> resendOtp({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/resend-otp');
    final request = SendOtpRequest(email: email, password: password);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        return SendOtpResponse.fromJson(bodyJson);
      } else {
        // Parse error message
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorJson['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      throw Exception('Error resending OTP: $e');
    }
  }
}
