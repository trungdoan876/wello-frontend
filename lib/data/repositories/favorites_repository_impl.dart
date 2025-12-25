import 'package:wello_frontend/data/data_source/favorites_remote_data_source.dart';
import 'package:wello_frontend/data/models/requests/add_favorite_combo_request.dart';
import 'package:wello_frontend/data/models/requests/update_favorite_combo_request.dart';
import 'package:wello_frontend/data/models/requests/log_favorite_request.dart';
import 'package:wello_frontend/data/models/responses/favorite_combo_response.dart';
import 'package:wello_frontend/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FavoriteComboResponse> getFavoriteById({
    required int favoriteId,
    required int userId,
  }) async {
    try {
      return await remoteDataSource.getFavoriteById(
        favoriteId: favoriteId,
        userId: userId,
      );
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> addCombo({
    required AddFavoriteComboRequest request,
  }) async {
    try {
      return await remoteDataSource.addCombo(request: request);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> updateCombo({
    required UpdateFavoriteComboRequest request,
  }) async {
    try {
      return await remoteDataSource.updateCombo(request: request);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<void> deleteFavorite({
    required int favoriteId,
    required int userId,
  }) async {
    try {
      await remoteDataSource.deleteFavorite(
        favoriteId: favoriteId,
        userId: userId,
      );
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> logFavorite({
    required LogFavoriteRequest request,
  }) async {
    try {
      return await remoteDataSource.logFavorite(request: request);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}
