class VerifyResetOtpRequest {
  final String email;
  final String otp;
  final String verificationToken;

  VerifyResetOtpRequest({
    required this.email,
    required this.otp,
    required this.verificationToken,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otp': otp,
        'verificationToken': verificationToken,
      };
}
