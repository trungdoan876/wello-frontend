class SendOtpRequest {
  final String email;
  final String password;

  SendOtpRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}
