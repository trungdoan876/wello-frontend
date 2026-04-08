import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/question.dart';
import '../../core/constants/api_endpoints.dart';

/// Nguồn dữ liệu từ xa cho câu hỏi khảo sát
/// Xử lý các API calls liên quan đến câu hỏi
class QuestionRemoteDataSource {
  final String baseUrl;

  QuestionRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  /// Lấy danh sách câu hỏi từ backend API
  Future<List<Question>> fetchQuestions(String token) async {
    final url = Uri.parse(ApiEndpoints.surveyQuestions);

    print('Dang lay danh sach cau hoi - URL: $url');
    print('Token length: ${token.length}');
    if (token.length > 20) {
      print('Token start: ${token.substring(0, 10)}...${token.substring(token.length - 10)}');
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      print('Request Headers: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      print('Trang thai phan hoi cau hoi: ${response.statusCode}');

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
