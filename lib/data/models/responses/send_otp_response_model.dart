class SendOtpResponse {
  final String verificationToken;
  final String message;

  SendOtpResponse({
    required this.verificationToken,
    required this.message,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      verificationToken: json['verificationToken'] as String,
      message: json['message'] as String,
    );
  }
}
