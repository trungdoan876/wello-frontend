class LogFoodRequest {
  final int userId;
  final int foodId;
  final int amountGrams;
  final String date;
  final String mealType;
  final int? caloriesOverride; // Optional: use this instead of DB lookup
  final String? foodNameOverride; // Optional: use this instead of DB lookup
  final double? proteinOverride;
  final double? carbsOverride;
  final double? fatOverride;

  LogFoodRequest({
    required this.userId,
    required this.foodId,
    required this.amountGrams,
    required this.date,
    required this.mealType,
    this.caloriesOverride,
    this.foodNameOverride,
    this.proteinOverride,
    this.carbsOverride,
    this.fatOverride,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'foodId': foodId,
      'amountGrams': amountGrams,
      'date': date,
      'mealType': mealType,
      if (caloriesOverride != null) 'caloriesOverride': caloriesOverride,
      if (foodNameOverride != null) 'foodNameOverride': foodNameOverride,
      if (proteinOverride != null) 'proteinOverride': proteinOverride,
      if (carbsOverride != null) 'carbsOverride': carbsOverride,
      if (fatOverride != null) 'fatOverride': fatOverride,
    };
  }
}
