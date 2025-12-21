import '../../data/data_source/favorites_remote_data_source.dart';
import '../../data/models/requests/add_favorite_request.dart';
import '../repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> addFavorite({
    required AddFavoriteRequest request,
  }) async {
    try {
      return await remoteDataSource.addFavorite(request: request);
    } catch (e) {
      throw Exception('Repository error: $e');
    }
  }
}
