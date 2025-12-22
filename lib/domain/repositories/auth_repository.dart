import '../../data/models/responses/login_response_model.dart';
import '../../data/models/responses/register_response_model.dart';
import '../../data/models/responses/password_reset_response.dart';

/// Authentication repository interface
/// Defines the contract for auth operations
abstract class AuthRepository {
  /// Login user with email and password
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  /// Register new user with email and hashed password
  Future<RegisterResponseModel> register({
    required String email,
    required String hashedPassword,
  });

  /// Login with Google account
  Future<LoginResponseModel> loginWithGoogle({String? idToken});

  /// Send OTP for password reset
  Future<PasswordResetResponse> forgotPassword({required String email});



  /// Reset password with reset token
  Future<PasswordResetResponse> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
