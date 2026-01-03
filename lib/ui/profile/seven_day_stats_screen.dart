import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
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
      backgroundColor: const Color(0xFFFFF7DA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFF7DA),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thống kê 7 ngày',
          style: GoogleFonts.baloo2(
            fontSize: context.sp(7),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SevenDayStatsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: const Color(0xFFEBCF23)),
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
                      backgroundColor: const Color(0xFFEBCF23),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(0.1),
                        vertical: context.h(0.015),
                      ),
                    ),
                    child: Text(
                      'Thử lại',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(5),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
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
                _buildSectionTitle(context, 'Chỉ số chính'),
                SizedBox(height: context.h(0.01)),
                _buildKeyMetrics(context, stats),
                SizedBox(height: context.h(0.02)),

                // Water statistics
                _buildSectionTitle(context, 'Nước uống'),
                SizedBox(height: context.h(0.01)),
                _buildWaterStats(context, stats),
                SizedBox(height: context.h(0.015)),
                _buildWaterChart(context, stats),
                SizedBox(height: context.h(0.02)),

                // Calorie statistics
                _buildSectionTitle(context, 'Calo'),
                SizedBox(height: context.h(0.01)),
                _buildCalorieStats(context, stats),
                SizedBox(height: context.h(0.015)),
                _buildCalorieChart(context, stats),
                SizedBox(height: context.h(0.02)),

                // Meal statistics
                _buildSectionTitle(context, 'Thống kê bữa ăn'),
                SizedBox(height: context.h(0.01)),
                _buildMealStats(context, stats),
                SizedBox(height: context.h(0.02)),

                // Macronutrient statistics
                _buildSectionTitle(context, 'Đạm / Carb / Chất béo'),
                SizedBox(height: context.h(0.01)),
                _buildMacroStats(context, stats),
                SizedBox(height: context.h(0.015)),
                _buildMacroChart(context, stats),
                SizedBox(height: context.h(0.02)),

                // Workout statistics
                _buildSectionTitle(context, 'Hoạt động thể chất'),
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

  Widget _buildDateRangeCard(BuildContext context, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Khoảng thời gian',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: context.h(0.005)),
              Text(
                '${DateFormat('dd/MM/yyyy').format(stats.startDate)} - ${DateFormat('dd/MM/yyyy').format(stats.endDate)}',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(5.5),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEBCF23),
                ),
              ),
            ],
          ),
          Icon(
            Icons.calendar_today,
            color: const Color(0xFFEBCF23),
            size: context.sp(7),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: context.w(0.02)),
      child: Text(
        title,
        style: GoogleFonts.baloo2(
          fontSize: context.sp(6.5),
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
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
      padding: EdgeInsets.all(context.w(0.03)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(0.02)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: context.sp(5.5)),
          ),
          SizedBox(height: context.h(0.008)),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.5),
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEBCF23),
            ),
          ),
          SizedBox(height: context.h(0.005)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(4),
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: context.h(0.008)),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 4,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterStats(BuildContext context, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(
            context,
            'Tổng nước uống',
            '${stats.totalWaterMl.toStringAsFixed(0)} ml',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Trung bình/ngày',
            '${stats.averageWaterMl.toStringAsFixed(0)} ml',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Cao nhất',
            '${stats.maxWaterMl.toStringAsFixed(0)} ml',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Thấp nhất',
            '${stats.minWaterMl.toStringAsFixed(0)} ml',
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStats(BuildContext context, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(
            context,
            'Tổng tiêu thụ',
            '${stats.totalCaloriesConsumed.toStringAsFixed(0)} cal',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Tổng đốt cháy',
            '${stats.totalCaloriesBurned.toStringAsFixed(0)} cal',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Thâm hụt',
            '${stats.totalCaloriesDeficit.toStringAsFixed(0)} cal',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Trung bình/ngày',
            '${stats.averageCaloriesConsumed.toStringAsFixed(0)} cal',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Trung bình đốt cháy',
            '${stats.averageCaloriesBurned.toStringAsFixed(0)} cal',
          ),
        ],
      ),
    );
  }

  Widget _buildMealStats(BuildContext context, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(context, 'Tổng bữa ăn', '${stats.totalMeals} bữa'),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Trung bình/ngày',
            '${stats.averageMealsPerDay.toStringAsFixed(1)} bữa',
          ),
          _buildStatDivider(context),
          _buildStatRow(context, 'Bữa sáng', '${stats.breakfastCount} lần'),
          _buildStatDivider(context),
          _buildStatRow(context, 'Bữa trưa', '${stats.lunchCount} lần'),
          _buildStatDivider(context),
          _buildStatRow(context, 'Bữa tối', '${stats.dinnerCount} lần'),
          _buildStatDivider(context),
          _buildStatRow(context, 'Ăn vặt', '${stats.snackCount} lần'),
        ],
      ),
    );
  }

  Widget _buildMacroStats(BuildContext context, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Carbs
          Text(
            'Carb (Tinh bột)',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.5),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: context.h(0.008)),
          _buildStatRow(
            context,
            'Tổng',
            '${stats.totalCarbs.toStringAsFixed(0)}g',
          ),
          _buildStatRow(
            context,
            'Trung bình/ngày',
            '${stats.averageCarbsPerDay.toStringAsFixed(1)}g',
          ),
          SizedBox(height: context.h(0.012)),
          // Protein
          Text(
            'Đạm',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.5),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: context.h(0.008)),
          _buildStatRow(
            context,
            'Tổng',
            '${stats.totalProtein.toStringAsFixed(0)}g',
          ),
          _buildStatRow(
            context,
            'Trung bình/ngày',
            '${stats.averageProteinPerDay.toStringAsFixed(1)}g',
          ),
          SizedBox(height: context.h(0.012)),
          // Fat
          Text(
            'Chất béo',
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5.5),
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: context.h(0.008)),
          _buildStatRow(
            context,
            'Tổng',
            '${stats.totalFat.toStringAsFixed(0)}g',
          ),
          _buildStatRow(
            context,
            'Trung bình/ngày',
            '${stats.averageFatPerDay.toStringAsFixed(1)}g',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats(BuildContext context, dynamic stats) {
    return Container(
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow(
            context,
            'Ngày tập luyện',
            '${stats.daysWithWorkout} ngày',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Trung bình/tuần',
            '${stats.averageWorkoutDaysPerWeek.toStringAsFixed(1)} ngày',
          ),
          _buildStatDivider(context),
          _buildStatRow(
            context,
            'Calo đốt cao nhất',
            '${stats.maxDailyCaloriesBurned.toStringAsFixed(0)} cal',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(0.008)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.baloo2(
              fontSize: context.sp(5),
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEBCF23),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(0.006)),
      child: Divider(color: Colors.grey[300], height: 1),
    );
  }

  Widget _buildWaterChart(BuildContext context, dynamic stats) {
    // Tạo dữ liệu mẫu cho 7 ngày (nếu API không trả về daily data)
    final waterData = List.generate(7, (index) {
      // Giá trị mẫu giảm dần từ max xuống min
      final range = stats.maxWaterMl - stats.minWaterMl;
      final value = stats.minWaterMl + (range * (6 - index) / 6);
      return value;
    });

    return Container(
      height: context.h(0.3),
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (stats.maxWaterMl > 0 ? stats.maxWaterMl * 1.2 : 2000)
              .toDouble(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                  return Text(
                    days[value.toInt()],
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
                interval:
                    (stats.maxWaterMl > 0 ? (stats.maxWaterMl * 1.2) / 3 : 667)
                        .toDouble(),
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
            horizontalInterval:
                (stats.maxWaterMl > 0 ? stats.maxWaterMl / 4 : 500).toDouble(),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: waterData[index],
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

  Widget _buildCalorieChart(BuildContext context, dynamic stats) {
    // Tạo dữ liệu mẫu cho 7 ngày - giá trị luôn dương
    // Nếu API trả về giá trị quá nhỏ, dùng fallback để tránh cột quá cao lệch thang đo
    final baseConsumed =
        (stats.averageCaloriesConsumed > 500
                ? stats.averageCaloriesConsumed
                : 1800)
            .toDouble();

    final calorieData = List.generate(7, (index) {
      final variation = (index - 3) * 80.0; // dao động nhẹ quanh base
      final consumed = baseConsumed + variation;
      // không cho nhỏ hơn 70% base để giữ biểu đồ ổn định
      return consumed.clamp(baseConsumed * 0.7, double.infinity);
    });

    final maxCalorie = calorieData.reduce((a, b) => a > b ? a : b);
    final maxY = (maxCalorie * 1.1).clamp(1200.0, 3200.0);

    return Container(
      height: context.h(0.28),
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    days[value.toInt()],
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
                interval: (maxY / 4).clamp(200.0, 900.0),
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
            horizontalInterval: (maxY / 4).clamp(200.0, 900.0),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
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

  Widget _buildMacroChart(BuildContext context, dynamic stats) {
    final avgProtein =
        (stats.averageProteinPerDay > 0 ? stats.averageProteinPerDay : 30)
            .toDouble();
    final avgCarbs =
        (stats.averageCarbsPerDay > 0 ? stats.averageCarbsPerDay : 150)
            .toDouble();
    final avgFat = (stats.averageFatPerDay > 0 ? stats.averageFatPerDay : 50)
        .toDouble();

    return Container(
      height: context.h(0.28),
      padding: EdgeInsets.all(context.w(0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(context, 'Đạm', const Color(0xFF43C6AC)), // teal
              SizedBox(width: context.w(0.06)),
              _buildLegend(
                context,
                'Carb',
                const Color(0xFFFFB347),
              ), // warm amber
              SizedBox(width: context.w(0.06)),
              _buildLegend(context, 'Béo', const Color(0xFFF45C43)), // coral
            ],
          ),
          SizedBox(height: context.h(0.015)),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 38,
                    sections: [
                      PieChartSectionData(
                        value: avgProtein,
                        color: const Color(0xFF43C6AC),
                        showTitle: false,
                        radius: 52,
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      PieChartSectionData(
                        value: avgCarbs,
                        color: const Color(0xFFFFB347),
                        showTitle: false,
                        radius: 52,
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      PieChartSectionData(
                        value: avgFat,
                        color: const Color(0xFFF45C43),
                        showTitle: false,
                        radius: 52,
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (_) {
                    final total = (avgProtein + avgCarbs + avgFat).clamp(
                      1,
                      double.infinity,
                    );
                    final proteinPct = (avgProtein / total * 100)
                        .toStringAsFixed(0);
                    final carbPct = (avgCarbs / total * 100).toStringAsFixed(0);
                    final fatPct = (avgFat / total * 100).toStringAsFixed(0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${total.toStringAsFixed(0)}g',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(5.5),
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: context.h(0.004)),
                        Text(
                          'P $proteinPct%  |  C $carbPct%  |  F $fatPct%',
                          style: GoogleFonts.baloo2(
                            fontSize: context.sp(3.4),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  },
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
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: context.w(0.02)),
        Text(
          label,
          style: GoogleFonts.baloo2(
            fontSize: context.sp(4),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
