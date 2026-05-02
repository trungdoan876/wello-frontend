import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/home/home_screen.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'dart:math' as math;

class WaterTracker extends StatefulWidget {
  const WaterTracker({super.key});

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> with SingleTickerProviderStateMixin {
  AnimationController? _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, child) {
        final waterIntake = provider.dailySummary?.waterIntake;
        final int consumed = waterIntake?.consumed ?? 0;
        final int target = waterIntake?.target ?? 2000;
        
        const int glassCapacity = 250;
        final int totalGlasses = (target / glassCapacity).ceil().clamp(1, 15);

        return Container(
          padding: EdgeInsets.all(context.w(0.05)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.w(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_drink_rounded,
                        color: Colors.blue.shade400,
                        size: context.sp(6),
                      ),
                      SizedBox(width: context.w(0.02)),
                      Text(
                        'Nước uống',
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(5),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4C494C),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$consumed / $target ml',
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(4.5),
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(0.025)),
              
              Wrap(
                spacing: context.w(0.03),
                runSpacing: context.h(0.015),
                children: List.generate(totalGlasses, (index) {
                  final double glassFill = ((consumed - (index * glassCapacity)) / glassCapacity).clamp(0.0, 1.0);
                  final bool isEmpty = glassFill <= 0.0;

                  return InkWell(
                    key: ValueKey('water_glass_$index'), // Thêm Key để giữ trạng thái hiệu ứng, tránh bị giật
                    onTap: () async {
                      final credentials = await AuthHelper.getCredentials();
                      if (credentials == null) return;
                      
                      if (glassFill >= 1.0) {
                        await provider.subtractWaterGlass(
                          credentials.token,
                          credentials.userIdString,
                          glassSize: glassCapacity,
                        );
                      } else {
                        final engagement = await provider.addWaterGlass(
                          credentials.token,
                          credentials.userIdString,
                          glassSize: glassCapacity,
                        );

                        if (engagement != null && engagement.isStreak) {
                          HomeScreen.homeKey.currentState?.showStreakCelebration(engagement.message);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 0.0, end: glassFill), // Quay lại begin: 0.0 nhưng nhờ có Key nên nó sẽ không bị reset
                      builder: (context, animatedFill, child) {
                        return AnimatedBuilder(
                          animation: _waveController ?? const AlwaysStoppedAnimation(0.0),
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: Size(context.w(0.10), context.h(0.075)),
                                  painter: _WavyGlassPainter(
                                    percent: animatedFill,
                                    wavePhase: _waveController?.value ?? 0.0,
                                  ),
                                ),
                                if (isEmpty)
                                  Icon(
                                    Icons.add_rounded,
                                    color: Colors.blue.shade300,
                                    size: context.sp(5),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WavyGlassPainter extends CustomPainter {
  final double percent;
  final double wavePhase;

  _WavyGlassPainter({required this.percent, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final double topW = size.width;
    final double botW = size.width * 0.8; // Rộng hơn một chút ở đáy
    final double xOffset = (topW - botW) / 2;

    // 1. Tạo Path cho khung ly (hình thang)
    Path glassPath = Path();
    glassPath.moveTo(0, 0); // Trên trái
    glassPath.lineTo(topW, 0); // Trên phải
    glassPath.lineTo(topW - xOffset, size.height - 4); // Dưới phải (chừa 4px cho đế)
    glassPath.quadraticBezierTo(topW - xOffset, size.height, topW - xOffset - 4, size.height); // Bo góc đáy
    glassPath.lineTo(xOffset + 4, size.height); // Đáy
    glassPath.quadraticBezierTo(xOffset, size.height, xOffset, size.height - 4); // Bo góc đáy
    glassPath.close();

    // 2. Vẽ viền ly và nền ly
    final border = Paint()
      ..color = Colors.blue.shade200.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final bg = Paint()..color = Colors.blue.shade50.withOpacity(0.3);

    canvas.drawPath(glassPath, bg);
    canvas.drawPath(glassPath, border);

    // Vẽ thêm một đường bóng mờ nhẹ bên cạnh ly để tạo chiều sâu
    final shine = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(4, 5), Offset(4, size.height - 10), shine);

    // 3. Vẽ nước với hiệu ứng sóng (Cắt theo glassPath)
    if (percent > 0) {
      canvas.save();
      canvas.clipPath(glassPath); // Quan trọng: Nước chỉ hiện trong lòng ly

      // Giới hạn nước dâng lên tối đa để trông đẹp hơn
      double availableHeight = size.height - 9; // Chừa khoảng trống 9px ở trên (hạ thấp mực nước)
      double h = availableHeight * percent;
      double waterY = size.height - h;

      final water = Paint()
        ..color = const Color(0xFF29B6F6).withOpacity(0.75)
        ..style = PaintingStyle.fill;

      Path waterPath = Path();
      waterPath.moveTo(-10, waterY);

      // Tạo hình sóng dập dềnh mềm mại
      double waveAmplitude = 1.8; // Sóng nhẹ nhàng hơn
      double waveFrequency = 1.0; // Tần số thấp hơn cho cảm giác êm đềm

      for (double x = -10; x <= size.width + 10; x += 0.5) { // Tăng độ mịn bằng cách giảm bước nhảy (0.5)
        double normalizedX = x / size.width;
        double wave = math.sin((normalizedX * waveFrequency + wavePhase) * 2 * math.pi) * waveAmplitude;
        waterPath.lineTo(x, waterY + wave);
      }

      waterPath.lineTo(size.width + 10, size.height);
      waterPath.lineTo(-10, size.height);
      waterPath.close();

      canvas.drawPath(waterPath, water);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_WavyGlassPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.wavePhase != wavePhase;
}
