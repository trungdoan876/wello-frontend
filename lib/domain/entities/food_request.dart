class FoodRequest {
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;

  FoodRequest({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
    };
  }
}
