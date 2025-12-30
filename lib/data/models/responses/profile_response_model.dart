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
  });

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      idProfile: json['idProfile'] as int?,
      userId: json['userId'] as int,
      fullname: json['fullname'] as String,
      gender: json['gender'] as String,
      age: json['age'] as int,
      height: json['height'] as int,
      weight: (json['weight'] as num).toDouble(),
      goal: json['goal'] as String,
      activityLevel: json['activityLevel'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      surveyDate: json['surveyDate'] as String,
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
    };
  }
}
