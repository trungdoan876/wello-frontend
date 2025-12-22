class RegisterRequestModel {
  final String email;
  final String hashedPassword;

  RegisterRequestModel({
    required this.email,
    required this.hashedPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'hashedPassword': hashedPassword,
    };
  }
}
