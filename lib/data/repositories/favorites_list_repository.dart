import '../models/responses/favorite_response.dart';
import '../data_source/favorites_data_source.dart';

class FavoritesRepository {
  final FavoritesDataSource dataSource;

  FavoritesRepository({FavoritesDataSource? dataSource})
    : dataSource = dataSource ?? FavoritesDataSource();

  Future<List<FavoriteResponse>> getMyFavorites(int userId) async {
    try {
      return await dataSource.getMyFavorites(userId);
    } catch (e) {
      rethrow;
    }
  }
}
