import 'package:flutter/foundation.dart';
import '../../data/models/requests/survey_request_model.dart';
import '../../data/models/responses/survey_response_model.dart';
import '../../data/models/responses/calculate_bmi_response_model.dart';
import '../../data/repositories/survey_repository_impl.dart';
import '../repositories/survey_repository.dart';
import '../../core/utils/auth_helper.dart';

class SurveyProvider extends ChangeNotifier {
  final SurveyRepository _repository;

  SurveyResponseModel? _surveyResult;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Store request data for display
  int? _height;
  int? _weight;

  SurveyProvider({SurveyRepository? repository})
      : _repository = repository ?? SurveyRepositoryImpl();

  // Getters
  SurveyResponseModel? get surveyResult => _surveyResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasResult => _surveyResult != null;
  int? get height => _height;
  int? get weight => _weight;

  /// Submit survey and get health metrics
  Future<void> submitSurvey(SurveyRequestModel request) async {
    _isLoading = true;
    _errorMessage = null;
    
    // Store height and weight for later display
    _height = request.height;
    _weight = request.weight;
    
    notifyListeners();

    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      _surveyResult = await _repository.submitSurvey(request, token: token);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _surveyResult = null;
      notifyListeners();
      rethrow;
    }
  }

  /// Calculate BMI with health warnings
  Future<CalculateBmiResponse> calculateBmi({
    required int weight,
    required int height,
    String? goal,
  }) async {
    try {
      final credentials = await AuthHelper.getCredentials();
      final token = credentials?.token;

      return await _repository.calculateBmi(
        weight: weight,
        height: height,
        goal: goal,
        token: token,
      );
    } catch (e) {
      print('Loi khi tinh BMI trong Provider: $e');
      rethrow;
    }
  }

  /// Clear survey result
  void clearResult() {
    _surveyResult = null;
    _errorMessage = null;
    _height = null;
    _weight = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
