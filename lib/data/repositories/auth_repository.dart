import '../../domain/repositories/auth_repository.dart';
import '../data_source/auth_remote_data_source.dart';
import '../models/requests/login_request_model.dart';
import '../models/requests/register_request_model.dart';
import '../models/responses/login_response_model.dart';
import '../models/responses/register_response_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      final request = LoginRequestModel(
        email: email,
        password: password,
      );
      return await _dataSource.login(request: request);
    } catch (e) {
      return LoginResponseModel(
        success: false,
        message: 'Login failed: $e',
      );
    }
  }

  @override
  Future<RegisterResponseModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final request = RegisterRequestModel(
        email: email,
        password: password,
      );
      return await _dataSource.register(request: request);
    } catch (e) {
      return RegisterResponseModel(
        success: false,
        message: 'Registration failed: $e',
      );
    }
  }

  @override
  Future<LoginResponseModel> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign in with Google
      final account = await googleSignIn.signIn();
      if (account == null) {
        return LoginResponseModel(
          success: false,
          message: 'Google sign-in cancelled',
        );
      }

      // Get authentication
      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        return LoginResponseModel(
          success: false,
          message: 'Failed to get ID token',
        );
      }

      // Call backend API
      return await _dataSource.loginWithGoogle(idToken: idToken);
    } catch (e) {
      return LoginResponseModel(
        success: false,
        message: 'Google login failed: $e',
      );
    }
  }
}
