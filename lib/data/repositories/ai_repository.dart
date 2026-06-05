import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wello_frontend/core/constants/api_endpoints.dart';
import 'package:wello_frontend/data/models/responses/ai_parse_meal_response.dart';

class AiRepository {
  /// Gửi văn bản bữa ăn lên backend để AI bóc tách dinh dưỡng và nguyên liệu
  Future<AiParseMealResponse> parseMeal({
    required String text,
    required String date,
    required String token,
  }) async {
    final url = Uri.parse(ApiEndpoints.aiParseMeal);

    print('🤖 [AI API] Đang gửi văn bản phân tích: "$text"');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'text': text,
        'date': date,
      }),
    );

    print('🤖 [AI API] Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      final jsonMap = jsonDecode(body) as Map<String, dynamic>;
      return AiParseMealResponse.fromJson(jsonMap);
    } else {
      throw Exception('Không thể phân tích bữa ăn: ${response.statusCode}');
    }
  }
}
