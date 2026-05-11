import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/food.dart';
import '../../domain/entities/food_request.dart';
import '../models/requests/food_preview_request.dart';
import '../../core/constants/api_endpoints.dart';

/// Nguồn dữ liệu từ xa cho các API calls về thực phẩm
class FoodRemoteDataSource {
  final String baseUrl;

  FoodRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  /// Lấy tất cả thực phẩm
  /// GET /food/all
  Future<List<Food>> getAllFoods(String token) async {
    final url = Uri.parse(ApiEndpoints.foodAll);

    print('🍽️ [FOOD API] Đang lấy tất cả thức ăn...');
    print('   URL: $url');
    print('   Token: ${token.substring(0, 20)}...');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🍽️ [FOOD API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List;
        print('✅ [FOOD API] Thành công! Lấy được ${jsonList.length} thức ăn');

        // Log first few items
        for (var i = 0; i < (jsonList.length < 3 ? jsonList.length : 3); i++) {
          final item = jsonList[i];
          print('   - ${item['name']} (${item['calories']} kcal)');
        }

        return jsonList.map((json) => Food.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        print('❌ [FOOD API] Unauthorized - Token không hợp lệ');
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        print('❌ [FOOD API] Not Found - Endpoint không tồn tại: $url');
        throw Exception('Food API endpoint not found');
      } else {
        print('❌ [FOOD API] Error: ${response.statusCode}');
        print('   Response body: ${response.body}');
        throw Exception('Failed to load foods: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [FOOD API] Exception: $e');
      rethrow;
    }
  }

  /// Preview food nutrition for a specific amount
  /// POST /food/preview
  Future<Food> previewFood(String token, FoodPreviewRequest request) async {
    final url = Uri.parse(ApiEndpoints.foodPreview);

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
      final Map<String, dynamic> jsonMap =
          jsonDecode(response.body) as Map<String, dynamic>;
      return Food.fromJson(jsonMap);
    } else {
      throw Exception('Failed to preview food: ${response.statusCode}');
    }
  }

  /// Request new food addition
  /// POST /food/request
  Future<void> requestFood(String token, FoodRequest foodRequest) async {
    final url = Uri.parse(ApiEndpoints.foodRequest);

    print('Dang gui yeu cau thuc pham moi - URL: $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(foodRequest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to request food: ${response.statusCode}');
    }
  }
}
