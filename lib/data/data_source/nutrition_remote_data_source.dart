import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nutrition_summary.dart';
import '../models/user_profile.dart';
import '../models/week_overview.dart';

/// Remote data source for nutrition and fitness data
/// Handles API calls related to nutrition tracking, user profile, and weekly overview
class NutritionRemoteDataSource {
  final String baseUrl;

  NutritionRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Get user profile with fitness goals and targets
  /// @param userId - User ID
  Future<UserProfile> getUserProfile(String token, String userId) async {
    final url = Uri.parse('$baseUrl/user/profile?userId=$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return UserProfile.fromJson(bodyJson);
    } else {
      throw Exception('Failed to load user profile: ${response.statusCode}');
    }
  }

  /// Verify if user exists in database
  /// @param userId - User ID to verify
  /// Returns true if user exists, throws exception if not found
  Future<bool> verifyUser(String userId) async {
    final url = Uri.parse('$baseUrl/user/verify?userId=$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return bodyJson['exists'] == true;
    } else if (response.statusCode == 404) {
      // User not found
      return false;
    } else {
      throw Exception('Failed to verify user: ${response.statusCode}');
    }
  }

  /// Get daily nutrition summary for a specific date
  /// @param userId - User ID
  /// @param date - Format: YYYY-MM-DD (e.g., "2024-12-18")
  Future<NutritionSummary> getDailySummary(String token, String userId, String date) async {
    final url = Uri.parse('$baseUrl/nutrition/daily-summary?userId=$userId&date=$date');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return NutritionSummary.fromJson(bodyJson);
    } else {
      throw Exception('Failed to load daily summary: ${response.statusCode}');
    }
  }

  /// Get weekly overview for calendar
  /// @param userId - User ID
  /// @param startDate - Start date of the week (Format: YYYY-MM-DD)
  Future<WeekOverview> getWeekOverview(String token, String userId, String startDate) async {
    final url = Uri.parse('$baseUrl/nutrition/week-overview?userId=$userId&startDate=$startDate');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return WeekOverview.fromJson(bodyJson);
    } else {
      throw Exception('Failed to load week overview: ${response.statusCode}');
    }
  }

  /// Get daily water intake
  /// @param userId - User ID
  /// @param date - Format: YYYY-MM-DD
  Future<WaterIntake> getWaterIntake(String token, String userId, String date) async {
    final url = Uri.parse('$baseUrl/water-intake/daily?userId=$userId&date=$date');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return WaterIntake.fromJson(bodyJson);
    } else {
      throw Exception('Failed to load water intake: ${response.statusCode}');
    }
  }

  /// Update water intake (add a glass of water)
  /// @param userId - User ID
  /// @param date - Date (Format: YYYY-MM-DD)
  /// @param glassSize - Size of glass in ml (default: 250ml)
  Future<WaterIntake> addWaterGlass(String token, String userId, String date, {int glassSize = 250}) async {
    final url = Uri.parse('$baseUrl/water-intake/add');
    
    final requestBody = {
      'userId': int.parse(userId),
      'amountMl': glassSize,
      'date': date,
    };
    
    print('🌐 Making POST request to: $url');
    print('📦 Request body: $requestBody');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Backend returns "Water intake added successfully" message
      // Fetch fresh data from daily endpoint to get updated water intake
      return getWaterIntake(token, userId, date);
    } else {
      throw Exception('Failed to add water: ${response.statusCode}');
    }
  }
}
