import '../entities/user.dart';
import '../repositories/user_repository.dart';

class RegisterUser {
  final UserRepository repository;

  RegisterUser({required this.repository});

  Future<bool> execute({
    required String email,
    required String password,
  }) async {
    final user = User(email: email, password: password);
    return await repository.registerUser(user);
  }

 
}

