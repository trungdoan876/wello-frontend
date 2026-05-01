import 'package:wello_frontend/domain/entities/user.dart';

class RegisterRequestModel {
  final String email;
  final String hashedPassword;

  RegisterRequestModel({required this.email, required this.hashedPassword});

  factory RegisterRequestModel.fromEntity(User user) {
    return RegisterRequestModel(
      email: user.email,
      hashedPassword: user.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'hashedPassword': hashedPassword};
  }
}
