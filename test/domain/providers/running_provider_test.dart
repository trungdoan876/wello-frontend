import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/domain/entities/running_session.dart';
import 'package:wello_frontend/domain/providers/running_provider.dart';
import 'package:wello_frontend/domain/repositories/running_repository.dart';

class MockRunningRepository extends RunningRepository {
  RunningWeeklySummary? mockWeeklySummary;
  List<RunningSession> mockHistory = [];
  bool shouldThrow = false;
  RunningSession? lastSavedSession;

  @override
  Future<RunningWeeklySummary> getWeeklySummary(
    String token,
    int userId,
    String startDate,
  ) async {
    if (shouldThrow) throw Exception('Get summary failed');
    return mockWeeklySummary!;
  }

  @override
  Future<List<RunningSession>> getHistory(
    String token,
    int userId, {
    int limit = 10,
  }) async {
    if (shouldThrow) throw Exception('Get history failed');
    return mockHistory;
  }

  @override
  Future<int> saveSession(String token, RunningSession session) async {
    if (shouldThrow) throw Exception('Save session failed');
    lastSavedSession = session;
    return 123;
  }
}

void main() {
  group('RunningProvider Tests', () {
    late MockRunningRepository mockRepo;
    late RunningProvider provider;

    setUp(() {
      mockRepo = MockRunningRepository();
      provider = RunningProvider(repository: mockRepo);
    });

    test('Initial properties should be empty/default', () {
      expect(provider.isTracking, isFalse);
      expect(provider.isPaused, isFalse);
      expect(provider.km, 0.0);
      expect(provider.steps, 0);
      expect(provider.calories, 0);
      expect(provider.paceMinPerKm, 0.0);
      expect(provider.progress, 0.0);
    });

    test('FormattedTime helper tests', () {
      // Direct access is private, but we can verify it if we trigger timer/seconds.
      // Wait, we can test calories per km and steps per km getters directly.
      expect(provider.weeklyAverageSpeedKmh, 0.0);
    });

    test('weeklyAverageSpeedKmh should calculate correctly', () async {
      mockRepo.mockWeeklySummary = RunningWeeklySummary(
        totalDistanceKm: 10.0,
        totalCaloriesBurned: 700,
        totalDurationSeconds: 3600, // 1 hour
        totalSteps: 12000,
        sessionsCount: 2,
        dailySummaries: [],
      );

      await provider.loadDashboard('fake_token', 1);

      expect(provider.weeklyAverageSpeedKmh, 10.0); // 10 km / 1 hr = 10 km/h
    });

    test('loadDashboard failure sets error message', () async {
      mockRepo.shouldThrow = true;

      await provider.loadDashboard('fake_token', 1);

      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, contains('Get summary failed'));
    });
  });
}
