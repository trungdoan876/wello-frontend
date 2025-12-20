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

  /// Update FCM Token
  Future<bool> updateFcmToken({
    required int userId,
    required String fcmToken,
  }) async {
    try {
      return await _dataSource.updateFcmToken(
        userId: userId,
        fcmToken: fcmToken,
      );
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  /// Update Water Reminder Settings
  Future<bool> updateWaterReminderSettings({
    required int userId,
    required bool enabled,
    required int startHour,
    required int endHour,
    required int intervalHours,
    required int intervalMinutes,
  }) async {
    try {
      return await _dataSource.updateWaterReminderSettings(
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
