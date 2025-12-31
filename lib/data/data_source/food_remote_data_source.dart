import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/food.dart';
import '../models/requests/food_preview_request.dart';
import '../../core/constants/api_endpoints.dart';


/// Nguồn dữ liệu từ xa cho các API calls về thực phẩm
class FoodRemoteDataSource {
  final String baseUrl;

  FoodRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  /// Lấy tất cả thực phẩm
  /// GET /food/all
  Future<List<Food>> getAllFoods(String token) async {
    final url = Uri.parse('$baseUrl/food/all');

    print('Dang lay tat ca thuc pham - URL: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Trang thai phan hoi: ${response.statusCode}');
    print('Noi dung phan hoi: ${response.body}');

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

    print('Dang xem truoc dinh duong thuc pham - URL: $url');
    print('Goi tin yeu cau: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    print('Trang thai phan hoi xem truoc: ${response.statusCode}');
    print('Noi dung phan hoi xem truoc: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return Food.fromJson(jsonMap);
    } else {
      throw Exception('Failed to preview food: ${response.statusCode}');
    }
  }
}
