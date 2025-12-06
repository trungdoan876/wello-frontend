class LoginResponseModel {
  final bool success;
  final String? message;
  final bool? hasCompletedSurvey;

  LoginResponseModel({
    required this.success,
    this.message,
    this.hasCompletedSurvey,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      hasCompletedSurvey: json['hasCompletedSurvey'],
    );
  }
}
