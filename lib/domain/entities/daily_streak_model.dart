import 'package:wello_frontend/domain/entities/daily_streak.dart';

class DailyStreakModel extends DailyStreak {
  DailyStreakModel({
    required super.date,
    required super.water,
    required super.meal,
  });

  factory DailyStreakModel.fromJson(Map<String, dynamic> json) {
    return DailyStreakModel(
      date: DateTime.parse(json['date']),
      water: json['water'] ?? false,
      meal: json['meal'] ?? false,
    );
  }
}
