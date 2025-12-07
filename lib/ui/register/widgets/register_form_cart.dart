import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/data/repositories/auth_repository.dart';
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

  // Hàm hiển thị popup
  void showPopup(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(context.sp(5)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                width: context.sp(15),
                height: context.sp(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBCF23).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFEBCF23),
                  size: 30,
                ),
              ),
              
              SizedBox(height: context.h(0.02)),
              
              // Message
              Text(
                message,
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(4.5),
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: context.h(0.03)),
              
              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBCF23),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: context.h(0.015)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                  showPopup(
                    context,
                    title: "",
                    message: "Vui lòng điền đầy đủ thông tin.",
                  );
                  return;
                }

                if (password != confirmPassword) {
                  showPopup(
                    context,
                    title: "",
                    message: "Password và Confirm Password không khớp",
                  );
                  return;
                }

                try {
                  final repository = AuthRepositoryImpl();
                  final response = await repository.register(
                    email: email,
                    password: password,
                  );

                  if (response.success) {
                    // Navigate to Question Flow (Onboarding)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NamePage(),
                      ),
                    );
                  } else {
                    showPopup(
                      context,
                      title: "",
                      message: response.message ?? "Đăng ký thất bại.",
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
