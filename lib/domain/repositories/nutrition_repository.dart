import '../entities/nutrition_summary.dart';
import '../entities/user_profile.dart';
import '../entities/week_overview.dart';
import '../entities/food_log_result.dart';
import '../entities/food_history_item.dart';

/// Repository interface for nutrition and fitness data
abstract class NutritionRepository {
  /// Get user profile with fitness goals and targets
  Future<UserProfile> getUserProfile(String token, String userId);

  /// Get daily nutrition summary for a specific date
  /// @param userId - User ID
  /// @param date - Format: YYYY-MM-DD (e.g., "2024-12-18")
  Future<NutritionSummary> getDailySummary(
    String token,
    String userId,
    String date,
  );

  /// Get weekly overview for calendar
  /// @param userId - User ID
  /// @param startDate - Start date of the week (Format: YYYY-MM-DD)
  Future<WeekOverview> getWeekOverview(
    String token,
    String userId,
    String startDate,
  );

  /// Get daily water intake
  /// @param userId - User ID
  /// @param date - Format: YYYY-MM-DD
  Future<WaterIntake> getWaterIntake(String token, String userId, String date);

  /// Add a glass of water
  /// @param userId - User ID
  /// @param glassSize - Size of glass in ml (default: 325ml)
  Future<WaterIntake> addWaterGlass(
    String token,
    String userId,
    String date, {
    int glassSize,
  });

  /// Subtract a glass of water
  /// @param userId - User ID
  /// @param glassSize - Size of glass in ml (default: 325ml)
  Future<WaterIntake> subtractWaterGlass(
    String token,
    String userId,
    String date, {
    int glassSize,
  });

  /// Log food intake
  Future<FoodLogResult> logFood({
    required String token,
    required int userId,
    required int foodId,
    required int amountGrams,
    required String date,
    required String mealType,
    int? caloriesOverride,
    String? foodNameOverride,
  });

  /// Get food intake history
  Future<List<FoodHistoryItem>> getFoodHistory(
    String token,
    String userId,
    String date,
  );
}
