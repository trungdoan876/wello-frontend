import 'engagement_result.dart';

class FoodLogResult {
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String message;
  final EngagementResult? engagement;

  FoodLogResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.message,
    this.engagement,
  });
}
