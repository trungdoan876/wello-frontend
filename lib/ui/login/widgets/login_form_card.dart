// lib/widgets/login_form_card.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/login/widgets/login_textfields.dart';
import 'package:wello_frontend/ui/register/register_page.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';


class LoginFormContent extends StatelessWidget {
  const LoginFormContent({super.key});

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
          const LoginTextFields(),          
          // --- Quên mật khẩu ---
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
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
                    onPressed: () {
                      
                      // TODO: Xử lý logic login
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
          Container(
           
            child: Center(
              // Sử dụng icon Google nếu bạn đã cài gói font awesome hoặc tương đương
              child: Image.asset(
                'assets/images/google.png', // Thay thế bằng đường dẫn icon Google thực tế
                width: context.w(0.08),
              ), 
            ),
          ),
        ],
      ),
    );
  }
}