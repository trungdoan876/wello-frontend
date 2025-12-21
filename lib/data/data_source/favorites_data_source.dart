import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/responses/favorite_response.dart';

class FavoritesDataSource {
  final String baseUrl;

  FavoritesDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Lấy danh sách các món ăn yêu thích của user
  Future<List<FavoriteResponse>> getMyFavorites(int userId) async {
    final url = Uri.parse('$baseUrl/favorites/my-favorites?userId=$userId');
    print('🔗 URL: $url');

    try {
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('📡 Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print('✅ Parse thành công: ${jsonList.length} items');
        return jsonList
            .map(
              (item) => FavoriteResponse.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else if (response.statusCode == 404) {
        print('⚠️ Không tìm thấy dữ liệu (404)');
        return [];
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi HTTP: $e');
      throw Exception('Error loading favorites: $e');
    }
  }
}
