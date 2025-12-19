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

  /// Update user's fullname
  Future<bool> updateFullname({
    required int userId,
    required String fullname,
  }) async {
    try {
      return await _dataSource.updateFullname(
        userId: userId,
        fullname: fullname,
      );
    } catch (e) {
      throw Exception('Failed to update fullname: $e');
    }
  }

  /// Update user's gender
  Future<bool> updateGender({
    required int userId,
    required String gender,
  }) async {
    try {
      return await _dataSource.updateGender(userId: userId, gender: gender);
    } catch (e) {
      throw Exception('Failed to update gender: $e');
    }
  }

  /// Update user's age
  Future<bool> updateAge({required int userId, required int age}) async {
    try {
      return await _dataSource.updateAge(userId: userId, age: age);
    } catch (e) {
      throw Exception('Failed to update age: $e');
    }
  }

  /// Update user's height
  Future<bool> updateHeight({required int userId, required int height}) async {
    try {
      return await _dataSource.updateHeight(userId: userId, height: height);
    } catch (e) {
      throw Exception('Failed to update height: $e');
    }
  }

  /// Update user's weight
  Future<bool> updateWeight({required int userId, required int weight}) async {
    try {
      return await _dataSource.updateWeight(userId: userId, weight: weight);
    } catch (e) {
      throw Exception('Failed to update weight: $e');
    }
  }

  /// Update user's goal
  Future<bool> updateGoal({required int userId, required String goal}) async {
    try {
      return await _dataSource.updateGoal(userId: userId, goal: goal);
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  /// Update user's activity level
  Future<bool> updateActivityLevel({
    required int userId,
    required String activityLevel,
  }) async {
    try {
      return await _dataSource.updateActivityLevel(
        userId: userId,
        activityLevel: activityLevel,
      );
    } catch (e) {
      throw Exception('Failed to update activity level: $e');
    }
  }
}
