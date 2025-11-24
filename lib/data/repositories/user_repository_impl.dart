import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../services/api_service.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiService apiService;

  UserRepositoryImpl({required this.apiService});

  @override
  Future<bool> registerUser(User user) async {
    return await apiService.register(
      email: user.email,
      password: user.password,
    );
  }
}
