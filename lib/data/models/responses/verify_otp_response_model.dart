class VerifyOtpResponse {
  final int userId;
  final String message;

  VerifyOtpResponse({
    required this.userId,
    required this.message,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      userId: json['userId'] as int,
      message: json['message'] as String,
    );
  }
}
