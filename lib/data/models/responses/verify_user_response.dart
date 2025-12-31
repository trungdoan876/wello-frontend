class VerifyUserResponse {
  final bool exists;
  final bool valid;
  final int userId;
  final String message;

  VerifyUserResponse({
    required this.exists,
    required this.valid,
    required this.userId,
    required this.message,
  });

  factory VerifyUserResponse.fromJson(Map<String, dynamic> json) {
    return VerifyUserResponse(
      exists: json['exists'] as bool,
      valid: json['valid'] as bool,
      userId: json['userId'] as int,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exists': exists,
      'valid': valid,
      'userId': userId,
      'message': message,
    };
  }
}
