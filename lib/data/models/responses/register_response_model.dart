class RegisterResponseModel {
  final bool success;
  final String? message;
  final String? token;
  final String? userId;
  final int? idUser; // Maps to 'id_user' from API

  RegisterResponseModel({
    required this.success,
    this.message,
    this.token,
    this.userId,
    this.idUser,
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
      token: json['token']?.toString(),
      userId: json['userId']?.toString(),
      idUser: json['id_user'] != null ? int.tryParse(json['id_user'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (token != null) 'token': token,
      if (userId != null) 'userId': userId,
      if (idUser != null) 'id_user': idUser,
    };
  }
}
