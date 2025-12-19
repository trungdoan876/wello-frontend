import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/food.dart';

/// Remote data source for food API calls
class FoodRemoteDataSource {
  final String baseUrl;

  FoodRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

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
}
