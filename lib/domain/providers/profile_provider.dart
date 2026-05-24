import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../data/models/responses/profile_response_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../core/utils/auth_helper.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileResponseModel? _profileData;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository();

  // Getters
  ProfileResponseModel? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasData => _profileData != null;

  /// Load profile data from backend API
  Future<void> loadProfile(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    // Clear previous profile so UI doesn't show stale data while loading
    _profileData = null;
    notifyListeners();

    try {
      print('Dang tai ho so cho userId: $userId');
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      _profileData = await _repository.getProfileById(token ?? '', userId);
      print('Tai ho so thanh cong: ${_profileData?.fullname}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Loi khi tai ho so: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Retry loading profile
  Future<void> retry(int userId) async {
    await loadProfile(userId);
  }

  /// Upload profile avatar
  Future<bool> uploadProfileAvatar({
    required int userId,
    required File imageFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Dang tai anh dai dien cho userId: $userId');
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final success = await _repository.uploadAvatar(
        token: token ?? '',
        userId: userId,
        imageFile: imageFile,
      );
      print('Tai anh dai dien thanh cong');
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('Loi khi tai anh dai dien lên: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update fullname via API and refresh local state
  Future<bool> updateFullname({
    required int userId,
    required String fullname,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final success = await _repository.updateFullname(
        token: token ?? '',
        userId: userId,
        fullname: fullname,
      );
      if (success) {
        // Refresh from server to reflect persisted state
        await loadProfile(userId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update gender via API and refresh local state
  Future<bool> updateGender({
    required int userId,
    required String gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final success = await _repository.updateGender(
        token: token ?? '',
        userId: userId,
        gender: gender,
      );
      if (success) {
        await loadProfile(userId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update age via API and refresh local state
  Future<bool> updateAge({required int userId, required int age}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('[ProfileProvider] updateAge duoc goi: userId=$userId, age=$age');
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final success = await _repository.updateAge(
        token: token ?? '',
        userId: userId,
        age: age,
      );
      print('[ProfileProvider] ket qua updateAge: success=$success');
      if (success) {
        // Try to refresh from server to reflect persisted state, but don't
        // treat refresh failures as update failures.
        try {
          await loadProfile(userId);
        } catch (e) {
          // Log and continue to report success for the update.
          print(
            '[ProfileProvider] Canh bao: tai lai sau khi cap nhat tuoi that bai: $e',
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('[ProfileProvider] updateAge error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update height via API and refresh local state
  Future<bool> updateHeight({required int userId, required int height}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print(
        '[ProfileProvider] updateHeight called: userId=$userId, height=$height',
      );
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final success = await _repository.updateHeight(
        token: token ?? '',
        userId: userId,
        height: height,
      );
      print('[ProfileProvider] updateHeight result: success=$success');
      if (success) {
        try {
          await loadProfile(userId);
        } catch (e) {
          print(
            '[ProfileProvider] Warning: refresh after height update failed: $e',
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('[ProfileProvider] updateHeight error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update weight via API and refresh local state
  Future<bool> updateWeight({required int userId, required int weight}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print(
        '[ProfileProvider] updateWeight called: userId=$userId, weight=$weight',
      );
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final success = await _repository.updateWeight(
        token: token ?? '',
        userId: userId,
        weight: weight,
      );
      print('[ProfileProvider] updateWeight result: success=$success');
      if (success) {
        try {
          await loadProfile(userId);
        } catch (e) {
          print(
            '[ProfileProvider] Warning: refresh after weight update failed: $e',
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('[ProfileProvider] updateWeight error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update goal via API and refresh local state
  Future<bool> updateGoal({required int userId, required String goal}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('[ProfileProvider] updateGoal called: userId=$userId, goal=$goal');
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final success = await _repository.updateGoal(
        token: token ?? '',
        userId: userId,
        goal: goal,
      );
      print('[ProfileProvider] updateGoal result: success=$success');
      if (success) {
        try {
          await loadProfile(userId);
        } catch (e) {
          print(
            '[ProfileProvider] Warning: refresh after goal update failed: $e',
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('[ProfileProvider] updateGoal error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update activity level via API and refresh local state
  Future<bool> updateActivityLevel({
    required int userId,
    required String activityLevel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print(
        '[ProfileProvider] updateActivityLevel called: userId=$userId, activityLevel=$activityLevel',
      );
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final success = await _repository.updateActivityLevel(
        token: token ?? '',
        userId: userId,
        activityLevel: activityLevel,
      );
      print('[ProfileProvider] updateActivityLevel result: success=$success');
      if (success) {
        try {
          await loadProfile(userId);
        } catch (e) {
          print(
            '[ProfileProvider] Warning: refresh after activity level update failed: $e',
          );
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('[ProfileProvider] updateActivityLevel error: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
