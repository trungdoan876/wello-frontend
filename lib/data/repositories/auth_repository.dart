import '../../domain/repositories/auth_repository.dart';
import '../data_source/auth_remote_data_source.dart';
import '../models/requests/login_request_model.dart';
import '../models/requests/register_request_model.dart';
import '../models/responses/login_response_model.dart';
import '../models/responses/register_response_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/app_constants.dart';

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
      print('🔵 DEBUG: Starting Google Sign-In...');
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        // Web Client ID required for ID token on Android
        serverClientId: AppConstants.googleWebClientId,
      );

      print('🔵 DEBUG: GoogleSignIn initialized with serverClientId');
      
      // Sign in with Google
      final account = await googleSignIn.signIn();
      print('🔵 DEBUG: Sign-in completed. Account: ${account?.email ?? 'null'}');
      
      if (account == null) {
        print('🔴 DEBUG: User cancelled sign-in');
        return LoginResponseModel(
          success: false,
          message: 'Google sign-in cancelled',
        );
      }

      print('🔵 DEBUG: Getting authentication...');
      // Get authentication
      final auth = await account.authentication;
      print('🔵 DEBUG: Authentication object received');
      print('🔵 DEBUG: ID Token: ${auth.idToken != null ? "EXISTS (${auth.idToken!.substring(0, 20)}...)" : "NULL"}');
      print('🔵 DEBUG: Access Token: ${auth.accessToken != null ? "EXISTS" : "NULL"}');
      
      final idToken = auth.idToken;

      if (idToken == null) {
        print('🔴 DEBUG: ID Token is null!');
        print('🔴 DEBUG: Auth object details: accessToken=${auth.accessToken != null}, serverAuthCode=${auth.serverAuthCode}');
        return LoginResponseModel(
          success: false,
          message: 'Failed to get ID token',
        );
      }

      print('🔵 DEBUG: Calling backend API with ID token...');
      // Call backend API
      final response = await _dataSource.loginWithGoogle(idToken: idToken);
      print('🔵 DEBUG: Backend response: success=${response.success}');
      return response;
    } catch (e, stackTrace) {
      print('🔴 DEBUG: Exception caught!');
      print('🔴 DEBUG: Error type: ${e.runtimeType}');
      print('🔴 DEBUG: Error message: $e');
      print('🔴 DEBUG: Stack trace: $stackTrace');
      return LoginResponseModel(
        success: false,
        message: 'Google login failed: $e',
      );
    }
  }
}
