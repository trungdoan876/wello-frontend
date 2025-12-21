class PasswordResetResponse {
  final bool success;
  final String message;
  final String? resetToken;
  final String? verificationToken;

  PasswordResetResponse({
    required this.success,
    required this.message,
    this.resetToken,
    this.verificationToken,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      resetToken: json['resetToken'] as String?,
      verificationToken: json['verificationToken'] as String?,
    );
  }
}
