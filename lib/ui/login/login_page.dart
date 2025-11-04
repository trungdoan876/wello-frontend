import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/register/register_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';
import 'widgets/login_textfields.dart';
import 'widgets/social_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Nền hình ảnh
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login.png"),
            fit: BoxFit.cover, // full màn hình
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Text(
                  "Đăng nhập",
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F41BB),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "Chào mừng bạn trở lại!\nChúng tôi rất nhớ bạn!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 60),
                const LoginTextFields(),
                const SizedBox(height: 30),
                SizedBox(
                  width: 340,
                  child: AnimatedStartButton(
                    text: "Đăng nhập",
                    onPressed: () {
                      
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // TODO: Điều hướng sang trang đăng ký
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoadingPage(nextPage: const RegisterPage()),
                        ),
                      );
                  },
                  child: Text(
                    "Tạo tài khoản",
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 14,
                      color: const Color(0xFF777676),
                      decoration: TextDecoration.underline, // gạch chân chữ
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Hoặc tiếp tục với",
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F41BB),),
                ),
                const SizedBox(height: 20),
                const SocialButtonsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
