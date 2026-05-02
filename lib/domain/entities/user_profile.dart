/// Model for user profile and fitness goals
class UserProfile {
  final String userId;
  final String? startDate; // User registration/start date (yyyy-MM-dd)
  final double currentWeight;
  final String goalType; // "gain_weight", "lose_weight", "maintain"
  final int dailyCalorieTarget;
  final int dailyCalorieBurned;
  final int dailyWaterTarget;
  final int streakCount;
  final MacroTargets macroTargets;
  final double? sleepTargetHours;
  final String? sleepBedtimeTarget;
  final String? sleepWakeTimeTarget;

  UserProfile({
    required this.userId,
    this.startDate,
    required this.currentWeight,
    required this.goalType,
    required this.dailyCalorieTarget,
    this.dailyCalorieBurned = 0,
    this.dailyWaterTarget = 1950,
    this.streakCount = 0,
    required this.macroTargets,
    this.sleepTargetHours,
    this.sleepBedtimeTarget,
    this.sleepWakeTimeTarget,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId']?.toString() ?? '', // Handle both int and string
      startDate: json['startDate']?.toString(), // Ensure string
      currentWeight: (json['currentWeight'] ?? 0).toDouble(),
      goalType: json['goalType'] ?? 'maintain',
      dailyCalorieTarget: (json['dailyCalorieTarget'] ?? 2000).toInt(),
      dailyCalorieBurned: (json['dailyCalorieBurned'] ?? 0).toInt(),
      dailyWaterTarget: (json['dailyWaterTarget'] ?? 1950).toInt(),
      streakCount: (json['streakCount'] ?? 0).toInt(),
      macroTargets: MacroTargets.fromJson(json['macroTargets'] ?? {}),
      sleepTargetHours: json['sleepTargetHours'] != null ? (json['sleepTargetHours'] as num).toDouble() : null,
      sleepBedtimeTarget: json['sleepBedtimeTarget'] as String?,
      sleepWakeTimeTarget: json['sleepWakeTimeTarget'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'startDate': startDate,
      'currentWeight': currentWeight,
      'goalType': goalType,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyCalorieBurned': dailyCalorieBurned,
      'dailyWaterTarget': dailyWaterTarget,
      'streakCount': streakCount,
      'macroTargets': macroTargets.toJson(),
      'sleepTargetHours': sleepTargetHours,
      'sleepBedtimeTarget': sleepBedtimeTarget,
      'sleepWakeTimeTarget': sleepWakeTimeTarget,
    };
  }

  /// Calculate suggested target weight based on goal type
  double get suggestedTargetWeight {
    switch (goalType) {
      case 'lose_weight':
        return currentWeight - 5; // Lose 5kg
      case 'gain_weight':
        return currentWeight + 3; // Gain 3kg
      case 'maintain':
      default:
        return currentWeight;
    }
  }
}

/// Model for macro nutrient targets
class MacroTargets {
  final int carb;
  final int protein;
  final int fat;

  MacroTargets({
    required this.carb,
    required this.protein,
    required this.fat,
  });

  factory MacroTargets.fromJson(Map<String, dynamic> json) {
    return MacroTargets(
      carb: (json['carb'] as num?)?.toInt() ?? 150,
      protein: (json['protein'] as num?)?.toInt() ?? 117,
      fat: (json['fat'] as num?)?.toInt() ?? 45,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'carb': carb,
      'protein': protein,
      'fat': fat,
    };
  }
}
