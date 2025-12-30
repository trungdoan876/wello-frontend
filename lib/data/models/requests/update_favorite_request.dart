class UpdateFavoriteRequest {
  final int userId;
  final int favoriteId;
  final String foodName;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final String mealType;

  UpdateFavoriteRequest({
    required this.userId,
    required this.favoriteId,
    required this.foodName,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'favoriteId': favoriteId,
      'foodName': foodName,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'mealType': mealType,
    };
  }
}
