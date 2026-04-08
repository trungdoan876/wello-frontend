import '../../domain/entities/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/entities/exercise_request.dart';
import '../data_source/exercise_remote_data_source.dart';

/// Implementation of ExerciseRepository
class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseRemoteDataSource remoteDataSource;

  ExerciseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Exercise>> getExercises(String token) async {
    return await remoteDataSource.getExercises(token);
  }

  @override
  Future<CaloriePreview> calculateCalories(
    String token,
    String userId,
    int exerciseId,
    int durationMinutes,
  ) async {
    return await remoteDataSource.calculateCalories(
      token,
      userId,
      exerciseId,
      durationMinutes,
    );
  }

  @override
  Future<void> logWorkout(String token, WorkoutLog workoutLog) async {
    return await remoteDataSource.logWorkout(token, workoutLog);
  }

  @override
  Future<DailyWorkoutLog> getDailyWorkoutLog(
    String token,
    String userId,
    String date,
  ) async {
    return await remoteDataSource.getDailyWorkoutLog(token, userId, date);
  }

  @override
  Future<void> requestExercise(String token, ExerciseRequest request) async {
    return await remoteDataSource.requestExercise(token, request);
  }
}
