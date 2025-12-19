import '../../domain/repositories/nutrition_repository.dart';
import '../data_source/nutrition_remote_data_source.dart';
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/week_overview.dart';

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
    int glassSize = 325,
  }) async {
    return await remoteDataSource.addWaterGlass(
      token,
      userId,
      date,
      glassSize: glassSize,
    );
  }

  @override
  Future<WaterIntake> subtractWaterGlass(
    String token,
    String userId,
    String date, {
    int glassSize = 325,
  }) async {
    return await remoteDataSource.subtractWaterGlass(
      token,
      userId,
      date,
      glassSize: glassSize,
    );
  }
}
