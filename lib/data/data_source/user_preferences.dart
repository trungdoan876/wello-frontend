import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyUserId = 'user_id';
  static const String _keyFullname = 'user_fullname';

  /// Save user ID
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  /// Get user ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Save fullname
  static Future<void> saveFullname(String fullname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFullname, fullname);
  }

  /// Get fullname
  static Future<String?> getFullname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullname);
  }

  /// Clear all user data
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
