import 'package:flutter/material.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart'; // Import extension


class SocialButtonsRow extends StatelessWidget {
  const SocialButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonSize = context.w(0.14); // 14% chiều rộng màn hình

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(context, "assets/images/google.png", buttonSize),
        SizedBox(width: context.w(0.04)),
      ],
    );
  }

  Widget _buildSocialButton(BuildContext context, String imagePath, double size) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.26), // Scale padding theo size
      decoration: BoxDecoration(
        color: const Color(0xFFECECEC),
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.06),
          ),
        ],
      ),
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }
}