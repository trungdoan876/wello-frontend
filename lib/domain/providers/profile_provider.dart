import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../data/models/responses/profile_response_model.dart';
import '../../data/repositories/profile_repository.dart';

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
    notifyListeners();

    try {
      print('Loading profile for userId: $userId');
      _profileData = await _repository.getProfileById(userId);
      print('Profile loaded successfully: ${_profileData?.fullname}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
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
      print('Uploading avatar for userId: $userId');
      final success = await _repository.uploadAvatar(
        userId: userId,
        imageFile: imageFile,
      );
      print('Avatar uploaded successfully');
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('Error uploading avatar: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
