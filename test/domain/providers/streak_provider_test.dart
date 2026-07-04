import 'package:flutter_test/flutter_test.dart';
import 'package:wello_frontend/domain/entities/daily_streak.dart';
import 'package:wello_frontend/data/repositories/streak_repository.dart';
import 'package:wello_frontend/domain/providers/streak_provider.dart';

class MockStreakRepository implements StreakRepository {
  List<DailyStreak> mockResult = [];
  bool shouldThrow = false;
  String? lastToken;
  int? lastUserId;
  int? lastYear;
  int? lastMonth;

  @override
  Future<List<DailyStreak>> getMonthly(
    String token,
    int userId,
    int year,
    int month,
  ) async {
    lastToken = token;
    lastUserId = userId;
    lastYear = year;
    lastMonth = month;

    if (shouldThrow) {
      throw Exception('Repository error');
    }
    return mockResult;
  }
}

void main() {
  group('StreakProvider Tests', () {
    late MockStreakRepository mockRepo;
    late StreakProvider provider;

    setUp(() {
      mockRepo = MockStreakRepository();
      provider = StreakProvider(mockRepo);
    });

    test('loadMonthlyStreak should fetch monthly streaks and update state correctly', () async {
      final date1 = DateTime(2026, 6, 10);
      final date2 = DateTime(2026, 6, 11);
      final mockStreaks = [
        DailyStreak(date: date1, water: true, meal: false),
        DailyStreak(date: date2, water: true, meal: true),
      ];
      mockRepo.mockResult = mockStreaks;

      expect(provider.isLoading, isFalse);
      expect(provider.streaks, isEmpty);

      // Trigger load
      final future = provider.loadMonthlyStreak(
        token: 'auth_token_123',
        userId: 45,
        year: 2026,
        month: 6,
      );

      // While loading
      expect(provider.isLoading, isTrue);

      await future;

      // After load
      expect(provider.isLoading, isFalse);
      expect(provider.streaks.length, 2);
      expect(provider.streaks[date1]?.water, isTrue);
      expect(provider.streaks[date1]?.meal, isFalse);
      expect(provider.streaks[date2]?.water, isTrue);
      expect(provider.streaks[date2]?.meal, isTrue);

      expect(mockRepo.lastToken, 'auth_token_123');
      expect(mockRepo.lastUserId, 45);
      expect(mockRepo.lastYear, 2026);
      expect(mockRepo.lastMonth, 6);
    });

    test('loadMonthlyStreak should reset isLoading on failure', () async {
      mockRepo.shouldThrow = true;

      expect(provider.isLoading, isFalse);

      try {
        await provider.loadMonthlyStreak(
          token: 'token',
          userId: 1,
          year: 2026,
          month: 6,
        );
      } catch (_) {}

      expect(provider.isLoading, isFalse);
      expect(provider.streaks, isEmpty);
    });
  });
}
