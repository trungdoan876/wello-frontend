import '../entities/exercise.dart';
import '../entities/exercise_request.dart';

/// Abstract repository for exercise operations
abstract class ExerciseRepository {
  /// Get list of available exercises
  Future<List<Exercise>> getExercises(String token);

  /// Calculate estimated calories for exercise
  /// @param token - Authentication token
  /// @param userId - User ID
  /// @param exerciseId - Exercise ID
  /// @param durationMinutes - Duration in minutes
  Future<CaloriePreview> calculateCalories(
    String token,
    String userId,
    int exerciseId,
    int durationMinutes,
  );

  /// Log workout session
  /// @param token - Authentication token
  /// @param workoutLog - Workout log data
  Future<void> logWorkout(String token, WorkoutLog workoutLog);

  /// Get daily workout history
  /// @param token - Authentication token
  /// @param userId - User ID
  /// @param date - Date in yyyy-MM-dd format
  Future<DailyWorkoutLog> getDailyWorkoutLog(
    String token,
    String userId,
    String date,
  );

  /// Request new exercise addition
  Future<void> requestExercise(String token, ExerciseRequest request);
}
