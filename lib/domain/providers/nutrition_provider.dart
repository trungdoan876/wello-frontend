import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/nutrition_summary.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/week_overview.dart';
import '../../data/data_source/nutrition_remote_data_source.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../repositories/nutrition_repository.dart';

/// Provider for managing nutrition and fitness data state
class NutritionProvider extends ChangeNotifier {
  final NutritionRepository _repository;
  
  UserProfile? _userProfile;
  NutritionSummary? _dailySummary;
  WeekOverview? _weekOverview;
  
  bool _isLoadingProfile = false;
  bool _isLoadingSummary = false;
  bool _isLoadingWeek = false;
  bool _isAddingWater = false;
  
  String? _errorMessage;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  NutritionProvider({NutritionRepository? repository})
      : _repository = repository ?? NutritionRepositoryImpl(
          remoteDataSource: NutritionRemoteDataSource(),
        );

  // Getters
  UserProfile? get userProfile => _userProfile;
  NutritionSummary? get dailySummary => _dailySummary;
  WeekOverview? get weekOverview => _weekOverview;
  
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingWeek => _isLoadingWeek;
  bool get isAddingWater => _isAddingWater;
  bool get isLoading => _isLoadingProfile || _isLoadingSummary || _isLoadingWeek;
  
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String get selectedDate => _selectedDate;

  /// Load all home screen data
  Future<void> loadHomeData(String token, String userId) async {
    await Future.wait([
      loadUserProfile(token, userId),
      loadDailySummary(token, userId, _selectedDate),
      loadWeekOverview(token, userId),
    ]);
  }

  /// Load user profile
  Future<void> loadUserProfile(String token, String userId) async {
    _isLoadingProfile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _repository.getUserProfile(token, userId);
      _isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load profile: ${e.toString()}';
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  /// Load daily nutrition summary
  Future<void> loadDailySummary(String token, String userId, String date) async {
    _isLoadingSummary = true;
    _errorMessage = null;
    _selectedDate = date;
    notifyListeners();

    try {
      _dailySummary = await _repository.getDailySummary(token, userId, date);
      
      // Cache successful data to SharedPreferences
      await _cacheDailySummary(_dailySummary!, date);
      
      _isLoadingSummary = false;
      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to load daily summary: ${e.toString()}');
      
      // Try to load from cache when offline
      final cachedSummary = await _loadCachedDailySummary(date);
      if (cachedSummary != null) {
        print('✅ Loaded from cache for date: $date');
        _dailySummary = cachedSummary;
        _errorMessage = null; // Clear error if we have cached data
      } else {
        _errorMessage = 'Failed to load daily summary: ${e.toString()}';
      }
      
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  /// Load weekly overview
  Future<void> loadWeekOverview(String token, String userId) async {
    _isLoadingWeek = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Calculate start of current week (Monday)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startDate = DateFormat('yyyy-MM-dd').format(startOfWeek);
      
      _weekOverview = await _repository.getWeekOverview(token, userId, startDate);
      _isLoadingWeek = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load week overview: ${e.toString()}';
      _isLoadingWeek = false;
      notifyListeners();
    }
  }

  /// Add a glass of water
  Future<void> addWaterGlass(String token, String userId, {int glassSize = 250}) async {
    if (_isAddingWater) return; // Prevent multiple simultaneous requests
    
    _isAddingWater = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedWaterIntake = await _repository.addWaterGlass(
        token,
        userId,
        _selectedDate,
        glassSize: glassSize,
      );
      
      // Update the daily summary with new water intake
      if (_dailySummary != null) {
        _dailySummary = NutritionSummary(
          date: _dailySummary!.date,
          caloriesConsumed: _dailySummary!.caloriesConsumed,
          caloriesBurned: _dailySummary!.caloriesBurned,
          caloriesRemaining: _dailySummary!.caloriesRemaining,
          carb: _dailySummary!.carb,
          protein: _dailySummary!.protein,
          fat: _dailySummary!.fat,
          waterIntake: updatedWaterIntake,
        );
      }
      
      _isAddingWater = false;
      notifyListeners();
      
      // Reload daily summary to get fresh data from backend
      await loadDailySummary(token, userId, _selectedDate);
    } catch (e) {
      _errorMessage = 'Failed to add water: ${e.toString()}';
      _isAddingWater = false;
      notifyListeners();
      rethrow; // Re-throw để widget có thể catch và show error
    }
  }

  /// Change selected date and reload data
  Future<void> changeDate(String token, String userId, String newDate) async {
    if (_selectedDate == newDate) return;
    
    _selectedDate = newDate;
    await loadDailySummary(token, userId, newDate);
  }

  /// Refresh all data
  Future<void> refresh(String token, String userId) async {
    await loadHomeData(token, userId);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _userProfile = null;
    _dailySummary = null;
    _weekOverview = null;
    _errorMessage = null;
    _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    notifyListeners();
  }
  
  /// Cache daily summary to SharedPreferences
  Future<void> _cacheDailySummary(NutritionSummary summary, String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(summary.toJson());
      await prefs.setString('nutrition_cache_$date', jsonString);
      print('💾 Cached nutrition data for $date');
    } catch (e) {
      print('❌ Failed to cache data: $e');
    }
  }
  
  /// Load cached daily summary from SharedPreferences
  Future<NutritionSummary?> _loadCachedDailySummary(String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('nutrition_cache_$date');
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        return NutritionSummary.fromJson(jsonMap);
      }
    } catch (e) {
      print('❌ Failed to load cached data: $e');
    }
    return null;
  }
}
