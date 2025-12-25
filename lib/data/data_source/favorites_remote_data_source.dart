import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/requests/add_favorite_combo_request.dart';
import '../models/requests/update_favorite_combo_request.dart';
import '../models/requests/log_favorite_request.dart';
import '../models/responses/favorite_combo_response.dart';

class FavoritesRemoteDataSource {
  final String baseUrl;

  FavoritesRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Get a single favorite combo by ID
  Future<FavoriteComboResponse> getFavoriteById({
    required int favoriteId,
    required int userId,
  }) async {
    final url = Uri.parse('$baseUrl/favorites/$favoriteId?userId=$userId');

    try {
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return FavoriteComboResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to get favorite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting favorite: $e');
    }
  }

  /// Add a combo to favorites
  Future<Map<String, dynamic>> addCombo({
    required AddFavoriteComboRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/favorites/add-combo');

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
        throw Exception('Failed to add combo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding combo: $e');
    }
  }

  /// Update a favorite combo
  Future<Map<String, dynamic>> updateCombo({
    required UpdateFavoriteComboRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/favorites/update-combo');

    try {
      final response = await http
          .put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update combo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating combo: $e');
    }
  }

  /// Delete a favorite combo
  Future<void> deleteFavorite({
    required int favoriteId,
    required int userId,
  }) async {
    final url = Uri.parse('$baseUrl/favorites/delete/$favoriteId?userId=$userId');

    try {
      final response = await http
          .delete(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete favorite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting favorite: $e');
    }
  }

  /// Log a favorite combo to daily nutrition
  Future<Map<String, dynamic>> logFavorite({
    required LogFavoriteRequest request,
  }) async {
    final url = Uri.parse('$baseUrl/favorites/log');

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
        throw Exception('Failed to log favorite: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error logging favorite: $e');
    }
  }
}
