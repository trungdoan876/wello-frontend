// lib/widgets/calorie_summary.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';

class CalorieSummary extends StatelessWidget {
  const CalorieSummary({super.key});

  @override
  Widget build(BuildContext context) {
    const Color red = Colors.redAccent;
    const Color blue = Colors.blueAccent;

    return Consumer<NutritionProvider>(
      builder: (context, provider, child) {
        // Get data from provider with fallback values = 0
        final dailySummary = provider.dailySummary;
        final userProfile = provider.userProfile;
        
        final double caloriesConsumed = dailySummary?.caloriesConsumed.toDouble() ?? 0;
        final double targetCalories = userProfile?.dailyCalorieTarget.toDouble() ?? 0;
        final double caloriesBurned = dailySummary?.caloriesBurned.toDouble() ?? 0;
        final double caloriesRemaining = dailySummary?.caloriesRemaining.toDouble() ?? 0;
        
        final double carbConsumed = dailySummary?.carb.consumed ?? 0;
        final double carbTarget = dailySummary?.carb.target ?? 0;
        final double proteinConsumed = dailySummary?.protein.consumed ?? 0;
        final double proteinTarget = dailySummary?.protein.target ?? 0;
        final double fatConsumed = dailySummary?.fat.consumed ?? 0;
        final double fatTarget = dailySummary?.fat.target ?? 0;

        final double progress = targetCalories > 0 ? caloriesConsumed / targetCalories : 0;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Calo Đã nạp (Ăn vào)
                _buildStatItem(context, '${caloriesConsumed.toInt()}', 'đã nạp', blue, Icons.restaurant),

                // Vòng tròn Calo Nạp
                _buildCalorieCircle(
                  context,
                  caloriesRemaining,
                  progress,
                ), // updated calorie circle
                // Calo Tiêu hao (Đốt)
                _buildStatItem(
                  context,
                  '${caloriesBurned.toInt()}',
                  'tiêu hao',
                  red,
                  Icons.local_fire_department,
                ),
              ],
            ),
            SizedBox(height: context.h(0.03)),

            // --- Thanh Dinh Dưỡng (Macro) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMacroBar(
                  context,
                  '${carbConsumed.toInt()}/${carbTarget.toInt()}g',
                  'CARB',
                  Color(0xff43B483),
                  Color(0xffC5E1D5),
                  carbTarget > 0 ? carbConsumed / carbTarget : 0,
                  
                ),
                _buildMacroBar(
                  context,
                  '${proteinConsumed.toInt()}/${proteinTarget.toInt()}g',
                  'Chất đạm',
                 Color(0xffA581C7),
                  Color(0xffDED4E7),
                  proteinTarget > 0 ? proteinConsumed / proteinTarget : 0,
                ),
                _buildMacroBar(
                  context,
                  '${fatConsumed.toInt()}/${fatTarget.toInt()}g',
                  'Chất béo',
                   Color(0xff4880C6),
                  Color(0xffC2D4EC),
                  fatTarget > 0 ? fatConsumed / fatTarget : 0,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        // icon above the value (use default icon color)
        Icon(icon, color: Color(0xFFFFC107), size: context.sp(7.0)),
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(6.5),
            fontWeight: FontWeight.bold,
            color: const Color(0xff65645F),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(3.5),
            color: Color(0xffAFAEA9),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieCircle(
    BuildContext context,
    double value,
    double progress,
  ) {
    const Color yellow = Color(0xFFFFC107);
    const Color darkText = Color(0xFF5A5A5A);

    final double size = context.w(0.4); //vòng tròn trắng bên trong
    final double stroke = context.sp(4.7); // increased thickness per request

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 600),
        builder: (context, anim, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // background ring
              CustomPaint(
                size: Size(size, size),
                painter: _CalorieArcPainter(
                  progress: anim,
                  strokeWidth: stroke,
                ),
              ),

              // inner white circle with shadow
              // inner white circle with shadow (slightly smaller to fit thicker ring)
              Container(
                width: size * 0.75,
                height: size * 0.75,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flash_on,
                        color: yellow,
                        size: context.sp(6.0),
                      ),
                      Text(
                        value.round().toString(),
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(7.0),
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      Text(
                        'Cần nạp',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(4.0),
                          fontWeight: FontWeight.bold,
                          color: Color(0xffAFAEA9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMacroBar(
    BuildContext context,
    String title,
    String value,
    Color color,
    Color bgColor,
    double progress,  
  ) {
    final double barWidth = context.w(0.2); // chiều dài thanh ngang
    final double barHeight = context.sp(1.8); // chiều cao thanh ngang

    // background track uses provided bgColor or a much lighter version of the main color
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Thanh tiến trình ngang (Progress Bar)
        Container(
          width: barWidth,
          height: barHeight,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(context.sp(0.8)),
          ),
          alignment: Alignment.centerLeft,
          child: Container(
            width: barWidth * progress, // Giả lập tiến trình
            height: barHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(context.sp(0.8)),
            ),
          ),
        ),
        SizedBox(height: context.h(0.005)),
        // Giá trị
        Text(
          value,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(3.5),
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
       // SizedBox(height: context.h(0.005)),
        // Tiêu đề
        Text(
          title,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4.5),
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CalorieArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _CalorieArcPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // background ring
    final Paint bg = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);

    // Only draw arc if progress > 0
    if (progress > 0 && progress.isFinite) {
      // foreground arc with gradient
      final Rect rect = Rect.fromCircle(center: center, radius: radius);
      
      // Clamp progress to valid range
      final double clampedProgress = progress.clamp(0.0, 1.0);
      final double endAngle = -math.pi / 2 + 2 * math.pi * clampedProgress;
      
      // Only create gradient if we have a valid angle range
      if (endAngle > -math.pi / 2) {
        final Gradient gradient = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: endAngle,
          colors: [
            const Color.fromARGB(255, 232, 255, 79),
            const Color(0xFFFFB300),
          ],
        );

        final Paint arcPaint = Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

        final double sweep = 2 * math.pi * clampedProgress;
        canvas.drawArc(rect, -math.pi / 2, sweep, false, arcPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CalorieArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
