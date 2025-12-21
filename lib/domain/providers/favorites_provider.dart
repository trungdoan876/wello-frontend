import 'package:flutter/material.dart';
import '../../data/data_source/favorites_remote_data_source.dart';
import '../../data/models/requests/add_favorite_request.dart';
import '../../data/repositories/favorites_repository_impl.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepositoryImpl repository;

  FavoritesProvider({FavoritesRepositoryImpl? repository})
    : repository =
          repository ??
          FavoritesRepositoryImpl(
            remoteDataSource: FavoritesRemoteDataSource(),
          );

  bool _isLoading = false;
  String? _errorMessage;
  bool _success = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get success => _success;

  /// Add meal to favorites
  Future<bool> addToFavorites({
    required int userId,
    required String foodName,
    required int caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    required String mealType,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _success = false;
      notifyListeners();

      final request = AddFavoriteRequest(
        userId: userId,
        foodName: foodName,
        caloriesPer100g: caloriesPer100g,
        proteinPer100g: proteinPer100g,
        carbsPer100g: carbsPer100g,
        fatPer100g: fatPer100g,
        mealType: mealType,
      );

      final result = await repository.addFavorite(request: request);

      _isLoading = false;
      _success = true;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      _success = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _success = false;
    notifyListeners();
  }
}
