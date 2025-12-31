import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requests/survey_request_model.dart';
import '../models/requests/calculate_bmi_request_model.dart';
import '../models/responses/survey_response_model.dart';
import '../models/responses/calculate_bmi_response_model.dart';
import '../../core/constants/api_endpoints.dart';

/// Nguồn dữ liệu từ xa cho các thao tác khảo sát
/// Xử lý các API calls để submit khảo sát
class SurveyRemoteDataSource {
  final String baseUrl;

  SurveyRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  /// Submit khảo sát và nhận metrics sức khỏe
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

  /// Calculate BMI with health warnings
  Future<CalculateBmiResponse> calculateBmi({
    required int weight,
    required int height,
    String? goal, // Optional: LOSE_WEIGHT, GAIN_WEIGHT, MAINTAIN_WEIGHT
  }) async {
    final url = Uri.parse('$baseUrl/survey/calculate-bmi');
    final request = CalculateBmiRequest(
      weight: weight,
      height: height,
      goal: goal,
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return CalculateBmiResponse.fromJson(bodyJson);
    } else {
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorJson['message'] ?? 'BMI calculation failed');
      } catch (e) {
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    }
  }
}
