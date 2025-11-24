import 'package:flutter/material.dart';
import '../../../domain/usecases/user_register.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterUser registerUserUseCase;

  RegisterViewModel({required this.registerUserUseCase});

  bool _isLoading = false;
  String? _error;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await registerUserUseCase.execute(
        email: email,
        password: password,
      );
      if (success) {
        print("Đăng ký thành công");
      } else {
        _error = "Đăng ký thất bại";
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
