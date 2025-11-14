import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class QuestionDescriptionBox extends StatelessWidget {
  final String text;

  const QuestionDescriptionBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(0.045)), // ~18px
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.04)), // ~16px
        border: Border.all(
          color: Colors.grey[300]!,
          width: context.w(0.003), // ~1px
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: context.w(0.02),
            offset: Offset(0, context.h(0.002)),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.beVietnamPro(
          fontSize: context.sp(4.6), // ~18px
          fontWeight: FontWeight.w500,
          color: Colors.black87,
          height: 1.6,
        ),
      ),
    );
  }
}