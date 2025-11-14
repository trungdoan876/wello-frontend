// widgets/workout_header.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class WorkoutHeader extends StatelessWidget {
  const WorkoutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: context.h(0.01)), // ~20px
        Text(
          "Kế hoạch vận động của bạn",
          textAlign: TextAlign.center,
          style: GoogleFonts.beVietnamPro(
            fontSize: context.sp(6.2), // ~24px
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            height: 1.3,
            letterSpacing: 0.3,
          ),
        ),
        SizedBox(height: context.h(0.012)), // ~10px
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(0.03)), // Giới hạn chiều rộng
          child: Text(
            "Tập luyện hàng ngày tại với các bài tập được tuỳ chỉnh theo mục tiêu và sở thích của bạn.",
            textAlign: TextAlign.center,
            style: GoogleFonts.beVietnamPro(
              fontSize: context.sp(3.6), // ~14px
              color: const Color.fromARGB(137, 97, 97, 97),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}