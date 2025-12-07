import '../entities/user.dart';

abstract class UserRepository {
  Future<bool> registerUser(User user);
}
