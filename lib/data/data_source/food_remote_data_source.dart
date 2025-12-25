import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/food.dart';
import '../models/requests/food_preview_request.dart';
import '../../core/constants/app_constants.dart';


/// Remote data source for food API calls
class FoodRemoteDataSource {
  final String baseUrl;

  FoodRemoteDataSource({this.baseUrl = AppConstants.baseUrl});

  /// Get all foods
  /// GET /food/all
  Future<List<Food>> getAllFoods(String token) async {
    final url = Uri.parse('$baseUrl/food/all');

    print('🔍 Fetching all foods - URL: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📡 Food response status: ${response.statusCode}');
    print('📡 Food response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List;
      return jsonList.map((json) => Food.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load foods: ${response.statusCode}');
    }
  }

  /// Preview food nutrition for a specific amount
  /// POST /food/preview
  Future<Food> previewFood(String token, FoodPreviewRequest request) async {
    final url = Uri.parse('$baseUrl/food/preview');

    print('🔍 Previewing food nutrition - URL: $url');
    print('📦 Request: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    print('📡 Preview response status: ${response.statusCode}');
    print('📡 Preview response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return Food.fromJson(jsonMap);
    } else {
      throw Exception('Failed to preview food: ${response.statusCode}');
    }
  }
}
