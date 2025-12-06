import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../repositories/auth_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final AuthRepository authRepository;

  UserRepositoryImpl({required this.authRepository});

  @override
  Future<User> registerUser(User user) async {
    final response = await authRepository.register(
      email: user.email,
      password: user.password,
    );

    if (response.success) {
      // Return user entity with ID from response
      return User(
        email: user.email,
        password: user.password,
        id: response.idUser,
      );
    } else {
      // Throw exception if registration fails
      throw Exception(response.message ?? 'Registration failed');
    }
  }
}
