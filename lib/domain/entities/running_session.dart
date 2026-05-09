/// Entity đại diện cho một buổi chạy bộ GPS
class RunningSession {
  final int? sessionId;
  final int userId;
  final String date; // yyyy-MM-dd
  final String activityType; // running | walking | cycling
  final int durationSeconds;
  final double distanceKm;
  final int caloriesBurned;
  final int steps;
  final int avgPaceSecPerKm;
  final String goalType; // distance | time | calories | steps
  final double goalValue;
  final int completionPercent; // 0–100

  RunningSession({
    this.sessionId,
    required this.userId,
    required this.date,
    required this.activityType,
    required this.durationSeconds,
    required this.distanceKm,
    required this.caloriesBurned,
    required this.steps,
    required this.avgPaceSecPerKm,
    required this.goalType,
    required this.goalValue,
    required this.completionPercent,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'date': date,
    'activityType': activityType,
    'durationSeconds': durationSeconds,
    'distanceKm': distanceKm,
    'caloriesBurned': caloriesBurned,
    'steps': steps,
    'avgPaceSecPerKm': avgPaceSecPerKm,
    'goalType': goalType,
    'goalValue': goalValue,
    'completionPercent': completionPercent,
  };

  factory RunningSession.fromJson(Map<String, dynamic> json) => RunningSession(
    sessionId: json['sessionId'] as int?,
    userId: json['userId'] as int? ?? 0,
    date: json['date'] as String? ?? '',
    activityType: json['activityType'] as String? ?? 'running',
    durationSeconds: json['durationSeconds'] as int? ?? 0,
    distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
    caloriesBurned: json['caloriesBurned'] as int? ?? 0,
    steps: json['steps'] as int? ?? 0,
    avgPaceSecPerKm: json['avgPaceSecPerKm'] as int? ?? 0,
    goalType: json['goalType'] as String? ?? 'distance',
    goalValue: (json['goalValue'] as num?)?.toDouble() ?? 0,
    completionPercent: json['completionPercent'] as int? ?? 0,
  );
}

/// Tổng kết tuần chạy bộ
class RunningWeeklySummary {
  final double totalDistanceKm;
  final int totalCaloriesBurned;
  final int totalDurationSeconds;
  final int totalSteps;
  final int sessionsCount;
  final List<RunningDailySummary> dailySummaries;

  RunningWeeklySummary({
    required this.totalDistanceKm,
    required this.totalCaloriesBurned,
    required this.totalDurationSeconds,
    required this.totalSteps,
    required this.sessionsCount,
    required this.dailySummaries,
  });

  factory RunningWeeklySummary.fromJson(Map<String, dynamic> json) =>
      RunningWeeklySummary(
        totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
        totalCaloriesBurned: json['totalCaloriesBurned'] as int? ?? 0,
        totalDurationSeconds: json['totalDurationSeconds'] as int? ?? 0,
        totalSteps: json['totalSteps'] as int? ?? 0,
        sessionsCount: json['sessionsCount'] as int? ?? 0,
        dailySummaries: (json['dailySummaries'] as List<dynamic>? ?? [])
            .map((e) => RunningDailySummary.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Tóm tắt ngày trong tuần
class RunningDailySummary {
  final String date;
  final double distanceKm;
  final int caloriesBurned;
  final int steps;

  RunningDailySummary({
    required this.date,
    required this.distanceKm,
    required this.caloriesBurned,
    required this.steps,
  });

  factory RunningDailySummary.fromJson(Map<String, dynamic> json) =>
      RunningDailySummary(
        date: json['date'] as String? ?? '',
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        caloriesBurned: json['caloriesBurned'] as int? ?? 0,
        steps: json['steps'] as int? ?? 0,
      );
}
