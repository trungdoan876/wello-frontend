import 'package:flutter/material.dart';
import 'package:wello_frontend/domain/entities/daily_streak.dart';
import 'package:wello_frontend/data/repositories/streak_repository.dart';

class StreakProvider extends ChangeNotifier {
  final StreakRepository _repo;

  StreakProvider(this._repo);

  Map<DateTime, DailyStreak> streaks = {};
  bool isLoading = false;

  Future<void> loadMonthlyStreak({
    required String token,
    required int userId,
    required int year,
    required int month,
  }) async {
    isLoading = true;
    notifyListeners();

    final data = await _repo.getMonthly(token, userId, year, month);

    streaks = {
      for (final s in data)
        DateTime(s.date.year, s.date.month, s.date.day): s
    };

    isLoading = false;
    notifyListeners();
  }
}
