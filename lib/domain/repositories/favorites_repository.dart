import '../models/requests/add_favorite_request.dart';

abstract class FavoritesRepository {
  Future<Map<String, dynamic>> addFavorite({
    required AddFavoriteRequest request,
  });
}
