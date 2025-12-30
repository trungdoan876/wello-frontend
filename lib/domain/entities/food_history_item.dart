class FoodHistoryItem {
  final int id;
  final int? foodId;
  final String foodName;
  final int amountGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType;
  final String loggedAt;
  final String? imageUrl;
  final String? favoriteName;

  FoodHistoryItem({
    required this.id,
    this.foodId,
    required this.foodName,
    required this.amountGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.loggedAt,
    this.imageUrl,
    this.favoriteName,
  });

  factory FoodHistoryItem.fromJson(Map<String, dynamic> json) {
    return FoodHistoryItem(
      id: json['id'] as int,
      foodId: json['foodId'] as int?,
      foodName: json['foodName'] as String,
      amountGrams: json['amountGrams'] as int,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      mealType: json['mealType'] as String,
      loggedAt: json['loggedAt'] as String,
      imageUrl: json['imageUrl'] as String?,
      favoriteName: json['favoriteName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'amountGrams': amountGrams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealType': mealType,
      'loggedAt': loggedAt,
      'imageUrl': imageUrl,
      'favoriteName': favoriteName,
    };
  }
}
