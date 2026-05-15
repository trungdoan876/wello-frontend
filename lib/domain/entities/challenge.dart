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

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      type: _parseType(json['type']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      targetValue: (json['targetValue'] ?? 0).toDouble(),
      currentProgress: (json['currentProgress'] ?? 0).toDouble(),
      participantCount: json['participantCount'] ?? 0,
      isJoined: json['isJoined'] ?? false,
    );
  }

  static ChallengeType _parseType(String? type) {
    switch (type?.toUpperCase()) {
      case 'EATING_GREENS':
        return ChallengeType.eatingGreens;
      case 'STEPS':
        return ChallengeType.steps;
      case 'CALORIES':
        return ChallengeType.calories;
      case 'WATER':
        return ChallengeType.water;
      case 'WORKOUT':
        return ChallengeType.workout;
      default:
        return ChallengeType.steps;
    }
  }

  double get progressPercentage => (currentProgress / targetValue).clamp(0.0, 1.0);
  
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}
