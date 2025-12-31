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
    // print('CaloriePreview.fromJson - json goc: $json');
    // Backend returns 'caloriesBurned' not 'estimatedCalories'
    final calories = (json['caloriesBurned'] as num?)?.toInt() ?? 0;
    // print('Da parse calo: $calories');
    return CaloriePreview(
      estimatedCalories: calories,
    );
  }
}

/// Single workout history item
class WorkoutHistoryItem {
  final int id;
  final String exerciseName;
  final int durationMinutes;
  final int caloriesBurned;

  WorkoutHistoryItem({
    required this.id,
    required this.exerciseName,
    required this.durationMinutes,
    required this.caloriesBurned,
  });

  factory WorkoutHistoryItem.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryItem(
      id: json['id'] as int,
      exerciseName: json['exerciseName'] as String,
      durationMinutes: json['durationMinutes'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
    );
  }
}

/// Daily workout log containing all workouts for a day
class DailyWorkoutLog {
  final int totalCaloriesBurned;
  final List<WorkoutHistoryItem> workouts;

  DailyWorkoutLog({
    required this.totalCaloriesBurned,
    required this.workouts,
  });

  factory DailyWorkoutLog.fromJson(Map<String, dynamic> json) {
    final workoutsJson = json['workouts'] as List<dynamic>? ?? [];
    return DailyWorkoutLog(
      totalCaloriesBurned: json['totalCaloriesBurned'] as int? ?? 0,
      workouts: workoutsJson
          .map((item) => WorkoutHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

