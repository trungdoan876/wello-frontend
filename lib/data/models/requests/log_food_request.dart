class LogFoodRequest {
  final int userId;
  final int foodId;
  final int amountGrams;
  final String date;

  final String mealType;

  LogFoodRequest({
    required this.userId,
    required this.foodId,
    required this.amountGrams,
    required this.date,
    required this.mealType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'foodId': foodId,
      'amountGrams': amountGrams,
      'date': date,
      'mealType': mealType,
    };
  }
}
