import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class RegisterTextFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegisterTextFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(context, "Email", controller: emailController),
        SizedBox(height: context.h(0.025)),
        _buildTextField(
          context,
          "Password",
          controller: passwordController,
          isPassword: true,
        ),
        SizedBox(height: context.h(0.025)),
        _buildTextField(
          context,
          "Confirm Password",
          controller: confirmPasswordController,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label, {
    bool isPassword = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: label == "Email"
          ? TextInputType.emailAddress
          : TextInputType.text,
      autofillHints: label == "Email" ? const [AutofillHints.email] : null,
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
