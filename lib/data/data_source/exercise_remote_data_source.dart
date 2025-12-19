import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/exercise.dart';

/// Remote data source for exercise API calls
class ExerciseRemoteDataSource {
  final String baseUrl;

  ExerciseRemoteDataSource({this.baseUrl = "http://10.0.2.2:8080/api"});

  /// Get list of exercises
  /// GET /workout/exercises
  Future<List<Exercise>> getExercises(String token) async {
    final url = Uri.parse('$baseUrl/workout/exercises');

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
      '$baseUrl/workout/calculate?userId=$userId&exerciseId=$exerciseId&durationMinutes=$durationMinutes',
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
      return CaloriePreview.fromJson(bodyJson);
    } else {
      throw Exception('Failed to calculate calories: ${response.statusCode}');
    }
  }

  /// Log workout session
  /// POST /workout/log
  Future<void> logWorkout(String token, WorkoutLog workoutLog) async {
    final url = Uri.parse('$baseUrl/workout/log');

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
}
