/// Model for comprehensive 7-day statistics
class SevenDayStats {
  // Water intake
  final int daysWithSufficientWater;
  final double totalWaterMl;
  final double averageWaterMl;
  final double maxWaterMl;
  final double minWaterMl;

  // Workout
  final int daysWithWorkout;
  final double averageWorkoutDaysPerWeek;
  final double maxDailyCaloriesBurned;

  // Calories
  final int daysExceedingCalories;
  final double totalCaloriesConsumed;
  final double totalCaloriesBurned;
  final double totalCaloriesDeficit;
  final double averageCaloriesConsumed;
  final double averageCaloriesBurned;
  final double averageCaloriesDeficit;

  // Meals
  final int totalMeals;
  final double averageMealsPerDay;
  final int breakfastCount;
  final int lunchCount;
  final int dinnerCount;
  final int snackCount;

  // Macronutrients
  final double totalCarbs;
  final double totalProtein;
  final double totalFat;
  final double averageCarbsPerDay;
  final double averageProteinPerDay;
  final double averageFatPerDay;

  // Dates
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;

  SevenDayStats({
    required this.daysWithSufficientWater,
    required this.totalWaterMl,
    required this.averageWaterMl,
    required this.maxWaterMl,
    required this.minWaterMl,
    required this.daysWithWorkout,
    required this.averageWorkoutDaysPerWeek,
    required this.maxDailyCaloriesBurned,
    required this.daysExceedingCalories,
    required this.totalCaloriesConsumed,
    required this.totalCaloriesBurned,
    required this.totalCaloriesDeficit,
    required this.averageCaloriesConsumed,
    required this.averageCaloriesBurned,
    required this.averageCaloriesDeficit,
    required this.totalMeals,
    required this.averageMealsPerDay,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.snackCount,
    required this.totalCarbs,
    required this.totalProtein,
    required this.totalFat,
    required this.averageCarbsPerDay,
    required this.averageProteinPerDay,
    required this.averageFatPerDay,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
  });

  /// Create from JSON response
  factory SevenDayStats.fromJson(Map<String, dynamic> json) {
    return SevenDayStats(
      daysWithSufficientWater: json['daysWithSufficientWater'] ?? 0,
      totalWaterMl: (json['totalWaterMl'] ?? 0).toDouble(),
      averageWaterMl: (json['averageWaterMl'] ?? 0).toDouble(),
      maxWaterMl: (json['maxWaterMl'] ?? 0).toDouble(),
      minWaterMl: (json['minWaterMl'] ?? 0).toDouble(),
      daysWithWorkout: json['daysWithWorkout'] ?? 0,
      averageWorkoutDaysPerWeek: (json['averageWorkoutDaysPerWeek'] ?? 0)
          .toDouble(),
      maxDailyCaloriesBurned: (json['maxDailyCaloriesBurned'] ?? 0).toDouble(),
      daysExceedingCalories: json['daysExceedingCalories'] ?? 0,
      totalCaloriesConsumed: (json['totalCaloriesConsumed'] ?? 0).toDouble(),
      totalCaloriesBurned: (json['totalCaloriesBurned'] ?? 0).toDouble(),
      totalCaloriesDeficit: (json['totalCaloriesDeficit'] ?? 0).toDouble(),
      averageCaloriesConsumed: (json['averageCaloriesConsumed'] ?? 0)
          .toDouble(),
      averageCaloriesBurned: (json['averageCaloriesBurned'] ?? 0).toDouble(),
      averageCaloriesDeficit: (json['averageCaloriesDeficit'] ?? 0).toDouble(),
      totalMeals: json['totalMeals'] ?? 0,
      averageMealsPerDay: (json['averageMealsPerDay'] ?? 0).toDouble(),
      breakfastCount: json['breakfastCount'] ?? 0,
      lunchCount: json['lunchCount'] ?? 0,
      dinnerCount: json['dinnerCount'] ?? 0,
      snackCount: json['snackCount'] ?? 0,
      totalCarbs: (json['totalCarbs'] ?? 0).toDouble(),
      totalProtein: (json['totalProtein'] ?? 0).toDouble(),
      totalFat: (json['totalFat'] ?? 0).toDouble(),
      averageCarbsPerDay: (json['averageCarbsPerDay'] ?? 0).toDouble(),
      averageProteinPerDay: (json['averageProteinPerDay'] ?? 0).toDouble(),
      averageFatPerDay: (json['averageFatPerDay'] ?? 0).toDouble(),
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      totalDays: json['totalDays'] ?? 7,
    );
  }

  /// Calculate percentage of days with sufficient water
  double get waterPercentage => (daysWithSufficientWater / totalDays) * 100;

  /// Calculate percentage of days with workout
  double get workoutPercentage => (daysWithWorkout / totalDays) * 100;

  /// Calculate percentage of days exceeding calories
  double get caloriePercentage => (daysExceedingCalories / totalDays) * 100;
}
