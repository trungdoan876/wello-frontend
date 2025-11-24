// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/register/widgets/register_form_cart.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFFFBEA);

    return Scaffold(
      backgroundColor: lightCream,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                'assets/images/register_background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned.fill(child: Container(color: lightCream.withOpacity(0.2))),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: context.h(0.04)),

                  Container(
                    margin: EdgeInsets.only(
                      top: context.h(0.1),
                    ).copyWith(left: context.w(0.05), right: context.w(0.05)),
                    padding: EdgeInsets.symmetric(vertical: context.h(0.05)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(context.sp(5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: RegisterFormContent(
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
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
