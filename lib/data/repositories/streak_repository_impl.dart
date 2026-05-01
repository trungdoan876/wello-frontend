import 'package:wello_frontend/domain/entities/daily_streak.dart';
import 'package:wello_frontend/data/repositories/streak_repository.dart';
import 'package:wello_frontend/data/data_source/streak_remote_data_source.dart';

class StreakRepositoryImpl implements StreakRepository {
  final StreakRemoteDataSource remote;

  StreakRepositoryImpl(this.remote);

  @override
  Future<List<DailyStreak>> getMonthly(
    String token,
    int userId,
    int year,
    int month,
  ) {
    return remote.getMonthlyStreak(
      token: token,
      userId: userId,
      year: year,
      month: month,
    );
  }
}
