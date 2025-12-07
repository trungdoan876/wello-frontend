import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_source/user_remote_data_source.dart';
import '../models/requests/register_request_model.dart';
import '../models/responses/register_response_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userRemoteDataSource;

  UserRepositoryImpl({required this.userRemoteDataSource});

  @override
  Future<bool> registerUser(User user) async {
    final request = RegisterRequestModel.fromEntity(user);
    final RegisterResponseModel response = await userRemoteDataSource.register(
      request: request,
    );
    return response.success;
  }
}
