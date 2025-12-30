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
    print('[LoginResponseModel] Raw JSON: $json');
    print('[LoginResponseModel] hasCompletedSurvey value: ${json['hasCompletedSurvey']}');
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      hasCompletedSurvey: json['hasCompletedSurvey'],
      userId: json['id_user'], // Backend uses 'id_user' key
    );
  }
}
