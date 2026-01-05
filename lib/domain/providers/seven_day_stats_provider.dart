import 'package:flutter/foundation.dart';
import '../entities/seven_day_stats.dart';
import '../../data/data_source/nutrition_remote_data_source.dart';

/// Provider for managing 7-day statistics
class SevenDayStatsProvider extends ChangeNotifier {
  final NutritionRemoteDataSource _remoteDataSource;

  SevenDayStats? _stats;
  bool _isLoading = false;
  String? _errorMessage;

  SevenDayStatsProvider({NutritionRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? NutritionRemoteDataSource();

  // Getters
  SevenDayStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Load 7-day statistics from API
  Future<void> loadSevenDayStats(String token, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Loading 7-day stats for userId: $userId');
      _stats = await _remoteDataSource.getSevenDayStats(token, userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading 7-day stats: $e');
      _errorMessage = 'Lỗi tải dữ liệu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
