import 'badge.dart';

class EngagementResult {
  final bool isStreak;
  final String message;
  final int streakCount;
  final List<Badge> newBadges;

  EngagementResult({
    required this.isStreak,
    required this.message,
    required this.streakCount,
    this.newBadges = const [],
  });

  factory EngagementResult.fromJson(Map<String, dynamic> json) {
    var badgesJson = json['newBadges'] as List?;
    List<Badge> badgesList = badgesJson != null 
        ? badgesJson.map((i) => Badge.fromJson(i)).toList() 
        : [];

    return EngagementResult(
      isStreak: (json['isStreak'] ?? json['is_streak'] ?? false) as bool,
      message: (json['message'] ?? '') as String,
      streakCount: (json['streakCount'] ?? json['streak_count'] ?? 0) as int,
      newBadges: badgesList,
    );
  }
}
