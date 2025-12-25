/// Validators utility class for form validation
class Validators {
  /// Validate email format
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Email không được để trống';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email.trim())) {
      return 'Email không hợp lệ (ví dụ: ten@domain.com)';
    }

    return null;
  }

  /// Validate password strength
  /// Returns error message if invalid, null if valid
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    if (password.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  /// Validate confirm password matches original password
  /// Returns error message if invalid, null if valid
  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }

    if (password != confirmPassword) {
      return 'Mật khẩu xác nhận không khớp';
    }

    return null;
  }

  /// Validate that a field is not empty
  /// Returns error message if empty, null if valid
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }
}
