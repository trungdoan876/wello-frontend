import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/nutrition_summary.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/week_overview.dart';
import '../../domain/entities/seven_day_stats.dart';
import '../models/requests/log_food_request.dart';
import '../models/responses/log_food_response.dart';
import '../../domain/entities/food_history_item.dart';
import '../../domain/entities/weight_history_item.dart';
import '../../core/constants/api_endpoints.dart';

/// Nguồn dữ liệu từ xa cho dữ liệu dinh dưỡng và thể dục
/// Xử lý các API calls liên quan đến nutrition tracking, user profile, và weekly overview
class NutritionRemoteDataSource {
  final String baseUrl;

  NutritionRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

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
  Future<List<WeightHistoryItem>> getWeightHistory(
    String token,
    String userId,
  ) async {
    final url = Uri.parse('$baseUrl/history/$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
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

  /// Get latest weight history for a user
  /// Endpoint: GET /api/history/{userId}/latest?limit=5
  Future<List<WeightHistoryItem>> getLatestWeightHistory(
    String token,
    String userId, {
    int limit = 5,
  }) async {
    final url = Uri.parse('$baseUrl/history/$userId/latest?limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as List<dynamic>;
      return bodyJson
          .map((e) => WeightHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load latest weight history: ${response.statusCode}',
      );
    }
  }

  /// Verify if user exists in database
  /// @param userId - User ID to verify
  /// Returns true if user exists, throws exception if not found
  Future<bool> verifyUser(String token, String userId) async {
    final url = Uri.parse('$baseUrl/user/verify?userId=$userId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
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

  /// Get seven-day statistics for profile dashboard
  Future<SevenDayStats> getSevenDayStats(String token, String userId) async {
    final url = Uri.parse(ApiEndpoints.sevenDayStats(int.parse(userId)));

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return SevenDayStats.fromJson(bodyJson);
    } else {
      throw Exception('Failed to load seven day stats: ${response.statusCode}');
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

  /// Update water intake (add a glass of water) - Raw version returning full response
  Future<Map<String, dynamic>> addWaterGlassRaw(
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

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      try {
        return jsonDecode(body) as Map<String, dynamic>;
      } catch (e) {
        // Nếu backend trả về chuỗi thuần túy "Water intake added successfully"
        // Chúng ta tạo một map giả lập để tránh crash ở các lớp trên
        return {
          'waterIntake': {'consumed': 0, 'target': 2000},
          'engagement': {'isStreak': false, 'streakCount': 0, 'message': body},
        };
      }
    } else {
      throw Exception('Failed to add water: ${response.statusCode}');
    }
  }

  /// Update water intake (add a glass of water)
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

    print('Dang goi POST den: $url');
    print('Noi dung yeu cau: $requestBody');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print('Trang thai phan hoi: ${response.statusCode}');
    print('Noi dung phan hoi: ${response.body}');

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

    print('Dang goi POST den: $url (xoa nuoc)');
    print('Noi dung yeu cau: $requestBody');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    print('Trang thai phan hoi: ${response.statusCode}');
    print('Noi dung phan hoi: ${response.body}');

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

    print('Dang goi POST den: $url');
    print('Noi dung yeu cau: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    print('Trang thai phan hoi: ${response.statusCode}');
    print('Noi dung phan hoi: ${utf8.decode(response.bodyBytes)}');

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
      '$baseUrl/nutrition/history/food?userId=$userId&date=$date',
    );

    print('Dang goi GET den: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Trang thai phan hoi: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> bodyJson = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      print('🍽️ Food history items (${bodyJson.length} items):');
      for (var item in bodyJson) {
        print(
          '  - ${item['foodName']} (mealType: "${item['mealType']}", calories: ${item['calories']})',
        );
      }
      return bodyJson.map((item) => FoodHistoryItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load food history: ${response.statusCode}');
    }
  }
}
