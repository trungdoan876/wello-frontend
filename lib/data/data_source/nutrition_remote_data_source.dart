import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/week_overview.dart';
import '../models/requests/log_food_request.dart';
import '../models/responses/log_food_response.dart';
import '../../domain/entities/food_history_item.dart';
import '../../domain/entities/weight_history_item.dart';

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

  /// Get weight change history for a user
  /// Endpoint: GET /api/history/{userId}
  Future<List<WeightHistoryItem>> getWeightHistory(String userId) async {
    final url = Uri.parse('$baseUrl/history/$userId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as List<dynamic>;
      return bodyJson
          .map((e) => WeightHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load weight history: ${response.statusCode}');
    }
  }

  /// Verify if user exists in database
  /// @param userId - User ID to verify
  /// Returns true if user exists, throws exception if not found
  Future<bool> verifyUser(String userId) async {
    final url = Uri.parse('$baseUrl/user/verify?userId=$userId');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
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
  Future<NutritionSummary> getDailySummary(
    String token,
    String userId,
    String date,
  ) async {
    final url = Uri.parse(
      '$baseUrl/nutrition/daily-summary?userId=$userId&date=$date',
    );

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
  Future<WeekOverview> getWeekOverview(
    String token,
    String userId,
    String startDate,
  ) async {
    final url = Uri.parse(
      '$baseUrl/nutrition/week-overview?userId=$userId&startDate=$startDate',
    );

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
  Future<WaterIntake> getWaterIntake(
    String token,
    String userId,
    String date,
  ) async {
    final url = Uri.parse(
      '$baseUrl/water-intake/daily?userId=$userId&date=$date',
    );

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
  Future<WaterIntake> addWaterGlass(
    String token,
    String userId,
    String date, {
    int glassSize = 250,
  }) async {
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
      headers: {'Content-Type': 'application/json'},
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

  /// Subtract water intake (remove a glass of water)
  /// @param userId - User ID
  /// @param date - Date (Format: YYYY-MM-DD)
  /// @param glassSize - Size of glass in ml (default: 250ml)
  Future<WaterIntake> subtractWaterGlass(
    String token,
    String userId,
    String date, {
    int glassSize = 250,
  }) async {
    // Backend expects DELETE with JSON body { userId, amountMl, date }
    final url = Uri.parse('$baseUrl/water-intake/delete');

    final requestBody = {
      'userId': int.parse(userId),
      'amountMl': glassSize,
      'date': date,
    };

    print('🌐 Making POST request to: $url (delete water)');
    print('📦 Request body: $requestBody');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Include auth if backend requires; remove if not used
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Refresh daily water intake after delete
      return getWaterIntake(token, userId, date);
    } else {
      throw Exception('Failed to delete water: ${response.statusCode}');
    }
  }

  /// Log food intake
  /// @param token - Auth token
  /// @param request - LogFoodRequest object
  Future<LogFoodResponse> logFood(String token, LogFoodRequest request) async {
    final url = Uri.parse('$baseUrl/nutrition/log-food');

    print('🌐 Making POST request to: $url');
    print('📦 Request body: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final bodyJson =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return LogFoodResponse.fromJson(bodyJson);
    } else {
      throw Exception('Failed to log food: ${response.statusCode}');
    }
  }

  /// Get food intake history for a specific date
  /// @param userId - User ID
  /// @param date - Format: YYYY-MM-DD
  Future<List<FoodHistoryItem>> getFoodHistory(
    String token,
    String userId,
    String date,
  ) async {
    final url = Uri.parse(
      '$baseUrl/nutrition/history?userId=$userId&date=$date',
    );

    print('🌐 Making GET request to: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> bodyJson = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return bodyJson.map((item) => FoodHistoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load food history: ${response.statusCode}');
    }
  }
}
