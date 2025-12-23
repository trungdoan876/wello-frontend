import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/core/utils/validators.dart';

class RegisterTextFields extends StatefulWidget {
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
  State<RegisterTextFields> createState() => _RegisterTextFieldsState();
}

class _RegisterTextFieldsState extends State<RegisterTextFields> {
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    // Add listeners to validate on text change
    widget.emailController.addListener(_validateEmail);
    widget.passwordController.addListener(_validatePassword);
    widget.confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    // Remove listeners
    widget.emailController.removeListener(_validateEmail);
    widget.passwordController.removeListener(_validatePassword);
    widget.confirmPasswordController.removeListener(_validateConfirmPassword);
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      _emailError = Validators.validateEmail(widget.emailController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = Validators.validatePassword(widget.passwordController.text);
      // Also re-validate confirm password when password changes
      _validateConfirmPassword();
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _confirmPasswordError = Validators.validateConfirmPassword(
        widget.passwordController.text,
        widget.confirmPasswordController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          context,
          "Email",
          controller: widget.emailController,
          errorText: _emailError,
        ),
        SizedBox(height: context.h(0.025)),
        _buildTextField(
          context,
          "Password",
          controller: widget.passwordController,
          isPassword: true,
          errorText: _passwordError,
        ),
        SizedBox(height: context.h(0.025)),
        _buildTextField(
          context,
          "Confirm Password",
          controller: widget.confirmPasswordController,
          isPassword: true,
          errorText: _confirmPasswordError,
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label, {
    bool isPassword = false,
    required TextEditingController controller,
    String? errorText,
  }) {
    final hasError = errorText != null && controller.text.isNotEmpty;

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
        errorText: hasError ? errorText : null,
        errorStyle: GoogleFonts.beVietnamPro(
          fontSize: context.sp(3.5),
          color: Colors.red.shade700,
        ),
        filled: true,
        fillColor: const Color(0xFFFFFBE2),
        contentPadding: EdgeInsets.symmetric(
          vertical: context.h(0.025),
          horizontal: context.w(0.04),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.w(0.05)),
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade400 : const Color(0xFFEBCF23),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.w(0.03)),
          borderSide: BorderSide(
            color: hasError ? Colors.red.shade600 : const Color(0xFFEBCF23),
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.w(0.05)),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.w(0.03)),
          borderSide: BorderSide(color: Colors.red.shade600, width: 2.5),
        ),
      ),
    );
  }
}
