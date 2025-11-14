import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';

class WorkoutProgressCard extends StatelessWidget {
  final double progress;
  final int completed;
  final int total;

  const WorkoutProgressCard({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double circleSize = context.w(0.13); // ~48px trên màn 390px

    return Container(
      padding: EdgeInsets.all(context.w(0.04)), // ~16px
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(context.w(0.05)), // ~20px
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: context.w(0.04),
            offset: Offset(0, context.h(0.008)),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // === Văn bản ===
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tiến độ trong tuần",
                style: GoogleFonts.beVietnamPro(
                  fontSize: context.sp(3.6), // ~14px
                  color: Colors.white70,
                  height: 1.3,
                ),
              ),
              SizedBox(height: context.h(0.005)), // ~4px
              Text(
                "$completed/$total bài tập được hoàn thành.",
                style: GoogleFonts.beVietnamPro(
                  fontSize: context.sp(3.8), // ~15px
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ],
          ),

          // === Vòng tròn tiến độ ===
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: circleSize,
                width: circleSize,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF7BAAF7),
                  ),
                  strokeWidth: context.w(0.013), // ~5px
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                "${(progress * 100).round()}%",
                style: GoogleFonts.beVietnamPro(
                  fontSize: context.sp(3.8), // ~15px
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}