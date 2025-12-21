class FavoriteResponse {
  final int id;
  final int foodId; // Non-nullable, fallbacks to id
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType;

  FavoriteResponse({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
  });

  factory FavoriteResponse.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int;
    return FavoriteResponse(
      id: id,
      foodId:
          (json['foodId'] as int?) ?? id, // Fallback to id if foodId missing
      foodName: json['foodName'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      mealType: json['mealType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'foodId': foodId,
    'foodName': foodName,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'mealType': mealType,
  };
}
