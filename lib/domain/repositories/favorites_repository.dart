import 'package:wello_frontend/data/models/requests/add_favorite_combo_request.dart';
import 'package:wello_frontend/data/models/requests/update_favorite_combo_request.dart';
import 'package:wello_frontend/data/models/requests/log_favorite_request.dart';
import 'package:wello_frontend/data/models/responses/favorite_combo_response.dart';

abstract class FavoritesRepository {
  Future<FavoriteComboResponse> getFavoriteById({
    required String token,
    required int favoriteId,
    required int userId,
  });

  Future<FavoriteComboResponse> addCombo({
    required String token,
    required AddFavoriteComboRequest request,
  });

  Future<Map<String, dynamic>> updateCombo({
    required String token,
    required UpdateFavoriteComboRequest request,
  });

  Future<void> deleteFavorite({
    required String token,
    required int favoriteId,
    required int userId,
  });

  Future<Map<String, dynamic>> logFavorite({
    required String token,
    required LogFavoriteRequest request,
  });

  Future<List<FavoriteComboResponse>> getFavoritesByUserId({
    required String token,
    required int userId,
  });
}
