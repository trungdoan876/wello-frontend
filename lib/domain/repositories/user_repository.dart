import '../entities/user.dart';

abstract class UserRepository {
  Future<bool> registerUser(User user);
  Future<bool> updateFcmToken(String token, String fcmToken);
}
