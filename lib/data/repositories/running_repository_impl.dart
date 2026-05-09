import '../../domain/entities/running_session.dart';
import '../../domain/repositories/running_repository.dart';
import '../data_source/running_remote_data_source.dart';

class RunningRepositoryImpl implements RunningRepository {
  final RunningRemoteDataSource remoteDataSource;

  RunningRepositoryImpl({required this.remoteDataSource});

  @override
  Future<int> saveSession(String token, RunningSession session) async {
    return await remoteDataSource.saveSession(token, session);
  }

  @override
  Future<List<RunningSession>> getHistory(
    String token,
    int userId, {
    int limit = 10,
  }) async {
    return await remoteDataSource.getHistory(token, userId, limit: limit);
  }

  @override
  Future<RunningWeeklySummary> getWeeklySummary(
    String token,
    int userId,
    String startDate,
  ) async {
    return await remoteDataSource.getWeeklySummary(token, userId, startDate);
  }
}
