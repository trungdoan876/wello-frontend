import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/data_source/running_remote_data_source.dart';
import '../../data/repositories/running_repository_impl.dart';
import '../entities/running_session.dart';
import '../repositories/running_repository.dart';
import '../../ui/running/models/running_record.dart';

class RunningProvider extends ChangeNotifier {
  final RunningRepository _repository;

  RunningWeeklySummary? _weeklySummary;
  List<RunningSession> _history = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _historyLimit = 10;

  RunningProvider({RunningRepository? repository})
    : _repository =
          repository ??
          RunningRepositoryImpl(remoteDataSource: RunningRemoteDataSource());

  RunningWeeklySummary? get weeklySummary => _weeklySummary;
  List<RunningSession> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  List<RunningRecord> get historyRecords => _history
      .map(
        (session) => RunningRecord(
          date: session.date,
          distance: session.distanceKm,
          duration: _formatDuration(session.durationSeconds),
          pace: session.avgPaceSecPerKm > 0
              ? session.avgPaceSecPerKm / 60.0
              : 0,
        ),
      )
      .toList();

  RunningRecord? get latestRecord {
    if (_history.isEmpty) return null;
    final session = _history.first;
    return RunningRecord(
      date: session.date,
      distance: session.distanceKm,
      duration: _formatDuration(session.durationSeconds),
      pace: session.avgPaceSecPerKm > 0 ? session.avgPaceSecPerKm / 60.0 : 0,
    );
  }

  double get weeklyAverageSpeedKmh {
    final summary = _weeklySummary;
    if (summary == null || summary.totalDurationSeconds <= 0) return 0;
    return summary.totalDistanceKm / (summary.totalDurationSeconds / 3600.0);
  }

  Future<void> loadDashboard(
    String token,
    int userId, {
    int historyLimit = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _historyLimit = historyLimit;
    notifyListeners();

    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate = DateFormat('yyyy-MM-dd').format(startOfWeek);

      final results = await Future.wait([
        _repository.getWeeklySummary(token, userId, startDate),
        _repository.getHistory(token, userId, limit: historyLimit),
      ]);

      _weeklySummary = results[0] as RunningWeeklySummary;
      _history = results[1] as List<RunningSession>;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> saveSession(String token, RunningSession session) async {
    final sessionId = await _repository.saveSession(token, session);
    await loadDashboard(token, session.userId, historyLimit: _historyLimit);
    return sessionId;
  }

  static String _formatDuration(int durationSeconds) {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
