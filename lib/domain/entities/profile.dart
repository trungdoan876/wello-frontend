class Profile {
  final int idProfile;
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

  Profile({
    required this.idProfile,
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
}
