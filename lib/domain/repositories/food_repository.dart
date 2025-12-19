import '../entities/food.dart';

/// Abstract repository for food operations
abstract class FoodRepository {
  /// Get all available foods
  Future<List<Food>> getAllFoods(String token);
}
