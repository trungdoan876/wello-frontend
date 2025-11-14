import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/register/register_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'widgets/login_textfields.dart';
import 'widgets/social_buttons.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        // Nền ảnh phủ toàn màn hình
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login.png"),
            fit: BoxFit.cover, // Ảnh phủ toàn bộ nền
          ),
        ),

        // SafeArea tránh đè lên phần tai thỏ, status bar
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Cho phép cuộn khi bàn phím bật hoặc màn hình nhỏ
                child: ConstrainedBox(
                  // Đảm bảo chiều cao tối thiểu = chiều cao màn hình
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(0.07),
                      vertical: context.h(0.04),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: context.h(0.06)),

                            // Tiêu đề
                            Text(
                              "Đăng nhập",
                              style: GoogleFonts.beVietnamPro(
                                fontSize: context.sp(7.5), // responsive theo chiều ngang
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F41BB),
                              ),
                            ),

                            SizedBox(height: context.h(0.025)),

                            // Mô tả ngắn
                            Text(
                              "Chào mừng bạn trở lại!\nChúng tôi rất nhớ bạn!",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: context.sp(4.4), // responsive theo chiều ngang
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),

                            SizedBox(height: context.h(0.07)),

                            // Ô nhập email + password
                            const LoginTextFields(),

                            SizedBox(height: context.h(0.04)),

                            // Nút đăng nhập
                            SizedBox(
                              width: context.w(0.8), // responsive theo chiều ngang
                              child: AnimatedStartButton(
                                text: "Đăng nhập",
                                onPressed: () {
                                  // TODO: Xử lý logic login
                                },
                              ),
                            ),

                            SizedBox(height: context.h(0.025)),

                            // Nút sang trang đăng ký
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoadingPage(
                                      nextPage: const RegisterPage(),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Tạo tài khoản",
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: context.sp(3.8),
                                  color: const Color(0xFF777676),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // --- Phần dưới (Social Login) ---
                        Column(
                          children: [
                            SizedBox(height:context.h(0.03)),
                            Text(
                              "Hoặc tiếp tục với",
                              style: GoogleFonts.beVietnamPro(
                                fontSize: context.sp(4),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F41BB),
                              ),
                            ),
                            SizedBox(height: context.h(0.025)),
                            const SocialButtonsRow(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
