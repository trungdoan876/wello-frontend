import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/data/repositories/auth_repository_impl.dart';
import 'package:wello_frontend/ui/login/widgets/login_textfields.dart';
import 'package:wello_frontend/ui/main_navigation_screen.dart';
import 'package:wello_frontend/ui/question/name_question/name_page.dart';
import 'package:wello_frontend/ui/register/register_page.dart';
import 'package:wello_frontend/ui/auth/forgot_password_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/widgets/beautiful_dialog.dart';
import 'package:wello_frontend/core/utils/user_session.dart';

class LoginFormContent extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginFormContent({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  // Show beautiful dialog
  void showPopup(
    BuildContext context, {
    required String title,
    required String message,
    bool isError = true,
  }) {
    BeautifulDialog.show(
      context,
      title: title,
      message: message,
      isError: isError,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Màu sắc
    const Color titleYellow = Color(0xFFEBCF23);
    return Padding(
      // Padding ngang tương đối 10% chiều rộng màn hình cho Form Card
      padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
      child: Column(
        children: [
          // --- Tiêu đề "ĐĂNG NHẬP" ---
          Text(
            'ĐĂNG NHẬP',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(10),
              fontWeight: FontWeight.w900,
              color: titleYellow,
            ),
          ),
          SizedBox(height: context.h(0.01)),
          // --- Chào mừng ---
          Text(
            'Chào mừng bạn trở lại!',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4.3),
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 143, 142, 142),
              fontStyle: FontStyle.italic,
            ),
          ),

          SizedBox(height: context.h(0.02)),

          // --- Input Fields ---
          LoginTextFields(
            emailController: emailController,
            passwordController: passwordController,
          ),

          // --- Quên mật khẩu ---
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                );
              },
              child: Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: context.sp(4),
                  color: titleYellow,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: titleYellow,
                ),
              ),
            ),
          ),

          SizedBox(height: context.h(0.02)),

          // --- Nút ĐĂNG NHẬP ---
          SizedBox(
            width: context.w(0.8), // responsive theo chiều ngang
            child: AnimatedStartButton(
              text: "Đăng nhập",
              onPressed: () async {
                final email = emailController.text.trim();
                final password = passwordController.text;

                // Validation
                if (email.isEmpty || password.isEmpty) {
                  showPopup(
                    context,
                    title: "",
                    message: "Vui lòng điền đầy đủ thông tin.",
                  );
                  return;
                }

                try {
                  final repository = AuthRepositoryImpl();
                  final response = await repository.login(
                    email: email,
                    password: password,
                  );

                  print(
                    'Phan hoi dang nhap: thanh cong=${response.success}, userId=${response.userId}, da hoan thanh khao sat=${response.hasCompletedSurvey}',
                  );

                  if (response.success) {
                    // Save userId, token, and email for persistent auth
                    if (response.userId != null) {
                      await UserSession.saveUserId(response.userId!);
                      // TODO: Backend should return actual token
                      // For now, save userId as token for authentication
                      await UserSession.saveToken(response.userId!.toString());
                      // Save email from input
                      await UserSession.saveEmail(email);
                    }

                    // Route based on survey completion
                    if (response.hasCompletedSurvey == false) {
                      // Navigate to QuestionFlow (Khảo sát)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NamePage(userId: response.userId ?? 1),
                        ),
                      );
                    } else {
                      // Navigate to Home page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MainNavigationScreen(),
                        ),
                      );
                    }
                  } else {
                    showPopup(
                      context,
                      title: "",
                      message: response.message ?? "Đăng nhập thất bại.",
                    );
                  }
                } catch (e) {
                  showPopup(
                    context,
                    title: "",
                    message: "Không thể kết nối server: $e",
                  );
                }
              },
            ),
          ),

          SizedBox(height: context.h(0.03)),

          // --- Tạo tài khoản ---
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            child: Text(
              'Tạo tài khoản',
              style: TextStyle(
                fontSize: context.sp(4.0),
                color: Colors.grey.shade700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),

          SizedBox(height: context.h(0.02)),

          // --- Hoặc tiếp tục với ---
          Text(
            'Hoặc tiếp tục với',
            style: TextStyle(
              fontSize: context.sp(4),
              color: titleYellow,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: context.h(0.02)),

          // --- Nút Google ---
          GestureDetector(
            onTap: () async {
              try {
                final repository = AuthRepositoryImpl();
                final response = await repository.loginWithGoogle();

                if (response.success) {
                  // Save userId and token for persistent auth
                  if (response.userId != null) {
                    await UserSession.saveUserId(response.userId!);
                    // TODO: Backend should return actual token
                    // For now, save userId as token for authentication
                    await UserSession.saveToken(response.userId!.toString());
                    // Note: Google login doesn't provide email in response, would need to get from GoogleSignIn
                  }
                  // Route based on survey completion (same as email login)
                  if (response.hasCompletedSurvey == false) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NamePage(userId: response.userId ?? 1),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainNavigationScreen()),
                    );
                  }
                } else {
                  showPopup(
                    context,
                    title: "",
                    message: response.message ?? "Dang nhap Google that bai",
                  );
                }
              } catch (e) {
                showPopup(
                  context,
                  title: "",
                  message: "Khong the ket noi den server: $e",
                );
              }
            },
            child: Container(
              child: Center(
                child: Image.asset(
                  'assets/images/google.png',
                  width: context.w(0.08),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
