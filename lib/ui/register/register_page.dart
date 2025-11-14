import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/login/login_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/loading_page.dart';
import 'widgets/register_textfields.dart';
import '../login/widgets/social_buttons.dart';
import '../widgets/responsive.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(0.07),
                        vertical: context.h(0.04),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // === PHẦN TRÊN: Tiêu đề + Form ===
                          Column(
                            children: [
                              SizedBox(height: context.h(0.04)),

                              // Tiêu đề
                              Text(
                                "Tạo tài khoản",
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: context.sp(7.5),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F41BB),
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: context.h(0.025)),

                              // Mô tả
                              Text(
                                "Tạo một tài khoản để bạn khám phá\ntất cả các bài tập hiện có.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: context.sp(4.2),
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),

                              SizedBox(height: context.h(0.06)),

                              // Form nhập liệu
                              const RegisterTextFields(),
                            ],
                          ),

                          // === PHẦN GIỮA: Nút Đăng ký + Link Đăng nhập ===
                          Column(
                            children: [
                              SizedBox(height: context.h(0.035)),

                              // Nút Đăng ký
                              SizedBox(
                                width: context.w(0.86),
                                child: AnimatedStartButton(
                                  text: "Đăng ký",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LoadingPage(
                                          nextPage: const LoginPage(),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: context.h(0.025)),

                              // Link: Đã có tài khoản?
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoadingPage(
                                        nextPage: const LoginPage(),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Bạn đã có tài khoản?",
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

                          // === PHẦN DƯỚI: Social Login ===
                          Column(
                            children: [
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

                              SizedBox(height: context.h(0.01)),
                            ],
                          ),
                        ],
                      ),
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