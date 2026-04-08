import '../../data/data_source/user_preferences.dart';
import '../../data/data_source/user_remote_data_source.dart';

/// Helper class for authentication-related operations
class AuthHelper {
  /// Get token, userId, and email from shared preferences
  /// Returns null if any required field is missing
  static Future<AuthCredentials?> getCredentials() async {
    final token = await UserPreferences.getToken();
    final userId = await UserPreferences.getUserId();
    final email = await UserPreferences.getEmail();
    
    if (token == null || userId == null) {
      return null;
    }
    
    return AuthCredentials(
      token: token,
      userId: userId,
      email: email,
    );
  }
  
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final userId = await UserPreferences.getUserId();
    return userId != null;
  }
  
  /// Verify xem userId và email trong local storage có khớp nhau không
  /// Returns true nếu valid, false nếu không valid hoặc thiếu email
  static Future<bool> verifyStoredCredentials() async {
    final credentials = await getCredentials();
    
    // Nếu không có credentials hoặc không có email, return false
    if (credentials == null || credentials.email == null) {
      return false;
    }
    
    try {
      print('Dang goi verifyUser voi userId: ${credentials.userId}, email: ${credentials.email}');
      final remoteDataSource = UserRemoteDataSource();
      final response = await remoteDataSource.verifyUser(
        userId: credentials.userId,
        email: credentials.email!,
        token: credentials.token,
      );
      
      // Kiểm tra cả exists và valid
      return response.exists && response.valid;
    } catch (e) {
      // Nếu API call thất bại, return false
      print('Loi khi xac thuc thong tin dang nhap da luu: $e');
      return false;
    }
  }
  
  /// Clear all auth data
  static Future<void> logout() async {
    await UserPreferences.clearAll();
  }
}

/// Model to hold authentication credentials
class AuthCredentials {
  final String token;
  final int userId;
  final String? email;
  
  AuthCredentials({
    required this.token,
    required this.userId,
    this.email,
  });
  
  String get userIdString => userId.toString();
}
