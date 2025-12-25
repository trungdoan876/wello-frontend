// lib/ui/home/widgets/water_tracker.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wello_frontend/ui/widgets/responsive.dart';
import 'package:wello_frontend/domain/providers/nutrition_provider.dart';
import 'package:wello_frontend/core/utils/auth_helper.dart';
import 'package:wello_frontend/ui/widgets/info_bottom_sheet.dart';

class WaterTracker extends StatelessWidget {
  const WaterTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>(
      builder: (context, provider, child) {
        // Get data from provider with fallback values = 0
        final waterIntake = provider.dailySummary?.waterIntake;
        final int consumedMl = waterIntake?.consumed ?? 0;
        final int targetMl = waterIntake?.target ?? 0;
        final String targetMlString = targetMl > 0 ? '${targetMl}ml' : '0ml';

        // Calculate cups dynamically based on target
        const int glassSize = 250; // ml per glass
        final int totalCups = targetMl > 0
            ? (targetMl / glassSize).ceil()
            : 6; // Default 6 if no data
        final int cupsDrunk = consumedMl > 0
            ? (consumedMl / glassSize).floor()
            : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Bạn đã uống bao nhiêu nước',
                    softWrap: true,
                    maxLines: 2,
                    style: GoogleFonts.baloo2(
                      fontSize: context.sp(5.2),
                      color: const Color(0xff585755),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(width: context.w(0.02)),

                GestureDetector(
                  onTap: () => InfoBottomSheet.show(
                    context,
                      title: 'Theo dõi nước - Hydrating your body',
                      description: 'Uống đủ nước là yếu tố then chốt để duy trì năng lượng và hỗ trợ trao đổi chất.',
                      details: [
                        'Mục tiêu của bạn là **$targetMlString ml** mỗi ngày.',
                        'Mỗi ly nước bạn thêm vào ứng dụng tương đương với **250ml**.'
                      ],
                      note: 'Nhu cầu nước có thể tăng lên nếu bạn **tập luyện cường độ cao** hoặc ở trong môi trường nóng.',
                      tip: 'Hãy uống nước ngay cả khi bạn chưa thấy khát để duy trì trạng thái tốt nhất!',
                  ),
                    child: Text(
                      '${consumedMl}ml/$targetMlString',
                      style: GoogleFonts.baloo2(
                        fontSize: context.sp(4.5),
                        color: const Color(0xff6177D0),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

            // Label showing glass size
            Padding(
              padding: EdgeInsets.only(top: context.h(0.005)),
              child: Text(
                'Mỗi cốc = ${glassSize}ml',
                style: GoogleFonts.baloo2(
                  fontSize: context.sp(3.5),
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            SizedBox(height: context.h(0.01)),

            // Cup row - wrap to multiple rows if needed
            Container(
              padding: EdgeInsets.all(context.w(0.02)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(context.sp(4.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Wrap(
                spacing: context.w(0.02), // Horizontal spacing
                runSpacing: context.h(0.01), // Vertical spacing between rows
                children: List.generate(totalCups, (index) {
                  final bool isFilled = index < cupsDrunk;

                  return GestureDetector(
                    onTap: () async {
                      print(
                        '🔵 Water glass tapped! Index: $index, isFilled: $isFilled, cupsDrunk: $cupsDrunk',
                      );

                      final credentials = await AuthHelper.getCredentials();
                      if (credentials == null) {
                        print('❌ No credentials found! User not logged in?');
                        return;
                      }

                      try {
                        if (!isFilled) {
                          // Add water
                          print('🟢 Adding water...');
                          await provider.addWaterGlass(
                            credentials.token,
                            credentials.userIdString,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đã thêm 250ml nước! 💧',
                                      style: GoogleFonts.baloo2(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xff61C8F5),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } else {
                          // Remove water via DELETE endpoint
                          print('🟠 Removing water...');
                          await provider.subtractWaterGlass(
                            credentials.token,
                            credentials.userIdString,
                            glassSize: glassSize,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Đã giảm 250ml nước',
                                      style: GoogleFonts.baloo2(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        print('❌ Error handling water tap: $e');

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: Không thể cập nhật nước'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    },
                    child: SizedBox(
                      width: context.w(0.12),
                      child: GlassCup(
                        width: context.w(0.10),
                        height: context.w(0.12),
                        isFilled: isFilled,
                        showPlus: index == cupsDrunk && cupsDrunk < totalCups,
                        fillColor: const Color(0xff61C8F5),
                        borderColor: Colors.grey.shade400,
                        borderWidth: 2,
                        radius: context.sp(1.0),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Glass cup widget + clipper + painter
class GlassCup extends StatelessWidget {
  final double width;
  final double height;
  final bool isFilled;
  final bool showPlus;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;

  const GlassCup({
    Key? key,
    required this.width,
    required this.height,
    required this.isFilled,
    this.showPlus = false,
    this.fillColor = const Color(0xff61C8F5),
    this.borderColor = Colors.grey,
    this.borderWidth = 2,
    this.radius = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // outline
          CustomPaint(
            size: Size(width, height),
            painter: GlassOutlinePainter(borderColor, borderWidth, radius),
          ),

          // clipped fill
          ClipPath(
            clipper: _GlassClipper(),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: (width - borderWidth * 2) < 0
                    ? 0.0
                    : (width - borderWidth * 2),
                height: isFilled ? height * 0.55 : 0,
                margin: EdgeInsets.only(bottom: borderWidth),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      radius > borderWidth ? radius - borderWidth : radius,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showPlus)
            Icon(Icons.add, color: const Color(0xFFFFC107), size: width * 0.82),
        ],
      ),
    );
  }
}

class _GlassClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Rect r = Rect.fromLTWH(0, 0, size.width, size.height);
    final double topInset = 0.0;
    final double bottomInset = size.width * 0.25;
    final Path p = Path();
    p.moveTo(r.left + topInset, r.top);
    p.lineTo(r.right - topInset, r.top);
    p.lineTo(r.right - bottomInset, r.bottom);
    p.lineTo(r.left + bottomInset, r.bottom);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class GlassOutlinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;

  GlassOutlinePainter(this.color, this.strokeWidth, this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Rect.fromLTWH(0, 0, size.width, size.height);
    final double bottomInset = size.width * 0.15;
    final Path p = Path();
    p.moveTo(r.left, r.top + 0);
    p.lineTo(r.right, r.top + 0);
    p.lineTo(r.right - bottomInset, r.bottom);
    p.lineTo(r.left + bottomInset, r.bottom);
    p.close();

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WaterReminderSheet extends StatefulWidget {
  const WaterReminderSheet({super.key});

  @override
  State<WaterReminderSheet> createState() => _WaterReminderSheetState();
}

class _WaterReminderSheetState extends State<WaterReminderSheet> {
  bool _enabled = true;
  int _startHour = 8;
  int _endHour = 22;
  int _intervalHours = 0;
  int _intervalMinutes = 30;

  String get _intervalLabel {
    if (_intervalHours > 0 && _intervalMinutes > 0) {
      return 'Cách mỗi $_intervalHours giờ $_intervalMinutes phút';
    } else if (_intervalHours > 0) {
      return 'Cách mỗi $_intervalHours giờ';
    } else if (_intervalMinutes > 0) {
      return 'Cách mỗi $_intervalMinutes phút';
    }
    return 'Chưa đặt khoảng cách';
  }

  int get _intervalInMinutes {
    return (_intervalHours * 60) + _intervalMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nhắc nhở uống nước',
                style: GoogleFonts.baloo2(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEBCF23),
                ),
              ),
              Switch(
                value: _enabled,
                onChanged: (val) => setState(() => _enabled = val),
                activeColor: const Color(0xFFEBCF23),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Ứng dụng sẽ gửi thông báo nhắc bạn uống nước đúng giờ.',
            style: GoogleFonts.baloo2(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 25),
          _buildSettingRow(
            'Bắt đầu nhắc (giờ)',
            'Từ $_startHour:00 sáng',
            _startHour,
            24,
            (val) => setState(() => _startHour = val),
          ),
          const SizedBox(height: 15),
          _buildSettingRow(
            'Kết thúc nhắc (giờ)',
            'Đến $_endHour:00 tối',
            _endHour,
            24,
            (val) => setState(() => _endHour = val),
          ),
          const SizedBox(height: 15),
          // Interval Hours
          _buildSettingRow(
            'Khoảng cách (giờ)',
            '$_intervalHours giờ',
            _intervalHours,
            5,
            (val) => setState(() => _intervalHours = val),
          ),
          const SizedBox(height: 15),
          // Interval Minutes
          _buildSettingRow(
            'Khoảng cách (phút)',
            '$_intervalMinutes phút',
            _intervalMinutes,
            59,
            (val) => setState(() => _intervalMinutes = val),
          ),
          const SizedBox(height: 10),
          // Display combined interval
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEBCF23).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEBCF23).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time,
                  color: const Color(0xFFEBCF23),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _intervalLabel,
                  style: GoogleFonts.baloo2(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final provider = context.read<NutritionProvider>();
                final credentials = await AuthHelper.getCredentials();
                if (credentials != null) {
                  try {
                    await provider.updateWaterReminderSettings(
                      userId: credentials.userId,
                      enabled: _enabled,
                      startHour: _startHour,
                      endHour: _endHour,
                      intervalHours: _intervalHours,
                      intervalMinutes: _intervalMinutes,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã lưu cài đặt nhắc nhở!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lỗi: Không thể lưu cài đặt')),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEBCF23),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Lưu cài đặt',
                style: GoogleFonts.baloo2(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String subtitle, int value, int max, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.baloo2(fontSize: 14, color: Colors.grey.shade500),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subtitle,
              style: GoogleFonts.baloo2(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: value > 1 ? () => onChanged(value - 1) : null,
                ),
                Text(
                  '$value',
                  style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: value < max ? () => onChanged(value + 1) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
