import '../entities/user.dart';

abstract class UserRepository {
  /// Register a new user and return the user entity with ID from server.
  Future<User> registerUser(User user);
}
