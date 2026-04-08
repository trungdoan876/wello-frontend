import 'package:flutter/material.dart';
import '../../data/data_source/favorites_remote_data_source.dart';
import '../../data/models/requests/add_favorite_combo_request.dart';
import '../../data/models/requests/update_favorite_combo_request.dart';
import 'package:wello_frontend/data/models/requests/log_favorite_request.dart';
import '../../data/models/requests/favorite_combo_item.dart';
import '../../data/models/responses/favorite_combo_response.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../core/utils/auth_helper.dart';

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
  List<FavoriteComboResponse> _favorites = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get success => _success;
  List<FavoriteComboResponse> get favorites => _favorites;

  /// Fetch all favorites for a user
  Future<void> fetchFavorites(int userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final result = await repository.getFavoritesByUserId(
        token: token ?? '',
        userId: userId,
      );
      _favorites = result;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Get favorite combo by ID
  Future<FavoriteComboResponse?> getFavoriteById({
    required int favoriteId,
    required int userId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final favorite = await repository.getFavoriteById(
        token: token ?? '',
        favoriteId: favoriteId,
        userId: userId,
      );

      _isLoading = false;
      notifyListeners();

      return favorite;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Add combo to favorites
  Future<bool> addCombo({
    required int userId,
    required String favoriteName,
    required String mealType,
    required List<FavoriteComboItem> items,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _success = false;
      notifyListeners();

      final request = AddFavoriteComboRequest(
        userId: userId,
        favoriteName: favoriteName,
        mealType: mealType,
        items: items,
      );

      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final result = await repository.addCombo(
        token: token ?? '',
        request: request,
      );

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

  /// Update a favorite combo
  Future<bool> updateCombo({
    required int userId,
    required int favoriteId,
    required String favoriteName,
    required String mealType,
    required List<FavoriteComboItem> items,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _success = false;
      notifyListeners();

      final request = UpdateFavoriteComboRequest(
        userId: userId,
        favoriteId: favoriteId,
        favoriteName: favoriteName,
        mealType: mealType,
        items: items,
      );

      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      final result = await repository.updateCombo(
        token: token ?? '',
        request: request,
      );

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

  /// Delete a favorite combo
  Future<bool> deleteFavorite({
    required int favoriteId,
    required int userId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _success = false;
      notifyListeners();

      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      await repository.deleteFavorite(
        token: token ?? '',
        favoriteId: favoriteId,
        userId: userId,
      );

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

  /// Log a favorite combo to daily nutrition
  Future<bool> logFavorite({
    required int userId,
    required int favoriteId,
    required String date,
    required String mealType,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _success = false;
      notifyListeners();

      final request = LogFavoriteRequest(
        userId: userId,
        favoriteId: favoriteId,
        date: date,
        mealType: mealType,
      );

      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      await repository.logFavorite(token: token ?? '', request: request);

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
