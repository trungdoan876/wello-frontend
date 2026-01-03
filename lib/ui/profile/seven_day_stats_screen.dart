import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/domain/entities/seven_day_stats.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/seven_day_stats_provider.dart';

class SevenDayStatsScreen extends StatefulWidget {
  const SevenDayStatsScreen({super.key});

  @override
  State<SevenDayStatsScreen> createState() => _SevenDayStatsScreenState();
}

class _SevenDayStatsScreenState extends State<SevenDayStatsScreen> {
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final credentials = await AuthHelper.getCredentials();
    if (credentials != null && mounted) {
      final provider = Provider.of<SevenDayStatsProvider>(
        context,
        listen: false,
      );
      await provider.loadSevenDayStats(
        credentials.token,
        credentials.userId.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F3FF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thống kê 7 ngày',
          style: GoogleFonts.baloo2(
            fontSize: context.sp(7),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8A8FFF), Color(0xFFA39AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<SevenDayStatsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: const Color(0xFF8A8FFF)),
            );
          }

          if (provider.hasError && provider.stats == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: context.h(0.02)),
                  Text(
                    'Lỗi tải dữ liệu',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.h(0.01)),
                  Text(
                    provider.errorMessage ?? 'Vui lòng thử lại',
                    style: GoogleFonts.baloo2(fontSize: context.sp(5)),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.h(0.02)),
                  ElevatedButton(
                    onPressed: _loadStats,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A8FFF),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(0.1),
                        vertical: context.h(0.015),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Thử lại',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final stats = provider.stats;
          if (stats == null) {
            return Center(
              child: Text(
                'Không có dữ liệu',
                style: GoogleFonts.baloo2(fontSize: context.sp(6)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.04),
              vertical: context.h(0.02),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range header
                _buildDateRangeCard(context, stats),
                SizedBox(height: context.h(0.02)),

                // Key metrics section
                _buildSectionTitle(context, 'Chỉ số chính', icon: Icons.dashboard_rounded),
                SizedBox(height: context.h(0.015)),
                _buildKeyMetrics(context, stats),
                SizedBox(height: context.h(0.025)),

                // Water statistics
                _buildSectionTitle(context, 'Nước uống', icon: Icons.water_drop_rounded),
                SizedBox(height: context.h(0.01)),
                _buildWaterStats(context, stats),
                SizedBox(height: context.h(0.015)),
                _buildWaterChart(context, stats),
                SizedBox(height: context.h(0.02)),

                // Calorie statistics
                _buildSectionTitle(context, 'Calo', icon: Icons.local_fire_department_rounded),
                SizedBox(height: context.h(0.015)),
                _buildCalorieStats(context, stats),
                SizedBox(height: context.h(0.015)),
                _buildCalorieChart(context, stats),
                SizedBox(height: context.h(0.025)),

                // Meal statistics
                _buildSectionTitle(context, 'Thống kê bữa ăn', icon: Icons.restaurant_rounded),
                SizedBox(height: context.h(0.015)),
                _buildMealStats(context, stats),
                SizedBox(height: context.h(0.025)),

                // Macronutrient statistics
                _buildSectionTitle(context, 'Đạm / Carb / Chất béo', icon: Icons.pie_chart_rounded),
                SizedBox(height: context.h(0.015)),
                _buildMacroStats(context, stats),
                SizedBox(height: context.h(0.015)),
                _buildMacroChart(context, stats),
                SizedBox(height: context.h(0.025)),

                // Workout statistics
                _buildSectionTitle(context, 'Hoạt động thể chất', icon: Icons.fitness_center_rounded),
                SizedBox(height: context.h(0.01)),
                _buildWorkoutStats(context, stats),
                SizedBox(height: context.h(0.03)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ignore: unused_element
  Widget _buildDateRangeCard(BuildContext context, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(context.w(0.05)),
      decoration: _headerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(0.025)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: context.sp(6),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xem chi tiết hoạt động của bạn',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.2),
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: context.h(0.003)),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(stats.startDate)} - ${DateFormat('dd/MM/yyyy').format(stats.endDate)}',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.8),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(0.02)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.03),
              vertical: context.h(0.008),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: context.sp(4),
                ),
                SizedBox(width: context.w(0.015)),
                Text(
                  'Nhấn để xem thống kê chi tiết',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.8),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {IconData? icon}) {
    return Container(
      margin: EdgeInsets.only(left: context.w(0.01)),
      padding: EdgeInsets.symmetric(
        horizontal: context.w(0.03),
        vertical: context.h(0.01),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8A8FFF).withOpacity(0.1),
            const Color(0xFFBBAAFF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(context.w(0.015)),
              decoration: BoxDecoration(
                color: const Color(0xFF8A8FFF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: context.sp(4.5),
                color: const Color(0xFF8A8FFF),
              ),
            ),
            SizedBox(width: context.w(0.025)),
          ],
          Text(
            title,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(6),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF8A8FFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, dynamic stats) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.water_drop,
            color: Colors.blue,
            title: 'Uống đủ nước',
            value: '${stats.daysWithSufficientWater}/${stats.totalDays}',
            percentage: stats.waterPercentage,
          ),
        ),
        SizedBox(width: context.w(0.02)),
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.fitness_center,
            color: Colors.green,
            title: 'Tập luyện',
            value: '${stats.daysWithWorkout}/${stats.totalDays}',
            percentage: stats.workoutPercentage,
          ),
        ),
        SizedBox(width: context.w(0.02)),
        Expanded(
          child: _buildMetricCard(
            context,
            icon: Icons.local_fire_department,
            color: Colors.orange,
            title: 'Vượt calo',
            value: '${stats.daysExceedingCalories}/${stats.totalDays}',
            percentage: stats.caloriePercentage,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required double percentage,
  }) {
    return Container(
      padding: EdgeInsets.all(context.w(0.035)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            color.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.025)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: context.sp(6)),
          ),
          SizedBox(height: context.h(0.012)),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(6.2),
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: context.h(0.004)),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.6),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              height: 1.1,
            ),
          ),
          SizedBox(height: context.h(0.01)),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.7), color],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(0.006)),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.5),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterStats(BuildContext context, dynamic stats) {
    return Column(
      children: [
        // Summary Card
        Container(
          padding: EdgeInsets.all(context.w(0.04)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF64B5F6), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.w(0.04)),
            border: Border.all(color: const Color(0xFF64B5F6).withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF64B5F6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(0.03)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                ),
                child: Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: context.sp(10),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng nước uống',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.5),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '7 ngày qua',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.03),
                  vertical: context.h(0.008),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.w(0.02)),
                ),
                child: Text(
                  '${stats.totalWaterMl.toStringAsFixed(0)} ml',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF42A5F5),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(0.015)),
        // Stats Cards Grid
        Row(
          children: [
            Expanded(
              child: _buildWaterStatCard(
                context,
                icon: Icons.show_chart_rounded,
                label: 'Trung bình/ngày',
                value: '${stats.averageWaterMl.toStringAsFixed(0)}',
                unit: 'ml',
                gradient: const LinearGradient(
                  colors: [Color(0xFF9FE2BF), Color(0xFF7BD4A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: const Color(0xFF7BD4A8),
              ),
            ),
            SizedBox(width: context.w(0.025)),
            Expanded(
              child: _buildWaterStatCard(
                context,
                icon: Icons.arrow_upward_rounded,
                label: 'Cao nhất',
                value: '${stats.maxWaterMl.toStringAsFixed(0)}',
                unit: 'ml',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFBCB3), Color(0xFFFF9E8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: const Color(0xFFFF9E8A),
              ),
            ),
            SizedBox(width: context.w(0.025)),
            Expanded(
              child: _buildWaterStatCard(
                context,
                icon: Icons.arrow_downward_rounded,
                label: 'Thấp nhất',
                value: '${stats.minWaterMl.toStringAsFixed(0)}',
                unit: 'ml',
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8B5FF), Color(0xFFA898FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: const Color(0xFFA898FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaterStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Gradient gradient,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.w(0.04)),
        border: Border.all(color: borderColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.03)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [borderColor.withOpacity(0.9), borderColor],
              ),
              borderRadius: BorderRadius.circular(context.w(0.03)),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: context.sp(8),
            ),
          ),
          SizedBox(height: context.h(0.012)),
          Expanded(
            child: Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.8),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: context.h(0.008)),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(8),
              fontWeight: FontWeight.w900,
              color: borderColor,
              height: 1,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.5),
              fontWeight: FontWeight.w500,
              color: borderColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: context.h(0.01)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.025),
              vertical: context.h(0.006),
            ),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(context.w(0.02)),
            ),
            child: Text(
              'TB: $value',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(3.5),
                fontWeight: FontWeight.w600,
                color: borderColor,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildCalorieStats(BuildContext context, dynamic stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCalorieCard(
                context,
                icon: Icons.restaurant_rounded,
                color: const Color(0xFFFF6B6B),
                label: 'Tiêu thụ',
                value: stats.totalCaloriesConsumed.toStringAsFixed(0),
                subtitle: 'TB: ${stats.averageCaloriesConsumed.toStringAsFixed(0)}',
              ),
            ),
            SizedBox(width: context.w(0.03)),
            Expanded(
              child: _buildCalorieCard(
                context,
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFFF8C42),
                label: 'Đốt cháy',
                value: stats.totalCaloriesBurned.toStringAsFixed(0),
                subtitle: 'TB: ${stats.averageCaloriesBurned.toStringAsFixed(0)}',
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(0.015)),
        _buildCalorieDeficitCard(
          context,
          deficit: stats.totalCaloriesDeficit.toStringAsFixed(0),
          avgDeficit: stats.averageCaloriesDeficit.toStringAsFixed(0),
        ),
      ],
    );
  }

  Widget _buildCalorieCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.025)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: context.sp(6),
            ),
          ),
          SizedBox(height: context.h(0.012)),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          SizedBox(height: context.h(0.005)),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(6.5),
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'cal',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.5),
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
            ),
          ),
          SizedBox(height: context.h(0.008)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.025),
              vertical: context.h(0.005),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              subtitle,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(3.2),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieDeficitCard(
    BuildContext context, {
    required String deficit,
    required String avgDeficit,
  }) {
    final isPositive = double.tryParse(deficit) != null && double.parse(deficit) < 0;
    final color = isPositive ? const Color(0xFF51CF66) : const Color(0xFF8A8FFF);
    
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.03)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isPositive ? Icons.trending_down_rounded : Icons.trending_up_rounded,
              color: Colors.white,
              size: context.sp(7),
            ),
          ),
          SizedBox(width: context.w(0.04)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thâm hụt Calo',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.5),
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(height: context.h(0.003)),
                Text(
                  'Tổng: ${deficit} cal',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.8),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.035),
              vertical: context.h(0.012),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  avgDeficit,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.5),
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'cal/ngày',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3),
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealStats(BuildContext context, dynamic stats) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(context.w(0.04)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF3CD),
                Color(0xFFFFE5B4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD93D).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD93D).withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(0.03)),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD93D), Color(0xFFFFC107)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD93D).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: context.sp(7),
                ),
              ),
              SizedBox(width: context.w(0.04)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tổng bữa ăn',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF8C00),
                      ),
                    ),
                    Text(
                      '${stats.totalMeals} bữa trong 7 ngày',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.5),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(context.w(0.035)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFD93D).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      stats.averageMealsPerDay.toStringAsFixed(1),
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(6.5),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFF8C00),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'bữa/ngày',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3),
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF8C00).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(0.015)),
        Row(
          children: [
            Expanded(
              child: _buildMealTypeCard(
                context,
                icon: Icons.wb_sunny_rounded,
                color: const Color(0xFFFFB84D),
                label: 'Sáng',
                count: stats.breakfastCount,
              ),
            ),
            SizedBox(width: context.w(0.025)),
            Expanded(
              child: _buildMealTypeCard(
                context,
                icon: Icons.wb_twilight_rounded,
                color: const Color(0xFFFF8C42),
                label: 'Trưa',
                count: stats.lunchCount,
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(0.015)),
        Row(
          children: [
            Expanded(
              child: _buildMealTypeCard(
                context,
                icon: Icons.nightlight_rounded,
                color: const Color(0xFF8A8FFF),
                label: 'Tối',
                count: stats.dinnerCount,
              ),
            ),
            SizedBox(width: context.w(0.025)),
            Expanded(
              child: _buildMealTypeCard(
                context,
                icon: Icons.cake_rounded,
                color: const Color(0xFFFF6B9D),
                label: 'Ăn vặt',
                count: stats.snackCount,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealTypeCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required int count,
  }) {
    return Container(
      padding: EdgeInsets.all(context.w(0.035)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.025)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: context.sp(5.5),
            ),
          ),
          SizedBox(height: context.h(0.01)),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: context.h(0.003)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.025),
              vertical: context.h(0.005),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count lần',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.2),
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroStats(BuildContext context, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: _surfaceCardDecoration(),
      child: Column(
        children: [
          // Carbs
          _buildMacroItem(
            context,
            icon: Icons.grain_rounded,
            color: const Color(0xFFFFB347),
            label: 'Carb (Tinh bột)',
            total: stats.totalCarbs.toStringAsFixed(0),
            average: stats.averageCarbsPerDay.toStringAsFixed(1),
          ),
          SizedBox(height: context.h(0.015)),
          // Protein
          _buildMacroItem(
            context,
            icon: Icons.egg_rounded,
            color: const Color(0xFF43C6AC),
            label: 'Đạm',
            total: stats.totalProtein.toStringAsFixed(0),
            average: stats.averageProteinPerDay.toStringAsFixed(1),
          ),
          SizedBox(height: context.h(0.015)),
          // Fat
          _buildMacroItem(
            context,
            icon: Icons.water_drop_rounded,
            color: const Color(0xFFF45C43),
            label: 'Chất béo',
            total: stats.totalFat.toStringAsFixed(0),
            average: stats.averageFatPerDay.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String total,
    required String average,
  }) {
    return Container(
      padding: EdgeInsets.all(context.w(0.035)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.08),
            color.withOpacity(0.03),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.025)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: context.sp(6),
            ),
          ),
          SizedBox(width: context.w(0.035)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4.8),
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(height: context.h(0.004)),
                Row(
                  children: [
                    Text(
                      'Tổng: ',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.8),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${total}g',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.2),
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.03),
              vertical: context.h(0.01),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${average}g',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5.5),
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '/ngày',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(3.2),
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats(BuildContext context, dynamic stats) {
    return Column(
      children: [
        // Summary Card
        Container(
          padding: EdgeInsets.all(context.w(0.04)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7EC8FF), Color(0xFF5AA1FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(context.w(0.04)),
            border: Border.all(color: const Color(0xFF7EC8FF).withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7EC8FF).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(0.03)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(context.w(0.03)),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: context.sp(10),
                ),
              ),
              SizedBox(width: context.w(0.03)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoạt động tổng thể',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5.5),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '7 ngày qua',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(0.03),
                  vertical: context.h(0.008),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.w(0.02)),
                ),
                child: Text(
                  '${stats.daysWithWorkout} ngày',
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2F82E0),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(0.015)),
        // Stats Cards Grid
        Row(
          children: [
            Expanded(
              child: _buildWorkoutStatCard(
                context,
                icon: Icons.calendar_today_rounded,
                label: 'Trung bình/tuần',
                value: '${stats.averageWorkoutDaysPerWeek.toStringAsFixed(1)}',
                unit: 'ngày',
                gradient: const LinearGradient(
                  colors: [Color(0xFF6FA8FF), Color(0xFF9CB3FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: const Color(0xFF6FA8FF),
              ),
            ),
            SizedBox(width: context.w(0.03)),
            Expanded(
              child: _buildWorkoutStatCard(
                context,
                icon: Icons.local_fire_department_rounded,
                label: 'Calo đốt cao nhất',
                value: '${stats.maxDailyCaloriesBurned.toStringAsFixed(0)}',
                unit: 'cal',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC3A0), Color(0xFFFF9A9E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderColor: const Color(0xFFFF9A9E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkoutStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Gradient gradient,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(context.w(0.04)),
        border: Border.all(color: borderColor.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.03)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [borderColor.withOpacity(0.9), borderColor],
              ),
              borderRadius: BorderRadius.circular(context.w(0.03)),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: context.sp(8),
            ),
          ),
          SizedBox(height: context.h(0.012)),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.8),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: context.h(0.008)),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(8),
              fontWeight: FontWeight.w900,
              color: borderColor,
              height: 1,
            ),
          ),
          Text(
            unit,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(3.5),
              fontWeight: FontWeight.w500,
              color: borderColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: context.h(0.01)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(0.025),
              vertical: context.h(0.006),
            ),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(context.w(0.02)),
            ),
            child: Text(
              'TB: $value',
              style: GoogleFonts.baloo2(
                fontSize: context.sp(3.5),
                fontWeight: FontWeight.w600,
                color: borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildEmptyChartCard(BuildContext context, String message) {
    return Container(
      height: context.h(0.22),
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: _surfaceCardDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.w(0.04)),
              decoration: BoxDecoration(
                color: const Color(0xFF8A8FFF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.show_chart_rounded,
                size: context.sp(10),
                color: const Color(0xFF8A8FFF).withOpacity(0.5),
              ),
            ),
            SizedBox(height: context.h(0.015)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(
                fontSize: context.sp(4.5),
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterChart(BuildContext context, SevenDayStats stats) {
    final waterData = stats.dailyWaterMl;

    if (waterData.isEmpty) {
      return _buildEmptyChartCard(
        context,
        'Chưa có dữ liệu uống nước từng ngày.',
      );
    }

    final maxWater = waterData.reduce((a, b) => a > b ? a : b);
    final maxY = (maxWater > 0 ? maxWater * 1.25 : 800).clamp(600.0, 4000.0).toDouble();

    return Container(
      height: context.h(0.3),
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: _surfaceCardDecoration(),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                  return Text(
                    days[value.toInt() % days.length],
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(3.5),
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(1)}L',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(3),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(waterData.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: waterData[index].toDouble(),
                  color: Colors.blue.shade400,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCalorieChart(BuildContext context, SevenDayStats stats) {
    final calorieData = stats.dailyCaloriesConsumed;

    if (calorieData.isEmpty) {
      return _buildEmptyChartCard(
        context,
        'Chưa có dữ liệu calo từng ngày.',
      );
    }

    final maxCalorie = calorieData.reduce((a, b) => a > b ? a : b);
    final maxY = (maxCalorie > 0 ? maxCalorie * 1.25 : 800).clamp(400.0, 3200.0).toDouble();

    return Container(
      height: context.h(0.24),
      padding: EdgeInsets.all(context.w(0.035)),
      decoration: _surfaceCardDecoration(),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                  return Text(
                    days[value.toInt() % days.length],
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(3.5),
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value / 100).toStringAsFixed(0)}',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(2.8),
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(calorieData.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: calorieData[index].toDouble(),
                  color: Colors.orange.shade400,
                  width: 14,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMacroChart(BuildContext context, SevenDayStats stats) {
    final avgProtein = stats.averageProteinPerDay.toDouble();
    final avgCarbs = stats.averageCarbsPerDay.toDouble();
    final avgFat = stats.averageFatPerDay.toDouble();

    if (avgProtein <= 0 && avgCarbs <= 0 && avgFat <= 0) {
      return _buildEmptyChartCard(
        context,
        'Chưa có dữ liệu từng ngày.',
      );
    }

    final totalMacro = (avgProtein + avgCarbs + avgFat).clamp(0.0001, double.infinity);
    final baseRing = (totalMacro * 0.25).clamp(0.0001, double.infinity);
    final totalKcal = (avgProtein * 4 + avgCarbs * 4 + avgFat * 9)
        .clamp(0, double.infinity)
        .toStringAsFixed(0);

    return Container(
      height: context.h(0.28),
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: _surfaceCardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(context, 'Đạm', const Color(0xFF30C6D9)),
              SizedBox(width: context.w(0.06)),
              _buildLegend(context, 'Carb', const Color(0xFFFF7BA0)),
              SizedBox(width: context.w(0.06)),
              _buildLegend(context, 'Béo', const Color(0xFFB27BFF)),
            ],
          ),
          SizedBox(height: context.h(0.01)),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 34,
                    sections: [
                      PieChartSectionData(
                        value: avgProtein,
                        color: const Color(0xFF30C6D9), // aqua
                        showTitle: false,
                        radius: 50,
                        borderSide: const BorderSide(color: Colors.white, width: 2.5),
                      ),
                      PieChartSectionData(
                        value: avgCarbs,
                        color: const Color(0xFFFF7BA0), // pink
                        showTitle: false,
                        radius: 50,
                        borderSide: const BorderSide(color: Colors.white, width: 2.5),
                      ),
                      PieChartSectionData(
                        value: avgFat,
                        color: const Color(0xFFB27BFF), // violet
                        showTitle: false,
                        radius: 50,
                        borderSide: const BorderSide(color: Colors.white, width: 2.5),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalKcal,
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(7),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF6A04D),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(3.8),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: context.w(0.03),
          height: context.w(0.03),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: context.w(0.015)),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(3.6),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  BoxDecoration _headerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF8A8FFF), Color(0xFFA39AFF), Color(0xFFBBAAFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF8A8FFF).withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  BoxDecoration _surfaceCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF8A8FFF).withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
