// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/login/widgets/login_form_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFFFBEA);

    return Scaffold(
      backgroundColor: lightCream,
      body: Stack(
        children: [
          // 1. Hình ảnh nền (Phía sau) - Salad mờ
          Positioned.fill(
            child: Opacity(
              opacity: 1, 
              child: Image.asset(
                'assets/images/login_background.png', // Thay thế bằng hình ảnh salad của bạn
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Thêm lớp phủ mỏng màu kem nhạt để tăng độ mờ và làm nổi bật form
          Positioned.fill(
            child: Container(
              color: lightCream.withOpacity(0.4),
            ),
          ),

          // 2. Nội dung chính (Phía trước)
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: context.h(0.04)), 

                  // --- Form Card Container ---
                  Container(
                    width: context.w(1), // Chiều rộng 90% màn hình
                    margin: EdgeInsets.only(
                      top: context.h(0.1),
                    ).copyWith(
                      left: context.w(0.05),   // thụt trái 5% màn hình
                      right: context.w(0.05),  // thụt phải 5% màn hình
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: context.h(0.05),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75), // Nền trắng mờ
                      borderRadius: BorderRadius.circular(context.sp(5.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: LoginFormContent(
                      emailController: emailController,
                      passwordController: passwordController,
                    ),
                  ),
                  
                  SizedBox(height: context.h(0.05)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}