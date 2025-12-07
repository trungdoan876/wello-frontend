import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

/// Remote data source for questions
/// Handles direct API calls related to questions
class QuestionRemoteDataSource {
  final String baseUrl;

  QuestionRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Fetch questions list from backend API
  Future<List<Question>> fetchQuestions() async {
    final url = Uri.parse('$baseUrl/survey/questions');

    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load questions: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    }
  }

  /// Submit survey answers to backend
  /// TODO: Implement when backend endpoint is ready
  Future<Map<String, dynamic>> submitSurvey({
    required List<Map<String, dynamic>> answers,
    String? token,
  }) async {
    final url = Uri.parse('$baseUrl/survey/submit');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'answers': answers}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to submit survey: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error submitting survey: $e');
    }
  }
}
