/// Model for user profile and fitness goals
class UserProfile {
  final String userId;
  final double currentWeight;
  final String goalType; // "gain_weight", "lose_weight", "maintain"
  final int dailyCalorieTarget;
  final int dailyCalorieBurned;
  final int dailyWaterTarget;
  final MacroTargets macroTargets;

  UserProfile({
    required this.userId,
    required this.currentWeight,
    required this.goalType,
    required this.dailyCalorieTarget,
    this.dailyCalorieBurned = 0,
    this.dailyWaterTarget = 1950,
    required this.macroTargets,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] ?? '',
      currentWeight: (json['currentWeight'] ?? 0).toDouble(),
      goalType: json['goalType'] ?? 'maintain',
      dailyCalorieTarget: json['dailyCalorieTarget'] ?? 2000,
      dailyCalorieBurned: json['dailyCalorieBurned'] ?? 0,
      dailyWaterTarget: json['dailyWaterTarget'] ?? 1950,
      macroTargets: MacroTargets.fromJson(json['macroTargets'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentWeight': currentWeight,
      'goalType': goalType,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyCalorieBurned': dailyCalorieBurned,
      'dailyWaterTarget': dailyWaterTarget,
      'macroTargets': macroTargets.toJson(),
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
      carb: json['carb'] ?? 150,
      protein: json['protein'] ?? 117,
      fat: json['fat'] ?? 45,
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
