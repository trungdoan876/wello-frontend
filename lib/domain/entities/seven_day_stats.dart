class SevenDayStats {
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int daysWithSufficientWater;
  final int daysWithWorkout;
  final int daysExceedingCalories;
  final double totalWaterMl;
  final double averageWaterMl;
  final double maxWaterMl;
  final double minWaterMl;
  final double totalCaloriesConsumed;
  final double averageCaloriesConsumed;
  final double totalCaloriesBurned;
  final double averageCaloriesBurned;
  final double totalCaloriesDeficit;
  final double averageCaloriesDeficit;
  final int totalMeals;
  final int breakfastCount;
  final int lunchCount;
  final int dinnerCount;
  final int snackCount;
  final double averageMealsPerDay;
  final double totalCarbs;
  final double averageCarbsPerDay;
  final double totalProtein;
  final double averageProteinPerDay;
  final double totalFat;
  final double averageFatPerDay;
  final double averageWorkoutDaysPerWeek;
  final double maxDailyCaloriesBurned;
  final List<double> dailyWaterMl;
  final List<double> dailyCaloriesConsumed;

  const SevenDayStats({
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.daysWithSufficientWater,
    required this.daysWithWorkout,
    required this.daysExceedingCalories,
    required this.totalWaterMl,
    required this.averageWaterMl,
    required this.maxWaterMl,
    required this.minWaterMl,
    required this.totalCaloriesConsumed,
    required this.averageCaloriesConsumed,
    required this.totalCaloriesBurned,
    required this.averageCaloriesBurned,
    required this.totalCaloriesDeficit,
    required this.averageCaloriesDeficit,
    required this.totalMeals,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.snackCount,
    required this.averageMealsPerDay,
    required this.totalCarbs,
    required this.averageCarbsPerDay,
    required this.totalProtein,
    required this.averageProteinPerDay,
    required this.totalFat,
    required this.averageFatPerDay,
    required this.averageWorkoutDaysPerWeek,
    required this.maxDailyCaloriesBurned,
    required this.dailyWaterMl,
    required this.dailyCaloriesConsumed,
  });

  factory SevenDayStats.fromJson(Map<String, dynamic> json) {
    return SevenDayStats(
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      totalDays: _asInt(json['totalDays'], fallback: 7),
      daysWithSufficientWater: _asInt(json['daysWithSufficientWater']),
      daysWithWorkout: _asInt(json['daysWithWorkout']),
      daysExceedingCalories: _asInt(json['daysExceedingCalories']),
      totalWaterMl: _asDouble(json['totalWaterMl']),
      averageWaterMl: _asDouble(json['averageWaterMl']),
      maxWaterMl: _asDouble(json['maxWaterMl']),
      minWaterMl: _asDouble(json['minWaterMl']),
      totalCaloriesConsumed: _asDouble(json['totalCaloriesConsumed']),
      averageCaloriesConsumed: _asDouble(json['averageCaloriesConsumed']),
      totalCaloriesBurned: _asDouble(json['totalCaloriesBurned']),
      averageCaloriesBurned: _asDouble(json['averageCaloriesBurned']),
      totalCaloriesDeficit: _asDouble(json['totalCaloriesDeficit']),
      averageCaloriesDeficit: _asDouble(json['averageCaloriesDeficit']),
      totalMeals: _asInt(json['totalMeals']),
      breakfastCount: _asInt(json['breakfastCount']),
      lunchCount: _asInt(json['lunchCount']),
      dinnerCount: _asInt(json['dinnerCount']),
      snackCount: _asInt(json['snackCount']),
      averageMealsPerDay: _asDouble(json['averageMealsPerDay']),
      totalCarbs: _asDouble(json['totalCarbs']),
      averageCarbsPerDay: _asDouble(json['averageCarbsPerDay']),
      totalProtein: _asDouble(json['totalProtein']),
      averageProteinPerDay: _asDouble(json['averageProteinPerDay']),
      totalFat: _asDouble(json['totalFat']),
      averageFatPerDay: _asDouble(json['averageFatPerDay']),
      averageWorkoutDaysPerWeek: _asDouble(json['averageWorkoutDaysPerWeek']),
      maxDailyCaloriesBurned: _asDouble(json['maxDailyCaloriesBurned']),
      dailyWaterMl: _asDoubleList(json['dailyWaterMl']),
      dailyCaloriesConsumed: _asDoubleList(json['dailyCaloriesConsumed']),
    );
  }

  double get waterPercentage =>
      totalDays > 0 ? (daysWithSufficientWater / totalDays) * 100 : 0;

  double get workoutPercentage =>
      totalDays > 0 ? (daysWithWorkout / totalDays) * 100 : 0;

  double get caloriePercentage =>
      totalDays > 0 ? (daysExceedingCalories / totalDays) * 100 : 0;

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return fallback;
  }

  static double _asDouble(dynamic value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return fallback;
  }

  static List<double> _asDoubleList(dynamic value) {
    if (value is List) {
      return value.map((item) {
        if (item is num) return item.toDouble();
        if (item is String) return double.tryParse(item) ?? 0.0;
        if (item is Map<String, dynamic>) {
          final rawValue = item['value'] ?? item['amount'] ?? item['ml'];
          return _asDouble(rawValue);
        }
        return 0.0;
      }).toList();
    }
    return const <double>[];
  }
}
