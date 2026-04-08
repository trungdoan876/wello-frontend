import 'dart:io';
import '../models/responses/profile_response_model.dart';
import '../data_source/profile_remote_data_source.dart';

class ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepository({ProfileRemoteDataSource? dataSource})
    : _dataSource = dataSource ?? ProfileRemoteDataSource();

  /// Fetch profile by user ID
  Future<ProfileResponseModel> getProfileById(String token, int userId) async {
    try {
      return await _dataSource.fetchProfileById(token, userId);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  /// Upload profile avatar
  Future<bool> uploadAvatar({
    required String token,
    required int userId,
    required File imageFile,
  }) async {
    try {
      return await _dataSource.uploadAvatar(
        token: token,
        userId: userId,
        imageFile: imageFile,
      );
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Update user's fullname
  Future<bool> updateFullname({
    required String token,
    required int userId,
    required String fullname,
  }) async {
    try {
      return await _dataSource.updateFullname(
        token: token,
        userId: userId,
        fullname: fullname,
      );
    } catch (e) {
      throw Exception('Failed to update fullname: $e');
    }
  }

  /// Update user's gender
  Future<bool> updateGender({
    required String token,
    required int userId,
    required String gender,
  }) async {
    try {
      return await _dataSource.updateGender(
        token: token,
        userId: userId,
        gender: gender,
      );
    } catch (e) {
      throw Exception('Failed to update gender: $e');
    }
  }

  /// Update user's age
  Future<bool> updateAge({
    required String token,
    required int userId,
    required int age,
  }) async {
    try {
      return await _dataSource.updateAge(token: token, userId: userId, age: age);
    } catch (e) {
      throw Exception('Failed to update age: $e');
    }
  }

  /// Update user's height
  Future<bool> updateHeight({
    required String token,
    required int userId,
    required int height,
  }) async {
    try {
      return await _dataSource.updateHeight(
        token: token,
        userId: userId,
        height: height,
      );
    } catch (e) {
      throw Exception('Failed to update height: $e');
    }
  }

  /// Update user's weight
  Future<bool> updateWeight({
    required String token,
    required int userId,
    required int weight,
  }) async {
    try {
      return await _dataSource.updateWeight(
        token: token,
        userId: userId,
        weight: weight,
      );
    } catch (e) {
      throw Exception('Failed to update weight: $e');
    }
  }

  /// Update user's goal
  Future<bool> updateGoal({
    required String token,
    required int userId,
    required String goal,
  }) async {
    try {
      return await _dataSource.updateGoal(token: token, userId: userId, goal: goal);
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  /// Update user's activity level
  Future<bool> updateActivityLevel({
    required String token,
    required int userId,
    required String activityLevel,
  }) async {
    try {
      return await _dataSource.updateActivityLevel(
        token: token,
        userId: userId,
        activityLevel: activityLevel,
      );
    } catch (e) {
      throw Exception('Failed to update activity level: $e');
    }
  }


  /// Update Water Reminder Settings
  Future<bool> updateWaterReminderSettings({
    required String token,
    required int userId,
    required bool enabled,
    required int startHour,
    required int endHour,
    required int intervalHours,
    required int intervalMinutes,
  }) async {
    try {
      return await _dataSource.updateWaterReminderSettings(
        token: token,
        userId: userId,
        enabled: enabled,
        startHour: startHour,
        endHour: endHour,
        intervalHours: intervalHours,
        intervalMinutes: intervalMinutes,
      );
    } catch (e) {
      throw Exception('Failed to update water reminder settings: $e');
    }
  }
}
