import '../../domain/entities/badge.dart';
import '../../domain/entities/post.dart';

abstract class CompetitionRepository {
  Future<List<Map<String, dynamic>>> getLeaderboard({
    required String token,
    required String type,
    required String period,
  });

  Future<List<Badge>> getBadges({required String token});

  Future<List<Badge>> getUserBadges({
    required String token,
    required int userId,
  });

  Future<bool> equipBadge({required String token, required int badgeId});
  Future<bool> unequipBadge({required String token});
}
