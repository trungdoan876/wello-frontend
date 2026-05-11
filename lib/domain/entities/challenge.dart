enum ChallengeType {
  eatingGreens,
  steps,
  calories,
  water,
  workout,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final ChallengeType type;
  final DateTime startDate;
  final DateTime endDate;
  final double targetValue;
  final double currentProgress;
  final int participantCount;
  final bool isJoined;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.targetValue,
    required this.currentProgress,
    required this.participantCount,
    this.isJoined = false,
  });

  double get progressPercentage => (currentProgress / targetValue).clamp(0.0, 1.0);
  
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}
