import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'dart:math' as math;

class WaterTrackingCard extends StatefulWidget {
  final int amount;
  final int goal; // tổng ml cần uống
  final String lastTime;
  final bool isNotificationOn;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onToggleNotification;

  const WaterTrackingCard({
    super.key,
    required this.amount,
    required this.goal,
    required this.lastTime,
    required this.isNotificationOn,
    this.onIncrease,
    this.onDecrease,
    this.onToggleNotification,
  });

  @override
  State<WaterTrackingCard> createState() => _WaterTrackingCardState();
}

class _WaterTrackingCardState extends State<WaterTrackingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

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
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percent = (widget.amount / widget.goal).clamp(0, 1).toDouble();

    return Container(
      padding: EdgeInsets.all(context.w(0.06)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.w(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, context.h(0.005)),
          ),
        ],
      ),
      child: Row(
        children: [
          // LEFT -------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.goal} ml",
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(8.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE53935),
                  ),
                ),
                SizedBox(height: context.h(0.005)),
                Text(
                  "Lượng nước bạn cần uống",
                  style: GoogleFonts.baloo2(
                    fontSize: context.sp(4),
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 118, 118, 118),
                  ),
                ),
                SizedBox(height: context.h(0.02)),

                // full-width thin divider between BMI and metrics
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.withOpacity(0.25),
                ),

                SizedBox(height: context.h(0.02)),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: context.sp(4.5),
                      color: Colors.grey,
                    ),
                    SizedBox(width: context.w(0.02)),
                    Text(
                      "Lần cuối cùng ${widget.lastTime}",
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4),
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.015)),
                GestureDetector(
                  onTap: widget.onToggleNotification,
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // tránh chiếm toàn bộ chiều ngang
                    children: [
                      Icon(
                        widget.isNotificationOn
                            ? Icons.notifications_off
                            : Icons.notifications,
                        color: const Color(0xFFFFAA00),
                        size: context.sp(
                          4.5,
                        ), // có thể điều chỉnh kích thước icon
                      ),
                      SizedBox(
                        width: context.w(0.02),
                      ), // khoảng cách giữa icon và text
                      Text(
                        widget.isNotificationOn
                            ? "Tắt tính năng thông báo"
                            : "Bật tính năng thông báo",
                        style: GoogleFonts.baloo2(
                          fontSize: context.sp(3.8),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFAA00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // RIGHT -------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  _roundButton(context, Icons.add, widget.onIncrease),
                  SizedBox(height: context.h(0.015)),
                  _roundButton(context, Icons.remove, widget.onDecrease),
                ],
              ),
              SizedBox(width: context.w(0.03)),
              // 🟦 WATER ANIMATION WITH WAVES
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(context.w(0.17), context.h(0.20)),
                    painter: _WavyWaterPainter(
                      percent: percent,
                      wavePhase: _waveController.value,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundButton(
    BuildContext context,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(0.11),
        height: context.w(0.11),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: context.w(0.03),
            ),
          ],
        ),
        child: Icon(icon, size: context.sp(4.5)),
      ),
    );
  }
}

// PAINTER -------------------------------------------------------------------

class _WavyWaterPainter extends CustomPainter {
  final double percent;
  final double wavePhase;

  _WavyWaterPainter({required this.percent, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ background và border
    final border = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final bg = Paint()..color = Colors.white;

    final rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(30),
    );

    canvas.drawRRect(rRect, bg);
    canvas.drawRRect(rRect, border);

    // Vẽ nước với sóng
    if (percent > 0) {
      double h = size.height * percent;
      double waterY = size.height - h;

      final water = Paint()
        ..color = const Color(0xFF4FC3F7)
        ..style = PaintingStyle.fill;

      Path waterPath = Path();

      // Bắt đầu từ góc trái
      waterPath.moveTo(0, waterY);

      // Vẽ sóng trên bề mặt nước
      double waveAmplitude = 3.0; // Độ cao sóng
      double waveFrequency = 2.0; // Số lượng sóng

      for (double x = 0; x <= size.width; x += 2) {
        double normalizedX = x / size.width;
        double wave =
            math.sin((normalizedX * waveFrequency + wavePhase) * 2 * math.pi) *
            waveAmplitude;
        waterPath.lineTo(x, waterY + wave);
      }

      // Vẽ xuống dưới
      waterPath.lineTo(size.width, size.height);
      waterPath.lineTo(0, size.height);
      waterPath.close();

      // Clip để tạo border radius
      canvas.save();
      canvas.clipRRect(rRect);
      canvas.drawPath(waterPath, water);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_WavyWaterPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.wavePhase != wavePhase;
}
