import '../entities/user.dart';
import '../repositories/user_repository.dart';

class RegisterUser {
  final UserRepository repository;

  RegisterUser({required this.repository});

  /// Register a new user and return the registered user entity with ID.
  Future<User> execute({
    required String email,
    required String password,
  }) async {
    final user = User(email: email, password: password);
    return await repository.registerUser(user);
  }
}
