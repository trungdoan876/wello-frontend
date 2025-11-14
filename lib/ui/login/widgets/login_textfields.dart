import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class LoginTextFields extends StatelessWidget {
  const LoginTextFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(context, "Email"),
        SizedBox(height: context.h(0.025)),
        _buildTextField(context, "Password", isPassword: true),
        SizedBox(height: context.h(0.015)),
        _buildForgotPassword(context),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, String label, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.beVietnamPro(
          color: const Color(0xFF3A5DD9),
          fontSize: context.w(0.04),
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        contentPadding: EdgeInsets.symmetric(
          vertical: context.h(0.028),
          horizontal: context.w(0.05),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.w(0.05)),
          borderSide: const BorderSide(color: Color(0xFF7D90D2), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.w(0.03)),
          borderSide: const BorderSide(color: Color(0xFF7D90D2), width: 2.5),
        ),
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF3A5DD9),
          overlayColor: Colors.transparent,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          "Quên mật khẩu?",
          style: GoogleFonts.beVietnamPro(
            fontSize: context.w(0.035),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xFF3A5DD9),
            decorationThickness: 1.5,
          ),
        ),
      ),
    );
  }
}