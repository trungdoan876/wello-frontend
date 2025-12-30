class FoodPreviewRequest {
  final int foodId;
  final int amountGrams;

  FoodPreviewRequest({
    required this.foodId,
    required this.amountGrams,
  });

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'amountGrams': amountGrams,
    };
  }
}
