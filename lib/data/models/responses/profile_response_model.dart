class ProfileResponseModel {
  final int? idProfile;
  final int userId;
  final String fullname;
  final String gender;
  final int age;
  final int height;
  final double weight;
  final String goal;
  final String activityLevel;
  final String? avatarUrl;
  final String surveyDate;
  final int streakCount;
  final double? sleepTargetHours;
  final String? sleepBedtimeTarget;
  final String? sleepWakeTimeTarget;

  ProfileResponseModel({
    this.idProfile,
    required this.userId,
    required this.fullname,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    required this.activityLevel,
    this.avatarUrl,
    required this.surveyDate,
    required this.streakCount,
    this.sleepTargetHours,
    this.sleepBedtimeTarget,
    this.sleepWakeTimeTarget,
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      idProfile: json['idProfile'] as int?,
      userId: json['userId'] as int,
      fullname: (json['fullname'] ?? '') as String,
      gender: (json['gender'] ?? 'male') as String,
      age: (json['age'] ?? 0) as int,
      height: (json['height'] ?? 0) as int,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      goal: (json['goal'] ?? 'maintain') as String,
      activityLevel: (json['activityLevel'] ?? 'SEDENTARY') as String,
      avatarUrl: json['avatarUrl'] as String?,
      surveyDate: (json['surveyDate'] ?? '') as String,
      streakCount: (json['streakCount'] ?? 0) as int,
      sleepTargetHours: json['sleepTargetHours'] != null ? (json['sleepTargetHours'] as num).toDouble() : null,
      sleepBedtimeTarget: json['sleepBedtimeTarget'] as String?,
      sleepWakeTimeTarget: json['sleepWakeTimeTarget'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProfile': idProfile,
      'userId': userId,
      'fullname': fullname,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
      'activityLevel': activityLevel,
      'avatarUrl': avatarUrl,
      'surveyDate': surveyDate,
      'streakCount': streakCount,
      'sleepTargetHours': sleepTargetHours,
      'sleepBedtimeTarget': sleepBedtimeTarget,
      'sleepWakeTimeTarget': sleepWakeTimeTarget,
    };
  }
}
