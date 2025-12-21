import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requests/add_favorite_request.dart';

class FavoritesRemoteDataSource {
  final String baseUrl;

  FavoritesRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Add a meal to favorites
  Future<Map<String, dynamic>> addFavorite({
    required AddFavoriteRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/favorites/add');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to add favorite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding favorite: $e');
    }
  }
}
