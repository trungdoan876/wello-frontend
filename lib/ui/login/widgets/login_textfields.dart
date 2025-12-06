import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';


class LoginTextFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginTextFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(context, "Email", emailController),
        SizedBox(height: context.h(0.025)),
        _buildTextField(context, "Password", passwordController, isPassword: true),
        SizedBox(height: context.h(0.025)),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.beVietnamPro(
          fontSize: context.sp(4),
          fontWeight: FontWeight.w500,
          color: const Color(0xFF626262),
        ),
        filled: true,
        fillColor: const Color(0xFFFFFBE2),
        contentPadding: EdgeInsets.symmetric(
          vertical: context.h(0.025),
          horizontal: context.w(0.04),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.w(0.05)),
          borderSide: const BorderSide(color: Color(0xFFEBCF23), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.w(0.03)),
          borderSide: const BorderSide(color: Color(0xFFEBCF23), width: 2.5),
        ),
      ),
    );
  }
}