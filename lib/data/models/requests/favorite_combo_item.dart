class FavoriteComboItem {
  final int? itemId;
  final int foodId;
  final String? foodName;
  final int amountGrams;
  final int? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  FavoriteComboItem({
    this.itemId,
    required this.foodId,
    this.foodName,
    required this.amountGrams,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory FavoriteComboItem.fromJson(Map<String, dynamic> json) {
    return FavoriteComboItem(
      itemId: json['itemId'] as int?,
      foodId: json['foodId'] as int,
      foodName: json['foodName'] as String?,
      amountGrams: json['amountGrams'] as int,
      calories: json['calories'] as int?,
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    // Only send required fields for backend
    return {
      'foodId': foodId,
      'amountGrams': amountGrams,
    };
  }
}
