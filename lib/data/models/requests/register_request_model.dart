import '../../../domain/entities/user.dart';

class RegisterRequestModel {
  final String email;
  final String password;

  RegisterRequestModel({required this.email, required this.password});

  factory RegisterRequestModel.fromEntity(User user) {
    return RegisterRequestModel(email: user.email, password: user.password);
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
