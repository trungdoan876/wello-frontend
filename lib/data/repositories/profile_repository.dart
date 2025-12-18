import 'dart:io';
import '../models/responses/profile_response_model.dart';
import '../data_source/profile_remote_data_source.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepository({ProfileRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? ProfileRemoteDataSource();

  /// Fetch profile by user ID
  Future<ProfileResponseModel> getProfileById(int userId) async {
    try {
      return await _dataSource.fetchProfileById(userId);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Upload profile avatar
  Future<bool> uploadAvatar({
    required int userId,
    required File imageFile,
  }) async {
    try {
      return await _dataSource.uploadAvatar(
        userId: userId,
        imageFile: imageFile,
      );
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
