import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, _) {
        final summary = provider.dailySummary;
        final profile = provider.userProfile;

        // Tính toán các chỉ số
        // 1. Calo
        final double calConsumed = summary?.caloriesConsumed.toDouble() ?? 0;
        final double calTarget = profile?.dailyCalorieTarget.toDouble() ?? 2000;
        final double calPercent = (calTarget > 0)
            ? (calConsumed / calTarget).clamp(0.0, 1.0)
            : 0.0;

        // 2. Nước (mục tiêu tính bằng ml)
        final double waterConsumed =
            summary?.waterIntake.consumed.toDouble() ?? 0;
        final double waterTarget = profile?.dailyWaterTarget.toDouble() ?? 2000;
        final double waterPercent = (waterTarget > 0)
            ? (waterConsumed / waterTarget).clamp(0.0, 1.0)
            : 0.0;

        // 3. Bữa ăn (Ví dụ: tính dựa trên số món đã log trong foodHistory)
        final int mealsLogged = provider.foodHistory.length;
        final double mealPercent = (mealsLogged / 4).clamp(
          0.0,
          1.0,
        ); // Giả định mục tiêu 4 bữa/ngày

        // 4. Tập luyện (Calo đốt cháy)
        final double burnConsumed = summary?.caloriesBurned.toDouble() ?? 0;
        final double burnTarget =
            500.0; // Bạn có thể thay bằng profile?.workoutTarget nếu có
        final double burnPercent = (burnTarget > 0)
            ? (burnConsumed / burnTarget).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(context.w(0.05)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.sp(4.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TIÊU ĐỀ CÓ ICON
              Row(
                children: [
                  Icon(
                    Icons.analytics_rounded, // Icon biểu đồ tổng quát
                    color: const Color(0xffEBCF23),
                    size: context.sp(6.5),
                  ),
                  SizedBox(width: context.w(0.02)),
                  Text(
                    'Tiến độ hôm nay',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5.5),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(0.025)),

              _buildProgressRow(
                context,
                Icons.local_fire_department,
                'Calo nạp',
                calPercent,
                const Color(0xffEBCF23),
              ),
              _buildProgressRow(
                context,
                Icons.water_drop,
                'Nước uống',
                waterPercent,
                Colors.blue,
              ),
              _buildProgressRow(
                context,
                Icons.fitness_center,
                'Tập luyện',
                burnPercent,
                Colors.orange,
              ),
              _buildProgressRow(
                context,
                Icons.restaurant,
                'Bữa ăn',
                mealPercent,
                Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressRow(
    BuildContext context,
    IconData icon,
    String label,
    double percent,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(0.015)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.sp(2)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: context.sp(5), color: color),
          ),
          SizedBox(width: context.w(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.baloo2(
                        fontWeight: FontWeight.w600,
                        fontSize: context.sp(4),
                      ),
                    ),
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: GoogleFonts.baloo2(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.005)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
