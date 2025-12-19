import '../entities/food.dart';

/// Abstract repository for food operations
abstract class FoodRepository {
  /// Get all available foods
  Future<List<Food>> getAllFoods(String token);

  /// Preview food nutrition for a specific amount
  Future<Food> previewFood(String token, int foodId, int amountGrams);
}
