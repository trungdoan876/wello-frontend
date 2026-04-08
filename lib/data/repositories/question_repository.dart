import '../../domain/entities/question.dart';
import '../data_source/question_remote_data_source.dart';

class QuestionRepository {
  final QuestionRemoteDataSource _dataSource;

  QuestionRepository({QuestionRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? QuestionRemoteDataSource();

  /// Fetch questions from backend
  Future<List<Question>> getQuestions(String token) async {
    try {
      return await _dataSource.fetchQuestions(token);
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }
}
