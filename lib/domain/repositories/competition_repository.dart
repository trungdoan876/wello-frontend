import '../../domain/entities/challenge.dart';
import '../../domain/entities/badge.dart';

abstract class CompetitionRepository {
  Future<List<Map<String, dynamic>>> getLeaderboard({
    required String token,
    required String type,
    required String period,
  });

  Future<List<Challenge>> getChallenges({required String token});

  Future<void> joinChallenge({
    required String token,
    required int challengeId,
  });

  Future<void> submitProof({
    required String token,
    required int challengeId,
    required String content,
    required String? imageUrl,
  });

  Future<List<Badge>> getBadges({required String token});

  Future<List<Badge>> getUserBadges({
    required String token,
    required int userId,
  });
}
