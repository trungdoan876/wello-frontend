import '../../domain/entities/challenge.dart';
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
  Future<List<Challenge>> getChallenges({required String token}) async {
    return await remoteDataSource.getChallenges(token: token);
  }

  @override
  Future<void> joinChallenge({
    required String token,
    required int challengeId,
  }) async {
    return await remoteDataSource.joinChallenge(
      token: token,
      challengeId: challengeId,
    );
  }

  @override
  Future<Post> submitProof({
    required String token,
    required int challengeId,
    required String content,
    required String? imageUrl,
  }) async {
    return await remoteDataSource.submitProof(
      token: token,
      challengeId: challengeId,
      content: content,
      imageUrl: imageUrl,
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
}
