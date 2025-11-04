import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/login/login_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';
import 'widgets/register_textfields.dart';
import '../login/widgets/social_buttons.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
                  "Tạo tài khoản",
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F41BB),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Tạo một tài khoản để bạn khám phá \ntất cả các bài tập hiện có.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 60),
                const RegisterTextFields(),
                const SizedBox(height: 30),
                SizedBox(
                  width: 340,
                  child: AnimatedStartButton(
                    text: "Đăng kí",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
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
                          builder: (_) => LoadingPage(nextPage: const LoginPage()),
                        ),
                      );
                  },
                  child: Text(
                    "Bạn đã có tài khoản",
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
