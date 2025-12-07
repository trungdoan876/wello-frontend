import '../../domain/repositories/auth_repository.dart';
import '../data_source/auth_remote_data_source.dart';
import '../models/requests/login_request_model.dart';
import '../models/requests/register_request_model.dart';
import '../models/responses/login_response_model.dart';
import '../models/responses/register_response_model.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? AuthRemoteDataSource();

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(email: email, password: password);
      return await _dataSource.login(request: request);
    } catch (e) {
      return LoginResponseModel(success: false, message: 'Login failed: $e');
    }
  }

  @override
  Future<RegisterResponseModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequestModel(email: email, password: password);
      return await _dataSource.register(request: request);
    } catch (e) {
      return RegisterResponseModel(
        success: false,
        message: 'Registration failed: $e',
      );
    }
  }
}
