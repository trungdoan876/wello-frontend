class RegisterResponseModel {
  final bool success;
  final String? message;
  final String? userId;

  RegisterResponseModel({
    required this.success,
    this.message,
    this.userId,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    // Be permissive: support different API shapes
    final bool successFlag =
        json['success'] == true ||
        json['status'] == 'ok' ||
        json['status'] == 'success' ||
        (json['code'] != null && json['code'] == 200);

    return RegisterResponseModel(
      success: successFlag,
      message: json['message']?.toString(),
      userId: json['userId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (userId != null) 'userId': userId,
    };
  }
}
