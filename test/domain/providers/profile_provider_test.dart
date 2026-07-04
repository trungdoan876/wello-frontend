import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wello_frontend/data/models/responses/profile_response_model.dart';
import 'package:wello_frontend/data/repositories/profile_repository.dart';
import 'package:wello_frontend/domain/providers/profile_provider.dart';
import 'package:wello_frontend/data/data_source/user_preferences.dart';

class MockProfileRepository extends ProfileRepository {
  ProfileResponseModel? mockProfile;
  bool shouldThrow = false;
  bool updateAgeResult = true;
  bool updateHeightResult = true;

  @override
  Future<ProfileResponseModel> getProfileById(String token, int userId) async {
    if (shouldThrow) throw Exception('Get profile failed');
    return mockProfile!;
  }

  @override
  Future<bool> updateAge({
    required String token,
    required int userId,
    required int age,
  }) async {
    if (shouldThrow) throw Exception('Update age failed');
    return updateAgeResult;
  }

  @override
  Future<bool> updateHeight({
    required String token,
    required int userId,
    required int height,
  }) async {
    if (shouldThrow) throw Exception('Update height failed');
    return updateHeightResult;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'fake_token',
      'user_id': 99,
    });
  });

  group('ProfileProvider Tests', () {
    late MockProfileRepository mockRepo;
    late ProfileProvider provider;

    setUp(() {
      mockRepo = MockProfileRepository();
      provider = ProfileProvider(repository: mockRepo);
    });

    test('loadProfile should populate profileData on success', () async {
      final mockData = ProfileResponseModel(
        userId: 99,
        fullname: 'John Doe',
        gender: 'male',
        age: 25,
        height: 175,
        weight: 70.0,
        goal: 'lose_weight',
        activityLevel: 'ACTIVE',
        surveyDate: '2026-06-10',
        streakCount: 3,
      );
      mockRepo.mockProfile = mockData;

      expect(provider.isLoading, isFalse);
      expect(provider.profileData, isNull);

      final future = provider.loadProfile(99);
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.profileData, isNotNull);
      expect(provider.profileData?.fullname, 'John Doe');
      expect(provider.hasError, isFalse);
    });

    test('loadProfile should handle errors correctly', () async {
      mockRepo.shouldThrow = true;

      await provider.loadProfile(99);

      expect(provider.isLoading, isFalse);
      expect(provider.profileData, isNull);
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('Get profile failed'));
    });

    test('updateAge should update age and refresh profile', () async {
      final mockData = ProfileResponseModel(
        userId: 99,
        fullname: 'John Doe',
        gender: 'male',
        age: 30, // Updated age
        height: 175,
        weight: 70.0,
        goal: 'lose_weight',
        activityLevel: 'ACTIVE',
        surveyDate: '2026-06-10',
        streakCount: 3,
      );
      mockRepo.mockProfile = mockData;

      final success = await provider.updateAge(userId: 99, age: 30);

      expect(success, isTrue);
      expect(provider.profileData?.age, 30);
    });
  });
}
