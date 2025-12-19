class FoodHistoryItem {
  final int id;
  final String foodName;
  final int amountGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType;
  final String loggedAt;

  FoodHistoryItem({
    required this.id,
    required this.foodName,
    required this.amountGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.loggedAt,
  });

  factory FoodHistoryItem.fromJson(Map<String, dynamic> json) {
    return FoodHistoryItem(
      id: json['id'] as int,
      foodName: json['foodName'] as String,
      amountGrams: json['amountGrams'] as int,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      mealType: json['mealType'] as String,
      loggedAt: json['loggedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'amountGrams': amountGrams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealType': mealType,
      'loggedAt': loggedAt,
    };
  }
}
