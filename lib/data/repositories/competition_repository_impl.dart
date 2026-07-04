import '../../domain/entities/badge.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/competition_repository.dart';
import '../data_source/competition_remote_data_source.dart';

class CompetitionRepositoryImpl implements CompetitionRepository {
  final CompetitionRemoteDataSource remoteDataSource;

  CompetitionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard({
    required String token,
    required String type,
    required String period,
  }) async {
    return await remoteDataSource.getLeaderboard(
      token: token,
      type: type,
      period: period,
    );
  }

  @override
  Future<List<Badge>> getBadges({required String token}) async {
    return await remoteDataSource.getBadges(token: token);
  }

  @override
  Future<List<Badge>> getUserBadges({
    required String token,
    required int userId,
  }) async {
    return await remoteDataSource.getUserBadges(
      token: token,
      userId: userId,
    );
  }

  @override
  Future<bool> equipBadge({required String token, required int badgeId}) async {
    return await remoteDataSource.equipBadge(token: token, badgeId: badgeId);
  }

  @override
  Future<bool> unequipBadge({required String token}) async {
    return await remoteDataSource.unequipBadge(token: token);
  }
}
