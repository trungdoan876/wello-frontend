import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../data/data_source/running_remote_data_source.dart';
import '../../data/repositories/running_repository_impl.dart';
import '../entities/running_session.dart';
import '../repositories/running_repository.dart';
import '../../ui/running/models/running_record.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RunningProvider extends ChangeNotifier {
  final RunningRepository _repository;

  RunningWeeklySummary? _weeklySummary;
  List<RunningSession> _history = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _historyLimit = 5;

  // Active Tracking State
  bool _isTracking = false;
  bool _isPaused = false;
  int _secondsElapsed = 0;
  double _km = 0.0;
  int _steps = 0;
  int _calories = 0;
  double _paceMinPerKm = 0.0;
  double _progress = 0.0;
  bool _gpsReady = false;
  LatLng? _currentPosition;
  final List<LatLng> _routePoints = [];

  // Configuration Properties
  String _activityLabel = '';
  String _activityType = '';
  String _goalValueText = '';
  String _selectedGoal = '';
  int _targetKm = 0;
  int _targetMinutes = 0;
  int _targetCalories = 0;
  int _targetSteps = 0;

  // Active tracking streams & timers
  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;
  bool _isSaving = false;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Getters
  bool get isTracking => _isTracking;
  bool get isPaused => _isPaused;
  int get secondsElapsed => _secondsElapsed;
  double get km => _km;
  int get steps => _steps;
  int get calories => _calories;
  double get paceMinPerKm => _paceMinPerKm;
  double get progress => _progress;
  bool get gpsReady => _gpsReady;
  LatLng? get currentPosition => _currentPosition;
  List<LatLng> get routePoints => _routePoints;

  String get activityLabel => _activityLabel;
  String get activityType => _activityType;
  String get goalValueText => _goalValueText;
  String get selectedGoal => _selectedGoal;
  int get targetKm => _targetKm;
  int get targetMinutes => _targetMinutes;
  int get targetCalories => _targetCalories;
  int get targetSteps => _targetSteps;
  bool get isSaving => _isSaving;

  // Helper getters
  double get caloriesPerKm {
    switch (_activityLabel.toLowerCase()) {
      case 'đi bộ':
        return 60.0;
      case 'đạp xe':
        return 40.0;
      default:
        return 80.0;
    }
  }

  double get stepsPerKm {
    switch (_activityLabel.toLowerCase()) {
      case 'đi bộ':
        return 1350.0;
      case 'đạp xe':
        return 0.0;
      default:
        return 1250.0;
    }
  }

  String get formattedTime {
    final h = _secondsElapsed ~/ 3600;
    final m = (_secondsElapsed % 3600) ~/ 60;
    final s = _secondsElapsed % 60;
    return '${h > 0 ? '${h.toString().padLeft(2, '0')}:' : ''}${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get formattedPace {
    if (_paceMinPerKm <= 0) return '--:--';
    final m = _paceMinPerKm.floor();
    final s = ((_paceMinPerKm - m) * 60).round();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

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
    int historyLimit = 5,
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

  Future<void> startTracking({
    required String activityLabel,
    required String activityType,
    required String goalValueText,
    required String selectedGoal,
    required int targetKm,
    required int targetMinutes,
    required int targetCalories,
    required int targetSteps,
    LatLng? center,
  }) async {
    _isTracking = true;
    _isPaused = false;
    _secondsElapsed = 0;
    _km = 0.0;
    _steps = 0;
    _calories = 0;
    _paceMinPerKm = 0.0;
    _progress = 0.0;
    _gpsReady = false;
    _isSaving = false;
    _currentPosition = center;
    _routePoints.clear();
    if (center != null) {
      _routePoints.add(center);
    }

    _activityLabel = activityLabel;
    _activityType = activityType;
    _goalValueText = goalValueText;
    _selectedGoal = selectedGoal;
    _targetKm = targetKm;
    _targetMinutes = targetMinutes;
    _targetCalories = targetCalories;
    _targetSteps = targetSteps;

    // Request notification permission for Android 13+
    try {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _localNotifications.initialize(
        const InitializationSettings(android: androidSettings),
      );
    } catch (e) {
      print('Lỗi yêu cầu quyền thông báo: $e');
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      _secondsElapsed++;
      _updateProgress();
      _updateOngoingNotification();
      notifyListeners();
    });

    // GPS Permission & initialization
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      notifyListeners();
      return;
    }

    _gpsReady = true;
    notifyListeners();

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationText: "Ứng dụng Wello đang ghi lại hoạt động của bạn",
          notificationTitle: "${_activityLabel.isNotEmpty ? _activityLabel : 'Hoạt động'} đang diễn ra",
        ),
      ),
    ).listen(_onPositionUpdate);

    _updateOngoingNotification();
  }

  void _onPositionUpdate(Position position) {
    if (_isPaused) return;

    final speedMs = position.speed >= 0 ? position.speed : 0.0;
    final double distanceMeters = _currentPosition != null
        ? Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            position.latitude,
            position.longitude,
          )
        : 0.0;

    print('📍 [RunningProvider] GPS Update: accuracy=${position.accuracy.toStringAsFixed(1)}m, speed=${speedMs.toStringAsFixed(2)}m/s, dist=${distanceMeters.toStringAsFixed(2)}m');

    // Filter out bad GPS accuracy points (Drift filter)
    if (position.accuracy > 20.0) {
      print('📍 [RunningProvider] GPS Update rejected: accuracy > 20m');
      return;
    }

    final newPoint = LatLng(position.latitude, position.longitude);

    if (_currentPosition == null) {
      _currentPosition = newPoint;
      _routePoints.add(newPoint);
      print('📍 [RunningProvider] Initialized GPS start position');
    } else {
      final isWalking = _activityLabel.toLowerCase() == 'đi bộ';
      final minSpeedMs = isWalking ? 0.3 : 0.8;
      final hasRealMovement = distanceMeters >= 10.0 && speedMs >= minSpeedMs;

      if (hasRealMovement) {
        final addedKm = distanceMeters / 1000.0;
        _km += addedKm;
        _steps += (addedKm * stepsPerKm).round();
        _calories = (_km * caloriesPerKm).round();

        if (_km > 0 && _secondsElapsed > 0) {
          _paceMinPerKm = (_secondsElapsed / 60.0) / _km;
        }

        _routePoints.add(newPoint);
        _currentPosition = newPoint;
        _updateProgress();
        _updateOngoingNotification();
        print('📍 [RunningProvider] GPS Update accepted! New distance=${_km.toStringAsFixed(3)} km');
      } else {
        print('📍 [RunningProvider] GPS Update filtered (movement too small or speed too low). Min speed needed: ${minSpeedMs}m/s');
      }
    }
    notifyListeners();
  }

  void _updateProgress() {
    switch (_selectedGoal) {
      case 'distance':
        _progress = (_km / _targetKm).clamp(0.0, 1.0);
        break;
      case 'time':
        _progress = (_secondsElapsed / 60.0 / _targetMinutes).clamp(0.0, 1.0);
        break;
      case 'calories':
        _progress = (_calories / _targetCalories).clamp(0.0, 1.0);
        break;
      case 'steps':
        _progress = (_steps / _targetSteps).clamp(0.0, 1.0);
        break;
      default:
        _progress = (_km / _targetKm).clamp(0.0, 1.0);
    }
  }

  void togglePause() {
    _isPaused = !_isPaused;
    _updateOngoingNotification();
    notifyListeners();
  }

  Future<bool> stopAndSaveTracking(String token, int userId) async {
    if (_isSaving) return false;
    _isSaving = true;
    notifyListeners();

    try {
      final session = RunningSession(
        userId: userId,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        activityType: _activityType,
        durationSeconds: _secondsElapsed,
        distanceKm: _km,
        caloriesBurned: _calories,
        steps: _steps,
        avgPaceSecPerKm: _km > 0 ? (_secondsElapsed / _km).round() : 0,
        goalType: _selectedGoal,
        goalValue: switch (_selectedGoal) {
          'distance' => _targetKm.toDouble(),
          'time' => _targetMinutes.toDouble(),
          'calories' => _targetCalories.toDouble(),
          'steps' => _targetSteps.toDouble(),
          _ => _targetKm.toDouble(),
        },
        completionPercent: (_progress * 100).clamp(0, 100).round(),
      );

      print('🏃 [RunningProvider] stopAndSaveTracking: saving session payload: ${session.toJson()}');
      final sessionId = await saveSession(token, session);
      print('🏃 [RunningProvider] stopAndSaveTracking: save success! sessionId = $sessionId');
      
      cancelTracking();
      return true;
    } catch (e) {
      print('🏃 [RunningProvider] stopAndSaveTracking: error: $e');
      _isSaving = false;
      notifyListeners();
      rethrow;
    }
  }

  void cancelTracking() {
    _timer?.cancel();
    _timer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;

    try {
      _localNotifications.cancel(888);
    } catch (e) {
      print('Lỗi hủy thông báo: $e');
    }

    _isTracking = false;
    _isPaused = false;
    _secondsElapsed = 0;
    _km = 0.0;
    _steps = 0;
    _calories = 0;
    _paceMinPerKm = 0.0;
    _progress = 0.0;
    _gpsReady = false;
    _isSaving = false;
    _currentPosition = null;
    _routePoints.clear();

    _activityLabel = '';
    _activityType = '';
    _goalValueText = '';
    _selectedGoal = '';
    _targetKm = 0;
    _targetMinutes = 0;
    _targetCalories = 0;
    _targetSteps = 0;

    notifyListeners();
  }

  Future<void> _updateOngoingNotification() async {
    if (!_isTracking) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'running_active_channel',
        'Buổi tập đang diễn ra',
        channelDescription: 'Thông tin quãng đường và thời gian buổi tập',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        onlyAlertOnce: true,
        showWhen: false,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      final statusText = _isPaused ? 'đang tạm dừng' : 'đang diễn ra';
      await _localNotifications.show(
        888,
        'Buổi tập ${_activityLabel} $statusText...',
        'Quãng đường: ${_km.toStringAsFixed(2)} km | Thời gian: ${formattedTime}',
        notificationDetails,
      );
    } catch (e) {
      print('Lỗi cập nhật thông báo: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    try {
      _localNotifications.cancel(888);
    } catch (_) {}
    super.dispose();
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
