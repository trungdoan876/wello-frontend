import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requests/survey_request_model.dart';
import '../models/responses/survey_response_model.dart';

/// Remote data source for survey operations
/// Handles direct API calls for survey submission
class SurveyRemoteDataSource {
  final String baseUrl;

  SurveyRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Submit survey and get health metrics
  Future<SurveyResponseModel> submitSurvey({
    required SurveyRequestModel request,
  }) async {
    final url = Uri.parse('$baseUrl/survey/submit');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return SurveyResponseModel.fromJson(bodyJson);
    } else {
      // Try to parse error message
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorJson['message'] ?? 'Survey submission failed');
      } catch (e) {
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    }
  }
}
