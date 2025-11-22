// lib/ui/register/widgets/register_form_card.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/login/login_page.dart';
import 'package:wello_frontend/ui/register/widgets/register_textfields.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/ui/widgets/animated_start_button.dart';

class RegisterFormContent extends StatelessWidget {
  const RegisterFormContent({super.key});

  @override
  Widget build(BuildContext context) {
    const Color titleYellow = Color(0xFFEBCF23);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(0.04)),
      child: Column(
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
          ),

          SizedBox(height: context.h(0.02)),

          // --- Input Fields ---
          const RegisterTextFields(),

          SizedBox(height: context.h(0.03)),

          // --- Nút Đăng ký ---
          SizedBox(
            width: context.w(0.8),
            child: AnimatedStartButton(
              text: "Đăng ký",
              onPressed: () {},
            ),
          ),

          SizedBox(height: context.h(0.03)),

          // ---- Đã có tài khoản ----
          TextButton(
            onPressed: () {
              Navigator.push(
              context,
              CupertinoPageRoute(builder: (_) => const LoginPage()),
            );
              // TODO: điều hướng sang LoginPage
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
          Image.asset(
            "assets/images/google.png",
            width: context.w(0.08),
          ),
        ],
      ),
    );
  }
}
