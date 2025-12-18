class LoginResponseModel {
  final bool success;
  final String? message;
  final bool? hasCompletedSurvey;
  final int? userId;

  LoginResponseModel({
    required this.success,
    this.message,
    this.hasCompletedSurvey,
    this.userId,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      hasCompletedSurvey: json['hasCompletedSurvey'],
      userId: json['userId'] != null
          ? int.tryParse(json['userId'].toString())
          : null,
    );
  }
}
