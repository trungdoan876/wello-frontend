import 'package:flutter/foundation.dart';
import '../entities/question.dart';
import '../../data/repositories/question_repository.dart';

class QuestionProvider extends ChangeNotifier {
  final QuestionRepository _repository;
  
  List<Question> _questions = [];
  bool _isLoading = false;
  String? _errorMessage;

  QuestionProvider({QuestionRepository? repository})
      : _repository = repository ?? QuestionRepository();

  // Getters
  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Load questions from backend API
  Future<void> loadQuestions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _questions = await _repository.getQuestions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Get question by ID
  Question? getQuestionById(int id) {
    try {
      return _questions.firstWhere((q) => q.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get question by index
  Question? getQuestionByIndex(int index) {
    if (index >= 0 && index < _questions.length) {
      return _questions[index];
    }
    return null;
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Retry loading questions
  Future<void> retry() async {
    await loadQuestions();
  }
}
