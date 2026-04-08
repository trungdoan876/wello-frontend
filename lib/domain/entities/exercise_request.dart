class ExerciseRequest {
  final String exerciseName;
  final double? metValue;

  ExerciseRequest({
    required this.exerciseName,
    this.metValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'metValue': metValue,
    };
  }
}
