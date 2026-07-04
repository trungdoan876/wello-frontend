import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wello_frontend/core/constants/api_endpoints.dart';
import 'package:wello_frontend/domain/entities/badge.dart';
import 'package:wello_frontend/data/models/responses/post_model.dart';

class CompetitionRemoteDataSource {
  final http.Client client = http.Client();

  Future<List<Map<String, dynamic>>> getLeaderboard({
    required String token,
    required String type,
    required String period,
  }) async {
    final url = Uri.parse(ApiEndpoints.leaderboard(type, period));
    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List entries = data['entries'] ?? [];
      return entries.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }

  Future<List<Badge>> getBadges({required String token}) async {
    final url = Uri.parse(ApiEndpoints.badges);
    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Badge.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load badges');
    }
  }

  Future<List<Badge>> getUserBadges({
    required String token,
    required int userId,
  }) async {
    final url = Uri.parse(ApiEndpoints.userBadges(userId));
    final response = await client.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Badge.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load user badges');
    }
  }

  Future<bool> equipBadge({required String token, required int badgeId}) async {
    final url = Uri.parse(ApiEndpoints.equipBadge(badgeId));
    final response = await client.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> unequipBadge({required String token}) async {
    final url = Uri.parse(ApiEndpoints.unequipBadge);
    final response = await client.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return response.statusCode == 200;
  }
}
