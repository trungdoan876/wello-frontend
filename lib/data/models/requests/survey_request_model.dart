class SurveyRequestModel {
  final int userId;
  final String fullname;
  final String gender;
  final int age;
  final int height;
  final int weight;
  final String goal;
  final String activityLevel;
  final int? targetWeight; // Target weight for LOSE_WEIGHT or GAIN_WEIGHT goals

  SurveyRequestModel({
    required this.userId,
    required this.fullname,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    required this.activityLevel,
    this.targetWeight,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fullname': fullname,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
      'activityLevel': activityLevel,
      if (targetWeight != null) 'targetWeight': targetWeight,
    };
  }
}
