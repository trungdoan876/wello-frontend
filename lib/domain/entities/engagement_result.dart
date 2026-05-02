class EngagementResult {
  final bool isStreak;
  final String message;
  final int streakCount;

  EngagementResult({
    required this.isStreak,
    required this.message,
    required this.streakCount,
  });

  factory EngagementResult.fromJson(Map<String, dynamic> json) {
    return EngagementResult(
      isStreak: (json['isStreak'] ?? json['is_streak'] ?? false) as bool,
      message: (json['message'] ?? '') as String,
      streakCount: (json['streakCount'] ?? json['streak_count'] ?? 0) as int,
    );
  }
}
