import 'package:wello_frontend/domain/entities/daily_streak.dart';

abstract class StreakRepository {
  Future<List<DailyStreak>> getMonthly(
    String token,
    int userId,
    int year,
    int month,
  );
}
