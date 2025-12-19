import '../entities/exercise.dart';

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
}
