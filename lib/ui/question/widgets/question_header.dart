import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class QuestionHeader extends StatelessWidget {
  const QuestionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: context.h(0.01)), // ~8px
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nút back ở góc trái
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: context.w(0.06), // ~24px
                color: const Color(0xFF7BAAF7),
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.all(context.w(0.03)),
              constraints: BoxConstraints(
                minWidth: context.w(0.12),
                minHeight: context.w(0.12),
              ),
            ),
          ),

          // Chữ "Wello" nằm giữa hoàn hảo
          Text(
            'Wello',
            style: GoogleFonts.pacifico(
              fontSize: context.sp(11), // ~44px (giữa 40-48)
              color: const Color(0xFF7BAAF7),
              fontWeight: FontWeight.w400,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: Offset(0, context.h(0.002)),
                  blurRadius: context.w(0.02),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}