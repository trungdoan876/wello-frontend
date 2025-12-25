import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:wello_frontend/data/repositories/auth_repository_impl.dart';
import 'package:wello_frontend/ui/auth/otp_verification_page.dart';
import 'package:wello_frontend/ui/login/login_page.dart';
import 'package:wello_frontend/ui/question/name_question/name_page.dart';
import 'package:wello_frontend/ui/register/widgets/register_textfields.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/core/utils/validators.dart';

class RegisterFormContent extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegisterFormContent({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  State<RegisterFormContent> createState() => _RegisterFormContentState();
}

class _RegisterFormContentState extends State<RegisterFormContent> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    const Color titleYellow = Color(0xFFEBCF23);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'TẠO TÀI KHOẢN',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(8),
              fontWeight: FontWeight.w900,
              color: titleYellow,
            ),
          ),

          SizedBox(height: context.h(0.01)),

          Text(
            'Ăn thông minh, sống khỏe mạnh!',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5),
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 143, 142, 142),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: context.h(0.03)),

          // --- Input Fields ---
          RegisterTextFields(
            emailController: widget.emailController,
            passwordController: widget.passwordController,
            confirmPasswordController: widget.confirmPasswordController,
          ),

          SizedBox(height: context.h(0.04)),

          // --- Nút Đăng ký ---
          SizedBox(
            width: context.w(0.8),
            child: AnimatedStartButton(
              text: _isLoading ? "Đang gửi OTP..." : "Đăng ký",
              onPressed: _isLoading ? () {} : () async {
                final email = widget.emailController.text.trim();
                final password = widget.passwordController.text;
                final confirmPassword = widget.confirmPasswordController.text;

                // Validate all fields using centralized validators
                final emailError = Validators.validateEmail(email);
                final passwordError = Validators.validatePassword(password);
                final confirmPasswordError = Validators.validateConfirmPassword(
                  password,
                  confirmPassword,
                );

                // Show first error found
                if (emailError != null) {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    title: 'Email không hợp lệ',
                    text: emailError,
                  );
                  return;
                }

                if (passwordError != null) {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    title: 'Mật khẩu không hợp lệ',
                    text: passwordError,
                  );
                  return;
                }

                if (confirmPasswordError != null) {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    title: 'Xác nhận mật khẩu',
                    text: confirmPasswordError,
                  );
                  return;
                }

                // Show loading state
                setState(() {
                  _isLoading = true;
                });

                try {
                  final repository = AuthRepositoryImpl();

                  // Send OTP instead of direct registration
                  final response = await repository.sendOtp(
                    email: email,
                    password: password,
                  );

                  // Hide loading state
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });

                    // Navigate to OTP verification screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OtpVerificationPage(
                          email: email,
                          password: password,
                          verificationToken: response.verificationToken,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  // Hide loading state on error
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });

                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.error,
                      title: "Lỗi",
                      text: e.toString().replaceAll('Exception: ', ''),
                    );
                  }
                }
              },
            ),
          ),

          SizedBox(height: context.h(0.04)),

          // ---- Đã có tài khoản ----
          TextButton(
            onPressed: _isLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: Text(
              'Bạn đã có tài khoản',
              style: TextStyle(
                fontSize: context.sp(4),
                color: _isLoading ? Colors.grey.shade400 : Colors.grey.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          SizedBox(height: context.h(0.02)),

          Text(
            'Hoặc tiếp tục với',
            style: TextStyle(
              fontSize: context.sp(4),
              color: titleYellow,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: context.h(0.02)),

          // Google Icon
          Opacity(
            opacity: _isLoading ? 0.5 : 1.0,
            child: Image.asset("assets/images/google.png", width: context.w(0.08)),
          ),
        ],
      ),
    );
  }
}
