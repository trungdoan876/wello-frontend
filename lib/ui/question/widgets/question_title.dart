import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class QuestionTitle extends StatelessWidget {
  final String text;

  const QuestionTitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.beVietnamPro(
        fontSize: context.sp(6.4), // ~25px (tự scale theo màn hình)
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.3, // Khoảng cách dòng đẹp
        letterSpacing: 0.2,
      ),
    );
  }
}