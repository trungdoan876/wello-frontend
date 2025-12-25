class VerifyOtpResponse {
  final bool success;
  final String email;
  final String type; // "registration" or "password_reset"
  final String message;
  final String? hashedPassword; // For registration
  final String? resetToken; // For password reset

  VerifyOtpResponse({
    required this.success,
    required this.email,
    required this.type,
    required this.message,
    this.hashedPassword,
    this.resetToken,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] as bool,
      email: json['email'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      hashedPassword: json['hashedPassword'] as String?,
      resetToken: json['resetToken'] as String?,
    );
  }
}
