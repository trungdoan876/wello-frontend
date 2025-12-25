class TotalNutrition {
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  TotalNutrition({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory TotalNutrition.fromJson(Map<String, dynamic> json) {
    return TotalNutrition(
      totalCalories: json['totalCalories'] as int,
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }
}
