import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/responses/favorite_combo_response.dart';

class FavoritesDataSource {
  final String baseUrl;

  FavoritesDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Lấy danh sách các combo yêu thích của user
  Future<List<FavoriteComboResponse>> getMyFavorites(int userId) async {
    final url = Uri.parse('$baseUrl/favorites/my-favorites?userId=$userId');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((json) => FavoriteComboResponse.fromJson(json as Map<String, dynamic>))
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
