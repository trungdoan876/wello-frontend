import '../../domain/entities/food.dart';
import '../../domain/repositories/food_repository.dart';
import '../data_source/food_remote_data_source.dart';
import '../models/requests/food_preview_request.dart';


/// Implementation of FoodRepository
class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource remoteDataSource;

  FoodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Food>> getAllFoods(String token) async {
    return await remoteDataSource.getAllFoods(token);
  }

  @override
  Future<Food> previewFood(String token, int foodId, int amountGrams) async {
    return await remoteDataSource.previewFood(
      token,
      FoodPreviewRequest(foodId: foodId, amountGrams: amountGrams),
    );
  }
}
