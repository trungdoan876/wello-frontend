import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../entities/nutrition_summary.dart';
import '../entities/user_profile.dart';
import '../entities/week_overview.dart';
import '../entities/food_log_result.dart';
import '../entities/goal_status.dart';
import '../entities/food_history_item.dart';

import '../../data/data_source/nutrition_remote_data_source.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../repositories/nutrition_repository.dart';

/// Provider for managing nutrition and fitness data state
class NutritionProvider extends ChangeNotifier {
  final NutritionRepository _repository;

  UserProfile? _userProfile;
  NutritionSummary? _dailySummary;
  WeekOverview? _weekOverview;
  List<FoodHistoryItem> _foodHistory = [];

  bool _isLoadingProfile = false;
  bool _isLoadingSummary = false;
  bool _isLoadingWeek = false;
  bool _isAddingWater = false;
  bool _isSubtractingWater = false;
  bool _isLoggingFood = false;
  bool _isLoadingHistory = false;


  String? _errorMessage;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  NutritionProvider({NutritionRepository? repository})
    : _repository =
          repository ??
          NutritionRepositoryImpl(
            remoteDataSource: NutritionRemoteDataSource(),
          );

  // Getters
  UserProfile? get userProfile => _userProfile;
  NutritionSummary? get dailySummary => _dailySummary;
  WeekOverview? get weekOverview => _weekOverview;
  List<FoodHistoryItem> get foodHistory => _foodHistory;

  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingSummary => _isLoadingSummary;
  bool get isLoadingWeek => _isLoadingWeek;
  bool get isAddingWater => _isAddingWater;
  bool get isSubtractingWater => _isSubtractingWater;
  bool get isLoggingFood => _isLoggingFood;
  bool get isLoadingHistory => _isLoadingHistory;

  bool get isLoading =>
      _isLoadingProfile || _isLoadingSummary || _isLoadingWeek;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  String get selectedDate => _selectedDate;

  /// Load all home screen data
  Future<void> loadHomeData(String token, String userId) async {
    await Future.wait([
      loadUserProfile(token, userId),
      loadDailySummary(token, userId, _selectedDate),
      loadWeekOverview(token, userId),
      loadFoodHistory(token, userId, _selectedDate),
    ]);
  }

  /// Load user profile
  Future<void> loadUserProfile(String token, String userId) async {
    _isLoadingProfile = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 Loading user profile for userId: $userId');
      _userProfile = await _repository.getUserProfile(token, userId);
      print('✅ UserProfile loaded: startDate=${_userProfile?.startDate}');
      _isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      print('❌ Failed to load profile: ${e.toString()}');
      _errorMessage = 'Failed to load profile: ${e.toString()}';
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  /// Load daily nutrition summary
  Future<void> loadDailySummary(
    String token,
    String userId,
    String date,
  ) async {
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

  /// Load food history
  Future<void> loadFoodHistory(String token, String userId, String date) async {
    _isLoadingHistory = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _foodHistory = await _repository.getFoodHistory(token, userId, date);
      _isLoadingHistory = false;
      notifyListeners();
    } catch (e) {
      print('⚠️ Failed to load food history: ${e.toString()}');
      // On error, clear history to avoid showing old data
      _foodHistory = [];
      _isLoadingHistory = false;
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

      _weekOverview = await _repository.getWeekOverview(
        token,
        userId,
        startDate,
      );
      _isLoadingWeek = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load week overview: ${e.toString()}';
      _isLoadingWeek = false;
      notifyListeners();
    }
  }

  /// Add a glass of water
  Future<void> addWaterGlass(
    String token,
    String userId, {
    int glassSize = 250,
  }) async {
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

  /// Subtract water glass from daily intake
  Future<void> subtractWaterGlass(
    String token,
    String userId, {
    int glassSize = 250,
  }) async {
    _isSubtractingWater = true;
    notifyListeners();

    try {
      final updatedWaterIntake = await _repository.subtractWaterGlass(
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

      _isSubtractingWater = false;
      notifyListeners();

      // Reload daily summary to get fresh data from backend
      await loadDailySummary(token, userId, _selectedDate);
    } catch (e) {
      _errorMessage = 'Failed to subtract water: ${e.toString()}';
      _isSubtractingWater = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Log food intake
  Future<FoodLogResult> logFood({
    required String token,
    required int userId,
    required int foodId,
    required int amountGrams,
    required String mealType,
  }) async {
    _isLoggingFood = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.logFood(
        token: token,
        userId: userId,
        foodId: foodId,
        amountGrams: amountGrams,
        date: _selectedDate,
        mealType: mealType,
      );

      _isLoggingFood = false;
      notifyListeners();

      // Refresh daily summary after successful log to update calories/macros
      await loadDailySummary(token, userId.toString(), _selectedDate);
      // Refresh history
      await loadFoodHistory(token, userId.toString(), _selectedDate);

      return result;
    } catch (e) {
      _errorMessage = 'Failed to log food: ${e.toString()}';
      _isLoggingFood = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Change selected date and reload data

  Future<void> changeDate(String token, String userId, String newDate) async {
    if (_selectedDate == newDate) return;

    _selectedDate = newDate;
    await Future.wait([
      loadDailySummary(token, userId, newDate),
      loadFoodHistory(token, userId, newDate),
    ]);
  }

  /// Refresh all data
  Future<void> refresh(String token, String userId) async {
    await loadHomeData(token, userId);
  }

  /// Check if any nutritional goals are reached or exceeded
  List<GoalAchievement> checkGoals() {
    if (_dailySummary == null || _userProfile == null) return [];

    final List<GoalAchievement> achievements = [];
    final summary = _dailySummary!;
    final profile = _userProfile!;

    // 1. Calories
    final calTarget = profile.dailyCalorieTarget;
    if (calTarget > 0) {
      if (summary.caloriesConsumed >= calTarget) {
        achievements.add(GoalAchievement(
          type: GoalType.calories,
          reached: true,
          exceeded: summary.caloriesConsumed > calTarget,
          message: summary.caloriesConsumed > calTarget
              ? 'Bạn đã vượt mục tiêu Calorie trong ngày!'
              : 'Chúc mừng! Bạn đã hoàn thành mục tiêu Calorie hôm nay.',
        ));
      }
    }

    // 2. Protein
    final proteinTarget = profile.macroTargets.protein.toDouble();
    if (proteinTarget > 0) {
      if (summary.protein.consumed >= proteinTarget) {
        achievements.add(GoalAchievement(
          type: GoalType.protein,
          reached: true,
          exceeded: summary.protein.consumed > proteinTarget + 10,
          message: 'Bạn đã nạp đủ lượng Protein cần thiết!',
        ));
      }
    }

    // 3. Water
    final waterTarget = profile.dailyWaterTarget;
    if (waterTarget > 0) {
      if (summary.waterIntake.consumed >= waterTarget) {
        achievements.add(GoalAchievement(
          type: GoalType.water,
          reached: true,
          exceeded: summary.waterIntake.consumed > waterTarget,
          message: 'Tuyệt vời! Bạn đã uống đủ nước hôm nay.',
        ));
      }
    }

    return achievements;
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
