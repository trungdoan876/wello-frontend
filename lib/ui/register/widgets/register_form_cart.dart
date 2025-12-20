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

class RegisterFormContent extends StatelessWidget {
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
            emailController: emailController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
          ),

          SizedBox(height: context.h(0.04)),

          // --- Nút Đăng ký ---
          SizedBox(
            width: context.w(0.8),
            child: AnimatedStartButton(
              text: "Đăng ký",
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (email.isEmpty ||
                    password.isEmpty ||
                    confirmPassword.isEmpty) {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: 'Lỗi',
                    text: 'Vui lòng điền đầy đủ thông tin.',
                  );
                  return;
                }

                // Validate email format
                final emailRegex = RegExp(
                  r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                );
                if (!emailRegex.hasMatch(email)) {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: 'Email không hợp lệ',
                    text:
                        'Vui lòng nhập đúng định dạng (ví dụ: ten@domain.com).',
                  );
                  return;
                }

                if (password != confirmPassword) {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: "Lỗi",
                    text: "Password và Confirm Password không khớp",
                  );
                  return;
                }

                try {
                  final repository = AuthRepositoryImpl();

                  // Send OTP instead of direct registration
                  final response = await repository.sendOtp(
                    email: email,
                    password: password,
                  );

                  // Navigate to OTP verification screen
                  if (context.mounted) {
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
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: "Lỗi",
                    text: e.toString().replaceAll('Exception: ', ''),
                  );
                }
              },
            ),
          ),

          SizedBox(height: context.h(0.04)),

          // ---- Đã có tài khoản ----
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: Text(
              'Bạn đã có tài khoản',
              style: TextStyle(
                fontSize: context.sp(4),
                color: Colors.grey.shade700,
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
          Image.asset("assets/images/google.png", width: context.w(0.08)),
        ],
      ),
    );
  }
}
