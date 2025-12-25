import '../models/requests/add_favorite_combo_request.dart';
import '../models/requests/update_favorite_combo_request.dart';

abstract class FavoritesRepository {
  Future<Map<String, dynamic>> addCombo({
    required AddFavoriteComboRequest request,
  });

  Future<Map<String, dynamic>> updateCombo({
    required UpdateFavoriteComboRequest request,
  });

  Future<void> deleteFavorite({
    required int favoriteId,
    required int userId,
  });
}
