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
    required String hashedPassword,
  }) async {
    try {
      return await _dataSource.register(
        email: email,
        hashedPassword: hashedPassword,
      );
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
      print('DEBUG: Dang bat dau dang nhap Google...');
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        // Web Client ID required for ID token on Android
        serverClientId: AppConstants.googleWebClientId,
      );

      print('DEBUG: GoogleSignIn da duoc khoi tao voi serverClientId');
      
      // Sign in with Google
      final account = await googleSignIn.signIn();
      print('ὓ5 DEBUG: Sign-in completed. Account: ${account?.email ?? 'null'}');
      
      if (account == null) {
        print('DEBUG: Nguoi dung da huy dang nhap');
        return LoginResponseModel(
          success: false,
          message: 'Google sign-in cancelled',
        );
      }

      print('DEBUG: Dang lay thong tin xac thuc...');
      // Get authentication
      final auth = await account.authentication;
      print('DEBUG: Nhan duoc doi tuong xac thuc');
      print('DEBUG: ID Token: ${auth.idToken != null ? "TON TAI (${auth.idToken!.substring(0, 20)}...)" : "NULL"}');
      print('DEBUG: Access Token: ${auth.accessToken != null ? "TON TAI" : "NULL"}');
      
      final token = auth.idToken;

      if (token == null) {
        print('DEBUG: ID Token bi null!');
        print('DEBUG: Chi tiet doi tuong xac thuc: accessToken=${auth.accessToken != null}, serverAuthCode=${auth.serverAuthCode}');
        return LoginResponseModel(
          success: false,
          message: 'Failed to get ID token',
        );
      }

      print('DEBUG: Dang goi backend API voi ID token...');
      // Call backend API
      final response = await _dataSource.loginWithGoogle(idToken: token);
      print('DEBUG: Phan hoi tu backend: success=${response.success}');
      return response;
    } catch (e, stackTrace) {
      print('DEBUG: Nhan duoc ngoai le!');
      print('DEBUG: Loai loi: ${e.runtimeType}');
      print('DEBUG: Thong bao loi: $e');
      print('DEBUG: Stack trace: $stackTrace');
      return LoginResponseModel(
        success: false,
        message: 'Google login failed: $e',
      );
    }
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
