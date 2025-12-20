class VerifyOtpRequest {
  final String verificationToken;
  final String otp;

  VerifyOtpRequest({
    required this.verificationToken,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'verificationToken': verificationToken,
        'otp': otp,
      };
}
