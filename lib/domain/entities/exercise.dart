/// Exercise entity representing a workout type
class Exercise {
  final int id;
  final String name;
  final double metValue; // Metabolic Equivalent of Task

  Exercise({
    required this.id,
    required this.name,
    required this.metValue,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      metValue: (json['metValue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'metValue': metValue,
    };
  }
}

/// Workout log entity for recording exercise sessions
class WorkoutLog {
  final int userId;
  final int exerciseId;
  final int durationMinutes;
  final String date; // yyyy-MM-dd

  WorkoutLog({
    required this.userId,
    required this.exerciseId,
    required this.durationMinutes,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'exerciseId': exerciseId,
      'durationMinutes': durationMinutes,
      'date': date,
    };
  }
}

/// Calorie calculation result
class CaloriePreview {
  final int estimatedCalories;

  CaloriePreview({required this.estimatedCalories});

  factory CaloriePreview.fromJson(Map<String, dynamic> json) {
    return CaloriePreview(
      estimatedCalories: json['estimatedCalories'] as int,
    );
  }
}
