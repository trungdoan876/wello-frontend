import '../../data/data_source/user_preferences.dart';

/// Helper class for authentication-related operations
class AuthHelper {
  /// Get both token and userId from shared preferences
  /// Returns null if either token or userId is missing
  static Future<AuthCredentials?> getCredentials() async {
    final token = await UserPreferences.getToken();
    final userId = await UserPreferences.getUserId();
    
    if (token == null || userId == null) {
      return null;
    }
    
    return AuthCredentials(token: token, userId: userId);
  }
  
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final userId = await UserPreferences.getUserId();
    return userId != null;
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
  
  AuthCredentials({
    required this.token,
    required this.userId,
  });
  
  String get userIdString => userId.toString();
}
