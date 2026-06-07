import '../../domain/repositories/nutrition_repository.dart';
import '../data_source/nutrition_remote_data_source.dart';
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/week_overview.dart';
import '../../domain/entities/food_log_result.dart';
import '../models/requests/log_food_request.dart';
import '../../domain/entities/food_history_item.dart';
import '../../domain/entities/weight_history_item.dart';
import '../../domain/entities/engagement_result.dart';
import '../../data/models/responses/water_log_response.dart';

/// Implementation of NutritionRepository
class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionRemoteDataSource remoteDataSource;

  NutritionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserProfile> getUserProfile(String token, String userId) async {
    return await remoteDataSource.getUserProfile(token, userId);
  }

  @override
  Future<NutritionSummary> getDailySummary(
    String token,
    String userId,
    String date,
  ) async {
    return await remoteDataSource.getDailySummary(token, userId, date);
  }

  @override
  Future<WeekOverview> getWeekOverview(
    String token,
    String userId,
    String startDate,
  ) async {
    return await remoteDataSource.getWeekOverview(token, userId, startDate);
  }

  @override
  Future<WaterIntake> getWaterIntake(
    String token,
    String userId,
    String date,
  ) async {
    return await remoteDataSource.getWaterIntake(token, userId, date);
  }

  @override
  Future<WaterIntake> addWaterGlass(
    String token,
    String userId,
    String date, {
    int glassSize = 250,
  }) async {
    return await remoteDataSource.addWaterGlass(
      token,
      userId,
      date,
      glassSize: glassSize,
    );
  }

  @override
  Future<WaterLogResponse> addWaterGlassWithEngagement(
    String token,
    String userId,
    String date, {
    int glassSize = 250,
  }) async {
    final response = await remoteDataSource.addWaterGlassRaw(
      token,
      userId,
      date,
      glassSize: glassSize,
    );
    return WaterLogResponse.fromJson(response);
  }

  @override
  Future<WaterIntake> subtractWaterGlass(
    String token,
    String userId,
    String date, {
    int glassSize = 250,
  }) async {
    return await remoteDataSource.subtractWaterGlass(
      token,
      userId,
      date,
      glassSize: glassSize,
    );
  }

  @override
  Future<FoodLogResult> logFood({
    required String token,
    required int userId,
    required int foodId,
    required int amountGrams,
    required String date,
    required String mealType,
    int? caloriesOverride,
    String? foodNameOverride,
    double? proteinOverride,
    double? carbsOverride,
    double? fatOverride,
  }) async {
    final response = await remoteDataSource.logFood(
      token,
      LogFoodRequest(
        userId: userId,
        foodId: foodId,
        amountGrams: amountGrams,
        date: date,
        mealType: mealType,
        caloriesOverride: caloriesOverride,
        foodNameOverride: foodNameOverride,
        proteinOverride: proteinOverride,
        carbsOverride: carbsOverride,
        fatOverride: fatOverride,
      ),
    );

    return FoodLogResult(
      foodName: response.foodName,
      calories: response.calories,
      protein: response.protein,
      carbs: response.carbs,
      fat: response.fat,
      message: response.message,
      engagement: response.engagement != null
          ? EngagementResult.fromJson(response.engagement!)
          : null,
    );
  }

  @override
  Future<List<FoodHistoryItem>> getFoodHistory(
    String token,
    String userId,
    String date,
  ) async {
    return await remoteDataSource.getFoodHistory(token, userId, date);
  }

  @override
  Future<List<WeightHistoryItem>> getWeightHistory(
    String token,
    String userId,
  ) async {
    return await remoteDataSource.getWeightHistory(token, userId);
  }

  @override
  Future<List<WeightHistoryItem>> getLatestWeightHistory(
    String token,
    String userId, {
    int limit = 5,
  }) async {
    return await remoteDataSource.getLatestWeightHistory(
      token,
      userId,
      limit: limit,
    );
  }
}
