import 'package:flutter/material.dart';
import '../entities/food_request.dart';
import '../entities/exercise_request.dart';
import '../repositories/food_repository.dart';
import '../repositories/exercise_repository.dart';
import '../../core/utils/auth_helper.dart';

class ContributionProvider with ChangeNotifier {
  final FoodRepository foodRepository;
  final ExerciseRepository exerciseRepository;

  bool _isLoading = false;
  String? _error;
  bool _isSuccess = false;

  ContributionProvider({
    required this.foodRepository,
    required this.exerciseRepository,
  });

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSuccess => _isSuccess;

  void reset() {
    _isLoading = false;
    _error = null;
    _isSuccess = false;
    notifyListeners();
  }

  Future<bool> submitFoodRequest(String token, FoodRequest request) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final effectiveToken = token.isNotEmpty ? token : (credentials?.token ?? '');
      
      await foodRepository.requestFood(effectiveToken, request);
      _isSuccess = true;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitExerciseRequest(String token, ExerciseRequest request) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final effectiveToken = token.isNotEmpty ? token : (credentials?.token ?? '');
      
      await exerciseRepository.requestExercise(effectiveToken, request);
      _isSuccess = true;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
