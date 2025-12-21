import '../../domain/repositories/auth_repository.dart';
import '../data_source/auth_remote_data_source.dart';
import '../models/requests/login_request_model.dart';
import '../models/requests/register_request_model.dart';
import '../models/responses/login_response_model.dart';
import '../models/responses/register_response_model.dart';
import '../models/responses/send_otp_response_model.dart';
import '../models/responses/verify_otp_response_model.dart';
import '../models/responses/password_reset_response.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_constants.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? AuthRemoteDataSource();

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(email: email, password: password);
      return await _dataSource.login(request: request);
    } catch (e) {
      return LoginResponseModel(success: false, message: 'Login failed: $e');
    }
  }

  @override
  Future<RegisterResponseModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequestModel(email: email, password: password);
      return await _dataSource.register(request: request);
    } catch (e) {
      return RegisterResponseModel(
        success: false,
        message: 'Registration failed: $e',
      );
    }
  }

  /// Send OTP to email
  Future<SendOtpResponse> sendOtp({
    required String email,
    required String password,
  }) async {
    return await _dataSource.sendOtp(email: email, password: password);
  }

  /// Verify OTP and create account
  Future<VerifyOtpResponse> verifyOtp({
    required String verificationToken,
    required String otp,
  }) async {
    return await _dataSource.verifyOtp(
      verificationToken: verificationToken,
      otp: otp,
    );
  }

  @override
  Future<LoginResponseModel> loginWithGoogle({String? idToken}) async {
    try {
      // If idToken is provided, use it directly
      if (idToken != null) {
        return await _dataSource.loginWithGoogle(idToken: idToken);
      }

      // Otherwise, perform Google Sign-In flow
      print('ὓ5 DEBUG: Starting Google Sign-In...');
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        // Web Client ID required for ID token on Android
        serverClientId: AppConstants.googleWebClientId,
      );

      print('ὓ5 DEBUG: GoogleSignIn initialized with serverClientId');
      
      // Sign in with Google
      final account = await googleSignIn.signIn();
      print('ὓ5 DEBUG: Sign-in completed. Account: ${account?.email ?? 'null'}');
      
      if (account == null) {
        print('ὓ4 DEBUG: User cancelled sign-in');
        return LoginResponseModel(
          success: false,
          message: 'Google sign-in cancelled',
        );
      }

      print('ὓ5 DEBUG: Getting authentication...');
      // Get authentication
      final auth = await account.authentication;
      print('ὓ5 DEBUG: Authentication object received');
      print('ὓ5 DEBUG: ID Token: ${auth.idToken != null ? "EXISTS (${auth.idToken!.substring(0, 20)}...)" : "NULL"}');
      print('ὓ5 DEBUG: Access Token: ${auth.accessToken != null ? "EXISTS" : "NULL"}');
      
      final token = auth.idToken;

      if (token == null) {
        print('ὓ4 DEBUG: ID Token is null!');
        print('ὓ4 DEBUG: Auth object details: accessToken=${auth.accessToken != null}, serverAuthCode=${auth.serverAuthCode}');
        return LoginResponseModel(
          success: false,
          message: 'Failed to get ID token',
        );
      }

      print('ὓ5 DEBUG: Calling backend API with ID token...');
      // Call backend API
      final response = await _dataSource.loginWithGoogle(idToken: token);
      print('ὓ5 DEBUG: Backend response: success=${response.success}');
      return response;
    } catch (e, stackTrace) {
      print('ὓ4 DEBUG: Exception caught!');
      print('ὓ4 DEBUG: Error type: ${e.runtimeType}');
      print('ὓ4 DEBUG: Error message: $e');
      print('ὓ4 DEBUG: Stack trace: $stackTrace');
      return LoginResponseModel(
        success: false,
        message: 'Google login failed: $e',
      );
    }
  }

  /// Resend OTP to email
  Future<SendOtpResponse> resendOtp({
    required String email,
    required String password,
  }) async {
    return await _dataSource.resendOtp(email: email, password: password);
  }

  @override
  Future<PasswordResetResponse> forgotPassword({
    required String email,
  }) async {
    try {
      return await _dataSource.forgotPassword(email: email);
    } catch (e) {
      return PasswordResetResponse(
        success: false,
        message: 'Failed to send reset OTP: $e',
      );
    }
  }

  @override
  Future<PasswordResetResponse> verifyResetOtp({
    required String email,
    required String otp,
    required String verificationToken,
  }) async {
    try {
      return await _dataSource.verifyResetOtp(
        email: email,
        otp: otp,
        verificationToken: verificationToken,
      );
    } catch (e) {
      return PasswordResetResponse(
        success: false,
        message: 'Failed to verify OTP: $e',
      );
    }
  }

  @override
  Future<PasswordResetResponse> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      return await _dataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
    } catch (e) {
      return PasswordResetResponse(
        success: false,
        message: 'Failed to reset password: $e',
      );
    }
  }
}
