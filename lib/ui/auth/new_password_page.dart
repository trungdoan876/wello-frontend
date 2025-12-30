import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wello_frontend/data/repositories/auth_repository_impl.dart';
import 'package:wello_frontend/ui/login/login_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class NewPasswordPage extends StatefulWidget {
  final String resetToken;

  const NewPasswordPage({
    super.key,
    required this.resetToken,
  });

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleResetPassword() async {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    
    print('🔵 [NewPassword] Bắt đầu đặt lại mật khẩu');
    print('🔵 [NewPassword] Password length: ${password.length}');

    // Validation
    if (password.isEmpty || confirmPassword.isEmpty) {
      print('🔴 [NewPassword] Thiếu thông tin');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Thiếu thông tin',
        text: 'Vui lòng điền đầy đủ thông tin',
      );
      return;
    }

    if (password.length < 6) {
      print('🔴 [NewPassword] Mật khẩu quá ngắn: ${password.length} ký tự');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Mật khẩu yếu',
        text: 'Mật khẩu phải có ít nhất 6 ký tự',
      );
      return;
    }

    if (password != confirmPassword) {
      print('🔴 [NewPassword] Mật khẩu không khớp');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Mật khẩu không khớp',
        text: 'Mật khẩu xác nhận không khớp với mật khẩu mới',
      );
      return;
    }

    print('🔵 [NewPassword] Validation thành công, gọi API...');
    setState(() {
      isLoading = true;
    });

    try {
      print('🔵 [NewPassword] Gọi API /reset-password...');
      final response = await _authRepository.resetPassword(
        resetToken: widget.resetToken,
        newPassword: password,
      );
      print('🔵 [NewPassword] Nhận response: success=${response.success}, message=${response.message}');

      setState(() {
        isLoading = false;
      });

      if (response.success) {
        print('✅ [NewPassword] Đặt lại mật khẩu thành công!');
        print('🔵 [NewPassword] Chuyển về LoginPage');
        // Show success dialog and navigate to login
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công!',
          text: response.message,
          onConfirmBtnTap: () {
            Navigator.of(context).pop(); // Close alert
            // Navigate to login and remove all previous routes
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
        );
      } else {
        print('🔴 [NewPassword] Thất bại: ${response.message}');
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Lỗi',
          text: response.message,
        );
      }
    } catch (e) {
      print('🔴 [NewPassword] Exception: $e');
      setState(() {
        isLoading = false;
      });
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: 'Không thể kết nối server: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFFFBEA);
    const Color titleYellow = Color(0xFFEBCF23);
    const Color darkText = Color(0xFF5A5A5A);

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: titleYellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(0.08)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.h(0.05)),

                // Title
                Text(
                  'ĐẶT LẠI MẬT KHẨU',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(10),
                    fontWeight: FontWeight.w900,
                    color: titleYellow,
                  ),
                ),

                SizedBox(height: context.h(0.02)),

                // Description
                Text(
                  'Nhập mật khẩu mới của bạn',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: context.sp(4.0),
                    color: darkText,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: context.h(0.05)),

                // New Password input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.sp(3.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu mới',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: context.sp(4.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.sp(3.0)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.w(0.05),
                        vertical: context.h(0.02),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.h(0.02)),

                // Confirm Password input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(context.sp(3.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Xác nhận mật khẩu',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: context.sp(4.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(context.sp(3.0)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: context.w(0.05),
                        vertical: context.h(0.02),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: context.h(0.04)),

                // Submit button
                SizedBox(
                  width: context.w(0.8),
                  child: AnimatedStartButton(
                    text: isLoading ? "Đang xử lý..." : "Đặt lại mật khẩu",
                    onPressed: isLoading ? () {} : handleResetPassword,
                  ),
                ),

                SizedBox(height: context.h(0.03)),

                // Password requirements
                Container(
                  padding: EdgeInsets.all(context.w(0.04)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(context.sp(2.0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yêu cầu mật khẩu:',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: context.sp(3.5),
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      SizedBox(height: context.h(0.01)),
                      Text(
                        '• Ít nhất 6 ký tự',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: context.sp(3.2),
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
