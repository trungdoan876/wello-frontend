import '../entities/running_session.dart';

abstract class RunningRepository {
  Future<int> saveSession(String token, RunningSession session);

  Future<List<RunningSession>> getHistory(
    String token,
    int userId, {
    int limit = 10,
  });

  Future<RunningWeeklySummary> getWeeklySummary(
    String token,
    int userId,
    String startDate,
  );
}
