/// Model for macronutrient data
class MacroData {
  final double consumed;
  final double target;
  final String unit;

  MacroData({required this.consumed, required this.target, this.unit = 'g'});

  factory MacroData.fromJson(Map<String, dynamic> json) {
    return MacroData(
      consumed: (json['consumed'] ?? 0).toDouble(),
      target: (json['target'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
    );
  }

  Map<String, dynamic> toJson() {
    return {'consumed': consumed, 'target': target, 'unit': unit};
  }

  double get percentage => target > 0 ? (consumed / target * 100) : 0;
  double get remaining => target - consumed;
}

/// Model for water intake tracking
class WaterIntake {
  final int consumed;
  final int target;
  final String unit;
  final int glasses;

  final int? id;

  WaterIntake({
    this.id,
    required this.consumed,
    required this.target,
    this.unit = 'ml',
    this.glasses = 0,
  });

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'] as int?,
      consumed: json['consumed'] ?? 0,
      target: json['target'] ?? 1950,
      unit: json['unit'] ?? 'ml',
      glasses: json['glasses'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumed': consumed,
      'target': target,
      'unit': unit,
      'glasses': glasses,
    };
  }

  int get remaining => target - consumed;
  double get percentage => target > 0 ? (consumed / target * 100) : 0;
}

/// Model for daily nutrition summary
class NutritionSummary {
  final String date;
  final int caloriesConsumed;
  final int caloriesBurned;
  final int caloriesRemaining;
  final MacroData carb;
  final MacroData protein;
  final MacroData fat;
  final WaterIntake waterIntake;

  NutritionSummary({
    required this.date,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    required this.caloriesRemaining,
    required this.carb,
    required this.protein,
    required this.fat,
    required this.waterIntake,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    final macrosJson = json['macros'] ?? {};
    final waterJson = json['waterIntake'] ?? {};

    return NutritionSummary(
      date: json['date'] ?? '',
      caloriesConsumed: json['caloriesConsumed'] ?? 0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      caloriesRemaining: json['caloriesRemaining'] ?? 0,
      carb: MacroData.fromJson(macrosJson['carb'] ?? {}),
      protein: MacroData.fromJson(macrosJson['protein'] ?? {}),
      fat: MacroData.fromJson(macrosJson['fat'] ?? {}),
      waterIntake: WaterIntake.fromJson(waterJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'caloriesConsumed': caloriesConsumed,
      'caloriesBurned': caloriesBurned,
      'caloriesRemaining': caloriesRemaining,
      'macros': {
        'carb': carb.toJson(),
        'protein': protein.toJson(),
        'fat': fat.toJson(),
      },
      'waterIntake': waterIntake.toJson(),
    };
  }

  int get totalCalories => caloriesConsumed + caloriesRemaining;
  double get caloriesPercentage =>
      totalCalories > 0 ? (caloriesConsumed / totalCalories * 100) : 0;
}
