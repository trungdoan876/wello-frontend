import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_request.dart';
import '../../core/constants/api_endpoints.dart';

/// Nguồn dữ liệu từ xa cho các API calls về exercise/bài tập
class ExerciseRemoteDataSource {
  final String baseUrl;

  ExerciseRemoteDataSource({this.baseUrl = ApiEndpoints.baseUrl});

  /// Lấy danh sách bài tập
  /// GET /workout/exercises
  Future<List<Exercise>> getExercises(String token) async {
    final url = Uri.parse(ApiEndpoints.workoutExercises);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List;
      return jsonList.map((json) => Exercise.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load exercises: ${response.statusCode}');
    }
  }

  /// Calculate calories for exercise
  /// GET /workout/calculate?userId=1&exerciseId=1&durationMinutes=30
  Future<CaloriePreview> calculateCalories(
    String token,
    String userId,
    int exerciseId,
    int durationMinutes,
  ) async {
    final url = Uri.parse(
      ApiEndpoints.workoutCalculate(
        int.parse(userId),
        exerciseId,
        durationMinutes,
      ),
    );

    print('Dang tinh calo - URL: $url');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Trang thai phan hoi tinh calo: ${response.statusCode}');
    print('Noi dung phan hoi tinh calo: ${response.body}');

    if (response.statusCode == 200) {
      final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
      return CaloriePreview.fromJson(bodyJson);
    } else {
      throw Exception('Failed to calculate calories: ${response.statusCode}');
    }
  }

  /// Log workout session - Raw version returning full response
  Future<Map<String, dynamic>> logWorkoutRaw(
    String token,
    WorkoutLog workoutLog,
  ) async {
    final url = Uri.parse('$baseUrl/workout/log');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(workoutLog.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } else {
      throw Exception('Failed to log workout: ${response.statusCode}');
    }
  }

  /// Log workout session
  /// POST /workout/log
  Future<void> logWorkout(String token, WorkoutLog workoutLog) async {
    final url = Uri.parse(ApiEndpoints.workoutLog);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(workoutLog.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to log workout: ${response.statusCode}');
    }
  }

  /// Get daily workout history
  /// GET /workout/daily?userId=1&date=2024-12-19
  Future<DailyWorkoutLog> getDailyWorkoutLog(
    String token,
    String userId,
    String date,
  ) async {
    final url = Uri.parse(ApiEndpoints.workoutDaily(int.parse(userId), date));

    print('💪 [WORKOUT API] Đang lấy lịch sử tập luyện...');
    print('   URL: $url');
    print('   Ngày: $date');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('💪 [WORKOUT API] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final bodyJson = jsonDecode(response.body) as Map<String, dynamic>;
        final log = DailyWorkoutLog.fromJson(bodyJson);

        print(
          '✅ [WORKOUT API] Thành công! Tổng calo: ${log.totalCaloriesBurned} | Số bài tập: ${log.workouts.length}',
        );

        // Log individual workouts
        for (var workout in log.workouts) {
          print(
            '   - ${workout.exerciseName}: ${workout.durationMinutes} phút (${workout.caloriesBurned} calo)',
          );
        }

        if (log.workouts.isEmpty) {
          print('   ℹ️ Chưa có bài tập nào ghi nhận hôm nay');
        }

        return log;
      } else if (response.statusCode == 401) {
        print('❌ [WORKOUT API] Unauthorized - Token không hợp lệ');
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        print('❌ [WORKOUT API] Not Found - Endpoint không tồn tại: $url');
        throw Exception('Workout API endpoint not found');
      } else {
        print('❌ [WORKOUT API] Error: ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception(
          'Failed to load daily workout log: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [WORKOUT API] Exception: $e');
      rethrow;
    }
  }

  /// Request new exercise addition
  /// POST /workout/request
  Future<void> requestExercise(
    String token,
    ExerciseRequest exerciseRequest,
  ) async {
    final url = Uri.parse(ApiEndpoints.workoutRequestExercise);

    print('Dang gui yeu cau bai tap moi - URL: $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(exerciseRequest.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to request exercise: ${response.statusCode}');
    }
  }
}
